import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/rootPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  String _baseUrl = 'qwsopzco8h.execute-api.eu-central-1.amazonaws.com';
  Map<String, String> _headers = {
    'x-api-key': '2aZ4yPAsNR1WCzQH1PxUh7tGD6o2E5YW2TZuM4IT'
  };

  Future<List<Actevent>> getEventsInArea(
      String longitude, String latitude, int distance) async {
    Map<String, dynamic> queryParameters = {
      'longitude': longitude,
      'latitude': latitude,
      'distance': distance.toString()
    };
    var uri = Uri.https(this._baseUrl, '/default' + '/events', queryParameters);

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
    list.add(Actevent(
        id: 'kadjfkladhjfkladsjfla',
        name: 'Testevent #1',
        longitude: '8.5500',
        latitude: '48.4557',
        distance: 100));
    list.add(Actevent(
        id: 'dafdggfda',
        name: 'Rave bei Marvin',
        longitude: '8.5011',
        latitude: '48.4679',
        distance: 100));
    list.add(Actevent(
        id: 'kadjfkladhjfklafsdgfdsjfla',
        name: 'Rave bei Marvin #2',
        longitude: '8.5011',
        latitude: '48.4679',
        distance: 100));

    return Future.value(list);
  }
}
