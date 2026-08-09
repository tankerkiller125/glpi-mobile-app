import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug convenience: `flutter run --dart-define=DEV_SERVER=http://10.0.2.2:8081`
/// pre-fills the server form (empty in release builds unless explicitly set).
const devServer = String.fromEnvironment('DEV_SERVER');

/// Carries the (probed) server URL from the server screen to the scan screen
/// before an account exists.
class OnboardingDraft {
  const OnboardingDraft({this.serverUrl = ''});

  final String serverUrl;
}

class OnboardingDraftNotifier extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft(serverUrl: devServer);

  void set(OnboardingDraft draft) => state = draft;
}

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftNotifier, OnboardingDraft>(
      OnboardingDraftNotifier.new,
    );
