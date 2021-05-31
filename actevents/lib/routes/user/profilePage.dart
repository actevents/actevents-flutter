import 'package:actevents/models/actevent.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/auth.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.auth, this.onSingout, this.apiService}) {}
  final VoidCallback onSingout;
  final BaseAuth auth;
  final ApiService apiService;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool refresh = false;

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
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0)),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white70)),
              )),
              Container(
                  child: Column(
                children: [
                  Container(
                    child: Text(
                      "Meine Events:",
                      textScaleFactor: 2,
                    ),
                    margin: EdgeInsets.all(10),
                  ),
                  FutureBuilder<List<Actevent>>(
                      builder: (c, s) {
                        if (s.hasError) {
                          return Text(
                              "Leider ist beim laden deiner Events etwas schief gegangen.:(");
                        }
                        if (s.hasData) {
                          List<Widget> widgets = <Widget>[];
                          for (var event in s.data) {
                            widgets.add(Card(
                                child: ListTile(
                                    leading: Icon(Icons.pin_drop_outlined),
                                    trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteFavourite(event)),
                                    title: Text(event.name))));
                          }
                          return Column(children: widgets);
                        }
                        return CircularProgressIndicator();
                      },
                      future: (() => this.widget.apiService.getOwnEvents())())
                ],
              ))
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

  Future<void> _deleteFavourite(Actevent event) async {
    try {
      await widget.apiService.deleteOwnEvent(event);
      setState(() {
        refresh = !refresh;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Das Event konnte aufgrund eines Fehlers nicht aus deinen Favoriten gelöscht werden. Versuche es später erneut.")));
      print(e);
    }
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
