import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/events/eventsDetailPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as LatLng;

class EventsPage extends StatefulWidget {
  EventsPage({this.locationService, this.apiService});

  final ApiService apiService;
  final LocationService locationService;
  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  double _distance = 50;
  Future<List<Actevent>> _events;
  Future<List<String>> _favourites;
  List<Marker> _markers;
  bool _filterOptionsExpanded = false;

  @override
  void initState() {
    _markers = [];
    _events = _fetchActevents();
    _events.then((value) => _mapMarkers(value));
    _favourites = _fetchFavourites();
    _favourites.then((value) => _mapFavourites(value));
  }

  void _mapMarkers(List<Actevent> acteventList) {
    _markers = [];
    setState(() {
      acteventList.forEach((actevent) {
        _markers.add(Marker(
            width: 50.0,
            height: 50.0,
            point: LatLng.LatLng(double.parse(actevent.latitude),
                double.parse(actevent.longitude)),
            builder: (ctx) {
              return GestureDetector(
                child: SvgPicture.asset("assets/logo.svg",
                    semanticsLabel: 'Actevent', color: Color(0xFFdc3100)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                    return EventsDetailPage(
                      eventId: actevent.id,
                      apiService: widget.apiService,
                      locationService: widget.locationService,
                    );
                  }));
                },
              );
            }));
      });
    });
  }

  void _mapFavourites(List<String> favouriteIds) {
    _events.then((events) => favouriteIds.forEach((element) {
          setState(() {
            events
                .firstWhere((eventElement) => eventElement.id == element)
                .favourite = true;
          });
        }));
  }

  void _sliderChanged(double sliderValue) {
    setState(() {
      _distance = sliderValue;
    });
  }

  Widget _mapElement() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: FutureBuilder<Position>(
          future: (() async => await widget.locationService.getLocation())(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FlutterMap(
                options: MapOptions(
                    zoom: 12.0,
                    center: LatLng.LatLng(
                        snapshot.data.latitude, snapshot.data.longitude)),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: _markers)
                ],
              );
            }
            if (snapshot.hasError) {
              return Text("Die Karte könnte nicht geladen werden.");
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
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

  Future<List<Actevent>> _fetchActevents() async {
    Position pos = await widget.locationService.getLocation();
    String latitude = pos.latitude.toString();
    String longitude = pos.longitude.toString();
    print("Getting events for $latitude, $longitude and $_distance");
    return await widget.apiService
        .getEventsInArea(latitude, longitude, _distance.round());
    // return await apiService.getLocalTestList();
  }

  Future<List<String>> _fetchFavourites() async {
    var favourites = await widget.apiService.getUserFavourites();
    return favourites.map((e) => e.id).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _events = _fetchActevents();
    });
    _events.then((list) => _mapMarkers(list));
    _favourites = _fetchFavourites();
    _favourites.then((value) => _mapFavourites(value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterOptionsPanel(),
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
      Widget item = _buildListItem(event);
      children.add(item);
    }

    return RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: children,
        ),
        onRefresh: _handleRefresh);
  }

  Future<void> _addFavourite(Actevent event) async {
    try {
      await widget.apiService.addUserFavourite(event);
      setState(() {
        event.favourite = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Das Event konnte aufgrund eines Fehlers nicht zu deinen Favoriten hinzugefügt werden. Versuche es später erneut.")));
      print(e);
    }
  }

  Future<void> _deleteFavourite(Actevent event) async {
    try {
      await widget.apiService.deleteUserFavourite(event);
      setState(() {
        event.favourite = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Das Event konnte aufgrund eines Fehlers nicht aus deinen Favoriten gelöscht werden. Versuche es später erneut.")));
      print(e);
    }
  }

  Widget _buildListItem(Actevent event) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.pin_drop_outlined),
        trailing: event.favourite
            ? IconButton(
                icon: Icon(Icons.star),
                onPressed: () => _deleteFavourite(event))
            : IconButton(
                icon: Icon(Icons.star_outline_outlined),
                onPressed: () => _addFavourite(event)),
        title: Text(event.name),
        subtitle: Text("Abstand zur derzeitigen Position " +
            event.distance.round().toString() +
            "km"),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (c) {
            return EventsDetailPage(
              eventId: event.id,
              apiService: widget.apiService,
              locationService: widget.locationService,
            );
          }));
        },
      ),
    );
  }

  Widget _buildFilterOptionsPanel() {
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
