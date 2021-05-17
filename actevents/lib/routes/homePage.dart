import 'package:actevents/routes/events/findPage.dart';
import 'package:actevents/routes/user/profilePage.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/auth.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';

import 'events/eventsPage.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignOut, this.location, this.apiService});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final LocationService location;
  final ApiService apiService;
  @override
  _HomePageState createState() =>
      _HomePageState(auth: auth, onSignOut: onSignOut);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({this.auth, this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;

  int _selectedTabIndex = 0;
  List _pages;

  _changeIndex(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _signOut() async {
    try {
      await auth.signOut();
      onSignOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      EventsPage(location: widget.location, apiService: widget.apiService),
      FindPage(location: widget.location),
      ProfilePage(),
    ];

    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new TextButton(
              onPressed: _signOut,
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)))
        ],
      ),
      body: Center(child: _pages[_selectedTabIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _changeIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined), label: "Find"),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border), label: "Events"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined), label: "Profile"),
        ],
      ),
    );
  }
}
