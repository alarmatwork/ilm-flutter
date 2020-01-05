import 'package:flutter/material.dart';
import 'package:ilm/widgets/station_data_widget.dart';
import 'package:provider/provider.dart';
import 'providers/selected_stations_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MaterialApp(
      home: new StationsManagementScreen(),
    ));

class StationsManagementScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new StationsManagementScreenState();
}

class StationsManagementScreenState extends State<StationsManagementScreen> {
  List<dynamic> items = [];
  TextEditingController controller = new TextEditingController();
  String filter;
  List allStations = [];
  bool sortByName = true;
  bool group = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (items == null || items.isEmpty) {
      if (items == null) {
        items = [];
      }

      Provider.of<StationsDataProvider>(context, listen: false)
          .getAllStations()
          .then((List<DocumentSnapshot> resultList) {
        print("Got results: " + resultList.length.toString());
        setState(() {
          resultList.forEach((result) {
            items.add(result);
          });
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            backgroundColor: Colors.white,
            title: new TextField(
              decoration: new InputDecoration(
                  hintText: "Otsimiseks trüki ilmajaama nimi siia"),
              controller: controller,
            )),
        body: new Column(children: <Widget>[
          new Padding(
            padding: new EdgeInsets.only(top: 20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sorteeri :',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  new Radio(
                      value: sortByName,
                      groupValue: group,
                      onChanged: (value) {
                        setState(() {
                          sortByName = true;
                        });
                      }),
                  new Text(
                    'Nime',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                  new Radio(
                      value: !sortByName,
                      groupValue: group,
                      onChanged: (value) {
                        setState(() {
                          sortByName = false;
                        });
                      }),
                  new Text(
                    'Kauguse',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                ]),
          ),
          // new TextField(
          //   decoration:
          //       new InputDecoration(hintText: "Otsimiseks trüki nimi siia"),
          //   controller: controller,
          // ),
          new Expanded(
            child: StationCards(
              allStations: items,
              filter: filter,
              sortByDistance: !sortByName,
            ),
          ),
        ]));
  }
}

class StationCards extends StatelessWidget {
  final bool sortByDistance;

  const StationCards(
      {Key key,
      @required this.allStations,
      @required this.filter,
      this.sortByDistance: true})
      : super(key: key);

  final List<dynamic> allStations;
  final String filter;

  @override
  Widget build(BuildContext context) {
    List<String> selectedStations =
        Provider.of<StationsDataProvider>(context).selectedStations;

    allStations.sort((a, b) {
      var compareResult = 0;

      if (selectedStations.contains(a['id']) &&
          !selectedStations.contains(b['id'])) {
        compareResult = -1;
      } else if (!selectedStations.contains(a['id']) &&
          selectedStations.contains(b['id'])) {
        compareResult = 1;
      } else {
        if (sortByDistance) {
          if (a['location'] != null && b['location'] == null) {
            compareResult = -1;
          } else if (a['location'] == null && b['location'] != null) {
            compareResult = 1;
          } else if (a['location'] != null && b['location'] != null) {
            compareResult = Provider.of<StationsDataProvider>(context)
                        .getDistanceFromCurrent(
                            a['location']?.latitude, a['location']?.longitude) <
                    Provider.of<StationsDataProvider>(context)
                        .getDistanceFromCurrent(
                            b['location']?.latitude, b['location']?.longitude)
                ? -1
                : 1;
          }
        } else {
          compareResult = a['name'].compareTo(b['name']);
        }
      }

      //   print("${a['name']} vs ${b['name']} will retrun $compareResult");

      return compareResult;
    });
    return new ListView.builder(
      itemCount: allStations.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: filter == null ||
                  filter == "" ||
                  allStations[index]['name']
                      .toLowerCase()
                      .contains(filter.toLowerCase()) ||
                  (allStations[index]['genericLocation'] != null &&
                      allStations[index]['genericLocation']
                          .toLowerCase()
                          .contains(filter.toLowerCase()))
              ? StationCard(station: allStations[index])
              : new Container(),
        );
      },
    );
  }
}

class StationCard extends StatelessWidget {
  const StationCard({
    Key key,
    @required this.station,
  }) : super(key: key);

  final dynamic station;

  @override
  Widget build(BuildContext context) {
    bool isStationSelected = Provider.of<StationsDataProvider>(context)
        .selectedStations
        .contains(station['id']);

    double distance = Provider.of<StationsDataProvider>(context)
        .getDistanceFromCurrent(
            station['location']?.latitude, station['location']?.longitude);
    //print("Stamp: " + station['measuredTimeStamp'].toString());
    return new Card(
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                // leading: Icon(
                //   station['type'] == 'ILMATEENISTUS'
                //       ? Icons.cloud_queue
                //       : Icons.art_track,
                //   size: 20,
                // ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 5),
                  child: Row(
                    children: <Widget>[
                      new Text(station['name'].toString(),
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black54)),
                      Text(distance != null
                          ? ' [' + distance.toString() + 'km]'
                          : ''),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(
                          station['type'] == 'ILMATEENISTUS'
                              ? Icons.cloud_queue
                              : Icons.local_car_wash,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: StationDataCells(
                    stationData: station, isStationManagement: true),
                //  Text(station['measuredTimeStamp'] != null
                //     ? new DateFormat.d().add_M().add_y().add_Hm().format(
                //         DateTime.fromMillisecondsSinceEpoch(
                //             station['measuredTimeStamp']
                //                 .millisecondsSinceEpoch))
                //     : ''),
                trailing: Column(
                  children: <Widget>[
                    IconButton(
                      color: isStationSelected ? Colors.red : Colors.green,
                      iconSize: 40,
                      icon: Icon(isStationSelected
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline),
                      onPressed: () {
                        //  try {
                        if (isStationSelected) {
                          Provider.of<StationsDataProvider>(context,
                                  listen: false)
                              .removeSelectedId(station['id']);
                        } else {
                          Provider.of<StationsDataProvider>(context,
                                  listen: false)
                              .addSelectedId(station['id']);
                        }
                        // } catch (error) {
                        //   final snackBar = new SnackBar(
                        //       content: new Text('VIGA: ' + error.toString()),
                        //       backgroundColor: Colors.red);

                        //   // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                        //   Scaffold.of(context).showSnackBar(snackBar);
                        // }
                      },
                    ),
                  ],
                )
                //FlatButton(
                //     child: const Text('Vali', style: TextStyle(color: Colors.white)),
                //     onPressed: () {

                //     },
//                ),
                ),
          ],
        ));
  }
}
