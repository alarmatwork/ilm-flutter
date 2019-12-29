import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'providers/selected_stations_data_provider.dart';
import 'station_list_screen.dart';
import 'station_screen.dart';
import 'stations_management_screen.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => SelectedStationsDataProvider(),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, //or set color with: Color(0xFF0000FF)
    ));

    return MaterialApp(
      title: 'Ilm 2.0 - Ilmajaam sinu taskus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedStationsDataProvider>(
        builder: (context, cart, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              print("Hello from action button");
              navigateAndDisplaySubFlow(context, (_) {
                print("Back from selection");
              }, StationsManagementScreen());
            },
            child: Icon(Icons.add)),
        body: Center(child: StationCarousel()),
      );
    });
  }
}

class StationCarousel extends StatefulWidget {
  @override
  _StationCarouselState createState() => new _StationCarouselState();
}

class _StationCarouselState extends State<StationCarousel> {
  Stream<QuerySnapshot> _getData(List<String> selectedStations) {
    if (selectedStations == null || selectedStations.isEmpty) {
      return Stream.empty();
    }

    print("Currently selected: "+selectedStations.length.toString());
  
    return Firestore.instance
        .collection('stations')
        .where('id', whereIn: selectedStations)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var selectedStations =
        Provider.of<SelectedStationsDataProvider>(context).selectedStations;
    return new Scaffold(
        backgroundColor: Colors.white,
        // appBar: new AppBar(
        //   title: new Text(widget.title),
        // ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _getData(selectedStations),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  List data = getOrderedBySelectedIdsOrder(
                      snapshot.data?.documents, selectedStations);
                  return new Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return new StationScreen(stationData: data[index]);
                    },
                    itemCount: data.length,
                    //pagination: new SwiperPagination(),
                    control: new SwiperControl(),
                    scale: 0.9,
                    outer: true,
                  );
              }
            }));
  }
}

List getOrderedBySelectedIdsOrder(
    List<DocumentSnapshot> documents, List<String> selectedIds) {
  List result =
      List.from(selectedIds.map((id) => documents.firstWhere((document) {
            return document.documentID == id;
          })));
  return result;
}

Future<void> _refreshStockPrices() {
  print("Refresh called");
}

Future<void> navigateAndDisplaySubFlow(
    BuildContext context, Function onResult, Widget screen) async {
  // Navigator.push returns a Future that completes after calling
  // Navigator.pop on the Selection Screen.
  final result = await Navigator.push(
    context,
    // Create the SelectionScreen in the next step.
    MaterialPageRoute(builder: (context) => screen),
  );

  onResult(result);
  return;
}
