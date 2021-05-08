import 'package:actevents/models/actevent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as LatLng;

class EventsDetailPage extends StatelessWidget {
  EventsDetailPage({this.event});

  final Actevent event;

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
              child: Icon(
                Icons.location_on,
                color: Colors.red[700],
              ),
            ),
          )
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detailansicht - " + this.event.name),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: CarouselSlider(
              items: <Widget>[
                _showMapLocation(double.parse(this.event.latitude),
                    double.parse(this.event.longitude)),
                Image(
                  image: NetworkImage(
                      "https://via.placeholder.com/720x720.png?text=This+placeholder+was+brought+to+you+by+the+lacking+backend",
                      scale: 1),
                ),
                Image(
                  image: NetworkImage(
                      "https://via.placeholder.com/720x720.png?text=This+placeholder+was+brought+to+you+by+the+lacking+backend",
                      scale: 1),
                ),
              ],
              enableInfiniteScroll: false,
              initialPage: 1,
            ),
          ),
          Container(
            child: Column(
              children: [
                Text(
                  this.event.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                Text("Distanz zum aktuellen Standort: " +
                    this.event.distance.round().toString() +
                    "km"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
