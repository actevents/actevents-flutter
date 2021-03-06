import 'dart:collection';
import 'dart:developer';
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
  Future<String> getIdToken();
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
    try {
      await amplifyInstance.configure(amplifyconfig);
    } catch (e) {
      log(e);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await configureAmplify();
      SignInResult res = await authPlugin.signIn(
          request: SignInRequest(password: password, username: email.trim()));
      isSignedIn = res.isSignedIn;
      return isSignedIn;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> getIdToken() async {
    try {
      CognitoAuthSession res = await Amplify.Auth.fetchAuthSession(
        options: CognitoSessionOptions(getAWSCredentials: true)
      );
      return res.userPoolTokens.idToken;
    } catch (e) {
      return "";
    }
  }

  Future<bool> createUser(String email, String password) async {
    try {
      await configureAmplify();
      var result = await authPlugin.signUp(
          request: SignUpRequest(
              username: email,
              password: password,
              options:
                  CognitoSignUpOptions(userAttributes: Map<String, String>())));
      if (result.isSignUpComplete) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<AuthUser> currentUser() async {
    try {
      configureAmplify();
    } catch (e) {
    }
    return await authPlugin.getCurrentUser();
  }

  Future<void> signOut() async {
    authPlugin.signOut(request: SignOutRequest());
  }
}
