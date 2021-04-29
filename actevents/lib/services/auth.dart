import 'dart:collection';
import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'amplifyconfiguration.dart';

abstract class BaseAuth {
  Future<void> configureAmplify();
  Future<AuthUser> currentUser();
  Future<bool> signIn(String email, String password);
  Future<bool> createUser(String email, String password);
  Future<void> signOut();
}

class AmplifyAuth implements BaseAuth {
  String _uploadFileResult = '';
  String _getUrlResult = '';
  String _removeResult = '';
  bool isSignedIn = false;

  AmplifyClass amplifyInstance;
  AmplifyAuthCognito authPlugin = AmplifyAuthCognito();

  Future<void> configureAmplify() async {
    if (amplifyInstance != null) {
      return;
    }
    amplifyInstance = new AmplifyClass();
    amplifyInstance.addPlugin(authPlugin);
    await amplifyInstance.configure(amplifyconfig);
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await configureAmplify();
      SignInResult res = await authPlugin.signIn(
          request: SignInRequest(
              password: password,
              username: email,
              options: CognitoSignInOptions()));
    } catch (e) {
      print(e);
      return false;
    }
    isSignedIn = true;
    return true;
  }

  Future<bool> createUser(String email, String password) async {
    try {
      var result = await authPlugin.signUp(
          request: SignUpRequest(
              username: email,
              password: password,
              options: CognitoSignUpOptions(userAttributes: Map<String, String>())));
      if (result.isSignUpComplete) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<AuthUser> currentUser() async {
    return await authPlugin.getCurrentUser();
  }

  Future<void> signOut() async {
    authPlugin.signOut(request: SignOutRequest());
  }
}
