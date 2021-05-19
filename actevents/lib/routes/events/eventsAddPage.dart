import 'dart:developer';
import 'dart:io';

import 'package:actevents/helpers/dateTimePicker.dart';
import 'package:actevents/helpers/picturePreviewScreen.dart';
import 'package:actevents/models/actevent.dart';
import 'package:actevents/services/apiService.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

class EventsAddPage extends StatefulWidget {
  final ApiService apiService;

  EventsAddPage({this.apiService}) {}

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

  DateTime begin;
  DateTime end;

  final List<String> _pictureList = <String>[];
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
    this.begin = begin;
  }

  void _onChangeEnd(DateTime end) {
    this.end = end;
  }

  DateTimePicker _endDateTimePicker;

  DateTimePicker _startDateTimePicker;

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

  void _submitForm() {
    print("submit form pressed");
    if (_formKey.currentState.validate()) {
      print("Send data to api");

      var actevent = Actevent(
          name: _nameController.text,
          description: _descriptionController.text,
          latitude: _latitudeController.text,
          longitude: _longitudeController.text);
      // beginDate: _startDateTimePicker);

      try {
      widget.apiService.createNewEvent(actevent);
      } catch (e) {
        print(e);
      }
    }
  }

  void _onPictureTaken(String path) {
    log(path + " from callback");
    setState(() {
      _pictureList.add(path);
    });
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
    for (var path in _pictureList) {
      widgets.add(Image(image: FileImage(File(path), scale: 1)));
    }
    return widgets;
  }
}
