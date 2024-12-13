import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:memory_card_game_dinosaur/model/image_assets.dart';
import 'package:memory_card_game_dinosaur/utils/exit_game_dialog.dart';
import 'package:memory_card_game_dinosaur/widget/background_widget.dart';
import 'package:memory_card_game_dinosaur/widget/button_widget.dart';
import 'package:memory_card_game_dinosaur/widget/expanded_widget.dart';
import 'package:memory_card_game_dinosaur/widget/scoreprogressindicator_widget.dart';
import 'package:memory_card_game_dinosaur/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.gameMode});

  final String gameMode;

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
  int totalTime = 60;

  @override
  void initState() {
    super.initState();
    if (widget.gameMode == "Easy") {
      totalTime = 60;
    } else if (widget.gameMode == "Hard") {
      totalTime = 40;
    }
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
    timeLeft = totalTime;
    _timeValue = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            _timeValue.cancel();
            _saveGameHistory();
            _messageDialog("Game Lose!", "Good Luck Next Time");
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
          title: TextWidget(
              text: titleMessage,
              color: Colors.black,
              fontsize: 28.sp,
              fontweight: true),
          content: TextWidget(
              text: message,
              color: Colors.black,
              fontsize: 23.sp,
              fontweight: false),
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
                  fontSize: 20.sp,
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
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            duplicatedImages[flippedIndexes[0]] = "";
            duplicatedImages[flippedIndexes[1]] = "";
            flippedIndexes.clear();
            score += 5;
            isProcessing = false;
            _updateProgress();

            if (_checkCardMatched()) {
              _saveGameHistory();
              _shakeController.forward().then((_) {
                _shakeController.reset();
                _messageDialog("Game Win!", "you matched all the card!!!");
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
    gameHistory.add('TimePlay: $currentDateTime, Game Score: $score, $message');
    await prefs.setStringList('gameHistory', gameHistory);
  }

  Future<void> _loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? gameHistory = prefs.getStringList('gameHistory');

    if (gameHistory != null && gameHistory.isNotEmpty) {
      String allGameRecords = gameHistory.join('\n');
      _showHistoryDialog(allGameRecords);
    } else {
      return;
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
              TextWidget(
                  text: "Game History",
                  color: Colors.black,
                  fontsize: 28.sp,
                  fontweight: true),
              IconButton(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 40,
                ),
                onPressed: () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: TextWidget(
                            text: "Clear History",
                            color: Colors.black,
                            fontsize: 28.sp,
                            fontweight: true),
                        content: TextWidget(
                            text:
                                "Are you sure you want to remove all game history?",
                            color: Colors.black,
                            fontsize: 17.sp,
                            fontweight: false),
                        actions: const [
                          CustomButtonWidget(text: "Close", onRemove: false),
                          CustomButtonWidget(text: "Confirm", onRemove: true)
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('gameHistory');
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            // ignore: sized_box_for_whitespace
            child: Container(
                width: double.maxFinite,
                child: TextWidget(
                    text: allGameRecords,
                    color: Colors.black,
                    fontsize: 15.sp,
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6d3e00),
        title: TextWidget(
            text: "Jurassic Pairs Dino",
            color: Colors.white,
            fontsize: 28.sp,
            fontweight: true),
      ),
      body: Stack(
        children: [
          const BackgroundWidget(),
          buildScoreBoard(),
          buildTimer(),
          buildTheMemoryCard()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6d3e00),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            _loadGameHistory();
          } else if (index == 1) {
            showExitGameDialog(context);
          }
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color: Colors.white,
              size: 30,
            ),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 30,
            ),
            label: "Exit",
          ),
        ],
      ),
    );
  }

  Widget buildScoreBoard() {
    return Container(
      color: const Color(0xFF6d3e00),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ExpandedWidget(
                    text: "Game Win : $score",
                    color: Colors.white,
                    fontSize: 19.sp,
                    fontWeight: true),
                ExpandedWidget(
                    text: "Mode : ${widget.gameMode}",
                    color: Colors.white,
                    fontSize: 19.sp,
                    fontWeight: true),
                ExpandedWidget(
                    text:
                        "Card Left : ${duplicatedImages.where((img) => img.isNotEmpty).length ~/ 2}",
                    color: Colors.white,
                    fontSize: 19.sp,
                    fontWeight: true)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimer() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: ScoreProgressIndicator(
              totalTime: totalTime,
              timeLeft: timeLeft,
            ),
          ),
          TextWidget(
              text: "$timeLeft",
              color: Colors.white,
              fontsize: 24,
              fontweight: true)
        ],
      ),
    );
  }

  Widget buildTheMemoryCard() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final centerY = constraints.maxHeight / 2;
          const radius = 150.0;

          return Stack(
            children: List.generate(duplicatedImages.length, (index) {
              final angle = (2 * pi / duplicatedImages.length) * index;
              return Positioned(
                left: centerX + radius * cos(angle) - 50,
                top: centerY + radius * sin(angle) - 70,
                child: GestureDetector(
                  onTap: () {
                    if (!revealedImages[index]) {
                      _flipImage(index);
                    }
                  },
                  child: SizedBox(
                    width: 100,
                    height: 140,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: revealedImages[index]
                          ? (duplicatedImages[index].isNotEmpty
                              ? Image.asset(
                                  duplicatedImages[index],
                                  key: ValueKey(revealedImages[index]),
                                )
                              : Container())
                          : Image.asset(
                              ImageAssets.questionMarkImage,
                              key: ValueKey(revealedImages[index]),
                            ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
