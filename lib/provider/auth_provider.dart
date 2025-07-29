import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';

class AutProvider extends ChangeNotifier {
  static final GoogleSignIn googleSignInn = GoogleSignIn.instance;

  static bool isInitialized = false;

  static Future<void> _initSignin() async {
    if (!isInitialized) {
      await googleSignInn.initialize(
        serverClientId:
            "486705346592-3805ck018lr1m5vb4u40qb29uv1e5663.apps.googleusercontent.com",
      );
    }
    isInitialized = true;
  }

  //for signin
  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      _initSignin();

      final GoogleSignInAccount account = await googleSignInn.authenticate();

      // ignore: unnecessary_null_comparison
      if (account == null) {
        throw FirebaseAuthException(
          code: 'SIGNIN ABORTED BY USER',
          message: 'Signin Incomplete',
        );
      }

      final idToken = account.authentication.idToken;
      final authClient = account.authorizationClient;

      GoogleSignInClientAuthorization? auth = await authClient
          .authorizationForScopes(['email', 'profile']);

      final accessToken = auth?.accessToken;

      if (accessToken == null) {
        final auth2 = await authClient.authorizationForScopes([
          'email',
          'profile',
        ]);

        if (auth2?.accessToken == null) {
          throw FirebaseAuthException(
            code: 'No Access Token',
            message: 'Fail to Retrive google access token',
          );
        }
        auth = auth2;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print(e);
      Dialogs.showSnackbar(context, 'Something went wrong ...Check Internet');
      return null;
    }
  }

  //for signout
  static Future<void> signOut() async {
    await googleSignInn.signOut();
    await APIs.auth.signOut();
  }
}
