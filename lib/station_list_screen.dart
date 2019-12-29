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
    List<String> selectedIds =
        Provider.of<SelectedStationsDataProvider>(context).selectedStations;

    return new Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('stations').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                var data = snapshot.data.documents;
                // data.sort(sortStations);

                return new ReorderableListView(
                  onReorder: (int start, int current) {
                    print("Reordered with: $start to $current");
                  },
                  children: data.map((DocumentSnapshot document) {
                    return CheckboxListTile(
                      key: Key(document.documentID),
                      title: Text(document['name'] ?? ''),
                      value: selectedIds.contains(document.documentID),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool value) {
                        setState(() {
                          updateStationList(document.documentID, value,
                              context: context,
                              selectedStationIds: selectedIds);
                        });
                      },
                      secondary: Icon(document['type'] == 'ILMATEENISTUS'
                          ? Icons.star
                          : Icons.traffic),
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

  int sortStations(DocumentSnapshot a, DocumentSnapshot b,
      {List<String> selected}) {
    return a['name'].toString().compareTo(a['name'].toString());
  }
}

void updateStationList(String documentId, bool value,
    {BuildContext context, List<String> selectedStationIds}) {
  if (!value) {
    print("Removing: '$documentId'");
    selectedStationIds.remove(documentId);
  } else {
    print("Adding: '$documentId'");
    if (selectedStationIds.length > 10) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Liiga palju ilmajaamasid. Max lubatud 10"),
      ));
      return;
    }
    selectedStationIds.add(documentId);
  }
  try {
    Provider.of<SelectedStationsDataProvider>(context)
        .updateList(selectedStationIds);
  } catch (error) {}
  print(selectedStationIds.join(';'));
}
