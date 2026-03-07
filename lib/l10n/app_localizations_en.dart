// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PokeRush';

  @override
  String get classic => 'CLASSIC';

  @override
  String get survival => 'SURVIVAL';

  @override
  String get play => 'PLAY!';

  @override
  String get instructions =>
      'Place your phone on your forehead\nTilt forward for CORRECT\nTilt backward for PASS';

  @override
  String get settings => 'Settings';

  @override
  String get filters => 'Pokémon Filters';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get generations => 'GENERATIONS';

  @override
  String get types => 'TYPES';

  @override
  String get filterNote =>
      'Note: If you don\'t select any types, all will be shown.';

  @override
  String get visualSettings => 'VISUAL SETTINGS';

  @override
  String get dynamicBackgrounds => 'Dynamic Backgrounds';

  @override
  String get dynamicBackgroundsDesc =>
      'Changes color based on the Pokémon type.';

  @override
  String get sensorCalibration => 'SENSOR CALIBRATION';

  @override
  String get correctSensitivity => 'Correct Sensitivity (Forward Tilt)';

  @override
  String get skipSensitivity => 'Skip Sensitivity (Backward Tilt)';

  @override
  String get achievements => 'ACHIEVEMENTS';

  @override
  String get language => 'LANGUAGE';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get noPokemonTitle => 'No Pokémon';

  @override
  String get noPokemonContent =>
      'No Pokémon found with these filters. Please adjust your settings.';

  @override
  String get accept => 'ACCEPT';

  @override
  String get score => 'SCORE';

  @override
  String get time => 'TIME';

  @override
  String get pokedex => 'Pokédex';

  @override
  String get searchPokemon => 'Search Pokémon...';

  @override
  String get noPokemonFound => 'No Pokémon found';

  @override
  String get ready => 'READY?';

  @override
  String get correct => 'CORRECT!';

  @override
  String get skipped => 'SKIPPED...';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get finalScore => 'Final Score';

  @override
  String get backToHome => 'BACK TO HOME';
}
