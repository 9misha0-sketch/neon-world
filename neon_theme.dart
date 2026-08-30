import 'package:flutter/material.dart';

class NeonTheme {
  static const bg = Color(0xFF070816);
  static const panel = Color(0xFF111329);
  static const panel2 = Color(0xFF171A35);
  static const purple = Color(0xFF8B5CFF);
  static const blue = Color(0xFF22D3EE);
  static const pink = Color(0xFFFF4FD8);
  static const success = Color(0xFF42F5A7);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.dark,
      surface: panel,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme.copyWith(primary: purple, secondary: blue, tertiary: pink),
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel2.withValues(alpha: .78),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withValues(alpha: .08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: blue, width: 1.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0D0F20),
        indicatorColor: purple.withValues(alpha: .22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected) ? Colors.white : Colors.white60,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        )),
      ),
    );
  }
}

class NeonPanel extends StatelessWidget {
  const NeonPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: NeonTheme.panel.withValues(alpha: .90),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
      boxShadow: [BoxShadow(color: NeonTheme.purple.withValues(alpha: .10), blurRadius: 28, spreadRadius: 1)],
    ),
    child: child,
  );
}

class NeonLogo extends StatelessWidget {
  const NeonLogo({super.key, this.size = 84});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(colors: [NeonTheme.purple, NeonTheme.blue, NeonTheme.pink], begin: Alignment.topLeft, end: Alignment.bottomRight),
      boxShadow: [BoxShadow(color: NeonTheme.purple.withValues(alpha: .45), blurRadius: 34, spreadRadius: 3)],
    ),
    child: Icon(Icons.videocam_rounded, size: size * .48, color: Colors.white),
  );
}
