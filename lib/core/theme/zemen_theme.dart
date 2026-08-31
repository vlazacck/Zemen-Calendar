import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  ZEMEN DESIGN TOKENS
// ─────────────────────────────────────────────

abstract class ZemenColors {
  // Backgrounds — deep obsidian
  static const background = Color(0xFF080A0F);
  static const surface = Color(0xB3141820); // rgba(20,24,32,0.70)
  static const surfaceSolid = Color(0xFF141820);
  static const surfaceElevated = Color(0xFF1C2130);
  static const surfaceHigh = Color(0xFF232840);

  // Borders — brighter for visible glass edges
  static const glassBorder = Color(0x33FFFFFF); // rgba(255,255,255,0.20)
  static const glassBorderBright = Color(0x55FFFFFF); // rgba(255,255,255,0.33)
  static const glassBorderTop = Color(0x80FFFFFF); // top-edge highlight
  static const divider = Color(0x1AFFFFFF);

  // Brand
  static const primaryGold = Color(0xFFFFCB47);
  static const primaryGoldDim = Color(0x66FFCB47);
  static const primaryGoldGlow = Color(0x2AFFCB47);
  static const crimson = Color(0xFFFF5C6E);
  static const crimsonDim = Color(0x66FF5C6E);
  static const crimsonGlow = Color(0x2AFF5C6E);
  static const success = Color(0xFF4EEAA0);
  static const successDim = Color(0x664EEAA0);

  // Text
  static const textPrimary = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8A96B8);
  static const textTertiary = Color(0xFF3E4A6A);
  static const textGold = Color(0xFFFFCB47);

  // Semantic
  static const feastBlue = Color(0xFF6B9FFF);
  static const feastBlueDim = Color(0x666B9FFF);
  static const moonWhite = Color(0xFFE8EDF5);

  // Ambient glow orb colors
  static const glowGold = Color(0xFFFFCB47);
  static const glowBlue = Color(0xFF4D7FFF);
  static const glowPurple = Color(0xFF9B59FF);
  static const glowTeal = Color(0xFF00D4AA);
  static const glowCrimson = Color(0xFFFF3D5A);

  // Gradients
  static const goldGradientStart = Color(0xFFFFCB47);
  static const goldGradientEnd = Color(0xFFE5920A);
  static const backgroundGradientTop = Color(0xFF0B0D14);
  static const backgroundGradientBottom = Color(0xFF060709);
}

abstract class ZemenGradients {
  static const goldLinear = LinearGradient(
    colors: [ZemenColors.goldGradientStart, ZemenColors.goldGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroCard = LinearGradient(
    colors: [Color(0xFF1E2438), Color(0xFF0E1018)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Strong glass tint — visible white sheen
  static const glassCard = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x14FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass surface fill gradient
  static const glassFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0x3AFFFFFF), Color(0x18FFFFFF), Color(0x08FFFFFF)],
  );

  static const background = LinearGradient(
    colors: [
      ZemenColors.backgroundGradientTop,
      ZemenColors.backgroundGradientBottom
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const crimsonGlow = RadialGradient(
    colors: [Color(0x55FF5C6E), Color(0x00FF5C6E)],
    radius: 1.0,
  );

  static const goldGlow = RadialGradient(
    colors: [Color(0x55FFCB47), Color(0x00FFCB47)],
    radius: 1.0,
  );

  static const blueGlow = RadialGradient(
    colors: [Color(0x554D7FFF), Color(0x004D7FFF)],
    radius: 1.0,
  );
}

abstract class ZemenRadius {
  static const xs = Radius.circular(6);
  static const sm = Radius.circular(12);
  static const md = Radius.circular(16);
  static const lg = Radius.circular(24);
  static const xl = Radius.circular(32);
  static const full = Radius.circular(999);

  static const BorderRadius xsBR = BorderRadius.all(xs);
  static const BorderRadius smBR = BorderRadius.all(sm);
  static const BorderRadius mdBR = BorderRadius.all(md);
  static const BorderRadius lgBR = BorderRadius.all(lg);
  static const BorderRadius xlBR = BorderRadius.all(xl);
  static const BorderRadius fullBR = BorderRadius.all(full);
}

abstract class ZemenSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

abstract class ZemenShadows {
  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: ZemenColors.primaryGold.withValues(alpha: 0.30),
          blurRadius: 50,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: ZemenColors.primaryGold.withValues(alpha: 0.12),
          blurRadius: 100,
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> get cardFloat => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // Strong glass shadow with bright top-edge inner glow
  static List<BoxShadow> get glassSurface => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.50),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.20),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
        // Top-edge bright reflection
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.10),
          blurRadius: 1,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get crimsonGlow => [
        BoxShadow(
          color: ZemenColors.crimson.withValues(alpha: 0.35),
          blurRadius: 60,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get blueGlow => [
        BoxShadow(
          color: ZemenColors.feastBlue.withValues(alpha: 0.35),
          blurRadius: 60,
          spreadRadius: -4,
        ),
      ];
}

// ─────────────────────────────────────────────
//  TYPOGRAPHY
// ─────────────────────────────────────────────

abstract class ZemenTextStyles {
  // Hero — Ethiopian dates (Amharic)
  static TextStyle heroAmharic({double fontSize = 48, Color? color}) =>
      TextStyle(
        fontFamily: 'Benaiah',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? ZemenColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  // English Display
  static TextStyle heroEnglish({double fontSize = 48, Color? color}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? ZemenColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.0,
      );

  static TextStyle pageHeader({bool amharic = false, Color? color}) =>
      TextStyle(
        fontFamily: amharic ? 'Benaiah' : 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color ?? ZemenColors.textPrimary,
        letterSpacing: amharic ? 0 : -0.8,
        height: 1.2,
      );

  static TextStyle sectionHeader({bool amharic = false, Color? color}) =>
      TextStyle(
        fontFamily: amharic ? 'Benaiah' : 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? ZemenColors.textPrimary,
        letterSpacing: amharic ? 0 : -0.3,
      );

  static TextStyle body({bool amharic = false, Color? color}) => TextStyle(
        fontFamily: amharic ? 'Benaiah' : 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color ?? ZemenColors.textPrimary,
        height: 1.6,
      );

  static TextStyle bodyMedium({bool amharic = false, Color? color}) =>
      TextStyle(
        fontFamily: amharic ? 'Benaiah' : 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color ?? ZemenColors.textPrimary,
      );

  static TextStyle metadata({bool amharic = false, Color? color}) => TextStyle(
        fontFamily: amharic ? 'Benaiah' : 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color ?? ZemenColors.textSecondary,
        letterSpacing: 0.1,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color ?? ZemenColors.textTertiary,
        letterSpacing: 0.5,
      );

  static TextStyle goldLabel({double fontSize = 13}) => TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: ZemenColors.primaryGold,
        letterSpacing: 0.8,
      );
}

// ─────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────

ThemeData buildZemenTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ZemenColors.background,
    colorScheme: const ColorScheme.dark(
      primary: ZemenColors.primaryGold,
      secondary: ZemenColors.crimson,
      surface: ZemenColors.surfaceSolid,
      onPrimary: ZemenColors.background,
      onSecondary: ZemenColors.textPrimary,
      onSurface: ZemenColors.textPrimary,
      error: ZemenColors.crimson,
      onError: ZemenColors.textPrimary,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ZemenColors.background,
      ),
      centerTitle: false,
      iconTheme: IconThemeData(color: ZemenColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: ZemenColors.primaryGold,
      unselectedItemColor: ZemenColors.textTertiary,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: const CardThemeData(
      color: ZemenColors.surfaceSolid,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: ZemenRadius.lgBR,
        side: BorderSide(color: ZemenColors.glassBorder),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ZemenColors.divider,
      thickness: 1,
    ),
    textTheme: TextTheme(
      displayLarge: ZemenTextStyles.heroEnglish(),
      displayMedium: ZemenTextStyles.pageHeader(),
      displaySmall: ZemenTextStyles.sectionHeader(),
      bodyLarge: ZemenTextStyles.body(),
      bodyMedium: ZemenTextStyles.metadata(),
      labelSmall: ZemenTextStyles.caption(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? ZemenColors.primaryGold
            : ZemenColors.textTertiary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? ZemenColors.primaryGoldDim
            : ZemenColors.surfaceElevated,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
