import 'package:flutter/material.dart';

import 'glpi_colors.dart';

const _seed = Color(0xFF3F51B5);

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _seed);
  return ThemeData(
    colorScheme: scheme,
    extensions: const [GlpiColors.light],
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: scheme,
    extensions: const [GlpiColors.dark],
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

extension GlpiColorsX on BuildContext {
  GlpiColors get glpiColors => Theme.of(this).extension<GlpiColors>()!;
}
