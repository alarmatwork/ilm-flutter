import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

final df = DateFormat('H:mm');

class StationParams extends StatelessWidget {
  const StationParams({
    Key key,
    @required this.stationData,
  }) : super(key: key);

  final stationData;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Column(
             mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Wrap(runSpacing: 5.0, spacing: 5.0, children: <Widget>[
                StationDataPoint(
                    value: stationData['windSpeed'], unit: 'm/s', label: 'Tuul'),
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
                StationDataPoint(
                  value: stationData['tempRoad'],
                  unit: 'ºC',
                  label: 'Teetemp.',
                ),
                StationDataPoint(
                  value: stationData['visibility'] != null
                      ? stationData['visibility'] / 10000
                      : null,
                  unit: 'km',
                  label: 'Nähtavus',
                ),
                // StationDataPoint(
                //   value: stationData['roadStatus'],
                //   unit: '',
                //   label: 'TEE',
                // ),
                // StationDataPoint(
                //   value: df
                //       .format(DateTime.fromMillisecondsSinceEpoch(
                //           stationData['measuredTimeStamp']?.millisecondsSinceEpoch))
                //       .toString(),
                //   unit: '',
                //   label: 'ANDMED',
                // )
              ]),
            ],
          )
        ]));
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
