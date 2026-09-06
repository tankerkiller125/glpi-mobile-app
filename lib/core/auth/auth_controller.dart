import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/errors.dart';
import '../api/hl_client.dart';
import '../models/account.dart';
import '../models/session_info.dart';
import 'auth_flow.dart';
import 'secure_store.dart';
import 'token_manager.dart';

sealed class AuthState {
  const AuthState();
}

/// Restoring from storage at startup.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class SignedOut extends AuthState {
  const SignedOut();
}

/// Authenticated but no profile/entity picked yet.
class NeedsContext extends AuthState {
  const NeedsContext(this.account, this.session);
  final Account account;
  final SessionInfo session;
}

class Ready extends AuthState {
  const Ready(this.account);
  final Account account;
}

class AuthController extends Notifier<AuthState> {
  AuthController({AuthFlow? flow, SecureStore? store})
    : _flow = flow ?? const QrPairingFlow(),
      _store = store ?? SecureStore();

  final AuthFlow _flow;
  final SecureStore _store;
  TokenManager? _tokens;
  Dio? _dio;

  @override
  AuthState build() {
    unawaited(_restore());
    return const AuthUnknown();
  }

  TokenManager? get tokens => _tokens;

  /// The HL API client for the signed-in account. Null until authenticated.
  Dio? get dio => _dio;

  Account? get _account => switch (state) {
    Ready(:final account) => account,
    NeedsContext(:final account) => account,
    _ => null,
  };

  void _wire(Account account) {
    _tokens = TokenManager(
      store: _store,
      serverUrl: account.serverUrl,
      // A revoked or expired pairing must land the technician on the sign-in
      // screen, not on a stale queue where every action quietly fails.
      onReauthRequired: _onReauthRequired,
    );
    _dio = buildHlDio(
      serverUrl: account.serverUrl,
      tokens: _tokens!,
      account: () => _account,
    );
  }

  Future<void> _restore() async {
    final account = await _store.readAccount();
    final hasTokens = await _store.readCredentials() != null;
    if (account == null || !hasTokens) {
      state = const SignedOut();
      return;
    }
    _wire(account);
    if (account.hasContext) {
      if (account.userId == 0) {
        // A sign-in interrupted mid-flight can leave the placeholder row
        // (no identity) with a context already picked: heal it from the
        // session instead of showing a nameless account forever.
        try {
          final session = await _fetchSession();
          final healed = Account(
            serverUrl: account.serverUrl,
            userId: session.userId,
            username: session.username,
            displayName: session.friendlyName.isNotEmpty
                ? session.friendlyName
                : session.username,
            profileId: account.profileId,
            profileName: account.profileName,
            entityId: account.entityId,
            entityName: account.entityName,
            entityRecursive: account.entityRecursive,
            groupIds: session.groupIds,
          );
          await _store.writeAccount(healed);
          state = Ready(healed);
          return;
        } on Exception {
          // Offline: the placeholder still works, names fill in next time.
        }
      }
      state = Ready(account);
    } else {
      // Signed in but interrupted before picking a context: refetch session.
      try {
        final session = await _fetchSession();
        var refreshed = account;
        if (account.userId == 0) {
          // The stored row is the placeholder written before the first
          // session fetch — fill in the real identity so the drawer and
          // context picker don't show a nameless account.
          refreshed = Account(
            serverUrl: account.serverUrl,
            userId: session.userId,
            username: session.username,
            displayName: session.friendlyName.isNotEmpty
                ? session.friendlyName
                : session.username,
            groupIds: session.groupIds,
          );
          await _store.writeAccount(refreshed);
        }
        state = NeedsContext(refreshed, session);
      } on Exception {
        state = const SignedOut();
      }
    }
  }

  /// Full sign-in from the onboarding flow: redeem a scanned pairing code for
  /// tokens, then load the session. Throws [GlpiError] mapped to messages by
  /// the UI (e.g. an expired/used code surfaces as an auth error).
  Future<void> signIn({
    required String serverUrl,
    required String pairingCode,
  }) async {
    final paired = await _flow.signIn(
      serverUrl: serverUrl,
      pairingCode: pairingCode,
    );

    var account = Account(
      serverUrl: serverUrl,
      userId: 0,
      username: '',
      displayName: '',
    );
    await _store.writeAccount(account);
    _wire(account);
    await _tokens!.adopt(paired.credentials, device: paired.device);

    final session = await _fetchSession();
    account = Account(
      serverUrl: serverUrl,
      userId: session.userId,
      username: session.username,
      displayName: session.friendlyName.isNotEmpty
          ? session.friendlyName
          : session.username,
      groupIds: session.groupIds,
    );
    await _store.writeAccount(account);

    // Single profile with a single allowed entity: skip the picker.
    if (session.profiles.length == 1 &&
        session.profiles.single.entities.length == 1) {
      final profile = session.profiles.single;
      final entity = profile.entities.single;
      await pickContext(
        account: account,
        profileId: profile.id,
        profileName: profile.name,
        entityId: entity.id,
        entityName: entity.name,
        recursive: entity.isRecursive,
      );
      return;
    }
    state = NeedsContext(account, session);
  }

  Future<void> pickContext({
    Account? account,
    required int profileId,
    required String profileName,
    required int entityId,
    required String entityName,
    required bool recursive,
  }) async {
    final base = account ?? _account;
    if (base == null) return;
    final updated = base.copyWith(
      profileId: profileId,
      profileName: profileName,
      entityId: entityId,
      entityName: entityName,
      entityRecursive: recursive,
    );
    await _store.writeAccount(updated);
    state = Ready(updated);
  }

  /// The pairing died underneath us (admin revoke, expired grant). Tokens are
  /// already cleared; drop to signed-out, keeping the account record so cached
  /// data and the outbox survive until the technician pairs again.
  void _onReauthRequired() {
    if (state is SignedOut) return;
    _dio = null;
    state = const SignedOut();
  }

  Future<void> logout() async {
    await _tokens?.clear();
    _tokens = null;
    _dio = null;
    state = const SignedOut();
  }

  Future<SessionInfo> _fetchSession() async {
    try {
      final response = await _dio!.get<Map<String, Object?>>('/session');
      return SessionInfo.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
