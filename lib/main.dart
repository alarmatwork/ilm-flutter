import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:ilm/providers/selected_stations_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ilm 2.0 - Ilmajaam sinu taskus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Hello from action button");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StationList()),
            );
          },
          child: Icon(Icons.add)),
      body: Center(child: StationCarousel()),
    );
  }
}

class StationCarousel extends StatefulWidget {
  @override
  _StationCarouselState createState() => new _StationCarouselState();
}

class _StationCarouselState extends State<StationCarousel> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: new AppBar(
      //   title: new Text(widget.title),
      // ),
      body: RefreshIndicator(
        onRefresh: _refreshStockPrices,
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('stations').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  List data = getFilteredStationsInOrder(snapshot.data.documents);
                  return new Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return new StationScreen(stationData: data[index]);
                    },
                    itemCount: data.length,
                    //pagination: new SwiperPagination(),
                    control: new SwiperControl(),
                    scale: 0.5,
                    outer: true,                    
                  );
              }
            }),
      ),
    );
  }

 List getFilteredStationsInOrder(List<DocumentSnapshot> documents) async {
    List<String> selectedStations = await getSelectedStationsIds();
    List result = [];

    result = documents
        .where(
            (document) => selectedStations.contains(document['id'].toString()))
        .toList();

    print('Done sorting: $result');
    return result;
  }
}


Future<void> _refreshStockPrices() {
  print("Refresh called");
}

class StationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {

                    return CheckboxListTile(
    title: Text(document['name'] ?? ''),
    value: false,
    controlAffinity: ListTileControlAffinity.leading,
    onChanged: (bool value) {
      // setState(() { 
      //   //Store local value

      // });
    },
    secondary: const Icon(Icons.directions_car),
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

class StationScreen extends StatelessWidget {
  final dynamic stationData;

  const StationScreen({
    @required this.stationData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Center(
            // top: 150,
            // right: MediaQuery.of(context).size.width / 4,
            child: Container(
              margin: EdgeInsets.only(top: 50),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFFB5E1F9),
                borderRadius: BorderRadius.all(
                  Radius.circular(200),
                ),
              ),
              child: Center(
                child: Stack(children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Color(0xFF4FB6F0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(150),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${stationData['temp'] ?? ''}ºC',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      (stationData['name'] ?? '').toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 38,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              StationDataPoint(
                                  value: stationData['windSpeed'],
                                  unit: 'm/s',
                                  label: 'Tuul'),
                              StationDataPoint(
                                value: stationData['windDirection'],
                                unit: 'º',
                                label: 'Tuulesuund',
                              ),
                              StationDataPoint(
                                value: stationData['humidity'],
                                unit: '%',
                                label: 'Õhuniiskus',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StationDataPoint extends StatelessWidget {
  final dynamic value;
  final String unit;
  final String label;

  const StationDataPoint({
    this.value,
    this.unit,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                    fontSize: 16,
                  )),
              Text(unit,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
            ],
          ),
          Text(label.toUpperCase(),
              style: TextStyle(
                color: Color(0xFFB5E1F9),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              )),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
