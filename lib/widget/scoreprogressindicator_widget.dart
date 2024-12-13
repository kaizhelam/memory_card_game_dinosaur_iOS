import 'package:flutter/material.dart';

class ScoreProgressIndicator extends StatefulWidget {
  final int totalTime;
  final int timeLeft;

  const ScoreProgressIndicator({super.key, 
    required this.totalTime,
    required this.timeLeft,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ScoreProgressIndicatorState createState() => _ScoreProgressIndicatorState();
}

class _ScoreProgressIndicatorState extends State<ScoreProgressIndicator> {
  late Color progressColor;

  @override
  void initState() {
    super.initState();
    progressColor = _getColorBasedOnTimeLeft(widget.timeLeft);
  }

  @override
  void didUpdateWidget(covariant ScoreProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeLeft != widget.timeLeft) {
      setState(() {
        progressColor = _getColorBasedOnTimeLeft(widget.timeLeft);
      });
    }
  }

  Color _getColorBasedOnTimeLeft(int timeLeft) {
    if (timeLeft < 15) {
      return Colors.red;
    } else if (timeLeft < 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: widget.totalTime > 0
          ? (widget.timeLeft / widget.totalTime).clamp(0.0, 1.0)
          : 0.0,
      color: progressColor,
      strokeWidth: 10.0,
    );
  }
}