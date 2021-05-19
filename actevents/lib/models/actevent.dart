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

  Map<String, dynamic> acteventToJSON() {
    var json = Map<String, dynamic>();
    json['name'] = this.name;
    json['description'] = this.description;

    var jsonLocation = Map<String, dynamic>();
    jsonLocation['latitude'] = this.latitude;
    jsonLocation['longitude'] = this.longitude;
    json['location'] = jsonLocation;

    var jsonDates = Map<String, dynamic>();
    jsonDates['begin'] = this.beginDate;
    jsonDates['end'] = this.endDate;
    json['dates'] = jsonDates;

    json['tags'] = this.tags;
  }
}
