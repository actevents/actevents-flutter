import 'dart:developer';

import 'package:actevents/models/actevent.dart';
import 'package:actevents/routes/events/eventsDetailPage.dart';
import 'package:actevents/services/apiService.dart';
import 'package:actevents/services/locationService.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';

class FavouritePage extends StatefulWidget {
  final ApiService apiService;
  final LocationService locationService;

  FavouritePage({
    @required this.apiService,
    @required this.locationService,
  });

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  Future<List<String>> _favouriteIds;
  List<Actevent> _favouriteActevents;
  bool _loading = true;
  Future<Position> _location;

  @override
  void initState() {
    _loading = true;
    _favouriteActevents = [];
    _fetchData();
    _location = widget.locationService.getLocation();
    super.initState();
  }

  Future<void> _fetchData() async {
    try {
      var favourites = await widget.apiService.getUserFavourites();

      setState(() {
        _loading = false;
        _favouriteActevents = favourites;
      });
    } catch (e) {
      log("Error loading favourites ");
      log(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Favoriten konnten nicht geladen werden. Bitte versuchen Sie es später erneut.")));
    }
  }

  Future<void> _handleRefresh() async {
    print("Refresh triggered");
  }

  Widget _buildList() {
    List<Widget> listItems = _buildListItems();

    if (_loading) {
      return CircularProgressIndicator();
    } else if (listItems.length == 0) {
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
        leading: IconButton(
            icon: Icon(Icons.star),
            onPressed: () => showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Favorisiertes Event entfernen?"),
                    content: const Text(
                        "Bitte klicke auf Entfernen, wenn Du das Event aus deinen Favoriten löschen möchtest." +
                            "\nWenn Du das Event in deinen Favoriten beibehalten möchtest, wähle Abbrechen."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: Text("Abbrechen")),
                      TextButton(
                          onPressed: () {
                            try {
                              widget.apiService.deleteUserFavourite(event);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text(
                                      "Das Event konnte aufgrund eines Fehlers nicht aus deinen Favoriten gelöscht werden. Versuche es später erneut.")));
                              print(e);
                            }
                            Navigator.pop(context, "OK");
                            this._handleRefresh();
                          },
                          child: Text("Entfernen"))
                    ],
                  ),
                )),
        title: Text(event.name),
        subtitle: _buildSubtitle(event),
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

  Future<Address> _getAddressOfEvent(Actevent event) async {
    return widget.locationService.convertCoordinatesToAddress(Coordinates(
        double.parse(event.latitude), double.parse(event.longitude)));
  }

  Widget _buildSubtitle(Actevent event) {
    return FutureBuilder(
      future: _getAddressOfEvent(event),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Address address = snapshot.data;
          return Text(address.addressLine);
        } else {
          return Text(
              "Es ist ein Fehler beim Abrufen der Adresse aufgetreten.");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildList());
  }
}
