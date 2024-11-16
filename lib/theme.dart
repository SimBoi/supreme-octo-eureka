import "package:flutter/material.dart";

// http://material-foundation.github.io?primary=%23BD93F9&secondary=%2350FA7B&tertiary=%23FF79C6&error=%23FF5555&colorMatch=true
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4285614762),
      surfaceTint: Color(4285614762),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4291272703),
      onPrimaryContainer: Color(4281729389),
      secondary: Color(4278218283),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284678020),
      onSecondaryContainer: Color(4278211615),
      tertiary: Color(4288949881),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294937803),
      onTertiaryContainer: Color(4283433015),
      error: Color(4290191145),
      onError: Color(4294967295),
      errorContainer: Color(4294930283),
      onErrorContainer: Color(4280877058),
      surface: Color(4294899711),
      onSurface: Color(4280097313),
      onSurfaceVariant: Color(4283057233),
      outline: Color(4286346370),
      outlineVariant: Color(4291609555),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281544502),
      inversePrimary: Color(4292328191),
      primaryFixed: Color(4293778687),
      onPrimaryFixed: Color(4280877141),
      primaryFixedDim: Color(4292328191),
      onPrimaryFixedVariant: Color(4284035216),
      secondaryFixed: Color(4285136776),
      onSecondaryFixed: Color(4278198536),
      secondaryFixedDim: Color(4281459560),
      onSecondaryFixedVariant: Color(4278211358),
      tertiaryFixed: Color(4294957289),
      onTertiaryFixed: Color(4282122281),
      tertiaryFixedDim: Color(4294946775),
      onTertiaryFixedVariant: Color(4286975840),
      surfaceDim: Color(4292860129),
      surfaceBright: Color(4294899711),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294570490),
      surfaceContainer: Color(4294175733),
      surfaceContainerHigh: Color(4293781231),
      surfaceContainerHighest: Color(4293452009),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4292591615),
      surfaceTint: Color(4292328191),
      onPrimary: Color(4280418377),
      primaryContainer: Color(4290153714),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294967295),
      onSecondary: Color(4278204690),
      secondaryContainer: Color(4282839668),
      onSecondaryContainer: Color(4278199818),
      tertiary: Color(4294948314),
      onTertiary: Color(4281532450),
      tertiaryContainer: Color(4294472640),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949301),
      onError: Color(4281794563),
      errorContainer: Color(4294857812),
      onErrorContainer: Color(4278190080),
      surface: Color(4279570968),
      onSurface: Color(4294965757),
      onSurfaceVariant: Color(4291938263),
      outline: Color(4289241262),
      outlineVariant: Color(4287135886),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293452009),
      inversePrimary: Color(4284101009),
      primaryFixed: Color(4293778687),
      onPrimaryFixed: Color(4279959612),
      primaryFixedDim: Color(4292328191),
      onPrimaryFixedVariant: Color(4282850430),
      secondaryFixed: Color(4285136776),
      onSecondaryFixed: Color(4278195460),
      secondaryFixedDim: Color(4281459560),
      onSecondaryFixedVariant: Color(4278206485),
      tertiaryFixed: Color(4294957289),
      onTertiaryFixed: Color(4280942619),
      tertiaryFixedDim: Color(4294946775),
      onTertiaryFixedVariant: Color(4285268044),
      surfaceDim: Color(4279570968),
      surfaceBright: Color(4282071103),
      surfaceContainerLowest: Color(4279242003),
      surfaceContainerLow: Color(4280097313),
      surfaceContainer: Color(4280360485),
      surfaceContainerHigh: Color(4281084207),
      surfaceContainerHighest: Color(4281807674),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
