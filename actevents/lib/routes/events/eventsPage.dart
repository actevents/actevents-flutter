import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  //TODO: check save statemanagement when navigating from widget
  int count = 0;
  @override
  Widget build(BuildContext context) {
    setState(() {
      count++;
    });
    return Text("My Events from widget " + count.toString());
  }
}
