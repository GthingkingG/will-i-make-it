import 'package:flutter/widgets.dart';
import 'package:will_i_make_it/l10n/gen/app_localizations.dart';

export 'package:will_i_make_it/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
