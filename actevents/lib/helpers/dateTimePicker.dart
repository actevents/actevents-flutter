import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef void GetDateTimeUpdate(DateTime datetime);

class DateTimePicker extends StatefulWidget {
  final GetDateTimeUpdate onChange;
  final String dateTimeLabel;
  final bool defaultValidator;

  const DateTimePicker(
      {Key key, this.dateTimeLabel, this.defaultValidator, this.onChange})
      : super(key: key);

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

  bool _defaultValidator;

  TextEditingController _dateController;
  TextEditingController _timeController;

  String _setTime, _setDate;

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDateTime = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) widget.onChange(picked);
    setState(() {
      selectedDateTime = picked;
      _dateController.text = "${picked.day}.${picked.month}.${picked.year}";
    });
  }

  String _formatDate(DateTime dateTime) {
    var formatter = DateFormat("dd.MM.yyyy");
    return formatter.format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    if (dateTime != null) {
      var formatter = DateFormat("hh:mm");
      return formatter.format(dateTime);
    }
    throw ArgumentError(
        "Cannot format time with both arguments at the same time");
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime));
    if (picked != null) {
      setState(() {
        selectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            picked.hour,
            picked.minute);
        _time = _formatTime(selectedDateTime);
        _timeController.text = _time;
      });
      widget.onChange(selectedDateTime);
    }
  }

  @override
  void initState() {
    DateTime now = DateTime.now();
    _dateController.text = _formatDate(now);
    _timeController.text = _formatTime(now);
    super.initState();
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
            validator: (value) {
              if (widget.defaultValidator && (value == null || value.isEmpty)) {
                return "Datum darf nicht leer sein";
              }
              return null;
            },
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
            validator: (value) {
              if (widget.defaultValidator && (value == null || value.isEmpty)) {
                return "Uhrzeit darf nicht leer sein";
              }
              return null;
            },
            // enabled: false,
          )
        ],
      ),
    );
  }
}
