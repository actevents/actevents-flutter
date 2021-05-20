import 'package:actevents/services/auth.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage({this.auth, this.onSingout}) {}
  final VoidCallback onSingout;
  final BaseAuth auth;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthUser>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Container(
                child: Text(
                  "Benutzerdaten:",
                  textScaleFactor: 2,
                ),
                margin: EdgeInsets.all(10),
              ),
              Container(
                child: Row(
                  children: [
                    Container(
                        child: Text("Benutzername:"),
                        margin: EdgeInsets.all(10)),
                    Container(child: Text(snapshot.data.username)),
                  ],
                ),
                margin: EdgeInsets.all(10),
              ),
              Container(
                  child: new TextButton(
                      onPressed: _signOut,
                      child: new Text('Logout',
                          style: new TextStyle(
                              fontSize: 17.0)),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white70)),)
                  )
            ],
          );
        }

        if (snapshot.hasError) {
          return Text("Fehler beim Laden deiner Benutzerdaten:(");
        }
        return CircularProgressIndicator();
      },
      future: (() async => widget.auth.currentUser())(),
    );
  }

  
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSingout();
    } catch (e) {
      print(e);
    }
  }
}
