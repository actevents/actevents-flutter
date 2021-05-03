import 'package:actevents/models/actevent.dart';
import 'package:flutter/material.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:location/location.dart';

class EventsPage extends StatefulWidget {
  EventsPage({this.location});

  final LocationService location;
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  //TODO: check save statemanagement when navigating from widget

  double _distance = 10;
  LocationData _data;

  ApiService apiService = ApiService();

  List<Actevent> fetchedEvents = [];

  void loadEvents() async {
    fetchedEvents = await apiService.getEventsInArea(_data.longitude.toString(),
        _data.latitude.toString(), this._distance.round());
  }

  void sliderChanged(double newValue) {
    setState(() {
      _distance = newValue;
    });
  }

  @override
  void initState() {
    setState(() async {
      _data = await widget.location.getLocation();
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
        Row(
          children: [
            ElevatedButton(
              onPressed: loadEvents, 
              child: Text("Events laden")
            )
          ],
        )
        Column(
          children: [],
        )
      ],
    );
  }
}
