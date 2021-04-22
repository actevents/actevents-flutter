import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
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

  // Amplify amplifyInstance = Amplify();

  void _configureAmplify() async {
    // add all of the plugins we are currently using
    // in our case... just one - Auth
    // AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    // amplifyInstance.addPlugin(authPlugins: [authPlugin]);

    // await amplifyInstance.configure(amplifyconfig);
    _isAmplifyConfigured = true;
  }

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
