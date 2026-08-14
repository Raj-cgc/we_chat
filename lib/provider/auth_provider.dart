import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';

class AutProvider extends ChangeNotifier {
  static final GoogleSignIn googleSignInn = GoogleSignIn.instance;

  static bool isInitialized = false;

  static Future<void> _initSignin() async {
    if (!isInitialized) {
      final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'] ??
          "486705346592-3805ck018lr1m5vb4u40qb29uv1e5663.apps.googleusercontent.com";
      if (kIsWeb) {
        await googleSignInn.initialize(
          clientId: webClientId,
        );
      } else {
        await googleSignInn.initialize(
          serverClientId: webClientId,
          clientId: webClientId,
        );
      }
      isInitialized = true;
    }
  }

  //for signin
  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await APIs.auth.signInWithPopup(googleProvider);
      }

      await _initSignin();

      final GoogleSignInAccount? account = await googleSignInn.authenticate();

      if (account == null) {
        return null;
      }

      final idToken = account.authentication.idToken;
      final authClient = account.authorizationClient;

      final auth =
          await authClient.authorizationForScopes(['email', 'profile']);
      final accessToken = auth?.accessToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (context.mounted) {
        Dialogs.showSnackbar(context, 'Login Error: ${e.toString()}');
      }
      return null;
    }
  }

  //for signout
  static Future<void> signOut() async {
    await googleSignInn.signOut();
    await APIs.auth.signOut();
  }
}
