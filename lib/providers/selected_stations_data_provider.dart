import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SelectedStationsDataProvider with ChangeNotifier {


  SelectedStationsDataProvider(){
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

  void addId(String id){
    _selectedStations = [id];
    notifyListeners();
  }

  _storeSelectedIds(List<String> ids) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> defaultInitialList = [
      'IT_Tallinn-Harku',
      'TT_53_Tartu',
      'IT_Võru',
      'IT_Kuressaare linn',
      'IT_Pärnu'
    ];

    prefs.setStringList('selectedStations', ids);
    print("Saved selected IDs");
  }
}
