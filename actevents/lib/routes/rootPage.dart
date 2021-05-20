import 'dart:developer';

import 'package:actevents/routes/user/loginPage.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/auth.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';

import 'homePage.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth, this.location}) : super(key: key);
  final BaseAuth auth;
  final LocationService location;
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  ApiService _apiService;
  initState() {
    super.initState();
    checkLogin();
    authStatus = AuthStatus.notSignedIn;
  }

  void checkLogin() async {
    try {
      var result = await widget.auth.currentUser();
      var token = await widget.auth.getIdToken();
      _apiService = ApiService(idToken: token);
      setState(() {
        authStatus = AuthStatus.signedIn;
      });
    } catch (e) {
      log(e);
      setState(() {
        authStatus = AuthStatus.notSignedIn;
      });
    }
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          title: 'Actevents Login',
          auth: widget.auth,
          onSignIn: () => _updateAuthStatus(AuthStatus.signedIn),
        );
      case AuthStatus.signedIn:
        return new HomePage(
            auth: widget.auth,
            locationService: widget.location,
            apiService: _apiService,
            onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn));
    }
  }
}
