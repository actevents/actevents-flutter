import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final String dateTimeLabel;
  const DateTimePicker({Key key, this.dateTimeLabel}) : super(key: key);

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  _DateTimePickerState(/* String dateTimeLabel */) {
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    // this._dateTimeLabel = dateTimeLabel;
  }

  String _dateTimeLabel;

  TextEditingController _dateController;
  TextEditingController _timeController;

  String _setTime, _setDate;

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}.${picked.month}.${picked.year}";
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _time = _formatTime(timeOfDay: selectedTime);
        _timeController.text = _time;
      });
    }
  }

  @override
  void initState() {
    DateTime now = DateTime.now();
    _dateController.text = _formatDate(now);
    _timeController.text = _formatTime(dateTime: now);
    super.initState();
  }

  String _formatDate(DateTime dateTime) {
    var formatter = DateFormat("dd.MM.yyyy");
    return formatter.format(dateTime);
  }

  String _formatTime({timeOfDay: TimeOfDay, dateTime: DateTime}) {
    if (timeOfDay != null) {
      return timeOfDay.format(context);
    }
    if (dateTime != null) {
      var formatter = DateFormat("hh:mm");
      return formatter.format(dateTime);
    }
    throw ArgumentError(
        "Cannot format time with both arguments at the same time");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        children: [
          Text(widget.dateTimeLabel),
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.today), /*labelText: _dateLabel*/
            ),
            onTap: () {
              _selectDate(context);
            },
            controller: _dateController,
            // enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.access_time), /*labelText: _dateLabel*/
            ),
            onTap: () {
              _selectTime(context);
            },
            controller: _timeController,
            // enabled: false,
          )
        ],
      ),
    );
  }
}
