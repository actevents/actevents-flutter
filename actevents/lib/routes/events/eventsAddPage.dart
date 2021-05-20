import 'dart:developer';
import 'dart:io';

import 'package:actevents/helpers/dateTimePicker.dart';
import 'package:actevents/helpers/picturePreviewScreen.dart';
import 'package:actevents/models/actevent.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as LatLng;

class EventsAddPage extends StatefulWidget {
  final ApiService apiService;
  final LocationService loactionService;

  EventsAddPage({this.apiService, this.loactionService}) {}

  @override
  _EventsAddPageState createState() => _EventsAddPageState();
}

class _EventsAddPageState extends State<EventsAddPage> {
  _EventsAddPageState() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  Marker _positionMarker = null;

  DateTime _begin;
  DateTime _end;

  String _picturePath;
  final _formKey = GlobalKey<FormState>();
  bool notNull(Object o) => o != null;

  bool _paidEvent = false;

  List<String> _selectedTags = [];

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  TextEditingController _priceController;
  TextEditingController _latitudeController;
  TextEditingController _longitudeController;

  void _onChangeBegin(DateTime begin) {
    this._begin = begin;
  }

  void _onChangeEnd(DateTime end) {
    this._end = end;
  }

  DateTimePicker _endDateTimePicker;

  DateTimePicker _startDateTimePicker;

  void _setPositionMarker(LatLng.LatLng positionMarker) {
    _positionMarker = Marker(
      width: 50.0,
      height: 50.0,
      point: positionMarker,
      builder: (context) => Container(
        child: SvgPicture.asset("assets/logo.svg",
            semanticsLabel: 'Actevent', color: Color(0xFFdc3100)),
      ),
    );
  }

  Widget _buildForm() {
    _startDateTimePicker = DateTimePicker(
        key: Key("addEventFormBeginDateTime"),
        dateTimeLabel: "Beginn",
        defaultValidator: true,
        onChange: _onChangeBegin);
    _endDateTimePicker = DateTimePicker(
      key: Key("addEventFormEndDateTime"),
      dateTimeLabel: "Ende",
      defaultValidator: true,
      onChange: _onChangeEnd,
    );
    const double borderPadding = 15;
    return ListView(
      key: Key("addEventFormListView"),
      children: [
        // ----- Name and Description ---------
        TextFormField(
          key: Key("addEventFormName"),
          decoration: const InputDecoration(
              icon: Icon(Icons.info),
              hintText: "Wie soll das Event heißen?",
              labelText: "Name *"),
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte einen Namen angeben';
            }
            return null;
          },
        ),
        TextFormField(
          key: Key("addEventFormDescription"),
          decoration: const InputDecoration(
              icon: Icon(Icons.description),
              hintText: "Füge eine Beschreibung hinzu!",
              labelText: "Beschreibung *"),
          controller: _descriptionController,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte eine Beschreibung des Events angeben';
            }
            return null;
          },
        ),
        // ----------------------------------
        // ---------- Paid Event ------------
        _drawDivider(),
        SwitchListTile(
            key: Key("addEventFormPriceSwitch"),
            value: _paidEvent,
            title: const Text("Bezahltes Event / Ticket benötigt?"),
            onChanged: (bool newValue) {
              setState(() {
                _paidEvent = newValue;
              });
            }),
        _paidEvent
            ? TextFormField(
                key: Key("addEventFormPriceInput"),
                decoration: const InputDecoration(
                    icon: Icon(Icons.money),
                    hintText: "Wie viel kostet ein Ticket (Euro)",
                    labelText: "Eintrittspreis *"),
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Bitte einen Eintrittspreis angeben";
                  }
                  return null;
                },
              )
            : null,
        // ----------------------------------
        // ---------- DateTime --------------
        _drawDivider(),
        _startDateTimePicker,
        _drawDivider(),
        _endDateTimePicker,
        _drawDivider(),
        // ----------------------------------
        // ---------- Location --------------
        Text(
          "Ort",
          textAlign: TextAlign.center,
        ),
        FutureBuilder<Position>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: FlutterMap(
                    options: MapOptions(
                      zoom: 17.5,
                      center: LatLng.LatLng(
                          snapshot.data.latitude, snapshot.data.longitude),
                      onTap: (point) {
                        _longitudeController.text = point.longitude.toString();
                        _latitudeController.text = point.latitude.toString();
                        setState(() {
                          _setPositionMarker(
                              LatLng.LatLng(point.latitude, point.longitude));
                        });
                      },
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(
                          markers: [_positionMarker].where(notNull).toList())
                      // MarkerLayerOptions(markers: [
                      //   // Marker(
                      //   //   width: 80.0,
                      //   //   height: 80.0,
                      //   //   point: eventPosition,
                      //   //   builder: (ctx) => Container(

                      //   //   ),
                      //   )
                    ]),
                height: 300,
              );
            } else if (snapshot.hasError) {
              return Text("error");
            } else {
              return Center(
                  child: Container(
                padding: const EdgeInsets.all(10),
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ));
            }
          },
          future: (() async => await widget.loactionService.getLocation())(),
        ),
        // for now input fields for location lon and lat
        TextFormField(
          key: Key("addEventFormLatitude"),
          controller: _latitudeController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Bitte einen Wert für die Latitude angeben";
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              icon: Icon(Icons.location_on_outlined), labelText: "Latitude *"),
        ),
        TextFormField(
          key: Key("addEventFormLongitude"),
          controller: _longitudeController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Bitte einen Wert für die Longitude angeben";
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              icon: Icon(Icons.location_on_outlined), labelText: "Longitude *"),
        ),
        // ----------------------------------
        // ---------- Images ----------------
        _drawDivider(),
        Text("Bilder", textAlign: TextAlign.center),
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: CarouselSlider(
            items: _buildCarouselList(),
            options: CarouselOptions(
                enableInfiniteScroll: false,
                initialPage: 0,
                viewportFraction: 0.4,
                scrollDirection: Axis.horizontal),
          ),
        ),

        // ----------------------------------
        // ------------ Tags ----------------
        _drawDivider(),
        Text("Tags", textAlign: TextAlign.center),
        Container(
          // height: MediaQuery.of(context).size.height * 0.2,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          // child: FlutterTagging(
          //     initialItems: _selectedTags,
          //     findSuggestions: findSuggestions,
          //     configureChip: configureChip,
          //     configureSuggestion: configureSuggestion)
          child: Text("Tags - WIP"),
        ),
        // ----------------------------------
        // ------------ Submit --------------
        _drawDivider(),
        ElevatedButton(onPressed: _submitForm, child: Text("Event anlegen")),
      ].where(notNull).toList(),
      padding: const EdgeInsets.all(borderPadding),
    );
  }

  void _submitForm() async {
    print("submit form pressed");
    if (_formKey.currentState.validate()) {
      try {
        var actevent = Actevent(
            name: _nameController.text,
            description: _descriptionController.text,
            latitude: _latitudeController.text,
            longitude: _longitudeController.text,
            endDate: _end,
            beginDate: _begin,
            tags: []);

        if (_picturePath != null) {
          var split = _picturePath.split('.');
          var fileType = split[split.length - 1];
          var jsonResponse = await widget.apiService.getImageUrl(fileType);
          await widget.apiService
              .uploadImage(jsonResponse["uploadUrl"], _picturePath, fileType);
          actevent.fileName = jsonResponse['fileName'];
        }

        await widget.apiService.createNewEvent(actevent);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Event erfolgreich angelegt.")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                "Es ist ein Fehler aufgetreten. Bitte versuche es erneut.")));
        print(e);
      }
    }
  }

  void _onPictureTaken(String path) {
    setState(() {
      _picturePath = path;
    });
    log("Saved picture at " + path);
  }

  Future<String> _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final camera = cameras.first;

    Navigator.of(context).push(MaterialPageRoute(builder: (c) {
      return PicturePreviewScreen(
          camera: camera, onPictureTaken: _onPictureTaken);
    }));
  }

  Widget _drawDivider() {
    return Divider(
      color: Colors.grey,
      thickness: 1,
      height: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Event hinzufügen"),
        ),
        body: Form(key: _formKey, child: _buildForm()));
  }

  List<Widget> _buildCarouselList() {
    List<Widget> widgets = <Widget>[];
    widgets.add(OutlinedButton(
        onPressed: _takePicture,
        child: Container(width: 100, child: Icon(Icons.add_a_photo))));
    if (_picturePath != null) {
      widgets.add(Image(image: FileImage(File(_picturePath), scale: 1)));
    }
    return widgets;
  }
}
