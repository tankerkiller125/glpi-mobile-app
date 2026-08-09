import '../db/app_database.dart';
import '../db/cache_reset.dart';
import '../models/account.dart';
import 'auth_controller.dart';

/// Changes the working GLPI context (profile + entity) after sign-in.
///
/// Lives beside [AuthController] rather than inside it: the switch is as much
/// a cache operation as an identity one, and the controller has no business
/// knowing about the database.
class ContextSwitcher {
  const ContextSwitcher(this._db, this._auth, this._current);

  final AppDatabase _db;
  final AuthController _auth;

  /// The active account, read from the provider rather than the notifier's
  /// protected `state`.
  final Account? _current;

  /// Returns false when the choice matches the active context (nothing to do).
  ///
  /// Everything cached was pulled *in* the previous context — queue,
  /// categories, locations, assets — and the repositories only upsert, so the
  /// old entity's rows would linger forever. Synced rows are dropped; unsynced
  /// work and its outbox ops survive, and still drain into the entity they
  /// were composed in.
  Future<bool> switchTo({
    required int profileId,
    required String profileName,
    required int entityId,
    required String entityName,
    required bool recursive,
  }) async {
    final current = _current;
    if (current == null) return false;
    if (current.profileId == profileId &&
        current.entityId == entityId &&
        current.entityRecursive == recursive) {
      return false;
    }

    await clearSyncedCaches(_db);
    await _auth.pickContext(
      profileId: profileId,
      profileName: profileName,
      entityId: entityId,
      entityName: entityName,
      recursive: recursive,
    );
    return true;
  }
}
