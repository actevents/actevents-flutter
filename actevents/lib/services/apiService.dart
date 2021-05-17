import 'dart:math';

import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/rootPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

class ApiService {
  ApiService({this.idToken}) {
    _headers.putIfAbsent('Authorization' , () => idToken);
  }
  final String idToken;

  String _baseUrl = 'qwsopzco8h.execute-api.eu-central-1.amazonaws.com';
  Map<String, String> _headers = { };

  Future<List<Actevent>> getEventsInArea(
      String latitude, String longitude, int distance) async {
    Map<String, dynamic> queryParameters = {
      'longitude': longitude,
      'latitude': latitude,
      'distance': distance.toString()
    };
    var uri = Uri.https(this._baseUrl, '/test' + '/events', queryParameters);

    http.Response response = await http.get(uri, headers: this._headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Actevent> fetchedEvents =
          body.map((dynamic itemJson) => Actevent.fromJSON(itemJson)).toList();
      return fetchedEvents;
    } else {
      // TODO: error handling
      print("Error ocured. Non 200 status code returned from api.");
      print("Status code: " +
          response.statusCode.toString() +
          "\nBody: " +
          response.body);
      return [];
    }
  }

  // Actevent({this.id, this.name, this.longitude, this.latitude, this.distance});

  Future<List<Actevent>> getLocalTestList() async {
    List<Actevent> list = [];
    Random randomGenerator = Random();
    Uuid uuid = Uuid();
    for (int i = 0; i < randomGenerator.nextInt(25) + 1; i++) {
      list.add(Actevent(
          id: uuid.v4(),
          name: "Rave bei Marvin #$i",
          longitude: "8.5011",
          latitude: '48.4679',
          distance: randomGenerator.nextInt(100).toDouble()));
    }
    list.sort((a, b) => (a.distance - b.distance).toInt());
    return Future.value(list);
  }
}
