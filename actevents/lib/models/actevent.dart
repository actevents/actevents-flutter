import 'dart:ffi';

class Actevent {
  String id;
  String name;
  String longitude;
  String latitude;
  Double distance;

  Actevent({this.id, this.name, this.longitude, this.latitude, this.distance});

  factory Actevent.fromJSON(Map<String, dynamic> json) {
    return Actevent(
        id: json["id"] as String,
        name: json["name"] as String,
        longitude: json["longitude"] as String,
        latitude: json["latitude"] as String,
        distance: json["distance"] as Double);
  }
}
