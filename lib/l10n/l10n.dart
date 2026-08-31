import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
