import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ilm/widgets/compass_widget.dart';
import 'package:ilm/widgets/station_data_widget.dart';

class StationScreen extends StatelessWidget {
  final dynamic stationData;

  const StationScreen({
    @required this.stationData,
  });

  @override
  Widget build(BuildContext context) {
    double circleSize =
        (MediaQuery.of(context).size.height / 3) + 50.roundToDouble();
    double fontSize = (circleSize / 5).roundToDouble();
    double circleBorderSize = fontSize;
    print("Tsirkel: $circleSize font: $fontSize");
    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              (stationData['name'] ?? '').toUpperCase(),
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 34,
              ),
            ),
          ),
          CicularInfo(
              circleSize: circleSize,
              circleBorderSize: circleBorderSize,
              stationData: stationData,
              fontSize: fontSize),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: StationDataCell(stationData: stationData),
          ),
        ],
      ),
    );
  }
}

class CicularInfo extends StatelessWidget {
  const CicularInfo({
    Key key,
    @required this.circleSize,
    @required this.circleBorderSize,
    @required this.stationData,
    @required this.fontSize,
  }) : super(key: key);

  final double circleSize;
  final double circleBorderSize;
  final dynamic stationData;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TempAndWindCircle(
        circleSize: circleSize,
        circleBorderSize: circleBorderSize,
        stationData: stationData,
        fontSize: fontSize);
  }
}

class TempAndWindCircle extends StatelessWidget {
  const TempAndWindCircle({
    Key key,
    @required this.circleSize,
    @required this.circleBorderSize,
    @required this.stationData,
    @required this.fontSize,
  }) : super(key: key);

  final double circleSize;
  final double circleBorderSize;
  final DocumentSnapshot stationData;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      // top: 150,
      // right: MediaQuery.of(context).size.width / 2,
      child: Container(
        // margin: EdgeInsets.only(top: 10),
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: Color(0xFFB5E1F9),
          borderRadius: BorderRadius.all(
            Radius.circular(circleSize),
          ),
        ),
        child: Center(
          child: Stack(children: [
            Container(
              //   color: Colors.black12,
              height: circleSize,
              width: circleSize,
              // color: Colors.yellow,
              child: Compass(
                stationData: stationData,
              ),
            ),
            CircularInfo(
                circleSize: circleSize,
                circleBorderSize: circleBorderSize,
                stationData: stationData,
                fontSize: fontSize),
          ]),
        ),
      ),
    );
  }
}

class CircularInfo extends StatelessWidget {
  const CircularInfo({
    Key key,
    @required this.circleSize,
    @required this.circleBorderSize,
    @required this.stationData,
    @required this.fontSize,
  }) : super(key: key);

  final double circleSize;
  final double circleBorderSize;
  final DocumentSnapshot stationData;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: circleSize - circleBorderSize,
        height: circleSize - circleBorderSize,
        decoration: BoxDecoration(
          color: Color(0xFF4FB6F0),
          borderRadius: BorderRadius.all(
            Radius.circular(circleSize - circleBorderSize),
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
                  fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
