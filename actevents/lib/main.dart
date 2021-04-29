import 'package:actevents/routes/rootPage.dart';
import 'package:actevents/services/auth.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Login',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new AmplifyAuth()),
    );
  }
}


