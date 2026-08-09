import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../onboarding_draft.dart';

/// Passwordless sign-in: scan the QR shown in GLPI (My Settings → Mobile app).
/// The QR carries a one-time pairing code the plugin exchanges for real tokens.
/// A manual-entry fallback covers emulators (which can't scan their own screen).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _manual = TextEditingController();
  final _scanner = MobileScannerController();
  bool _manualMode = false;
  bool _busy = false;
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _manual.dispose();
    _scanner.dispose();
    super.dispose();
  }

  /// Accept either a raw pairing code or the JSON QR payload `{url, code}`.
  ({String code, String? url})? _parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('{')) {
      try {
        final map = jsonDecode(trimmed) as Map<String, Object?>;
        final code = (map['code'] as String?)?.trim();
        if (code == null || code.isEmpty) return null;
        return (code: code, url: (map['url'] as String?)?.trim());
      } on FormatException {
        return null;
      }
    }
    return (code: trimmed, url: null);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || _busy) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;
      final parsed = _parse(value);
      if (parsed == null) continue;
      _handled = true;
      await _scanner.stop();
      await _pair(parsed.code, parsed.url);
      return;
    }
  }

  Future<void> _pairManual() async {
    final parsed = _parse(_manual.text);
    if (parsed == null) return;
    await _pair(parsed.code, parsed.url);
  }

  Future<void> _pair(String code, String? qrUrl) async {
    // Prefer the server URL the user already validated; fall back to the QR's.
    final serverUrl = ref.read(onboardingDraftProvider).serverUrl.isNotEmpty
        ? ref.read(onboardingDraftProvider).serverUrl
        : (qrUrl ?? '');
    if (serverUrl.isEmpty) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(serverUrl: serverUrl, pairingCode: code);
      // Router redirect takes over on the auth-state change.
    } on Exception {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _handled = false;
        _error = AppLocalizations.of(context).pairFailed;
      });
      if (!_manualMode) {
        await _scanner.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanTitle),
        actions: [
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _manualMode = !_manualMode;
                    _error = null;
                  }),
            // Default foreground: onPrimary is white here, which vanished
            // against the app bar's surface colour on larger screens.
            child: Text(_manualMode ? l.scanTitle : l.scanManualToggle),
          ),
        ],
      ),
      body: SafeArea(child: _manualMode ? _manualEntry(l) : _scanView(l)),
    );
  }

  Widget _scanView(AppLocalizations l) {
    // A viewfinder stretched across a tablet is all margin and no target, so
    // the preview is boxed and centred like the rest of onboarding.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(l.scanInstructions, textAlign: TextAlign.center),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(controller: _scanner, onDetect: _onDetect),
                    if (_busy) const _Scrim(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _manualEntry(AppLocalizations l) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.scanInstructions, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: _manual,
                autocorrect: false,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.pairCodeLabel,
                  errorText: _error,
                  errorMaxLines: 3,
                ),
                onSubmitted: (_) => _pairManual(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _pairManual,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.pairAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x88000000),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
