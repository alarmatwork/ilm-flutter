import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedStationsDataProvider with ChangeNotifier {
  SelectedStationsDataProvider() {
    initStoredIds();
  }

  List<String> _selectedStations = [];

  List<String> get selectedStations => _selectedStations;

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
}
