import 'package:bagisto_flutter/features/auth/data/models/auth_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialLoginService {
  
  static Future<CustomerLogin> doLogin(String? platform) async {
    if(platform == 'Facebook') {
      return await FacebookAuthService.login();
    } else {
      return await GoogleAuthService.signInWithGoogle();
    }
  }

  void doLogout() {
    FacebookAuthService.logout();
    GoogleAuthService.signOut();
  }
}

class FacebookAuthService {
  static Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      // now you can call to  FacebookAuth.instance.getUserData();
      await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      accessToken;
      
    }
  }

  static Future<CustomerLogin> login() async {
    final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile

    // loginBehavior is only supported for Android devices, for ios it will be ignored
    // final result = await FacebookAuth.instance.login(
    //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
    //   loginBehavior: LoginBehavior
    //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
    // );

    if (result.status == LoginStatus.success) {
      _printCredentials();
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      return CustomerLogin(token: result.accessToken?.tokenString);
    } else {
      debugPrint(result.status.toString());
      debugPrint(result.message);
    }

    return CustomerLogin(success: false);
  }

  static void _printCredentials() {
    
  }


  static void logout() async {
    await FacebookAuth.instance.logOut();
  }
}

/// Service class to handle Firebase + Google authentication
class GoogleAuthService {

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in user using Google and authenticate with Firebase
  static Future<CustomerLogin> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the login
      if (googleUser == null) return CustomerLogin(success: false);

      // Get authentication tokens from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint("🔵 Google Sign In: accessToken: ${googleAuth.accessToken}, idToken: ${googleAuth.idToken}");
      return CustomerLogin(token: googleAuth.idToken);
    } catch (e) {

      // Handle sign-in errors
      debugPrint("❌ Google Sign-In Error: $e");
      return CustomerLogin(success: false);
    }
  }

  /// Sign out from both Google and Firebase
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}   