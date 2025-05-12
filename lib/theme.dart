import "package:flutter/material.dart";

class Dracula {
  static const Color background = Color(0xFF282A36);
  static const Color currentLine = Color(0xFF44475A);
  static const Color foreground = Color(0xFFF8F8F2);
  static const Color comment = Color(0xFF6272A4);
  static const Color cyan = Color(0xFF8BE9FD);
  static const Color green = Color(0xFF50FA7B);
  static const Color orange = Color(0xFFFFB86C);
  static const Color pink = Color(0xFFFF79C6);
  static const Color purple = Color(0xFFBD93F9);
  static const Color red = Color(0xFFFF5555);
  static const Color yellow = Color(0xFFF1FA8C);
}

// https://material-foundation.github.io/material-theme-builder/?primary=%23BD93F9&secondary=%2350FA7B&tertiary=%23FF79C6&error=%23FF5555&neutral=%23282A36&neutralVariant=%2344475A&custom%3AForeground=%23F8F8F2&custom%3AComment=%236272A4&custom%3ACyan=%238BE9FD&custom%3AOrange=%23FFB86C&custom%3AYellow=%23F1FA8C&colorMatch=true
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff714aaa),
      surfaceTint: Color(0xff714aaa),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc79fff),
      onPrimaryContainer: Color(0xff36016d),
      secondary: Color(0xff006e2b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff62ff84),
      onSecondaryContainer: Color(0xff00541f),
      tertiary: Color(0xffa42e79),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffff8ccb),
      onTertiaryContainer: Color(0xff500037),
      error: Color(0xffb71f29),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffff6f6b),
      onErrorContainer: Color(0xff290002),
      surface: Color(0xfffef7ff),
      onSurface: Color(0xff1d1a21),
      onSurfaceVariant: Color(0xff4a4451),
      outline: Color(0xff7c7482),
      outlineVariant: Color(0xffccc3d3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f36),
      inversePrimary: Color(0xffd7baff),
      primaryFixed: Color(0xffeddcff),
      onPrimaryFixed: Color(0xff290055),
      primaryFixedDim: Color(0xffd7baff),
      onPrimaryFixedVariant: Color(0xff593090),
      secondaryFixed: Color(0xff69ff88),
      onSecondaryFixed: Color(0xff002108),
      secondaryFixedDim: Color(0xff31e368),
      onSecondaryFixedVariant: Color(0xff00531e),
      tertiaryFixed: Color(0xffffd8e9),
      onTertiaryFixed: Color(0xff3c0029),
      tertiaryFixedDim: Color(0xffffafd7),
      onTertiaryFixedVariant: Color(0xff860f60),
      surfaceDim: Color(0xffdfd8e1),
      surfaceBright: Color(0xfffef7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1fa),
      surfaceContainer: Color(0xfff3ebf5),
      surfaceContainerHigh: Color(0xffede6ef),
      surfaceContainerHighest: Color(0xffe8e0e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdbbfff),
      surfaceTint: Color(0xffd7baff),
      onPrimary: Color(0xff220049),
      primaryContainer: Color(0xffb68cf2),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff003912),
      secondaryContainer: Color(0xff46f274),
      onSecondaryContainer: Color(0xff00260a),
      tertiary: Color(0xffffb5da),
      onTertiary: Color(0xff330022),
      tertiaryContainer: Color(0xfff873c0),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffb9b5),
      onError: Color(0xff370003),
      errorContainer: Color(0xfffe5454),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff151218),
      onSurface: Color(0xfffff9fd),
      onSurfaceVariant: Color(0xffd1c7d7),
      outline: Color(0xffa8a0ae),
      outlineVariant: Color(0xff88808e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e9),
      inversePrimary: Color(0xff5a3191),
      primaryFixed: Color(0xffeddcff),
      onPrimaryFixed: Color(0xff1b003c),
      primaryFixedDim: Color(0xffd7baff),
      onPrimaryFixedVariant: Color(0xff471c7e),
      secondaryFixed: Color(0xff69ff88),
      onSecondaryFixed: Color(0xff001504),
      secondaryFixedDim: Color(0xff31e368),
      onSecondaryFixedVariant: Color(0xff004015),
      tertiaryFixed: Color(0xffffd8e9),
      onTertiaryFixed: Color(0xff2a001b),
      tertiaryFixedDim: Color(0xffffafd7),
      onTertiaryFixedVariant: Color(0xff6c004c),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff3b383f),
      surfaceContainerLowest: Color(0xff100d13),
      surfaceContainerLow: Color(0xff1d1a21),
      surfaceContainer: Color(0xff211e25),
      surfaceContainerHigh: Color(0xff2c292f),
      surfaceContainerHighest: Color(0xff37333a),
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
