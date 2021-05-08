import 'package:actevents/models/actevent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EventsDetailPage extends StatelessWidget {
  EventsDetailPage({this.event});

  final Actevent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text('Detail Event'),
            ),
            body: Text(event.id),
          );
  }
}