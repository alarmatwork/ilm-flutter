
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getSelectedStationsIds() async{
  print("Start getting selected stations from the local storage");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  print("Start getting selected stations from the local storage");
  List<String> selectedStations = prefs.getStringList('selected_stations') ?? ['53_Tartu','ILMATEENISTUS_Tallinn-Harku','ILMATEENISTUS_Viljandi','ILMATEENISTUS_Narva linn'];
  print("Returning $selectedStations");
  return selectedStations;
}