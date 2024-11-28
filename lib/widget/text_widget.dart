import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.fontsize,
      required this.fontweight});

  final String text;
  final Color color;
  final double fontsize;
  final bool fontweight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.fredoka( color: color,
          fontSize: fontsize,
          fontWeight: fontweight ? FontWeight.bold : FontWeight.normal),
          textAlign: TextAlign.center,
    );
  }
}
