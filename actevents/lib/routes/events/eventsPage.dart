import 'dart:developer';

import 'package:actevents/models/actevent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:geolocator/geolocator.dart';

class EventsPage extends StatefulWidget {
  EventsPage({this.location});

  final LocationService location;
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  //TODO: check save statemanagement when navigating from widget

  double _distance = 10;
  Position _data;

  ApiService apiService = ApiService();

  List<Actevent> fetchedEvents = [];

  void loadEvents() async {
    print("Longitude: " +
        _data.longitude.toString() +
        "\nLatitude: " +
        _data.latitude.toString());
    fetchedEvents = await apiService.getEventsInArea(_data.longitude.toString(),
        _data.latitude.toString(), this._distance.round());
    // for (var item in fetchedEvents) {
    //   log(item.toString());
    // }
    //fetchedEvents = await apiService.getEventsInArea(_data.longitude.toString(),
    //    _data.latitude.toString(), this._distance.round());
  }

  @override
  void initState() {
    _loadAsync();
  }

  void _loadAsync() async {
    var data = await widget.location.getLocation();
    setState(() {
      _data = data;
    });
  }

  void sliderChanged(double newValue) {
    setState(() {
      _distance = newValue;
    });
  }

  Widget eventList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder<List<Actevent>>(
            future: fetchData(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Actevent>> snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                return displayEventList(snapshot.data);
              } else if (snapshot.hasError) {
                return Text("Fehler beim Abrufen der Daten.");
              } else {
                return Text("Keine Daten geladen.");
              }
            })
      ],
    );
  }

  Future<List<Actevent>> fetchData() async {
    //Position pos = await widget.location.getLocation();
    //return await apiService.getEventsInArea(
    //    pos.longitude.toString(), pos.latitude.toString(), _distance.round());
    return await apiService.getLocalTestList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [filterOptionsPanel(), eventList()],
    );
  }

  Widget displayEventList(List<Actevent> list) {
    List<Widget> children = [];

    list.forEach((event) {
      Widget item = listItem(event);
      children.add(item);
    });

    return ListView(
      shrinkWrap: true,
      children: children,
    );
  }

  Widget listItem(Actevent event) {
    return ListTile(
      leading: Icon(Icons.pin_drop_outlined),
      title: Text(event.name),
      subtitle: Text("Position: " + event.latitude + ", " + event.longitude),
      onTap: () {
        print("Event tile tapped.");
      },
    );
  }

  Widget filterOptionsPanel() {
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
                onPressed: loadEvents, child: Text("Events mit Filter laden"))
          ],
        )
      ],
    );
  }
}
