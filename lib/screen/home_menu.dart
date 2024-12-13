import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_card_game_dinosaur/screen/home_screen.dart';
import 'package:memory_card_game_dinosaur/widget/button_widget.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  String selectedMode = "Easy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
        child: AppBar(
          backgroundColor: const Color(0xFF6d3e00),
          title: Center(
            child: Text(
              "Jurassic Pairs Dino",
              style: GoogleFonts.fredoka(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50.h),
              child: Text(
                'Welcome to Jurassic Pairs',
                style: GoogleFonts.fredoka(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                padding: EdgeInsets.all(20.w),
                children: [
                  _buildMenuCard(
                    title: 'Game Mode',
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBB040),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: DropdownButton<String>(
                          value: selectedMode,
                          iconDisabledColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          dropdownColor: const Color(0xFFFBB040),
                          items: ["Easy", "Hard"].map((String mode) {
                            return DropdownMenuItem<String>(
                              value: mode,
                              child: Text(
                                mode,
                                style: GoogleFonts.fredoka(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newMode) {
                            setState(() {
                              selectedMode = newMode!;
                            });
                          },
                          underline: Container(),
                        ),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    title: 'Start Game',
                    child: ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return HomeScreen(gameMode: selectedMode);
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var offsetAnimation = animation.drive(
                                  Tween(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero,
                                  ).chain(
                                      CurveTween(curve: Curves.easeInOutCubic)),
                                );
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const CustomIconWidget(
                          icon: Icons.games,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                  _buildMenuCard(
                    title: 'Game Rules',
                    child: ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  "Game Rules",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  "1. Match pairs of cards by flipping them.\n"
                                  "2. Flip two cards at a time.\n"
                                  "3. Easy Mode: 60s, Hard Mode: 40s.\n"
                                  "4. Have fun!",
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                                actions: [
                                  TextButton(
                                    child: const CustomButtonWidget(
                                        text: "Close", onRemove: true),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const CustomIconWidget(
                          icon: Icons.info,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                  _buildMenuCard(
                    title: 'Exit',
                    child: ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () => exit(0),
                        child: const CustomIconWidget(
                          icon: Icons.exit_to_app,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      color: const Color(0xFF6d3e00).withOpacity(1),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFBB040),
      elevation: 10,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}

class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const CustomIconWidget({super.key, 
    required this.icon,
    this.size = 30.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}
