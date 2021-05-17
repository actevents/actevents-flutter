import 'dart:ffi';

class Actevent {
  String id;
  String name;
  String longitude;
  String latitude;
  double distance;
  String description;

  Actevent(
      {this.id,
      this.name,
      this.longitude,
      this.latitude,
      this.distance,
      this.description});

  factory Actevent.fromJSON(Map<String, dynamic> json) {
    return Actevent(
        id: json["id"] as String,
        name: json["name"] as String,
        description: json["description"] as String,
        longitude: (json["location"] as Map<String, dynamic>)["longitude"]as String,
        latitude: (json["location"] as Map<String, dynamic>)["latitude"] as String,
        distance: json["distance"]);
  }
}
