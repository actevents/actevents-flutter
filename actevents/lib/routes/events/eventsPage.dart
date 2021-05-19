import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/events/eventsDetailPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as LatLng;

class EventsPage extends StatefulWidget {
  EventsPage({this.location, this.apiService});

  final ApiService apiService;
  final LocationService location;
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  double _distance = 50;
  Position _data;
  Future<List<Actevent>> _events;
  List<Marker> _markers;
  bool _filterOptionsExpanded = false;

  @override
  void initState() {
    _markers = [];
    _loadAsync();
    _events = _fetchData();
    _events.then((value) => _mapMarkers(value));
  }

  void _mapMarkers(List<Actevent> acteventList) {
    _markers = [];
    acteventList.forEach((actevent) {
      _markers.add(Marker(
          width: 150.0,
          height: 150.0,
          point: LatLng.LatLng(double.parse(actevent.latitude),
              double.parse(actevent.longitude)),
          builder: (ctx) {
            return GestureDetector(
              child: Icon(
                Icons.location_on,
                color: Colors.red[700],
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                  return EventsDetailPage(
                      eventId: actevent.id,
                      apiService: widget.apiService,
                      location: _data);
                }));
              },
            );
          }));
    });
  }

  void _loadAsync() async {
    var data = await widget.location.getLocation();
    setState(() {
      _data = data;
    });
  }

  void _sliderChanged(double sliderValue) {
    setState(() {
      _distance = sliderValue;
    });
  }

  Widget _mapElement() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: FlutterMap(
          options: MapOptions(
              zoom: 10.0,
              center: LatLng.LatLng(_data.latitude, _data.longitude)),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            MarkerLayerOptions(markers: _markers)
          ],
        ));
  }

  Widget _eventList() {
    return Container(
        child: FutureBuilder<List<Actevent>>(
            future: _events,
            builder:
                (BuildContext context, AsyncSnapshot<List<Actevent>> snapshot) {
              if (snapshot.hasData) {
                return _displayEventList(snapshot.data);
              } else if (snapshot.hasError) {
                return _statusTextWithReloadOption(
                    "Fehler beim Abrufen der Daten");
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

  Widget _statusTextWithReloadOption(String statusText) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Text(
              statusText,
              style: TextStyle(color: Colors.grey),
            )),
        OutlinedButton(
            onPressed: _handleRefresh,
            child: Text(
              "Neu laden",
            ))
      ],
    );
  }

  Future<List<Actevent>> _fetchData() async {
    Position pos = await widget.location.getLocation();
    String latitude = pos.latitude.toString();
    String longitude = pos.longitude.toString();
    print("Getting events for $latitude, $longitude and $_distance");
    return await widget.apiService
        .getEventsInArea(latitude, longitude, _distance.round());
    // return await apiService.getLocalTestList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _events = _fetchData();
      _events.then((list) => _mapMarkers(list));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _filterOptionsPanel(),
        _mapElement(),
        Expanded(child: _eventList())
      ],
    );
  }

  Widget _displayEventList(List<Actevent> list) {
    // TODO: implement way to refresh page when no events are found with current filter options
    if (list.length == 0)
      return _statusTextWithReloadOption(
          "Keine Events für deinen Standort gefunden.");

    List<Widget> children = [];

    for (var event in list) {
      Widget item = _listItem(event);
      children.add(item);
    }

    return RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: children,
        ),
        onRefresh: _handleRefresh);
  }

  Widget _listItem(Actevent event) {
    // TODO: get address here from locationService.convert...
    return Card(
      child: ListTile(
        leading: Icon(Icons.pin_drop_outlined),
        title: Text(event.name),
        subtitle: Text("Abstand zur derzeitigen Position " +
            event.distance.round().toString() +
            "km"),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (c) {
            return EventsDetailPage(
                eventId: event.id,
                apiService: widget.apiService,
                location: _data);
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
