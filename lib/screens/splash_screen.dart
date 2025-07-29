import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:we_chat/api/apis.dart";
import "package:we_chat/main.dart";
import "package:we_chat/screens/auth/login_screen.dart";
import "package:we_chat/screens/home_screen.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white,
        ),
      );
      //In the 2 seconds duration of splashscreen check these
      // Check if already signed in...if yes..then directly go to homepage

      final user = APIs.auth.currentUser;

      if (user != null) {
        print("User logged in:");
        print("Name: ${user.displayName}");
        print("Email: ${user.email}");
        print("UID: ${user.uid}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        //else go to LoginPage
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to We Chat')),
      body: Stack(
        children: [
          Positioned(
            top: mq.height * 0.15,
            width: mq.width * 0.5,
            right: mq.width * 0.25,
            child: Image.asset("images/icon.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width,
            child: Text(
              "MADE BY RAJ",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
