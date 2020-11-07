import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ilm/providers/stations_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final df = DateFormat('H:mm');

class StationDataCells extends StatelessWidget {
  final bool isStationManagement;

  const StationDataCells({Key key, @required this.stationData, this.isStationManagement: false}) : super(key: key);

  final stationData;

  @override
  Widget build(BuildContext context) {
    print("STATION DATA:" + stationData['measuredTimeStamp'].toString());
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Expanded(
        child: Container(
          //color: Colors.yellow,
          child: Wrap(runSpacing: 5.0, spacing: 2.0, children: <Widget>[
            isStationManagement ? StationDataPoint(value: stationData['temp'], unit: 'ºC', label: 'Temp') : Container(),
            StationDataPoint(value: stationData['windSpeed'], unit: 'm/s', label: 'Tuul'),
            StationDataPoint(value: stationData['windSpeedMax'], unit: 'm/s', label: 'Max Tuul'),
            StationDataPoint(
              value: stationData['windDirection'],
              custom: Transform.rotate(
                angle: stationData['windDirection'] != null
                    ? (180 + stationData['windDirection'].toDouble()) * pi / 180
                    : 0,
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.deepOrangeAccent,
                  size: 20,
                ),
              ),
              label: 'Tuulesuund',
            ),
            StationDataPoint(
              value: stationData['humidity'],
              unit: '%',
              label: 'Õhuniiskus',
            ),
            StationDataPoint(
              value: stationData['tempRoad'],
              unit: 'ºC',
              label: 'Teetemp.',
            ),
            StationDataPoint(
              value: stationData['waterTemp'],
              unit: 'ºC',
              label: 'Vesi temp',
            ),
            StationDataPoint(
              value: stationData['waveLen'],
              unit: 'm',
              label: 'Laineperiood',
            ),
            StationDataPoint(
              value: stationData['waveHeight'] == "" ? 0 : stationData['waveHeight'],
              unit: 'm',
              label: 'Lainekõrgus',
            ),
            StationDataPoint(
              value: stationData['waveMax'] == "" ? 0 : stationData['waveMax'],
              unit: 'm',
              label: 'Max laine',
            ),
            StationDataPoint(
              value: stationData['waterLevel'],
              unit: 'cm',
              label: 'Veetase',
            ),
            StationDataPoint(
              value: stationData['visibility'] != null && stationData['visibility'] is int
                  ? stationData['visibility'] / 1000
                  : null,
              unit: 'km',
              label: 'Nähtavus',
            ),
            StationDataPoint(
              value: stationData['precipitationIntensity'],
              unit: 'mm/h',
              label: 'Sademed',
            ),
            !isStationManagement
                ? StationDataPoint(
                    value: Provider.of<StationsDataProvider>(context)
                        .getDistanceFromCurrent(stationData['location']?.latitude, stationData['location']?.longitude),
                    unit: 'km',
                    label: 'Kaugus',
                  )
                : Container(),
            // StationDataPoint(
            //   value: stationData['roadStatus'],
            //   unit: '',
            //   label: 'TEE',
            // ),
            StationDataPoint(
              value: df
                  .format(DateTime.fromMillisecondsSinceEpoch(stationData['measuredTimeStamp']?.millisecondsSinceEpoch))
                  .toString(),
              unit: '',
              label: 'MÕÕDETUD',
            )
          ]),
        ),
      )
    ]);
  }
}

class StationDataPoint extends StatelessWidget {
  final dynamic value;
  final String unit;
  final String label;

  final Widget custom;

  const StationDataPoint({this.value, this.unit, this.label, this.custom});

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return Container(
          width: 80,

          //color:Colors.red,
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  custom != null
                      ? custom
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                                child: Container(
                                    child: Text(value.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrangeAccent,
                                          fontSize: 18,
                                        )))),
                            Text(unit,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                          ],
                        ),
                ],
              ),
              Text(label.toUpperCase(),
                  style: TextStyle(
                    color: Color(0xFFB5E1F9),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  )),
            ],
          ));
    } else {
      return SizedBox.shrink();
    }
  }
}
