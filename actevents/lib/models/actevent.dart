import 'dart:ffi';

class Actevent {
  String id;
  String name;
  String longitude;
  String latitude;
  double distance;
  String description;
  DateTime beginDate;
  DateTime endDate;
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
        beginDate: (json["dates"] as Map<String, dynamic>)["begin"] as DateTime,
        endDate: (json["dates"] as Map<String, dynamic>)["begin"] as DateTime,
        tags: json["tags"] as List<String>);
  }

  Map<String, dynamic> acteventToJSON() {
    var json = Map<String, dynamic>();
    json['name'] = this.name;
    json['description'] = this.description;

    var jsonLocation = Map<String, dynamic>();
    jsonLocation['latitude'] = this.latitude;
    jsonLocation['longitude'] = this.longitude;
    json['location'] = jsonLocation;

    var jsonDates = Map<String, dynamic>();
    jsonDates['begin'] = this.beginDate.toIso8601String();
    jsonDates['end'] = this.endDate.toIso8601String();
    json['dates'] = jsonDates;

    json['tags'] = this.tags;
  }
}
