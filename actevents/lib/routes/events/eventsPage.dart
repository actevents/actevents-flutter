import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class EventsPage extends StatefulWidget {

  EventsPage({this.location});

  final LocationService location;
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  //TODO: check save statemanagement when navigating from widget
  LocationData _data;
  int count = 0;
@override
  void initState() { 
    setState(() async {
      _data = await widget.location.getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text("My Events from widget " + _data?.toString() ?? "");
  }
}
