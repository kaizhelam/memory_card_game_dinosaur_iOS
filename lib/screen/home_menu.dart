import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_card_game_dinosaur/screen/home_screen.dart';
import 'package:memory_card_game_dinosaur/widget/button_widget.dart';
import 'package:memory_card_game_dinosaur/widget/text_widget.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(
          text: "Dino Memory Quest",
          color: Colors.white,
          fontsize: 28,
          fontweight: true,
        ),
        backgroundColor: const Color(0xFF6d3e00),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74ad1e), Color(0xFF6d3e00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(
                text: "Embark on a Dino Memory Adventure",
                color: Colors.white,
                fontsize: 40.sp,
                fontweight: true,
              ),
              const SizedBox(
                height: 50,
              ),
              MenuButton(
                text: 'Play Now',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              MenuButton(
                text: 'Learn the Rules',
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: TextWidget(
                            text: "Game Rules",
                            color: Colors.black,
                            fontsize: 30.sp,
                            fontweight: true),
                        content: Text(
                          "Welcome to the Memory Card Game! Here are the rules:\n\n"
                          "1. The game consists of face-down cards arranged on the screen.\n"
                          "2. Your goal is to match pairs of cards by flipping them over.\n"
                          "3. You can only flip two cards at a time. If they match, they stay face-up.\n"
                          "4. If they don't match, they flip back over.\n"
                          "5. The game has a time limit of 60 seconds. Complete as many pairs as possible before the time runs out!\n\n"
                          "Good luck, and have fun!",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                        actions: const [
                          CustomButtonWidget(text: "Close", onRemove: false)
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 15),
              MenuButton(
                text: 'Quit Game',
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6d3e00),
        elevation: 10,
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.fredoka(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
