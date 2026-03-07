import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'PokeRush'**
  String get appTitle;

  /// No description provided for @classic.
  ///
  /// In es, this message translates to:
  /// **'CLÁSICO'**
  String get classic;

  /// No description provided for @survival.
  ///
  /// In es, this message translates to:
  /// **'SUPERVIVENCIA'**
  String get survival;

  /// No description provided for @play.
  ///
  /// In es, this message translates to:
  /// **'¡JUGAR!'**
  String get play;

  /// No description provided for @instructions.
  ///
  /// In es, this message translates to:
  /// **'Coloca el teléfono en tu frente\nInclina hacia adelante para ACIERTO\nInclina hacia atrás para PASAR'**
  String get instructions;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @filters.
  ///
  /// In es, this message translates to:
  /// **'Filtros Pokémon'**
  String get filters;

  /// No description provided for @resetFilters.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar Filtros'**
  String get resetFilters;

  /// No description provided for @generations.
  ///
  /// In es, this message translates to:
  /// **'GENERACIONES'**
  String get generations;

  /// No description provided for @types.
  ///
  /// In es, this message translates to:
  /// **'TIPOS'**
  String get types;

  /// No description provided for @filterNote.
  ///
  /// In es, this message translates to:
  /// **'Nota: Si no seleccionas ningún tipo, se mostrarán todos.'**
  String get filterNote;

  /// No description provided for @visualSettings.
  ///
  /// In es, this message translates to:
  /// **'AJUSTES VISUALES'**
  String get visualSettings;

  /// No description provided for @dynamicBackgrounds.
  ///
  /// In es, this message translates to:
  /// **'Fondos Dinámicos'**
  String get dynamicBackgrounds;

  /// No description provided for @dynamicBackgroundsDesc.
  ///
  /// In es, this message translates to:
  /// **'Cambia el color según el tipo del Pokémon.'**
  String get dynamicBackgroundsDesc;

  /// No description provided for @sensorCalibration.
  ///
  /// In es, this message translates to:
  /// **'CALIBRACIÓN DE SENSOR'**
  String get sensorCalibration;

  /// No description provided for @correctSensitivity.
  ///
  /// In es, this message translates to:
  /// **'Sensibilidad Acierto (Hacia Adelante)'**
  String get correctSensitivity;

  /// No description provided for @skipSensitivity.
  ///
  /// In es, this message translates to:
  /// **'Sensibilidad Paso (Hacia Atrás)'**
  String get skipSensitivity;

  /// No description provided for @achievements.
  ///
  /// In es, this message translates to:
  /// **'LOGROS'**
  String get achievements;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'IDIOMA'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @noPokemonTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin Pokémon'**
  String get noPokemonTitle;

  /// No description provided for @noPokemonContent.
  ///
  /// In es, this message translates to:
  /// **'No hay Pokémon con esos filtros. Por favor, ajusta tu selección en los ajustes.'**
  String get noPokemonContent;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'ACEPTAR'**
  String get accept;

  /// No description provided for @score.
  ///
  /// In es, this message translates to:
  /// **'PUNTOS'**
  String get score;

  /// No description provided for @time.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO'**
  String get time;

  /// No description provided for @pokedex.
  ///
  /// In es, this message translates to:
  /// **'Pokédex'**
  String get pokedex;

  /// No description provided for @searchPokemon.
  ///
  /// In es, this message translates to:
  /// **'Buscar Pokémon...'**
  String get searchPokemon;

  /// No description provided for @noPokemonFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron Pokémon'**
  String get noPokemonFound;

  /// No description provided for @ready.
  ///
  /// In es, this message translates to:
  /// **'¡LISTO?'**
  String get ready;

  /// No description provided for @correct.
  ///
  /// In es, this message translates to:
  /// **'¡ACIERTO!'**
  String get correct;

  /// No description provided for @skipped.
  ///
  /// In es, this message translates to:
  /// **'PASA...'**
  String get skipped;

  /// No description provided for @gameOver.
  ///
  /// In es, this message translates to:
  /// **'FIN DE LA PARTIDA'**
  String get gameOver;

  /// No description provided for @finalScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación Final'**
  String get finalScore;

  /// No description provided for @backToHome.
  ///
  /// In es, this message translates to:
  /// **'VOLVER A INICIO'**
  String get backToHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
