import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/push/push_service.dart';
import 'core/widgets/inline_error.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  // Release builds otherwise paint a widget that throws as a silent grey slab.
  installInlineErrorWidget();
  // The UnifiedPush native service runs this entrypoint with '--unifiedpush-bg'
  // when a push arrives and the app is killed: handle it headlessly (show a
  // notification) instead of launching the full UI.
  if (args.contains('--unifiedpush-bg')) {
    unifiedPushBackgroundMain();
    return;
  }
  runApp(const ProviderScope(child: GlpiMobileApp()));
}
