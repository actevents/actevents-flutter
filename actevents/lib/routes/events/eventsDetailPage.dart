import 'package:actevents/models/actevent.dart';
import 'package:actevents/services/apiService.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as LatLng;

class EventsDetailPage extends StatefulWidget {
  final String eventId;
  final ApiService apiService;
  final Position location;

  EventsDetailPage({this.eventId, this.apiService, this.location}) {}

  @override
  _EventsDetailPageState createState() => _EventsDetailPageState();
}

class _EventsDetailPageState extends State<EventsDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<Actevent> loadEvent() async {
    var res = await widget.apiService.getEventById(
        widget.eventId,
        widget.location.latitude.toString(),
        widget.location.longitude.toString());
    return res;
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
          title: Text("Detailansicht"),
        ),
        body: FutureBuilder<Actevent>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: CarouselSlider(
                      items: <Widget>[
                        _showMapLocation(double.parse(snapshot.data.latitude),
                            double.parse(snapshot.data.longitude)),
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
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        initialPage: 0,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text(
                          snapshot.data.name,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          child: Text(snapshot.data.description),
                          margin: EdgeInsets.all(20),
                        )

                        // Text("Distanz zum aktuellen Standort: " +
                        //     snapshot.data.distance.round().toString() +
                        //     "km"),
                      ],
                    ),
                  )
                ],
              );
            }
            if (snapshot.hasError) {
              return Text("Es ist etwas beim Laden schief gegangen :(");
            }
            return Text("Lade Event");
          },
          future: loadEvent(),
        ));
  }
}
