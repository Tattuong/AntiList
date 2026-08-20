import 'package:flutter/material.dart';

/// AntiList — black ground, signal yellow, rescue red, log blue.
class AppColors {
  static const Color primary = Color(0xFFE11D48);
  static const Color primaryLight = Color(0xFFF5C400);
  static const Color primarySoft = Color(0xFF2A1218);
  static const Color primaryMuted = Color(0xFF9F1239);

  static const Color accent = Color(0xFFF5C400);
  static const Color accentLight = Color(0xFFFFE566);
  static const Color accentDeep = Color(0xFF2563EB);
  static const Color success = Color(0xFF22C55E);
  static const Color successDeep = Color(0xFF15803D);
  static const Color warning = Color(0xFFF5C400);
  static const Color error = Color(0xFFE11D48);
  static const Color coin = Color(0xFFF5C400);
  static const Color onGold = Color(0xFF0A0A0A);

  static const Color paint = Color(0xFF3B82F6);
  static const Color tiles = Color(0xFFE11D48);
  static const Color concrete = Color(0xFF22C55E);
  static const Color flooring = Color(0xFFF5C400);
  static const Color wallpaper = Color(0xFF6366F1);

  static const List<Color> subjects = [
    Color(0xFFE11D48),
    Color(0xFFF5C400),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFA855F7),
    Color(0xFFFB7185),
  ];

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF161616);
  static const Color surfaceElevated = Color(0xFF1C1C1C);
  static const Color surfaceVariant = Color(0xFF242424);
  static const Color border = Color(0xFF2E2E2E);
  static const Color borderBright = Color(0xFFE11D48);
  static const Color parchment = Color(0xFFF3EDE4);
  static const Color parchmentInk = Color(0xFF1A1A1A);

  static const Color textPrimary = Color(0xFFF5F5F4);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textMuted = Color(0xFF737373);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF5F5F4);
  static const Color onSurfaceVariant = Color(0xFFA3A3A3);

  static const Color navBar = Color(0xFF0A0A0A);
  static const Color navActive = accent;
  static const Color navInactive = Color(0xFF737373);

  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF161616);
  static const Color darkCard = Color(0xFF1C1C1C);
  static const Color trueBlack = Color(0xFF000000);
  static const Color darkInk = Color(0xFFF5F5F4);

  static const Color lightBackground = Color(0xFFF4F1EA);
  static const Color lightSurface = Color(0xFFFFFBF4);
  static const Color lightPrimaryTint = Color(0xFFFFE4E8);
  static const Color lightWarmTint = Color(0xFFF4F1EA);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);

  static const Color salon = Color(0xFF0A0A0A);
  static const Color salonCard = Color(0xFF161616);
  static const Color salonLine = Color(0xFF2E2E2E);

  static const List<Color> papers = [
    Color(0xFFF3EDE4),
    Color(0xFFEDE6DA),
    Color(0xFFF8F0E4),
    Color(0xFFE8EEF8),
    Color(0xFFF7F3EA),
    Color(0xFFEEF4F0),
    Color(0xFFFFFDF9),
  ];

  static const List<Color> extraPapers = [
    Color(0xFFEDE6DA),
    Color(0xFFE8EEF8),
    Color(0xFFF3E8D8),
  ];

  static Color paperAt(int index, {bool extras = false}) {
    final all = extras ? [...papers, ...extraPapers] : papers;
    if (all.isEmpty) return surface;
    return all[index % all.length];
  }

  static Color brand(BuildContext context) => Theme.of(context).colorScheme.primary;

  static Color page(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  static Color brandSoft(BuildContext context) =>
      Color.lerp(page(context), brand(context), 0.16) ?? primarySoft;

  static Color sheet(BuildContext context) => Theme.of(context).colorScheme.surface;

  static Color ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondary : const Color(0xFF6B6560);

  static Color card(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) return Colors.white;
    return Theme.of(context).colorScheme.surface;
  }

  static Color line(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? salonLine : const Color(0xFFE0D8CC);

  static Color headline(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accent : parchmentInk;

  static Color display(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : parchmentInk;

  static Color wash(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceVariant : const Color(0xFFEDE7DC);

  static Color avoidCard(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? parchment : Colors.white;

  static Color navMark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accent : primary;

  static Color navBarColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? navBar : Colors.white;

  static Color paper(BuildContext context, int index) {
    if (Theme.of(context).brightness == Brightness.dark) return paperAt(index);
    return papers[index % papers.length];
  }

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF1A0A10)],
  );

  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF161616)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE566), Color(0xFFF5C400)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    colors: [Color(0xFFF5C400), Color(0xFFEAB308)],
  );

  static const LinearGradient shopPromoGradient = LinearGradient(
    colors: [Color(0xFF1A0A10), Color(0xFF0A0A0A)],
  );

  static const LinearGradient vipGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C400), Color(0xFFE11D48), Color(0xFF9F1239)],
  );

  static const LinearGradient shopVipHeroGradient = LinearGradient(
    colors: [Color(0xFF161616), Color(0xFF0A0A0A)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0xFF1C1C1C), Color(0xFF161616)],
  );

  static List<BoxShadow> softShadow({double opacity = 0.10}) => [
        BoxShadow(
          color: const Color(0xFFE11D48).withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
