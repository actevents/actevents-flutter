import 'package:flutter/material.dart';

class Events extends StatefulWidget {
  @override
  _Events createState() => _Events();
}


class _Events extends State<Events> {

  //TODO: check save statemanagement when navigating from widget
  int count=0;
  @override
  Widget build(BuildContext context) {
    count++;
    return Text("My Events from widget" + count.toString());
  }
}