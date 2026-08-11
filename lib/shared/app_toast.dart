import 'dart:async';

import 'package:bike_renting_app/shared/motion.dart';
import 'package:flutter/material.dart';

enum AppToastPosition { top, bottom }

enum AppToastBehavior { autoDismiss, untilAcknowledged }

enum AppToastVariant { info, success, warning, error }

/// Handle returned by [AppToast.show] for dismissing a toast from code.
class AppToastHandle {
  AppToastHandle._(this._dismiss);

  final VoidCallback _dismiss;

  void dismiss() => _dismiss();
}

/// App-wide entry point for displaying self-styled toast messages.
abstract final class AppToast {
  static AppToastHandle show(
    BuildContext context, {
    required String message,
    String? title,
    AppToastPosition position = AppToastPosition.bottom,
    AppToastBehavior behavior = AppToastBehavior.autoDismiss,
    AppToastVariant variant = AppToastVariant.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAcknowledged,
  }) {
    assert(message.trim().isNotEmpty, 'Toast message must not be empty.');
    assert(
      behavior == AppToastBehavior.untilAcknowledged ||
          duration > Duration.zero,
      'Auto-dismiss duration must be greater than zero.',
    );

    final host = _AppToastScope.maybeOf(context);
    if (host == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No AppToastHost found.'),
        ErrorDescription(
          'Wrap the app content with AppToastHost before calling AppToast.show.',
        ),
      ]);
    }

    return host.show(
      message: message,
      title: title,
      position: position,
      behavior: behavior,
      variant: variant,
      duration: duration,
      onAcknowledged: onAcknowledged,
    );
  }

  static void dismissAll(BuildContext context) {
    final host = _AppToastScope.maybeOf(context);
    if (host == null) {
      return;
    }
    host.dismissAll();
  }
}

/// Place once above the app's Navigator using [MaterialApp.builder].
class AppToastHost extends StatefulWidget {
  const AppToastHost({super.key, required this.child});

  final Widget child;

  @override
  State<AppToastHost> createState() => _AppToastHostState();
}

class _AppToastHostState extends State<AppToastHost> {
  static const _exitDuration = Duration(milliseconds: 180);

  final List<_ToastEntry> _entries = [];
  int _nextId = 0;

  AppToastHandle show({
    required String message,
    required String? title,
    required AppToastPosition position,
    required AppToastBehavior behavior,
    required AppToastVariant variant,
    required Duration duration,
    required VoidCallback? onAcknowledged,
  }) {
    final entry = _ToastEntry(
      id: _nextId++,
      message: message,
      title: title,
      position: position,
      behavior: behavior,
      variant: variant,
      onAcknowledged: onAcknowledged,
    );

    setState(() => _entries.add(entry));
    if (behavior == AppToastBehavior.autoDismiss) {
      entry.timer = Timer(duration, () => _dismiss(entry.id));
    }

    return AppToastHandle._(() => _dismiss(entry.id));
  }

  void dismissAll() {
    final dismissedIds = _entries.map((entry) => entry.id).toSet();
    for (final entry in _entries) {
      entry.timer?.cancel();
    }
    setState(() {
      for (final entry in _entries) {
        entry.visible = false;
      }
    });
    Timer(_exitDuration, () {
      if (mounted) {
        setState(
          () =>
              _entries.removeWhere((entry) => dismissedIds.contains(entry.id)),
        );
      }
    });
  }

  void _dismiss(int id, {bool acknowledged = false, bool immediate = false}) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1 || !_entries[index].visible) {
      return;
    }

    final entry = _entries[index];
    entry.timer?.cancel();
    if (acknowledged) {
      entry.onAcknowledged?.call();
    }

    if (immediate || reduceMotion(context)) {
      setState(() => _entries.removeAt(index));
      return;
    }

    setState(() => entry.visible = false);
    Timer(_exitDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _entries.removeWhere((item) => item.id == id));
    });
  }

  void _pauseAutoDismiss(int id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index].timer?.cancel();
    }
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topEntries = _entries
        .where((entry) => entry.position == AppToastPosition.top)
        .toList();
    final bottomEntries = _entries
        .where((entry) => entry.position == AppToastPosition.bottom)
        .toList()
        .reversed
        .toList();

    return _AppToastScope(
      host: this,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          _ToastRegion(
            alignment: Alignment.topCenter,
            entries: topEntries,
            onDismiss: _dismiss,
            onPauseAutoDismiss: _pauseAutoDismiss,
          ),
          _ToastRegion(
            alignment: Alignment.bottomCenter,
            entries: bottomEntries,
            onDismiss: _dismiss,
            onPauseAutoDismiss: _pauseAutoDismiss,
          ),
        ],
      ),
    );
  }
}

class _ToastRegion extends StatelessWidget {
  const _ToastRegion({
    required this.alignment,
    required this.entries,
    required this.onDismiss,
    required this.onPauseAutoDismiss,
  });

  final Alignment alignment;
  final List<_ToastEntry> entries;
  final void Function(int id, {bool acknowledged, bool immediate}) onDismiss;
  final ValueChanged<int> onPauseAutoDismiss;

  @override
  Widget build(BuildContext context) {
    final isBottom = alignment == Alignment.bottomCenter;
    final keyboardInset = isBottom
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;

    return IgnorePointer(
      ignoring: entries.isEmpty,
      child: AnimatedPadding(
        duration: motionDuration(context, 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 12),
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in entries)
                      AnimatedSize(
                        duration: motionDuration(context, 180),
                        curve: Curves.easeOutCubic,
                        alignment: alignment,
                        child: entry.visible
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: _ToastCard(
                                  entry: entry,
                                  onDismiss: onDismiss,
                                  onPauseAutoDismiss: onPauseAutoDismiss,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.entry,
    required this.onDismiss,
    required this.onPauseAutoDismiss,
  });

  final _ToastEntry entry;
  final void Function(int id, {bool acknowledged, bool immediate}) onDismiss;
  final ValueChanged<int> onPauseAutoDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = _ToastColors.forVariant(entry.variant, scheme);
    final acknowledgementLabel = entry.title == null
        ? 'Acknowledge: ${entry.message}'
        : 'Acknowledge: ${entry.title}. ${entry.message}';

    return Dismissible(
      key: ValueKey('app-toast-${entry.id}'),
      direction: DismissDirection.horizontal,
      resizeDuration: motionDuration(context, 180),
      confirmDismiss: (_) async {
        onPauseAutoDismiss(entry.id);
        return true;
      },
      onDismissed: (_) =>
          onDismiss(entry.id, acknowledged: true, immediate: true),
      child: Semantics(
        liveRegion: true,
        button: true,
        excludeSemantics: true,
        label: acknowledgementLabel,
        hint: 'Tap to acknowledge. Swipe left or right to dismiss.',
        child: Material(
          color: colors.background,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onDismiss(entry.id, acknowledged: true),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconFor(entry.variant),
                        color: colors.accent,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (entry.title != null) ...[
                            Text(
                              entry.title!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colors.foreground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            entry.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.foreground.withValues(alpha: 0.86),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.close_rounded,
                      color: colors.foreground.withValues(alpha: 0.58),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppToastVariant variant) => switch (variant) {
    AppToastVariant.info => Icons.info_outline_rounded,
    AppToastVariant.success => Icons.check_circle_outline_rounded,
    AppToastVariant.warning => Icons.warning_amber_rounded,
    AppToastVariant.error => Icons.error_outline_rounded,
  };
}

class _ToastColors {
  const _ToastColors({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final Color border;

  factory _ToastColors.forVariant(AppToastVariant variant, ColorScheme scheme) {
    final accent = switch (variant) {
      AppToastVariant.info => scheme.primary,
      AppToastVariant.success => const Color(0xFF059669),
      AppToastVariant.warning => const Color(0xFFD97706),
      AppToastVariant.error => scheme.error,
    };

    return _ToastColors(
      background: scheme.surface,
      foreground: scheme.onSurface,
      accent: accent,
      border: Color.alphaBlend(
        accent.withValues(alpha: 0.34),
        scheme.outline.withValues(alpha: 0.72),
      ),
    );
  }
}

class _ToastEntry {
  _ToastEntry({
    required this.id,
    required this.message,
    required this.title,
    required this.position,
    required this.behavior,
    required this.variant,
    required this.onAcknowledged,
  });

  final int id;
  final String message;
  final String? title;
  final AppToastPosition position;
  final AppToastBehavior behavior;
  final AppToastVariant variant;
  final VoidCallback? onAcknowledged;
  bool visible = true;
  Timer? timer;
}

class _AppToastScope extends InheritedWidget {
  const _AppToastScope({required this.host, required super.child});

  final _AppToastHostState host;

  static _AppToastHostState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppToastScope>()?.host;
  }

  @override
  bool updateShouldNotify(_AppToastScope oldWidget) => host != oldWidget.host;
}
