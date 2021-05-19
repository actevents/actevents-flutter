import 'dart:ffi';

class Actevent {
  String id;
  String name;
  String longitude;
  String latitude;
  double distance;
  String description;
  String beginDate;
  String endDate;
  List<String> tags;

  Actevent(
      {this.id,
      this.name,
      this.longitude,
      this.latitude,
      this.distance,
      this.description,
      this.beginDate,
      this.endDate,
      this.tags});

  factory Actevent.fromJSON(Map<String, dynamic> json) {
    return Actevent(
        id: json["id"] as String,
        name: json["name"] as String,
        description: json["description"] as String,
        longitude:
            (json["location"] as Map<String, dynamic>)["longitude"] as String,
        latitude:
            (json["location"] as Map<String, dynamic>)["latitude"] as String,
        distance: json["distance"],
        beginDate: (json["dates"] as Map<String, dynamic>)["begin"] as String,
        endDate: (json["dates"] as Map<String, dynamic>)["begin"] as String,
        tags: json["tags"] as List<dynamic>);
  }

  factory Actevent.toJSON(Actevent actevent) {}
}
