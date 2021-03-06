import 'dart:developer';

import 'package:actevents/models/actevent.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:latlong/latlong.dart" as LatLng;

class EventsDetailPage extends StatefulWidget {
  final String eventId;
  final ApiService apiService;
  final LocationService locationService;

  EventsDetailPage({this.eventId, this.apiService, this.locationService}) {}

  @override
  _EventsDetailPageState createState() => _EventsDetailPageState();
}

class _EventsDetailPageState extends State<EventsDetailPage> {
  bool notNull(Object o) => o != null;

  @override
  void initState() {
    super.initState();
  }

  Future<Actevent> loadEvent() async {
    try {
      var location = await widget.locationService.getLocation();
      var res = await widget.apiService.getEventById(
          id: widget.eventId,
          latitude: location.latitude.toString(),
          longitude: location.longitude.toString());
      return res;
    } catch (e) {
      log("Error on event loading ");
      log(e);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Das Event konnte aufgrund eines Fehlers nicht geladen werden. Versuche es später erneut.")));
    }
  }

  Widget _showMapLocation(double latitude, double longitude) {
    var eventPosition = LatLng.LatLng(latitude, longitude);
    print(eventPosition);

    return FlutterMap(
      options: MapOptions(
        zoom: 17.5,
        center: eventPosition,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(markers: [
          Marker(
            width: 80.0,
            height: 80.0,
            point: eventPosition,
            builder: (ctx) => Container(
              child: SvgPicture.asset(
                "assets/logo.svg",
                semanticsLabel: 'Actevent',
                color: Color(0xFFdc3100),
              ),
            ),
          )
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedPage = 0;
    var elementDescriptionWidth = MediaQuery.of(context).size.width * 0.35;
    var formatter = DateFormat("dd.MM.yyyy hh:mm");

    return Scaffold(
        appBar: AppBar(
          title: Text("Detailansicht"),
        ),
        body: FutureBuilder<Actevent>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: CarouselSlider(
                    items: <Widget>[
                      _showMapLocation(double.parse(snapshot.data.latitude),
                          double.parse(snapshot.data.longitude)),
                      snapshot.data.imageUrl == null
                          ? null
                          : Image(
                              image: NetworkImage(snapshot.data.imageUrl,
                                  scale: 1),
                            ),
                    ].where(notNull).toList(),
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                      initialPage: selectedPage,
                      viewportFraction: 0.9, // selectedPage == 0 ? 0.9 : 0.6,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      children: [
                        Text(
                          snapshot.data.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Container(
                                width: elementDescriptionWidth,
                                child: Text(
                                  "Distanz zum aktuellen Standort:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width -
                                    elementDescriptionWidth -
                                    15 -
                                    13,
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                    snapshot.data.distance.round().toString() +
                                        ' km'),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Container(
                                width: elementDescriptionWidth,
                                child: Text(
                                  "Eventbeschreibung:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width -
                                      elementDescriptionWidth -
                                      15 -
                                      13,
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(snapshot.data.description)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Container(
                                width: elementDescriptionWidth,
                                child: Text(
                                  "Start- und Enddatum:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width -
                                      elementDescriptionWidth -
                                      15 -
                                      13,
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                      "${formatter.format(snapshot.data.beginDate)} \nbis \n${formatter.format(snapshot.data.endDate)}"))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Container(
                                width: elementDescriptionWidth,
                                child: Text(
                                  "Tags:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(_getTagString(snapshot.data.tags))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Container(
                                width: elementDescriptionWidth,
                                child: Text(
                                  "Adresse:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width -
                                    elementDescriptionWidth -
                                    15 -
                                    13,
                                padding: const EdgeInsets.only(left: 15),
                                child: FutureBuilder<Address>(
                                  future: widget.locationService
                                      .convertCoordinatesToAddress(Coordinates(
                                          double.parse(snapshot.data.latitude),
                                          double.parse(
                                              snapshot.data.longitude))),
                                  builder: (context, snapshotAddress) {
                                    if (snapshotAddress.hasData) {
                                      return Text(
                                        snapshotAddress.data.addressLine,
                                      );
                                    } else if (snapshotAddress.hasError) {
                                      return Text(
                                          'Lat: ${snapshot.data.latitude} Lon: ${snapshot.data.longitude}');
                                    } else {
                                      return Text("Fehler");
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
              ]);
            }
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Daten konnten nicht geladen werden. Bitte versuchen Sie es später erneut!",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                  OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Zurück"))
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
          future: loadEvent(),
        ));
  }

  _getTagString(List<dynamic> tags) {
    var tagString = "";
    if (tags == null) return tagString;
    tags.asMap().forEach((var index, var value) {
      tagString = tagString + (index < tags.length - 1 ? ', ' : '') + value;
    });
    return tagString;
  }
}
