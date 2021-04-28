import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'amplifyconfiguration.dart';

abstract class BaseAuth {
  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String email, String password);
  Future<void> signOut();
}

class AmplifyAuth implements BaseAuth {
  bool _isAmplifyConfigured = false;
  String _uploadFileResult = '';
  String _getUrlResult = '';
  String _removeResult = '';

  AmplifyClass amplifyInstance = new AmplifyClass();

  void _configureAmplify() async {
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    await amplifyInstance.configure(amplifyconfig);
    _isAmplifyConfigured = true;
  }

  //  Future<String> _registerUser(LoginData data) async {
  //   try {
  //     Map<String, dynamic> userAttributes = {
  //       "email": emailController.text,
  //     };
  //     SignUpResult res = await Amplify.Auth.signUp(
  //         username: data.name,
  //         password: data.password,
  //         options: CognitoSignUpOptions(userAttributes: userAttributes));
  //     setState(() {
  //       isSignUpComplete = res.isSignUpComplete;
  //       print("Sign up: " + (isSignUpComplete ? "Complete" : "Not Complete"));
  //     });
  //   } on AuthError catch (e) {
  //     print(e);
  //     return "Register Error: " + e.toString();
  //   }
  // }

  // Future<String> _signIn(LoginData data) async {
  //   try {
  //     SignInResult res = await Amplify.Auth.signIn(
  //       username: data.name,
  //       password: data.password,
  //     );
  //     setState(() {
  //       isSignedIn = res.isSignedIn;
  //     });

  //     if (isSignedIn)
  //       Alert(context: context, type: AlertType.success, title: "Login Success")
  //           .show();
  //   } on AuthError catch (e) {
  //     print(e);
  //     Alert(context: context, type: AlertType.error, title: "Login Failed")
  //         .show();
  //     return 'Log In Error: ' + e.toString();
  //   }
  // }


  Future<String> signIn(String email, String password) async {
    // Amplify.addPlugin(AmplifyAuthCognito());
    return "Test";
  }

  Future<String> createUser(String email, String password) async {
    return "Test";
  }

  Future<String> currentUser() async {
    return "Test";
  }

  Future<void> signOut() async {}
}
