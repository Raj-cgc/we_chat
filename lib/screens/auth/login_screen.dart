import "package:flutter/material.dart";
import "package:we_chat/api/apis.dart";
import "package:we_chat/main.dart";
import "package:we_chat/screens/home_screen.dart";
import 'package:we_chat/provider/auth_provider.dart';
import 'package:we_chat/helper/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAnimate = true;
        });
      }
    });
  }

  _handleGoogleBtnClick() async {
    Dialogs.showProgressBar(context);

    final user = await AutProvider.signInWithGoogle(context);

    if (mounted) Navigator.pop(context);

    if (user != null && mounted) {
      if (await APIs.userExists()) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        await APIs.createUser();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E11),
      body: SafeArea(
        child: Stack(
          children: [
            // Background subtle gradient glow & painter
            Positioned.fill(
              child: CustomPaint(
                painter: _DashedPathPainter(),
              ),
            ),

            Positioned(
              top: mq.height * 0.15,
              left: mq.width * 0.2,
              child: Container(
                width: mq.width * 0.6,
                height: mq.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // 1. Centered Hero Content Block
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _isAnimate ? 1.0 : 0.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Icon with subtle glow container
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181920),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "images/icon.png",
                              height: 80,
                              width: 80,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.chat_bubble_rounded,
                                color: Color(0xFF7C3AED),
                                size: 70,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // App Name "We Chat"
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFA78BFA)],
                            ).createShader(bounds),
                            child: const Text(
                              "We Chat",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Hero Title
                          const Text(
                            "Stay Connected,\nYour Way",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Subtitle
                          Text(
                            "Experience seamless conversations like never before.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Bottom "Login with Google" Action Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 6,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _handleGoogleBtnClick,
                        icon: Image.asset(
                          'images/google.png',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.g_mobiledata,
                            color: Color(0xFFEA4335),
                            size: 32,
                          ),
                        ),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.3,
        size.width * 0.1,
        size.height * 0.6,
        size.width * 0.5,
        size.height * 0.8,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
