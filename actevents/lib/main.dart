import 'package:flutter/material.dart';
import 'profile.dart';
import 'events.dart';
import 'find.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedTabIndex = 0;

  List _pages = [
    Events(),
    Find(),
    Profile(),
  ];

  _changeIndex(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Actevents"), backgroundColor: Colors.lightBlue[900]),
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
