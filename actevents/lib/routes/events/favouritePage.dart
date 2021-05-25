import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/events/eventsDetailPage.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';

class FavouritePage extends StatefulWidget {
  final ApiService apiService;
  final LocationService locationService;

  FavouritePage({@required this.apiService, @required this.locationService});

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  Future<List<String>> _favouriteIds;
  List<Actevent> _favouriteActevents;

  @override
  void initState() {
    _favouriteActevents = [];
    _fetchData();
    super.initState();
  }

  void _fetchData() async {
    var favouriteIds = await widget.apiService.getUserFavourites();
    var location = await widget.locationService.getLocation();

    List<Future<Actevent>> futures = [];
    for (String id in favouriteIds) {
      futures.add(widget.apiService.getEventById(
          id: id,
          latitude: location.latitude.toString(),
          longitude: location.longitude.toString()));
    }

    var allEvents = await Future.wait(futures);

    setState(() {
      _favouriteActevents = allEvents;
    });
  }

  void _handleRefresh() async {
    print("Refresh triggered");
  }

  Widget _buildList() {
    List<Widget> listItems = _buildListItems();

    if (listItems.length == 0) {
      return Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Text(
            "Es sind noch keine Favoriten gespeichert.\nFavoriten können über die Finden Seite hinzugefügt werden.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ));
    } else {
      return RefreshIndicator(
          child: ListView(
            children: listItems,
          ),
          onRefresh: _handleRefresh);
    }
  }

  List<Widget> _buildListItems() {
    List<Widget> returnList = [];

    for (var item in _favouriteActevents) {
      returnList.add(_buildItemCard(item));
    }

    return returnList;
  }

  Widget _buildItemCard(Actevent event) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.pin_drop_outlined),
        title: Text(event.name),
        subtitle: Text("Weitere Info"),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (c) {
            return EventsDetailPage(
              eventId: event.id,
              apiService: widget.apiService,
              locationService: widget.locationService,
            );
          }));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildList());
  }
}
