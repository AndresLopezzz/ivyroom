import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/design/motion.dart';
import '../ui/design/tokens.dart';
import '../ui/design/type.dart';

/// El tema.
///
/// Claro y acromático a propósito, y sin variante oscura por ahora: en una
/// app de armario el color lo aportan las prendas, y las fotos recortadas
/// sobre fondo transparente se leen mucho mejor sobre papel claro que sobre
/// negro. Un tema oscuro obligaría a un tratamiento distinto de las
/// imágenes, no solo a cambiar tokens.
ThemeData buildTheme() {
  const scheme = ColorScheme.light(
    primary: Ivy.ink,
    onPrimary: Ivy.surface,
    secondary: Ivy.sage,
    onSecondary: Ivy.surface,
    surface: Ivy.surface,
    onSurface: Ivy.ink,
    surfaceContainerLowest: Ivy.surface,
    surfaceContainerLow: Ivy.paper,
    surfaceContainer: Ivy.paper,
    surfaceContainerHigh: Color(0xFFF1EFEA),
    surfaceContainerHighest: Color(0xFFEDEAE4),
    outline: Ivy.inkFaint,
    outlineVariant: Ivy.hairline,
    error: Ivy.clay,
    onError: Ivy.surface,
    errorContainer: Ivy.claySoft,
    onErrorContainer: Ivy.clay,
    secondaryContainer: Ivy.sageSoft,
    onSecondaryContainer: Ivy.sage,
    tertiary: Ivy.clay,
    tertiaryContainer: Ivy.claySoft,
    onTertiaryContainer: Ivy.clay,
    primaryContainer: Color(0xFFE9E7E1),
    onPrimaryContainer: Ivy.ink,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Ivy.paper,
    useMaterial3: true,
    splashFactory: NoSplash.splashFactory,
    // El brillo del toque lo pone `Pressable` con una escala: la onda de
    // Material sobre tarjetas blancas se ve sucia y llega tarde.
    highlightColor: Colors.transparent,
    textTheme: TextTheme(
      displayLarge: IvyType.hero,
      displayMedium: IvyType.display,
      titleLarge: IvyType.title,
      titleMedium: IvyType.heading,
      bodyLarge: IvyType.body,
      bodyMedium: IvyType.body,
      bodySmall: IvyType.small,
      labelLarge: IvyType.action,
      labelMedium: IvyType.smallStrong,
      labelSmall: IvyType.labelFaint,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Ivy.paper,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Ivy.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: IvyType.title,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Ivy.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Ivy.rSheet),
      ),
      titleTextStyle: IvyType.title,
      contentTextStyle: IvyType.body,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Ivy.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Ivy.rSheet)),
      ),
      dragHandleColor: Ivy.hairline,
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Ivy.ink,
      contentTextStyle: IvyType.body.copyWith(color: Ivy.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Ivy.rPill),
      ),
      insetPadding: const EdgeInsets.all(Ivy.s4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Ivy.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: Ivy.s4, vertical: Ivy.s3 + 2),
      hintStyle: IvyType.body.copyWith(color: Ivy.inkFaint),
      labelStyle: IvyType.small,
      floatingLabelStyle: IvyType.smallStrong.copyWith(color: Ivy.inkSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Ivy.rCard - 4),
        borderSide: const BorderSide(color: Ivy.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Ivy.rCard - 4),
        borderSide: const BorderSide(color: Ivy.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Ivy.rCard - 4),
        borderSide: const BorderSide(color: Ivy.ink, width: 1.4),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Ivy.paper,
      // Un tono claro y no tinta: el chip de Material pinta la etiqueta con
      // `labelStyle` tambien cuando esta seleccionado, asi que un fondo
      // oscuro dejaba el texto invisible. Los sitios que necesitan el
      // contraste fuerte usan `Pill`, que si cambia el color del texto.
      selectedColor: const Color(0xFFDDD9D0),
      side: BorderSide.none,
      labelStyle: IvyType.smallStrong,
      secondaryLabelStyle: IvyType.smallStrong.copyWith(color: Ivy.surface),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: Ivy.s2, vertical: 6),
      showCheckmark: false,
    ),
    dividerTheme: const DividerThemeData(
      color: Ivy.hairline,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Ivy.inkSoft,
      contentPadding: EdgeInsets.symmetric(horizontal: Ivy.gutter),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Ivy.ink,
      inactiveTrackColor: Ivy.hairline,
      thumbColor: Ivy.ink,
      overlayColor: Colors.transparent,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Ivy.surface : Ivy.surface),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Ivy.ink : Ivy.hairline),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Ivy.ink,
      linearTrackColor: Ivy.hairline,
      circularTrackColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: IvyPageTransition(),
        TargetPlatform.iOS: IvyPageTransition(),
      },
    ),
  );
}
