import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        labelMedium: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get monoSmall => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );
}
