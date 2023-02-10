import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoMenu {
  static const Color color = Color(0xFF191919);

  static Future show(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: color,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 8, left: 16, right: 16),
            child: DefaultTextStyle(style: GoogleFonts.poppins(), child: child),
          ),
        );
      },
    );
  }
}
