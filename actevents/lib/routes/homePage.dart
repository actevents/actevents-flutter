import 'package:actevents/routes/events/eventsAddPage.dart';
import 'package:actevents/routes/events/favouritePage.dart';
import 'package:actevents/routes/user/profilePage.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/auth.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';

import 'events/eventsPage.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignOut, this.locationService, this.apiService});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final LocationService locationService;
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

  Widget _getTitleFromIndex(int index) {
    if (index == 0)
      return Text("Finden");
    else if (index == 1)
      return Text("Favoriten");
    else if (index == 2)
      return Text("Profil");
    else
      return Text("");
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      EventsPage(
          locationService: widget.locationService,
          apiService: widget.apiService),
      FavouritePage(
        apiService: widget.apiService,
        locationService: widget.locationService,
      ),
      ProfilePage(auth: auth, onSingout: onSignOut,apiService: widget.apiService),
    ];

    return new Scaffold(
      appBar: new AppBar(title: _getTitleFromIndex(_selectedTabIndex)),
      body: Center(child: _pages[_selectedTabIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _changeIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined), label: "Finden"),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_border_outlined), label: "Favoriten"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined), label: "Profil"),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                  return EventsAddPage(
                      apiService: widget.apiService,
                      loactionService: widget.locationService);
                }));
              },
              child: Text(
                "+",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
              ),
            )
          : null,
    );
  }
}
