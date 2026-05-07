import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../constants/map_constants.dart';
import '../l10n/app_localizations.dart';

/// Shows a throttled snackbar when OSM tiles fail (network, timeout, HTTP).
void showTerangaMapTilesIssueSnackBar(BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.mapTilesLoadIssue),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// OpenStreetMap tile layer: shared URL, user-agent, error image, and optional
/// throttled feedback via [onTileLoadFailure].
class TerangaOsmTileLayer extends StatefulWidget {
  const TerangaOsmTileLayer({
    super.key,
    this.onTileLoadFailure,
    this.throttle = const Duration(seconds: 30),
  });

  /// Invoked at most once per [throttle] when any tile request fails.
  final VoidCallback? onTileLoadFailure;

  final Duration throttle;

  @override
  State<TerangaOsmTileLayer> createState() => _TerangaOsmTileLayerState();
}

class _TerangaOsmTileLayerState extends State<TerangaOsmTileLayer> {
  DateTime? _lastNoticeAt;

  void _handleTileError(
    TileImage tile,
    Object error,
    StackTrace? stackTrace,
  ) {
    final onFail = widget.onTileLoadFailure;
    if (onFail == null) return;
    final now = DateTime.now();
    if (_lastNoticeAt != null &&
        now.difference(_lastNoticeAt!) < widget.throttle) {
      return;
    }
    _lastNoticeAt = now;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      onFail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: MapConstants.osmTileUrlTemplate,
      userAgentPackageName: MapConstants.tileUserAgentPackageName,
      errorImage: MapConstants.tileLoadErrorImage,
      errorTileCallback: _handleTileError,
    );
  }
}
