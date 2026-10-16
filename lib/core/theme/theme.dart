import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006879),
      surfaceTint: Color(0xff006879),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa9edff),
      onPrimaryContainer: Color(0xff004e5b),
      secondary: Color(0xff6f5d0e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfffae287),
      onSecondaryContainer: Color(0xff544600),
      tertiary: Color(0xff0d6b58),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffa2f2da),
      onTertiaryContainer: Color(0xff005142),
      error: Color(0xff36618e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd1e4ff),
      onErrorContainer: Color(0xff194975),
      surface: Color(0xfff5fafc),
      onSurface: Color(0xff171c1e),
      onSurfaceVariant: Color(0xff3f484b),
      outline: Color(0xff6f797b),
      outlineVariant: Color(0xffbfc8cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff84d2e6),
      primaryFixed: Color(0xffa9edff),
      onPrimaryFixed: Color(0xff001f26),
      primaryFixedDim: Color(0xff84d2e6),
      onPrimaryFixedVariant: Color(0xff004e5b),
      secondaryFixed: Color(0xfffae287),
      onSecondaryFixed: Color(0xff221b00),
      secondaryFixedDim: Color(0xffddc66e),
      onSecondaryFixedVariant: Color(0xff544600),
      tertiaryFixed: Color(0xffa2f2da),
      onTertiaryFixed: Color(0xff002019),
      tertiaryFixedDim: Color(0xff86d6bf),
      onTertiaryFixedVariant: Color(0xff005142),
      surfaceDim: Color(0xffd5dbdd),
      surfaceBright: Color(0xfff5fafc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff4f6),
      surfaceContainer: Color(0xffe9eff1),
      surfaceContainerHigh: Color(0xffe4e9eb),
      surfaceContainerHighest: Color(0xffdee3e5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003c47),
      surfaceTint: Color(0xff006879),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1d7789),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff413500),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff7e6c1d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003e32),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff267a67),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff003862),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff46709e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafc),
      onSurface: Color(0xff0c1214),
      onSurfaceVariant: Color(0xff2f383a),
      outline: Color(0xff4b5457),
      outlineVariant: Color(0xff666f71),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff84d2e6),
      primaryFixed: Color(0xff1d7789),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005d6d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff7e6c1d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff645402),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff267a67),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00604f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7c9),
      surfaceBright: Color(0xfff5fafc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff4f6),
      surfaceContainer: Color(0xffe4e9eb),
      surfaceContainerHigh: Color(0xffd8dee0),
      surfaceContainerHighest: Color(0xffcdd2d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00313a),
      surfaceTint: Color(0xff006879),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00515e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff352b00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff574800),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003329),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff005344),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff002e51),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff1d4b77),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafc),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e30),
      outlineVariant: Color(0xff424b4d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff84d2e6),
      primaryFixed: Color(0xff00515e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003842),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff574800),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3d3200),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff005344),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003a2f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4babc),
      surfaceBright: Color(0xfff5fafc),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f4),
      surfaceContainer: Color(0xffdee3e5),
      surfaceContainerHigh: Color(0xffd0d5d7),
      surfaceContainerHighest: Color(0xffc2c7c9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff84d2e6),
      surfaceTint: Color(0xff84d2e6),
      onPrimary: Color(0xff003640),
      primaryContainer: Color(0xff004e5b),
      onPrimaryContainer: Color(0xffa9edff),
      secondary: Color(0xffddc66e),
      onSecondary: Color(0xff3a3000),
      secondaryContainer: Color(0xff544600),
      onSecondaryContainer: Color(0xfffae287),
      tertiary: Color(0xff86d6bf),
      onTertiary: Color(0xff00382d),
      tertiaryContainer: Color(0xff005142),
      onTertiaryContainer: Color(0xffa2f2da),
      error: Color(0xffa0cafd),
      onError: Color(0xff003258),
      errorContainer: Color(0xff194975),
      onErrorContainer: Color(0xffd1e4ff),
      surface: Color(0xff0f1416),
      onSurface: Color(0xffdee3e5),
      onSurfaceVariant: Color(0xffbfc8cb),
      outline: Color(0xff899295),
      outlineVariant: Color(0xff3f484b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff006879),
      primaryFixed: Color(0xffa9edff),
      onPrimaryFixed: Color(0xff001f26),
      primaryFixedDim: Color(0xff84d2e6),
      onPrimaryFixedVariant: Color(0xff004e5b),
      secondaryFixed: Color(0xfffae287),
      onSecondaryFixed: Color(0xff221b00),
      secondaryFixedDim: Color(0xffddc66e),
      onSecondaryFixedVariant: Color(0xff544600),
      tertiaryFixed: Color(0xffa2f2da),
      onTertiaryFixed: Color(0xff002019),
      tertiaryFixedDim: Color(0xff86d6bf),
      onTertiaryFixedVariant: Color(0xff005142),
      surfaceDim: Color(0xff0f1416),
      surfaceBright: Color(0xff343a3c),
      surfaceContainerLowest: Color(0xff090f11),
      surfaceContainerLow: Color(0xff171c1e),
      surfaceContainer: Color(0xff1b2122),
      surfaceContainerHigh: Color(0xff252b2d),
      surfaceContainerHighest: Color(0xff303637),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff9ae8fc),
      surfaceTint: Color(0xff84d2e6),
      onPrimary: Color(0xff002a32),
      primaryContainer: Color(0xff4b9bae),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff4db81),
      onSecondary: Color(0xff2e2500),
      secondaryContainer: Color(0xffa4903e),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff9cecd4),
      onTertiary: Color(0xff002c23),
      tertiaryContainer: Color(0xff4f9f8a),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffc7deff),
      onError: Color(0xff002747),
      errorContainer: Color(0xff6a94c4),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1416),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd5dee1),
      outline: Color(0xffaab3b6),
      outlineVariant: Color(0xff899295),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff004f5d),
      primaryFixed: Color(0xffa9edff),
      onPrimaryFixed: Color(0xff001419),
      primaryFixedDim: Color(0xff84d2e6),
      onPrimaryFixedVariant: Color(0xff003c47),
      secondaryFixed: Color(0xfffae287),
      onSecondaryFixed: Color(0xff161100),
      secondaryFixedDim: Color(0xffddc66e),
      onSecondaryFixedVariant: Color(0xff413500),
      tertiaryFixed: Color(0xffa2f2da),
      onTertiaryFixed: Color(0xff00150f),
      tertiaryFixedDim: Color(0xff86d6bf),
      onTertiaryFixedVariant: Color(0xff003e32),
      surfaceDim: Color(0xff0f1416),
      surfaceBright: Color(0xff404547),
      surfaceContainerLowest: Color(0xff04080a),
      surfaceContainerLow: Color(0xff191f20),
      surfaceContainer: Color(0xff23292a),
      surfaceContainerHigh: Color(0xff2e3435),
      surfaceContainerHighest: Color(0xff393f40),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd5f6ff),
      surfaceTint: Color(0xff84d2e6),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff80cee2),
      onPrimaryContainer: Color(0xff000d11),
      secondary: Color(0xffffefbf),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffd9c26a),
      onSecondaryContainer: Color(0xff0f0b00),
      tertiary: Color(0xffb4ffe8),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff82d2bb),
      onTertiaryContainer: Color(0xff000e0a),
      error: Color(0xffe8f0ff),
      onError: Color(0xff000000),
      errorContainer: Color(0xff9cc6f9),
      onErrorContainer: Color(0xff000c1b),
      surface: Color(0xff0f1416),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f4),
      outlineVariant: Color(0xffbbc4c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff004f5d),
      primaryFixed: Color(0xffa9edff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff84d2e6),
      onPrimaryFixedVariant: Color(0xff001419),
      secondaryFixed: Color(0xfffae287),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffddc66e),
      onSecondaryFixedVariant: Color(0xff161100),
      tertiaryFixed: Color(0xffa2f2da),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff86d6bf),
      onTertiaryFixedVariant: Color(0xff00150f),
      surfaceDim: Color(0xff0f1416),
      surfaceBright: Color(0xff4b5153),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2122),
      surfaceContainer: Color(0xff2b3133),
      surfaceContainerHigh: Color(0xff363c3e),
      surfaceContainerHighest: Color(0xff42484a),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
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
  );


  List<ExtendedColor> get extendedColors => [
  ];
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
