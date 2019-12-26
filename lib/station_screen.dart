import 'package:flutter/material.dart';

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
                          padding: const EdgeInsets.only(top: 20.0, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
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
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
