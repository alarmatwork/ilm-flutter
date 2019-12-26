import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/selected_stations_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StationList extends StatefulWidget {
  @override
  _StationListState createState() => _StationListState();
}

class _StationListState extends State<StationList> {
  @override
  Widget build(BuildContext context) {
    List<String> selectedIds = Provider.of<SelectedStationsDataProvider>(context).selectedStations;

    return new Scaffold(
        body: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('stations').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              controller: ScrollController(keepScrollOffset: true),
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return CheckboxListTile(
                  title: Text(document['name'] ?? ''),
                  value: selectedIds.contains(document.documentID),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool value) {
                    setState(() {
                        updateStationList(document.documentID, value, context:context, selectedStationIds: selectedIds);

                    });
                  },
                  secondary: Icon(document['type']=='ILMATEENISTUS' ? Icons.star : Icons.traffic),
                );
                // return new ListTile(
                //   title: new Text(document['name'] ?? ''),
                //   subtitle: new Text(document['temp'].toString() ?? ''),
                // );
              }).toList(),
            );
        }
      },
    ));
  }
}


void updateStationList(String documentId, bool value, {BuildContext context, List<String> selectedStationIds}) {

  if (!value){
    print("Removing: '$documentId'");
    selectedStationIds.remove(documentId);
  } else {
    print("Adding: '$documentId'");
    selectedStationIds.add(documentId);
  }

  Provider.of<SelectedStationsDataProvider>(context).updateList(selectedStationIds);
  print(selectedStationIds.join(';'));
}