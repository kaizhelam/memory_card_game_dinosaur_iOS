import 'package:flutter/material.dart';
import 'package:memory_card_game_dinosaur/widget/text_widget.dart';

class ExpandedWidget extends StatelessWidget {
  const ExpandedWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.fontSize,
      required this.fontWeight});

  final String text;
  final Color color;
  final double fontSize;
  final bool fontWeight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: const Color(0xFFFBB040),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: TextWidget(
            text: text,
            color: color,
            fontsize: fontSize,
            fontweight: fontWeight,
          ),
        ),
      ),
    );
  }
}
