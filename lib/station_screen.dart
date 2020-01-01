import 'package:flutter/material.dart';
import 'package:ilm/widgets/station_data_widget.dart';

class StationScreen extends StatelessWidget {
  final dynamic stationData;

  const StationScreen({
    @required this.stationData,
  });

  @override
  Widget build(BuildContext context) {
    double circleSize =
        (MediaQuery.of(context).size.width / 2) + 50.roundToDouble();
    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text(
              (stationData['name'] ?? '').toUpperCase(),
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          Center(
            // top: 150,
            // right: MediaQuery.of(context).size.width / 2,
            child: Container(
              margin: EdgeInsets.only(top: 50),
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
                    width: circleSize - 50,
                    height: circleSize - 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF4FB6F0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(circleSize - 50),
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
                    Column(
                      children: <Widget>[
                        StationParams(stationData: stationData),
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
