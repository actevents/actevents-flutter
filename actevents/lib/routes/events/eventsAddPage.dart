import 'package:actevents/helpers/dateTimePicker.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

class EventsAddPage extends StatefulWidget {
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

  final _formKey = GlobalKey<FormState>();
  bool notNull(Object o) => o != null;

  bool _paidEvent = false;

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  TextEditingController _priceController;
  TextEditingController _latitudeController;
  TextEditingController _longitudeController;

  Widget _buildForm() {
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
        ),
        TextFormField(
          key: Key("addEventFormDescription"),
          decoration: const InputDecoration(
              icon: Icon(Icons.description),
              hintText: "Füge eine Beschreibung hinzu!",
              labelText: "Beschreibung *"),
          controller: _descriptionController,
          maxLines: 4,
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
              )
            : null,
        // ----------------------------------
        // ---------- DateTime --------------
        _drawDivider(),
        DateTimePicker(
          key: Key("addEventFormBeginDateTime"),
          dateTimeLabel: "Beginn",
        ),
        _drawDivider(),
        DateTimePicker(
          key: Key("addEventFormEndDateTime"),
          dateTimeLabel: "Ende",
        ),
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
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              icon: Icon(Icons.location_on_outlined), labelText: "Latitude *"),
        ),
        TextFormField(
          key: Key("addEventFormLongitude"),
          controller: _longitudeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              icon: Icon(Icons.location_on_outlined), labelText: "Longitude *"),
        ),
        // ----------------------------------
        // ---------- Images ----------------
        _drawDivider(),
        Text("Bilder", textAlign: TextAlign.center)
      ].where(notNull).toList(),
      padding: const EdgeInsets.all(borderPadding),
    );
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
}
