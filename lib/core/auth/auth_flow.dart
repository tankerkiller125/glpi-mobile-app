import 'broker_client.dart';

/// Strategy interface for obtaining credentials during onboarding.
abstract class AuthFlow {
  Future<BrokerTokens> signIn({
    required String serverUrl,
    required String pairingCode,
  });
}

/// Passwordless, secretless sign-in: the user scans a QR code shown in their
/// GLPI profile, and the `glpimobile` plugin brokers genuine OAuth tokens for
/// the one-time pairing code. The app never sees a password or client secret,
/// and 2FA/SSO are honoured by the web login that produced the QR.
class QrPairingFlow implements AuthFlow {
  const QrPairingFlow();

  @override
  Future<BrokerTokens> signIn({
    required String serverUrl,
    required String pairingCode,
  }) {
    return BrokerClient(serverUrl).pair(pairingCode);
  }
}
