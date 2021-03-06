import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StationsDataProvider with ChangeNotifier {
  StationsDataProvider() {
    initStoredIds();

    triggerLocationUpdateInMinues(0, () {});

    // if (location.onLocationChanged() != null){
    //   location.onLocationChanged().listen(_locationListener);
    // }
  }

  void triggerLocationUpdateInMinues(double delayInMinutes, Function callback) {
    Future.delayed(Duration(milliseconds: (delayInMinutes * 60 * 1000).toInt()),
        () {
      try {
        location.getLocation().then((measuredLocation) {
          _locationListener(measuredLocation);
          triggerLocationUpdateInMinues(30, callback);
        }).catchError((error) {
          print("Error reading location, will retry soon: " + error);
          triggerLocationUpdateInMinues(0.2, callback);
        });
      } catch (err) {
        triggerLocationUpdateInMinues(0.2, callback);
      }
    });
  }

  var location = new Location();
  List<String> _selectedStations = [];
  LocationData _currentLocation;

  LocationData get currentLocation => _currentLocation;
  List<String> get selectedStations => _selectedStations;
  double getDistanceFromCurrent(double lat, lng) {
    //_currentLocation.
    final Distance distance = new Distance();
    if (lat == null || lng == null || _currentLocation == null) {
      return null;
    }

    return distance.as(
        LengthUnit.Kilometer,
        new LatLng(_currentLocation.latitude, _currentLocation.longitude),
        new LatLng(lat, lng));
  }

  set selectedStations(List<String> value) {
    _selectedStations = value;
    notifyListeners();
  }

  initStoredIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> defaultInitialList = [
      'IT_Tallinn-Harku',
      'TT_53_Tartu',
      'IT_Võru',
      'IT_Kuressaare linn',
      'IT_Pärnu'
    ];

    _selectedStations =
        prefs.getStringList('selectedStations') ?? defaultInitialList;

    print(
        "Loaded stored ID-s from preferences: " + _selectedStations.toString());
    notifyListeners();
  }

  Future<List<DocumentSnapshot>> getAllStations() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("stations").getDocuments();
    return querySnapshot.documents;
  }

  void updateList(List<String> newIdList) {
    if (newIdList.length >= 9) {
      throw Exception("Liiga palju ilmajaamasid valitud (max 10)");
    }

    _selectedStations = newIdList;
    _storeSelectedIds(newIdList);
    notifyListeners();
  }

  _storeSelectedIds(List<String> ids) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('selectedStations', ids);
    print("Saved selected IDs");
  }

  void addSelectedId(String id) {
    if (_selectedStations.contains(id)) {
      throw Exception("Ilmajaam juba valitud");
    }

    if (_selectedStations.length > 9) {
      throw Exception("Maksimaalselt on lubatud 10 ilmajaama");
    }

    selectedStations.add(id);
    _storeSelectedIds(selectedStations);
    notifyListeners();
  }

  void removeSelectedId(String id) {
    if (!_selectedStations.contains(id)) {
      throw Exception("See ilmajaam ei olnud valitud");
    }
    selectedStations.remove(id);
    _storeSelectedIds(selectedStations);
    notifyListeners();
  }

  void _locationListener(LocationData event) {
    final Distance distance = new Distance();

    double dist = _currentLocation == null || event == null
        ? null
        : distance.as(
            LengthUnit.Kilometer,
            new LatLng(_currentLocation.latitude, _currentLocation.longitude),
            new LatLng(event.latitude, event.longitude));

    if (_currentLocation == null ||
        (event.latitude != _currentLocation.latitude &&
                event.longitude != _currentLocation.longitude) &&
            (dist != null && dist > 1)) {
      _currentLocation = event;
      print("EVENT: LAT:${event.latitude} LNG:${event.longitude}");
      notifyListeners();
    }
  }
}
