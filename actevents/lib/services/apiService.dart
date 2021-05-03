import 'package:actevents/models/actevent.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  String baseUrl =
      'https://qwsopzco8h.execute-api.eu-central-1.amazonaws.com/default';
  Map<String, String> headers = {
    'x-api-key': '2aZ4yPAsNR1WCzQH1PxUh7tGD6o2E5YW2TZuM4IT'
  };

  Future<List<Actevent>> getEventsInArea(
      String longitude, String latitude, int distance) async {
    Map<String, dynamic> queryParameters = {
      'longitude': longitude,
      'latitude': latitude,
      'distance': distance
    };
    var uri = Uri.https(this.baseUrl, '/events', queryParameters);

    var response = await http.get(uri, headers: this.headers);
    var parsed = json.decode(response.body);
    return parsed.map((json) => Actevent.fromJSON(json)).toList();
  }
}
