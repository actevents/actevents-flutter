import 'package:actevents/routes/user/loginPage.dart';
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

  initState() {
    super.initState();
    authStatus = AuthStatus.notSignedIn;
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
          title: 'Flutter Login',
          auth: widget.auth,
          onSignIn: () => _updateAuthStatus(AuthStatus.signedIn),
        );
      case AuthStatus.signedIn:
        return new HomePage(
          auth: widget.auth,
          location: widget.location,
          onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn)
        );
    }
  }
}