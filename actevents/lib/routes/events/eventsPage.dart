import 'dart:developer';

import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/events/eventsdetailPage.dart';
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

  double _distance = 50;
  Position _data;
  Future<List<Actevent>> _events;
  bool _filterOptionsExpanded = false;

  ApiService apiService = ApiService();

  @override
  void initState() {
    _loadAsync();
    _events = _fetchData();
  }

  void _loadAsync() async {
    var data = await widget.location.getLocation();
    setState(() {
      _data = data;
    });
  }

  void _sliderChanged(double newValue) {
    setState(() {
      _distance = newValue;
    });
  }

  Widget _eventList() {
    return Container(
        child: FutureBuilder<List<Actevent>>(
            future: _events,
            builder:
                (BuildContext context, AsyncSnapshot<List<Actevent>> snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                return _displayEventList(snapshot.data);
              } else if (snapshot.hasError) {
                return Text("Fehler beim Abrufen der Daten.");
              } else {
                return Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Text(
                      "Daten werden geladen...",
                      style: TextStyle(color: Colors.grey),
                    ));
              }
            }));
  }

  Future<List<Actevent>> _fetchData() async {
    Position pos = await widget.location.getLocation();
    String latitude = pos.latitude.toString();
    String longitude = pos.longitude.toString();
    print("Getting events for $latitude, $longitude and $_distance");
    return await apiService.getEventsInArea(
        latitude, longitude, _distance.round());
    // return await apiService.getLocalTestList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _events = _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_filterOptionsPanel(), Expanded(child: _eventList())],
    );
  }

  Widget _displayEventList(List<Actevent> list) {
    // TODO: implement way to refresh page when no events are found with current filter options
    if (list.length == 0)
      return Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Text(
            "Keine Events für deinen Standort gefunden.",
            style: TextStyle(color: Colors.grey),
          ));

    List<Widget> children = [];

    list.forEach((event) {
      Widget item = _listItem(event);
      children.add(item);
    });

    return RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: children,
        ),
        onRefresh: _handleRefresh);
  }

  Widget _listItem(Actevent event) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.pin_drop_outlined),
        title: Text(event.name),
        subtitle: Text("Position: " +
            event.latitude +
            ", " +
            event.longitude +
            " / Abstand: " +
            event.distance.round().toString() +
            "km"),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (c) {
            return EventsDetailPage(event: event);
          }));
        },
      ),
    );
  }

  Widget _filterOptionsPanel() {
    const double containerPadding = 10;

    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) => {
        setState(() {
          _filterOptionsExpanded = !isExpanded;
        })
      },
      children: [
        ExpansionPanel(
            isExpanded: _filterOptionsExpanded,
            headerBuilder: (context, isExpanded) {
              return ListTile(
                title: Text("Filteroptionen"),
              );
            },
            body: Container(
              padding: const EdgeInsets.all(containerPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width -
                                containerPadding * 2) /
                            3,
                        child: Text(
                          "Umkreis",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width -
                                containerPadding * 2) *
                            2 /
                            3,
                        child: Slider(
                            value: _distance,
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: _distance.round().toString() + " km",
                            onChanged: _sliderChanged),
                      )
                    ],
                  ),
                ],
              ),
            ))
      ],
    );
  }
}
