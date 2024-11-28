import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:memory_card_game_dinosaur/model/image_assets.dart';
import 'package:memory_card_game_dinosaur/widget/button_widget.dart';
import 'package:memory_card_game_dinosaur/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<String> duplicatedImages = [];
  late List<bool> revealedImages;
  List<int> flippedIndexes = [];
  bool isProcessing = false;
  int timeLeft = 0;
  int score = 0;
  late Timer _timeValue;
  late AnimationController _shakeController;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startGame();
    _countDownTimer();
  }

  @override
  void dispose() {
    _timeValue.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startGame() {
    duplicatedImages = [...ImageAssets.images, ...ImageAssets.images];
    duplicatedImages.shuffle(Random());
    revealedImages = List.filled(duplicatedImages.length, false);
    progress = 0.0;
    score = 0;
  }

  void _countDownTimer() {
    timeLeft = 60;
    _timeValue = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            _timeValue.cancel();
            _saveGameHistory();
            _messageDialog("Time's Up!", "Better luck next time");
          }
        });
      },
    );
  }

  void _messageDialog(String titleMessage, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(text: titleMessage, color: Colors.black, fontsize: 28, fontweight: true),
          content: TextWidget(text: message, color: Colors.black, fontsize: 23, fontweight: false),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6d3e00),
                elevation: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
                _timeValue.cancel();
                _countDownTimer();
              },
              child: Text(
                "Restart",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _flipImage(int index) {
    if (isProcessing || revealedImages[index]) return;

    setState(() {
      revealedImages[index] = true;
      flippedIndexes.add(index);
    });

    if (flippedIndexes.length == 2) {
      isProcessing = true;
      if (duplicatedImages[flippedIndexes[0]] ==
          duplicatedImages[flippedIndexes[1]]) {
        setState(() {
          score += 10;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            flippedIndexes.clear();
            isProcessing = false;
            _updateProgress();
            if (_checkCardMatched()) {
              _saveGameHistory();
              _shakeController.forward().then((_) {
                _shakeController.reset();
                _messageDialog("You Won!", "you did a great job");
                _timeValue.cancel();
              });
            }
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          setState(() {
            revealedImages[flippedIndexes[0]] = false;
            revealedImages[flippedIndexes[1]] = false;
            flippedIndexes.clear();
            isProcessing = false;
          });
        });
      }
    }
  }

  void _updateProgress() {
    int matchedCards = revealedImages.where((revealed) => revealed).length;
    setState(() {
      progress = matchedCards / duplicatedImages.length;
    });
  }

  bool _checkCardMatched() {
    return !revealedImages.contains(false);
  }

  Future<void> _saveGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String message = "";
    String currentDateTime =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    await prefs.setString('lastGameDate', currentDateTime);
    await prefs.setInt('lastGameScore', score);
    await prefs.setInt('lastGameTimeLeft', timeLeft);

    if (timeLeft > 0) {
      message = "Victory!";
    } else {
      message = "Game Over";
    }
    List<String> gameHistory = prefs.getStringList('gameHistory') ?? [];
    gameHistory.add('DateTime: $currentDateTime, Score: $score, $message');
    await prefs.setStringList('gameHistory', gameHistory);
  }

  Future<void> _loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? gameHistory = prefs.getStringList('gameHistory');

    if (gameHistory != null && gameHistory.isNotEmpty) {
      String allGameRecords = gameHistory.join('\n');
      _showHistoryDialog(allGameRecords);
    } else {
      print("No game history found.");
    }
  }

  void _showHistoryDialog(String allGameRecords) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                  text: "Game History",
                  color: Colors.black,
                  fontsize: 28,
                  fontweight: true),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: TextWidget(
                            text: "Clear History",
                            color: Colors.black,
                            fontsize: 28,
                            fontweight: true),
                        content: TextWidget(
                            text:
                                "Are you sure you want to remove all game history?",
                            color: Colors.black,
                            fontsize: 17,
                            fontweight: false),
                        actions: [
                          CustomButtonWidget(text: "Close", onRemove: false),
                          CustomButtonWidget(text: "Confirm", onRemove: true)
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove(
                        'gameHistory'); // Clear game history from storage
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
                width: double.maxFinite, // Ensures the content doesn't overflow
                child: TextWidget(
                    text: allGameRecords,
                    color: Colors.black,
                    fontsize: 17,
                    fontweight: false)),
          ),
          actions: const [
            CustomButtonWidget(
              text: "Close",
              onRemove: false,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bg.png"), fit: BoxFit.cover),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 120),
            child: TextWidget(
                text: "Dino Farm Memory Rush",
                color: Color(0xFF6d3e00),
                fontsize: 35,
                fontweight: true),
          ),
        ),
        Positioned(
            top: 185,
            right: 28,
            left: 28,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: "Score $score",
                      color: Color(0xFF6d3e00),
                      fontsize: 32,
                      fontweight: true,
                    ),
                    TextWidget(
                      text: "Time $timeLeft",
                      color: const Color(0xFF6d3e00),
                      fontsize: 32,
                      fontweight: true,
                    )
                  ],
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                          value: value,
                          minHeight: 15,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(const Color(0xFF74ad1e),
                                const Color(0xFF74ad1e), value)!,
                          ),
                          backgroundColor: const Color(0xFFe0e0e0)),
                    );
                  },
                ),
              ],
            )),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 120, right: MediaQuery.of(context).size.width > 800 ? 150 : 0, left: MediaQuery.of(context).size.width > 800 ? 150 : 0),
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final double shakeOffset =
                      sin(_shakeController.value * 20) * 10;
                  return Transform.translate(
                    offset: Offset(shakeOffset, 0),
                    child: child,
                  );
                },
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    duplicatedImages.length,
                    (index) => GestureDetector(
                      onTap: () {
                        if (!revealedImages[index]) {
                          _flipImage(index);
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width > 800 ? 150 : 110,
                        height: MediaQuery.of(context).size.width > 800 ? 150 : 110,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            final flipAnimation =
                                Tween(begin: pi, end: 0.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                            );

                            return AnimatedBuilder(
                              animation: flipAnimation,
                              builder: (context, child) {
                                final isFlipped = animation.value > 0.5;
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(isFlipped
                                        ? pi - flipAnimation.value
                                        : flipAnimation.value),
                                  child: Material(
                                    elevation: isFlipped ? 4.0 : 2.0,
                                    shadowColor: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                    child: child,
                                  ),
                                );
                              },
                              child: child,
                            );
                          },
                          child: revealedImages[index]
                              ? Image.asset(
                                  duplicatedImages[index],
                                  key: ValueKey<bool>(revealedImages[index]),
                                )
                              : Image.asset(
                                  ImageAssets.questionMarkImage,
                                  key: ValueKey<bool>(revealedImages[index]),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          child: FloatingActionButton(
            onPressed: () {
              _loadGameHistory();
            },
            backgroundColor: const Color(0xFF6d3e00),
            child: const Icon(
              Icons.history,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}
