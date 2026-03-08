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

  /// No description provided for @difficulty.
  ///
  /// In es, this message translates to:
  /// **'DIFICULTAD'**
  String get difficulty;

  /// No description provided for @difficultyNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @difficultyExpert.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get difficultyExpert;

  /// No description provided for @thematicCategories.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍAS TEMÁTICAS'**
  String get thematicCategories;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get all;

  /// No description provided for @starters.
  ///
  /// In es, this message translates to:
  /// **'Iniciales'**
  String get starters;

  /// No description provided for @legendaries.
  ///
  /// In es, this message translates to:
  /// **'Legendarios'**
  String get legendaries;

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

  /// No description provided for @tabFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get tabFilters;

  /// No description provided for @tabGame.
  ///
  /// In es, this message translates to:
  /// **'Juego'**
  String get tabGame;

  /// No description provided for @tabSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get tabSettings;

  /// No description provided for @tabAccessibility.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get tabAccessibility;

  /// No description provided for @tabAchievements.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get tabAchievements;

  /// No description provided for @trainer.
  ///
  /// In es, this message translates to:
  /// **'ENTRENADOR'**
  String get trainer;

  /// No description provided for @trainerCard.
  ///
  /// In es, this message translates to:
  /// **'TARJETA DE ENTRENADOR'**
  String get trainerCard;

  /// No description provided for @changeName.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Nombre'**
  String get changeName;

  /// No description provided for @selectAvatar.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Avatar'**
  String get selectAvatar;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @enterName.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu nombre'**
  String get enterName;

  /// No description provided for @chooseFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Subir desde Galería'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar Foto'**
  String get removePhoto;

  /// No description provided for @shinies.
  ///
  /// In es, this message translates to:
  /// **'SHINIES'**
  String get shinies;

  /// No description provided for @bestStreak.
  ///
  /// In es, this message translates to:
  /// **'RACHA MÁX'**
  String get bestStreak;

  /// No description provided for @gamesPlayed.
  ///
  /// In es, this message translates to:
  /// **'Partidas Jugadas'**
  String get gamesPlayed;

  /// No description provided for @totalCorrectStats.
  ///
  /// In es, this message translates to:
  /// **'Aciertos Totales'**
  String get totalCorrectStats;

  /// No description provided for @profileKeepGoing.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue adelante para completar tu colección!'**
  String get profileKeepGoing;

  /// No description provided for @ach_first_win_title.
  ///
  /// In es, this message translates to:
  /// **'Novato'**
  String get ach_first_win_title;

  /// No description provided for @ach_first_win_desc.
  ///
  /// In es, this message translates to:
  /// **'Adivina tu primer Pokémon.'**
  String get ach_first_win_desc;

  /// No description provided for @ach_gen1_master_title.
  ///
  /// In es, this message translates to:
  /// **'Maestro de Kanto'**
  String get ach_gen1_master_title;

  /// No description provided for @ach_gen1_master_desc.
  ///
  /// In es, this message translates to:
  /// **'Adivina 50 Pokémon de la Gen 1.'**
  String get ach_gen1_master_desc;

  /// No description provided for @ach_shiny_found_title.
  ///
  /// In es, this message translates to:
  /// **'¡Shiny Encontrado!'**
  String get ach_shiny_found_title;

  /// No description provided for @ach_shiny_found_desc.
  ///
  /// In es, this message translates to:
  /// **'Encuentra un Pokémon variocolor.'**
  String get ach_shiny_found_desc;

  /// No description provided for @ach_survival_pro_title.
  ///
  /// In es, this message translates to:
  /// **'Pro en Supervivencia'**
  String get ach_survival_pro_title;

  /// No description provided for @ach_survival_pro_desc.
  ///
  /// In es, this message translates to:
  /// **'Aguanta más de 2 minutos en modo supervivencia.'**
  String get ach_survival_pro_desc;

  /// No description provided for @ach_velocista_title.
  ///
  /// In es, this message translates to:
  /// **'Velocista'**
  String get ach_velocista_title;

  /// No description provided for @ach_velocista_desc.
  ///
  /// In es, this message translates to:
  /// **'Acierta 10 Pokémon en menos de 30 segundos.'**
  String get ach_velocista_desc;

  /// No description provided for @ach_racha_bronce_title.
  ///
  /// In es, this message translates to:
  /// **'Racha de Bronce'**
  String get ach_racha_bronce_title;

  /// No description provided for @ach_racha_bronce_desc.
  ///
  /// In es, this message translates to:
  /// **'10 aciertos seguidos sin saltar ninguno.'**
  String get ach_racha_bronce_desc;

  /// No description provided for @ach_racha_plata_title.
  ///
  /// In es, this message translates to:
  /// **'Racha de Plata'**
  String get ach_racha_plata_title;

  /// No description provided for @ach_racha_plata_desc.
  ///
  /// In es, this message translates to:
  /// **'25 aciertos seguidos.'**
  String get ach_racha_plata_desc;

  /// No description provided for @ach_racha_oro_title.
  ///
  /// In es, this message translates to:
  /// **'Racha de Oro'**
  String get ach_racha_oro_title;

  /// No description provided for @ach_racha_oro_desc.
  ///
  /// In es, this message translates to:
  /// **'50 aciertos seguidos.'**
  String get ach_racha_oro_desc;

  /// No description provided for @ach_intocable_title.
  ///
  /// In es, this message translates to:
  /// **'Intocable'**
  String get ach_intocable_title;

  /// No description provided for @ach_intocable_desc.
  ///
  /// In es, this message translates to:
  /// **'Termina una partida clásica sin usar \'Paso\'.'**
  String get ach_intocable_desc;

  /// No description provided for @ach_maestro_elemental_title.
  ///
  /// In es, this message translates to:
  /// **'Maestro Elemental'**
  String get ach_maestro_elemental_title;

  /// No description provided for @ach_maestro_elemental_desc.
  ///
  /// In es, this message translates to:
  /// **'Acierta un Pokémon de cada tipo en una sesión.'**
  String get ach_maestro_elemental_desc;

  /// No description provided for @ach_explorador_johto_title.
  ///
  /// In es, this message translates to:
  /// **'Explorador Johto'**
  String get ach_explorador_johto_title;

  /// No description provided for @ach_explorador_johto_desc.
  ///
  /// In es, this message translates to:
  /// **'Acierta 50 Pokémon de la Gen 2.'**
  String get ach_explorador_johto_desc;

  /// No description provided for @ach_leyenda_hoenn_title.
  ///
  /// In es, this message translates to:
  /// **'Leyenda de Hoenn'**
  String get ach_leyenda_hoenn_title;

  /// No description provided for @ach_leyenda_hoenn_desc.
  ///
  /// In es, this message translates to:
  /// **'Acierta 50 Pokémon de la Gen 3.'**
  String get ach_leyenda_hoenn_desc;

  /// No description provided for @ach_especialista_title.
  ///
  /// In es, this message translates to:
  /// **'Especialista'**
  String get ach_especialista_title;

  /// No description provided for @ach_especialista_desc.
  ///
  /// In es, this message translates to:
  /// **'Acierta 20 Pokémon de un mismo tipo en una partida.'**
  String get ach_especialista_desc;

  /// No description provided for @ach_dios_supervivencia_title.
  ///
  /// In es, this message translates to:
  /// **'Dios de la Supervivencia'**
  String get ach_dios_supervivencia_title;

  /// No description provided for @ach_dios_supervivencia_desc.
  ///
  /// In es, this message translates to:
  /// **'Aguanta 5 minutos en modo Supervivencia.'**
  String get ach_dios_supervivencia_desc;

  /// No description provided for @ach_a_contrarreloj_title.
  ///
  /// In es, this message translates to:
  /// **'A Contrarreloj'**
  String get ach_a_contrarreloj_title;

  /// No description provided for @ach_a_contrarreloj_desc.
  ///
  /// In es, this message translates to:
  /// **'Acierta cuando queden menos de 5 segundos.'**
  String get ach_a_contrarreloj_desc;

  /// No description provided for @ach_cazador_shinies_title.
  ///
  /// In es, this message translates to:
  /// **'Cazador de Shinies'**
  String get ach_cazador_shinies_title;

  /// No description provided for @ach_cazador_shinies_desc.
  ///
  /// In es, this message translates to:
  /// **'Encuentra 5 Pokémon Shiny en total.'**
  String get ach_cazador_shinies_desc;

  /// No description provided for @ach_dia_suerte_title.
  ///
  /// In es, this message translates to:
  /// **'Día de Suerte'**
  String get ach_dia_suerte_title;

  /// No description provided for @ach_dia_suerte_desc.
  ///
  /// In es, this message translates to:
  /// **'Encuentra 2 Shinies en una misma partida.'**
  String get ach_dia_suerte_desc;

  /// No description provided for @ach_buho_nocturno_title.
  ///
  /// In es, this message translates to:
  /// **'Búho Nocturno'**
  String get ach_buho_nocturno_title;

  /// No description provided for @ach_buho_nocturno_desc.
  ///
  /// In es, this message translates to:
  /// **'Juega una partida después de medianoche.'**
  String get ach_buho_nocturno_desc;

  /// No description provided for @ach_madrugador_title.
  ///
  /// In es, this message translates to:
  /// **'Madrugador'**
  String get ach_madrugador_title;

  /// No description provided for @ach_madrugador_desc.
  ///
  /// In es, this message translates to:
  /// **'Juega una partida antes de las 8 AM.'**
  String get ach_madrugador_desc;
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
