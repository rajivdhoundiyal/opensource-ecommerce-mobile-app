import 'package:bagisto_app_demo/screens/sign_in/utils/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialLoginService {
  
  Future<SignInModel?> doLogin(String? platform) async {
    if(platform == 'FACEBOOK') {
      return await FacebookAuthService().login();
    } else {
      return await GoogleAuthService().signInWithGoogle();
    }
  }

  void doLogout() {
    FacebookAuthService().logout();
    GoogleAuthService().signOut();
  }
}

class FacebookAuthService {
  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      // now you can call to  FacebookAuth.instance.getUserData();
      await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      accessToken;
      
    }
  }

  Future<SignInModel?> login() async {
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
      SignInModel success = SignInModel(token: result.accessToken?.tokenString, 
          data: Data(name: userData['name'], email: userData['email'], id: userData['id']));
      success.status = true;
      return success;
    } else {
      print(result.status);
      print(result.message);
      throw Exception("Failed to verify facebook user autj");
    }

  }

  void _printCredentials() {
    
  }


  void logout() async {
    await FacebookAuth.instance.logOut();
  }
}

/// Service class to handle Firebase + Google authentication
class GoogleAuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in user using Google and authenticate with Firebase
  Future<SignInModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the login
      if (googleUser == null) return null;

      // Get authentication tokens from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      SignInModel success = SignInModel(token: googleAuth.idToken, 
          data: Data(firstName:  "", lastName: "", name: "", email: "", id: ""));
      success.status = true;
      return success;
    } catch (e) {

      // Handle sign-in errors
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}   