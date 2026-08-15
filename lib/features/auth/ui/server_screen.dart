import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/server_probe.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../onboarding_draft.dart';

class ServerScreen extends ConsumerStatefulWidget {
  const ServerScreen({super.key});

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> {
  late final TextEditingController _url;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(
      text: ref.read(onboardingDraftProvider).serverUrl,
    );
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await probeServer(_url.text);
    if (!mounted) return;
    switch (result) {
      case ServerOk(:final normalizedUrl):
        ref
            .read(onboardingDraftProvider.notifier)
            .set(OnboardingDraft(serverUrl: normalizedUrl));
        setState(() => _busy = false);
        context.go(Routes.pair);
      case ServerHlApiDisabled():
      case ServerUnreachable():
        setState(() {
          _busy = false;
          _error = l.serverInvalid;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Decorative: the heading right below says the same thing.
                  ExcludeSemantics(
                    child: Icon(
                      Icons.support_agent,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      l.serverTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _url,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l.serverUrlLabel,
                      hintText: l.serverUrlHint,
                      helperText: l.serverHelp,
                      helperMaxLines: 3,
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _next(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _next,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: 'Checking the server',
                            ),
                          )
                        : Text(l.next),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
