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

    // Animate the logo
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() async {
    //to show progress bar
    Dialogs.showProgressBar(context);
    await AutProvider.signInWithGoogle(context).then((user) async {
      //to hid progress bar
      Navigator.pop(context);

      if (user != null) {
        print(user.user);

        if (await APIs.userExists()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to We Chat')),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            width: mq.width * 0.5,
            right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
            duration: Duration(milliseconds: 700),
            child: Image.asset("images/icon.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 182, 212, 144),
              ),
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset("images/google.png", height: 45),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 19),
                  children: [
                    TextSpan(text: 'Login with '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
