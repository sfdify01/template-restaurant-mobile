import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shahirizada Fresh Market - Premium Theme System
///
/// Design Direction: Warm, inviting meat market aesthetic with Middle Eastern influences
/// - Rich burgundy/maroon primary color representing quality meat
/// - Warm cream/sand accents evoking Middle Eastern heritage
/// - Clean, premium feel with careful attention to hierarchy
class AppTheme {
  AppTheme._();

  // ==========================================================================
  // BRAND COLORS - Core identity colors
  // ==========================================================================

  /// Deep burgundy - Primary brand color (quality meat/premium feel)
  static const Color primaryColor = Color(0xFF6B0F1A);

  /// Lighter burgundy for hover/pressed states
  static const Color primaryLight = Color(0xFF8B2030);

  /// Darker burgundy for emphasis
  static const Color primaryDark = Color(0xFF4A0A12);

  /// Warm cream - Secondary/accent color (Middle Eastern heritage)
  static const Color accentColor = Color(0xFFE8D5BA);

  /// Muted gold for premium accents
  static const Color goldAccent = Color(0xFFD4A855);

  /// Gold star color for loyalty/rewards
  static const Color goldStar = Color(0xFFFFA000);

  /// Hint/placeholder text color (for backward compatibility)
  @Deprecated('Use context.colors.textTertiary instead')
  static const Color textHint = Color(0xFF9CA3AF);

  // ==========================================================================
  // SEMANTIC COLORS
  // ==========================================================================

  static const Color successColor = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color errorColor = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color infoColor = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ==========================================================================
  // LOYALTY TIER COLORS
  // ==========================================================================

  static const Color bronzeTier = Color(0xFFCD7F32);
  static const Color silverTier = Color(0xFF9E9E9E);
  static const Color goldTier = Color(0xFFFFD700);
  static const Color platinumTier = Color(0xFF7B8A94);

  // ==========================================================================
  // LIGHT THEME COLORS
  // ==========================================================================

  static const _LightColors _light = _LightColors();

  // ==========================================================================
  // DARK THEME COLORS
  // ==========================================================================

  static const _DarkColors _dark = _DarkColors();

  // ==========================================================================
  // TYPOGRAPHY
  // ==========================================================================

  /// Display font - Playfair Display for headlines (elegant, editorial)
  static String get _displayFont => GoogleFonts.playfairDisplay().fontFamily!;

  /// Body font - Source Sans 3 for readability (clean, modern)
  static String get _bodyFont => GoogleFonts.sourceSans3().fontFamily!;

  static TextTheme _buildTextTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      // Display - Large headlines
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),

      // Headlines - Section headers
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.sourceSans3(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Titles - Card headers, list items
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.sourceSans3(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Body - Main content
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
        height: 1.4,
      ),

      // Labels - Buttons, chips, tags
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ==========================================================================
  // LIGHT THEME
  // ==========================================================================

  static ThemeData get light {
    final textTheme = _buildTextTheme(_light.textPrimary, _light.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: accentColor,
        onSecondary: _light.textPrimary,
        secondaryContainer: accentColor.withOpacity(0.3),
        onSecondaryContainer: _light.textPrimary,
        tertiary: goldAccent,
        onTertiary: Colors.white,
        surface: _light.surface,
        onSurface: _light.textPrimary,
        surfaceContainerHighest: _light.surfaceVariant,
        onSurfaceVariant: _light.textSecondary,
        outline: _light.border,
        outlineVariant: _light.borderLight,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorLight,
        onErrorContainer: errorColor,
      ),

      // Backgrounds
      scaffoldBackgroundColor: _light.background,
      canvasColor: _light.background,

      // Typography
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: _light.surface,
        foregroundColor: _light.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _light.textPrimary,
        ),
        iconTheme: IconThemeData(color: _light.textPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: _light.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _light.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _light.disabled,
          disabledForegroundColor: _light.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          disabledForegroundColor: _light.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryColor, width: 1.5),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          disabledForegroundColor: _light.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Filled Buttons (alternative style)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _light.disabled,
          disabledForegroundColor: _light.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon Buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _light.textPrimary,
          disabledForegroundColor: _light.textTertiary,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _light.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _light.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _light.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _light.borderLight),
        ),
        labelStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _light.textSecondary,
        ),
        hintStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _light.textTertiary,
        ),
        errorStyle: GoogleFonts.sourceSans3(fontSize: 12, color: errorColor),
        prefixIconColor: _light.textSecondary,
        suffixIconColor: _light.textSecondary,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _light.surface,
        selectedItemColor: primaryColor,
        unselectedItemColor: _light.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _light.surface,
        indicatorColor: primaryColor.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor, size: 24);
          }
          return IconThemeData(color: _light.textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.sourceSans3(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: _light.textTertiary,
          );
        }),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: _light.surfaceVariant,
        disabledColor: _light.disabled,
        selectedColor: primaryColor.withOpacity(0.15),
        secondarySelectedColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _light.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _light.borderLight),
        ),
      ),

      // Segmented Button
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return _light.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return _light.textPrimary;
          }),
          side: WidgetStateProperty.all(BorderSide(color: _light.border)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: _light.borderLight,
        thickness: 1,
        space: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor: _light.textSecondary,
        textColor: _light.textPrimary,
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _light.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          color: _light.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _light.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return _light.disabled;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: _light.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return _light.textSecondary;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFE0E0E0),
        circularTrackColor: Color(0xFFE0E0E0),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _light.textPrimary,
        contentTextStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _light.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _light.textPrimary,
        ),
        contentTextStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _light.textSecondary,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _light.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        dragHandleColor: _light.border,
        dragHandleSize: const Size(32, 4),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: _light.textSecondary,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Badge
      badgeTheme: BadgeThemeData(
        backgroundColor: primaryColor,
        textColor: Colors.white,
        textStyle: GoogleFonts.sourceSans3(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _light.textPrimary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.sourceSans3(fontSize: 12, color: Colors.white),
      ),
    );
  }

  // ==========================================================================
  // DARK THEME
  // ==========================================================================

  static ThemeData get dark {
    final textTheme = _buildTextTheme(_dark.textPrimary, _dark.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        onPrimary: Colors.white,
        primaryContainer: primaryColor,
        onPrimaryContainer: Colors.white,
        secondary: accentColor,
        onSecondary: _dark.textPrimary,
        secondaryContainer: accentColor.withOpacity(0.2),
        onSecondaryContainer: accentColor,
        tertiary: goldAccent,
        onTertiary: Colors.black,
        surface: _dark.surface,
        onSurface: _dark.textPrimary,
        surfaceContainerHighest: _dark.surfaceVariant,
        onSurfaceVariant: _dark.textSecondary,
        outline: _dark.border,
        outlineVariant: _dark.borderLight,
        error: const Color(0xFFEF5350),
        onError: Colors.white,
        errorContainer: errorColor.withOpacity(0.2),
        onErrorContainer: const Color(0xFFEF5350),
      ),

      // Backgrounds
      scaffoldBackgroundColor: _dark.background,
      canvasColor: _dark.background,

      // Typography
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: _dark.surface,
        foregroundColor: _dark.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _dark.textPrimary,
        ),
        iconTheme: IconThemeData(color: _dark.textPrimary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: _dark.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _dark.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _dark.disabled,
          disabledForegroundColor: _dark.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          disabledForegroundColor: _dark.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryLight, width: 1.5),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          disabledForegroundColor: _dark.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Filled Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _dark.disabled,
          disabledForegroundColor: _dark.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon Buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _dark.textPrimary,
          disabledForegroundColor: _dark.textTertiary,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _dark.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _dark.borderLight),
        ),
        labelStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _dark.textSecondary,
        ),
        hintStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _dark.textTertiary,
        ),
        errorStyle: GoogleFonts.sourceSans3(
          fontSize: 12,
          color: const Color(0xFFEF5350),
        ),
        prefixIconColor: _dark.textSecondary,
        suffixIconColor: _dark.textSecondary,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _dark.surface,
        selectedItemColor: primaryLight,
        unselectedItemColor: _dark.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _dark.surface,
        indicatorColor: primaryLight.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryLight, size: 24);
          }
          return IconThemeData(color: _dark.textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.sourceSans3(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryLight,
            );
          }
          return GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: _dark.textTertiary,
          );
        }),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: _dark.surfaceVariant,
        disabledColor: _dark.disabled,
        selectedColor: primaryLight.withOpacity(0.2),
        secondarySelectedColor: accentColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _dark.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: primaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _dark.borderLight),
        ),
      ),

      // Segmented Button
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryLight;
            }
            return _dark.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return _dark.textPrimary;
          }),
          side: WidgetStateProperty.all(BorderSide(color: _dark.border)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: _dark.borderLight,
        thickness: 1,
        space: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor: _dark.textSecondary,
        textColor: _dark.textPrimary,
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _dark.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          color: _dark.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _dark.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return _dark.disabled;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: _dark.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLight;
          }
          return _dark.textSecondary;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryLight,
        linearTrackColor: _dark.surfaceVariant,
        circularTrackColor: _dark.surfaceVariant,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _dark.surfaceVariant,
        contentTextStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _dark.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _dark.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _dark.textPrimary,
        ),
        contentTextStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: _dark.textSecondary,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _dark.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        dragHandleColor: _dark.border,
        dragHandleSize: const Size(32, 4),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryLight,
        unselectedLabelColor: _dark.textSecondary,
        indicatorColor: primaryLight,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Badge
      badgeTheme: BadgeThemeData(
        backgroundColor: primaryLight,
        textColor: Colors.white,
        textStyle: GoogleFonts.sourceSans3(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _dark.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.sourceSans3(
          fontSize: 12,
          color: _dark.textPrimary,
        ),
      ),
    );
  }

  // ==========================================================================
  // LEGACY STATIC COLOR ACCESS (for gradual migration)
  // Prefer using Theme.of(context) or context.colors extension
  // ==========================================================================

  @Deprecated('Use Theme.of(context).colorScheme or context.colors instead')
  static const Color textPrimary = Color(0xFF1A1A1A);

  @Deprecated('Use Theme.of(context).colorScheme or context.colors instead')
  static const Color textSecondary = Color(0xFF6B7280);

  @Deprecated('Use Theme.of(context).colorScheme or context.colors instead')
  static const Color backgroundColor = Color(0xFFFAF9F7);

  @Deprecated('Use Theme.of(context).colorScheme or context.colors instead')
  static const Color surfaceColor = Colors.white;

  @Deprecated('Use Theme.of(context).colorScheme or context.colors instead')
  static const Color secondaryColor = Color(0xFFE8D5BA);
}

// =============================================================================
// LIGHT THEME COLOR PALETTE
// =============================================================================

class _LightColors {
  const _LightColors();

  // Backgrounds
  Color get background => const Color(0xFFFAF9F7);
  Color get surface => Colors.white;
  Color get surfaceVariant => const Color(0xFFF5F3F0);

  // Text
  Color get textPrimary => const Color(0xFF1A1A1A);
  Color get textSecondary => const Color(0xFF6B7280);
  Color get textTertiary => const Color(0xFF9CA3AF);

  // Borders
  Color get border => const Color(0xFFD1D5DB);
  Color get borderLight => const Color(0xFFE5E7EB);

  // States
  Color get disabled => const Color(0xFFE5E7EB);
  Color get hover => const Color(0xFFF3F4F6);
}

// =============================================================================
// DARK THEME COLOR PALETTE
// =============================================================================

class _DarkColors {
  const _DarkColors();

  // Backgrounds
  Color get background => const Color(0xFF0F0F0F);
  Color get surface => const Color(0xFF1A1A1A);
  Color get surfaceVariant => const Color(0xFF262626);

  // Text
  Color get textPrimary => const Color(0xFFF9FAFB);
  Color get textSecondary => const Color(0xFFA1A1AA);
  Color get textTertiary => const Color(0xFF71717A);

  // Borders
  Color get border => const Color(0xFF3F3F46);
  Color get borderLight => const Color(0xFF27272A);

  // States
  Color get disabled => const Color(0xFF27272A);
  Color get hover => const Color(0xFF3F3F46);
}

// =============================================================================
// THEME EXTENSIONS FOR EASY ACCESS
// =============================================================================

extension ThemeContextExtension on BuildContext {
  /// Access theme data
  ThemeData get theme => Theme.of(this);

  /// Access color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Get adaptive colors based on theme
  AppColors get colors => AppColors(this);
}

/// Adaptive colors that work in both light and dark themes
class AppColors {
  final BuildContext context;

  AppColors(this.context);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Primary
  Color get primary => _isDark ? AppTheme.primaryLight : AppTheme.primaryColor;

  // Backgrounds
  Color get background => Theme.of(context).scaffoldBackgroundColor;
  Color get surface => Theme.of(context).colorScheme.surface;
  Color get surfaceVariant =>
      _isDark ? const Color(0xFF262626) : const Color(0xFFF5F3F0);

  // Text
  Color get textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get textSecondary =>
      _isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
  Color get textTertiary =>
      _isDark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF);

  // Borders
  Color get border => Theme.of(context).colorScheme.outline;
  Color get borderLight => Theme.of(context).colorScheme.outlineVariant;

  // Semantic
  Color get success => AppTheme.successColor;
  Color get successBackground =>
      _isDark ? AppTheme.successColor.withOpacity(0.15) : AppTheme.successLight;
  Color get warning => AppTheme.warningColor;
  Color get warningBackground =>
      _isDark ? AppTheme.warningColor.withOpacity(0.15) : AppTheme.warningLight;
  Color get error => Theme.of(context).colorScheme.error;
  Color get errorBackground =>
      _isDark ? AppTheme.errorColor.withOpacity(0.15) : AppTheme.errorLight;
  Color get info => AppTheme.infoColor;
  Color get infoBackground =>
      _isDark ? AppTheme.infoColor.withOpacity(0.15) : AppTheme.infoLight;

  // Accent
  Color get accent => AppTheme.accentColor;
  Color get gold => AppTheme.goldAccent;

  // States
  Color get disabled =>
      _isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
  Color get hover =>
      _isDark ? const Color(0xFF3F3F46) : const Color(0xFFF3F4F6);

  // Shimmer
  Color get shimmerBase =>
      _isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB);
  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF3F3F46) : const Color(0xFFF5F5F5);
}
