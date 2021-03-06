import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:actevents/models/actevent.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

class ApiService {
  ApiService({this.idToken}) {
    _headers.putIfAbsent('Authorization', () => idToken);
  }
  final String idToken;

  // String _baseUrl = 'api.actevents.de';
  // String _envPath = '/test';
  String _baseUrl = 'qwsopzco8h.execute-api.eu-central-1.amazonaws.com';
  String _envPath = '/default';

  Map<String, String> _headers = {};

  Future<List<Actevent>> getEventsInArea(
      String latitude, String longitude, int radius) async {
    Map<String, dynamic> queryParameters = {
      'longitude': longitude,
      'latitude': latitude,
      'radius': radius.toString()
    };
    var uri =
        Uri.https(this._baseUrl, this._envPath + '/events', queryParameters);

    http.Response response = await http.get(uri, headers: this._headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Actevent> fetchedEvents =
          body.map((dynamic itemJson) => Actevent.fromJSON(itemJson)).toList();
      return fetchedEvents;
    } else {
      print("Error ocured. Non 200 status code returned from api.");
      print("Status code: " +
          response.statusCode.toString() +
          "\nBody: " +
          response.body);
      return [];
    }
  }

  Future<void> uploadImage(
      String uploadUrl, String filePath, String fileType) async {
    dev.log("Trying to upload image at " + filePath + "to " + uploadUrl);
    var bytes = File(filePath).readAsBytesSync();

    var response = await http.put(uploadUrl, body: bytes, headers: {
      "Content-Type": fileType == "jpg" ? "image/jpeg" : "image/png"
    });
    if (response.statusCode == 200) {
      dev.log("Image uploaded successfully to s3");
    } else {
      throw ErrorDescription(
          "Non 200 status code received when uploading image to s3");
    }
  }

  Future<List<Actevent>> getOwnEvents() async {
    var uri =
        Uri.https(this._baseUrl, this._envPath + '/events/me');

    http.Response response = await http.get(uri, headers: this._headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Actevent> fetchedEvents =
          body.map((dynamic itemJson) => Actevent.fromJSON(itemJson)).toList();
      return fetchedEvents;
    } else {
      print("Error ocured. Non 200 status code returned from api.");
      print("Status code: " +
          response.statusCode.toString() +
          "\nBody: " +
          response.body);
      return [];
    }
  }
  Future<void> createNewEvent(Actevent actevent) async {
    var uri = Uri.https(this._baseUrl, this._envPath + '/events');
    var body = json.encode(actevent.acteventToJSON());
    http.Response response =
        await http.post(uri, headers: this._headers, body: body);

    if (response.statusCode == 200) {
      print("Event created successfully");
    } else {
      print("Non 200 status code received");
      throw Error();
    }
  }

  Future<Actevent> getEventById(
      {@required id: String, latitude: String, longitude: String}) async {
    Map<String, dynamic> queryParameters = {};
    Uri uri;
    if (latitude != null &&
        latitude != '' &&
        longitude != null &&
        longitude != '') {
      queryParameters['latitude'] = latitude;
      queryParameters['longitude'] = longitude;

      uri = Uri.https(
          this._baseUrl, this._envPath + '/events/' + id, queryParameters);
    } else {
      uri = Uri.https(this._baseUrl, this._envPath + '/events/' + id);
    }

    http.Response response = await http.get(uri, headers: this._headers);
    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return Actevent.fromJSON(body);
    } else {
      print("Error ocured. Non 200 status code returned from api.");
      print("Status code: " +
          response.statusCode.toString() +
          "\nBody: " +
          response.body);
      throw ErrorDescription("Non 200 status code received from api");
    }
  }

  Future<Map<String, dynamic>> getImageUrl(String fileType) async {
    Map<String, dynamic> queryParameters = {"extension": fileType};

    var uri = Uri.https(
        this._baseUrl, this._envPath + '/events/upload', queryParameters);
    var response = await http.get(uri, headers: this._headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ErrorDescription(
          "Non 200 status code received for retrival of image url.");
    }
  }

  Future<List<Actevent>> getUserFavourites() async {
    var uri = Uri.https(this._baseUrl, this._envPath + '/favorites');
    var response = await http.get(uri, headers: this._headers);
    if (response.statusCode == 200) {
      List<dynamic> jsonBody = jsonDecode(response.body) as List;
      List<Actevent> fetchedEvents =
          (jsonBody?.map((e) => Actevent.fromJSON(e))?.toList()) ??
              <Actevent>[];
      return fetchedEvents;
    } else {
      throw ErrorDescription("Non 200 status code received from api");
    }
  }

  Future<void> addUserFavourite(Actevent actevent) async {
    Map<String, dynamic> bodyParameter = {"favorite": actevent.id};
    var uri = Uri.https(this._baseUrl, this._envPath + '/favorites');
    var response = await http.post(uri,
        body: jsonEncode(bodyParameter), headers: this._headers);
    if (response.statusCode != 200) {
      throw ErrorDescription("Non 200 status code received from api");
    }
  }


  Future<void> deleteUserFavourite(Actevent actevent) async {
    Map<String, dynamic> queryParameters = {"favorite": actevent.id};
    var uri =
        Uri.https(this._baseUrl, this._envPath + '/favorites', queryParameters);
    var response = await http.delete(uri, headers: this._headers);
    if (response.statusCode != 200) {
      throw ErrorDescription("Non 200 status code received from api");
    }
  }

  Future<void> deleteOwnEvent(Actevent actevent) async {
    var uri =
        Uri.https(this._baseUrl, this._envPath + '/events/'+actevent.id);
    var response = await http.delete(uri, headers: this._headers);
    if (response.statusCode != 200) {
      throw ErrorDescription("Non 200 status code received from api");
    }
  }

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
