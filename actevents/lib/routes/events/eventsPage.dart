import 'package:actevents/models/actevent.dart';
import 'package:flutter/material.dart';
import 'package:actevents/services/apiService.dart';
import 'package:flutter/rendering.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  //TODO: check save statemanagement when navigating from widget

  double _distance = 10;

  ApiService apiService = ApiService();

  List<Actevent> fetchedEvents = [];

  void loadEvents() async {
    // get location and distance from location service
    String longitude = "8.639580";
    String latitude = "48.357393";
    fetchedEvents = await apiService.getEventsInArea(
        longitude, latitude, this._distance.round());
  }

  void sliderChanged(double newValue) {
    setState(() {
      _distance = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Umkreis"),
          ],
        ),
        Row(
          children: [
            Slider(
                value: _distance,
                min: 10,
                max: 100,
                divisions: 9,
                label: _distance.round().toString() + " km",
                onChanged: sliderChanged)
          ],
        ),
        Column(
          children: [],
        )
      ],
    );
  }
}
