import 'package:flutter/widgets.dart';

/// Provides the active [Locale] and a mutation callback to descendant widgets.
class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  static AppLocaleScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
  }

  static AppLocaleScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AppLocaleScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return locale != oldWidget.locale ||
        onLocaleChanged != oldWidget.onLocaleChanged;
  }
}
