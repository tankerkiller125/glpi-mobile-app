import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/models/catalog_item.dart';
import '../../../core/providers.dart';
import 'catalog_tile.dart';

/// Point the camera at an asset label: the code is looked up as a serial or
/// inventory number across the primary asset types. One hit opens straight to
/// the asset — the whole point of doing this on a phone.
class CatalogScanScreen extends ConsumerStatefulWidget {
  const CatalogScanScreen({super.key});

  @override
  ConsumerState<CatalogScanScreen> createState() => _CatalogScanScreenState();
}

class _CatalogScanScreenState extends ConsumerState<CatalogScanScreen> {
  final _scanner = MobileScannerController();
  final _manual = TextEditingController();
  bool _busy = false;
  String? _message;
  List<CatalogItem> _matches = const [];

  @override
  void dispose() {
    _scanner.dispose();
    _manual.dispose();
    super.dispose();
  }

  Future<void> _lookup(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
      _matches = const [];
    });
    final repo = ref.read(catalogRepositoryProvider);
    List<CatalogItem> hits = const [];
    try {
      hits =
          await repo?.searchAcross('Assets', primaryAssetTypes, trimmed) ??
          const [];
    } on Exception {
      if (mounted) {
        setState(() {
          _busy = false;
          _message = 'Lookup failed — check the connection';
        });
      }
      return;
    }
    // A scanned code is exact: prefer serial/asset-tag equality over the
    // repository's broader "contains" match so one label opens one asset.
    final exact = [
      for (final h in hits)
        if ((h.serial ?? '').toLowerCase() == trimmed.toLowerCase() ||
            (h.otherserial ?? '').toLowerCase() == trimmed.toLowerCase())
          h,
    ];
    final result = exact.isNotEmpty ? exact : hits;
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isEmpty) {
      setState(() => _message = 'No asset with code "$trimmed"');
      announce(context, 'No asset with code $trimmed');
      await _scanner.start();
      return;
    }
    if (result.length == 1) {
      Navigator.of(context).pop();
      await openCatalogItem(context, ref, result.first);
      return;
    }
    setState(() => _matches = result);
    // The list appears below the fold; say how many so the next swipe has a
    // destination.
    announce(context, '${result.length} matching assets');
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;
      await _scanner.stop();
      await _lookup(value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scan asset')),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Semantics(
              // Unlabelled, this is a 260px mystery above the field that
              // actually works without sight.
              label:
                  'Camera viewfinder. Point it at the asset label, or type '
                  'the code below.',
              excludeSemantics: true,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(controller: _scanner, onDetect: _onDetect),
                  if (_busy)
                    const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Looking up',
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manual,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      labelText: 'Or type the code',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _lookup,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _lookup(_manual.text),
                  child: const Text('Find'),
                ),
              ],
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _message!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          if (_matches.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _matches.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) =>
                    CatalogTile(item: _matches[i], showType: true),
              ),
            ),
        ],
      ),
    );
  }
}
