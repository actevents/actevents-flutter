import 'package:flutter/material.dart';

class EventsAddPage extends StatefulWidget {
  @override
  _EventsAddPageState createState() => _EventsAddPageState();
}

class _EventsAddPageState extends State<EventsAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event hinzufügen"),
      ),
      body: Column(
        children: [Text("Event add page works!")],
      ),
    );
  }
}
