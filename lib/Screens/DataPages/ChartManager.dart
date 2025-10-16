import 'dart:convert';
import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart';
import 'JSONData.dart';
import 'package:flutter/foundation.dart';

/*DOCS: Floating action button will hold date range and check boxes 
        Have function to check date range, bools then add to list of functions
        Have to call json here; parse and pass data from here?
        */

/*Problem: Bottom titles need to be generated depending on length of calender
  Switch cases can be used to find if duration is more or less than x
  Switch cases are also used to generate the title names, based off x values in graph
  See if theres a better way to code than nested switches
  
  Switch case also to be used in listview children [] for tie into checklist*/

class Chartmanager extends StatefulWidget {
  final String id;
  final bool isHydromet;
  const Chartmanager({
    super.key,
    required this.isHydromet,
    required this.id,
  });

  @override
  State<Chartmanager> createState() => _ChartmanagerState();
}

class _ChartmanagerState extends State<Chartmanager> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final f = DateFormat('yyyy-MM-dd');
  DateTime now = DateTime.now();
  DateTimeRange? _selectedDateRange;

  bool? shortTimeSpan = false;

/*NOTE: Setting booleans for initial charting. */
  bool? airTemperature = true;
  bool? atmosphericPressure = false;
  bool? bulkEC = false;
  bool? gustSpeed = false;
  bool? maxPrecipRate = false;
  bool? precipitation = true;
  bool? referenceET = true;
  bool? relativeHumidity = false;
  bool? snowDepth = false;
  bool? soilTemperature = true;
  bool? soilVWC = true;
  bool? solarRadiation = false;
  bool? windDirection = false;
  bool? windSpeed = false;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _selectedDateRange =
        DateTimeRange(start: now.subtract(Duration(days: 7)), end: now);

    getDataList();
  }

// This block handles the Data retreval and api calls.
//==============================================================================
  //sets widgets in checklist.
  //Date picker and checkboxes
  List<String> calculateDaysInterval(DateTime startDate, DateTime endDate) {
    List<String> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      String temp = f.format(startDate.add(Duration(days: i)));
      days.add(temp);
    }
    setState(() {
      if (days.length > 15) {
        shortTimeSpan = false;
      } else {
        shortTimeSpan = true;
      }
    });

    return days;
  }

  //Returns the url with date range and station ID. Premade is forced
  String parseURL() {
    List<String> dayArr = calculateDaysInterval(
        _selectedDateRange!.start, _selectedDateRange!.end);
    if (shortTimeSpan!) {
      return 'https://mesonet.climate.umt.edu/api/v2/observations/hourly/?type=json&stations=${widget.id}&dates=${dayArr.join(',')}&premade=true&rm_na=true';
    } else {
      return 'https://mesonet.climate.umt.edu/api/v2/observations/daily/?type=json&stations=${widget.id}&dates=${dayArr.join(',')}&premade=true&rm_na=true';
    }
    //print('Parsed URL: https://mesonet.climate.umt.edu/api/v2/observations/hourly/?type=json&stations=${widget.id}&dates=${f.format(_selectedDateRange!.start)},${f.format(_selectedDateRange!.end)}&premade=true');
  }

  //returns a list of data entries following standard json format.
  //Acess data using dot format (Data[i].datetime)
  Future<List<Data>> getDataList() async {
    List<Data> dataList = [];
    String url = parseURL();
    String response = '';
    try {
      response = await flutterCompute(apiCall, url);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
      return dataList; // return empty list on error
    }

    List<dynamic> dataMap = jsonDecode(response);

    for (int i = 0; i < dataMap.length; i++) {
      dataList.add(Data.fromJson(dataMap[i]));
    }
    return dataList;
  }

//================================================================================

//This block handles the checklist and date picker
  Widget _buildOptionCheckbox({
    required String title,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: onChanged,
    );
  }

  List<Widget> checklist() {
    final options = <Map<String, dynamic>>[
      {
        'title': 'Air Temperature',
        'field': 'airTemperature',
        'value': airTemperature,
        'setter': (v) => airTemperature = v
      },
      {
        'title': 'Precipitation',
        'field': 'precipitation',
        'value': precipitation,
        'setter': (v) => precipitation = v
      },
      // {
      //   'title': 'Max Precipitation Rate',
      //   'field': 'maxPrecipRate',
      //   'value': maxPrecipRate,
      //   'setter': (v) => maxPrecipRate = v
      // },
      {
        'title': 'Atmospheric Pressure',
        'field': 'atmosphericPressure',
        'value': atmosphericPressure,
        'setter': (v) => atmosphericPressure = v
      },
      {
        'title': 'Relative Humidity',
        'field': 'relativeHumidity',
        'value': relativeHumidity,
        'setter': (v) => relativeHumidity = v
      },
      {
        'title': 'Soil Temperature',
        'field': 'soilTemperature',
        'value': soilTemperature,
        'setter': (v) => soilTemperature = v
      },
      {
        'title': 'Soil VWC',
        'field': 'soilVWC',
        'value': soilVWC,
        'setter': (v) => soilVWC = v
      },
      {
        'title': 'Bulk EC',
        'field': 'bulkEC',
        'value': bulkEC,
        'setter': (v) => bulkEC = v
      },
      {
        'title': 'Solar Radiation',
        'field': 'solarRadiation',
        'value': solarRadiation,
        'setter': (v) => solarRadiation = v
      },
      // {
      //   'title': 'Wind Direction',
      //   'field': 'windDirection',
      //   'value': windDirection,
      //   'setter': (v) => windDirection = v
      // },
      {
        'title': 'Wind Speed',
        'field': 'windSpeed',
        'value': windSpeed,
        'setter': (v) => windSpeed = v
      },
      {
        'title': 'Snow Depth',
        'field': 'snowDepth',
        'value': snowDepth,
        'setter': (v) => snowDepth = v
      },
    ];

    final List<Widget> list = [
      ListTile(
        leading: Text(
            '${f.format(_selectedDateRange!.start)} - ${f.format(_selectedDateRange!.end)}',
            style: TextStyle(fontWeight: FontWeight.w800)),
        trailing: MaterialButton(
          color: widget.isHydromet
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          onPressed: _show,
          child: Icon(Icons.date_range),
        ),
      ),
    ];

    for (final opt in options) {
      list.add(_buildOptionCheckbox(
        title: opt['title'] as String,
        value: opt['value'] as bool?,
        onChanged: (bool? v) => setState(() => opt['setter'](v)),
      ));
    }

    return list;
  }

//shows the datepicker
  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
      helpText: "Select a date range",
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (result != null) {
      // Rebuild the UI
      setState(() {
        _selectedDateRange = result;
      });
    }
  }

//=================================================================================

  // map param names to simple extractor functions
  final Map<String, double? Function(Data)> _extractors = {
    'airTemperature': (d) => d.airTemperature,
    'precipitation': (d) => d.Precipitation,
    'maxPrecipRate': (d) => d.maxPrecipRate,
    'atmosphericPressure': (d) => d.atmosphericPressure,
    'relativeHumidity': (d) => d.relativeHumidity,
    'soilTemperature5': (d) => d.soilTemperature5,
    'soilTemperature10': (d) => d.soilTemperature10,
    'soilTemperature20': (d) => d.soilTemperature20,
    'soilTemperature50': (d) => d.soilTemperature50,
    'soilTemperature100': (d) => d.soilTemperature100,
    'soilVWC5': (d) => d.soilVWC5,
    'soilVWC10': (d) => d.soilVWC10,
    'soilVWC20': (d) => d.soilVWC20,
    'soilVWC50': (d) => d.soilVWC50,
    'soilVWC100': (d) => d.soilVWC100,
    'bulkEC5': (d) => d.bulkEC5,
    'bulkEC10': (d) => d.bulkEC10,
    'bulkEC20': (d) => d.bulkEC20,
    'bulkEC50': (d) => d.bulkEC50,
    'bulkEC100': (d) => d.bulkEC100,
    'solarRadiation': (d) => d.solarRadiation,
    'windDirection': (d) => d.windDirection,
    'windSpeed': (d) => d.windSpeed,
    'snowDepth': (d) => d.snowDepth,
  };

  Future<List<FlSpot>> dataSpot(String param) async {
    final extractor = _extractors[param];
    if (extractor == null) return <FlSpot>[];

    final data = await getDataList();
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final y = extractor(data[i]);
      if (y == null) continue;
      // keep your original x representation (adjust if datetime type differs)
      final x = data[i].datetime is num
          ? (data[i].datetime as num).toDouble()
          : i.toDouble();
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  Future<List<FlSpot>> lineChart() async {
    List<FlSpot> spotList = [];
    List<Data> dataList = [];
    double y = 0;

    for (int i = 0; i < dataList.length; i++) {
      DateFormat('yyyy-MM-dd').format(dataList[i].datetime as DateTime);
      DateTime date = DateTime.parse(dataList[i].datetime as String);
      y = dataList[i].airTemperature ?? 0;
      spotList.add(FlSpot(
          DateTime.parse(date as String).millisecondsSinceEpoch.toDouble(), y));
    }

    return spotList;
  }

  Widget airTempGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: dataSpot('airTemperature'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double minY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b);
            double maxY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(
                LineChartData(
                  minY: minY - 5,
                  maxY: maxY + 5,
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Air Temperature",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          axisNameSize: 26),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          getTitlesWidget: (value, meta) {
                            if (shortTimeSpan!) {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(14, -5),
                                  child: Text(
                                    DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(10, -5),
                                  child: Text(
                                    DateFormat('MM-dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                          },
                          reservedSize: shortTimeSpan! ? 75 : 40,
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Temperature [°F]',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            maxIncluded: false,
                            minIncluded: false,
                          )),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        maxIncluded: false,
                        minIncluded: false,
                      ))),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright, //pick something better for colors
                  lineBarsData: [
                    LineChartBarData(
                        color: Colors.red,
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        int count = 0;
                        if (touchedSpots.isEmpty) {
                          return [];
                        }
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          );
                          final date = shortTimeSpan!
                              ? DateFormat('MM-dd - HH:00').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()))
                              : DateFormat('MM-dd-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()));
                          final value = touchedSpot.y;

                          LineTooltipItem first = LineTooltipItem(
                            '$date\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$value °F',
                                style: textStyle,
                              )
                            ],
                          );

                          if (count == 0) {
                            count++;
                            return first;
                          } else {
                            return LineTooltipItem(
                              '$value °F',
                              textStyle,
                            );
                          }
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event,
                        LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget snowDepthGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: dataSpot('snowDepth'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double maxY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(
                LineChartData(
                  minY: -.1,
                  maxY: (maxY >= 1) ? maxY * 1.25 : 1,
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Ultrasonic Snow Depth",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          axisNameSize: 26),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          getTitlesWidget: (value, meta) {
                            if (shortTimeSpan!) {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(14, -5),
                                  child: Text(
                                    DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(10, -5),
                                  child: Text(
                                    DateFormat('MM-dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                          },
                          reservedSize: shortTimeSpan! ? 75 : 40,
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Snow Depth [in]',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            maxIncluded: false,
                            minIncluded: false,
                          )),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        maxIncluded: false,
                        minIncluded: false,
                      ))),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright, //pick something better for colors
                  lineBarsData: [
                    LineChartBarData(
                        color: const Color.fromARGB(255, 45, 93, 117),
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        int count = 0;
                        if (touchedSpots.isEmpty) {
                          return [];
                        }
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          );
                          final date = shortTimeSpan!
                              ? DateFormat('MM-dd - HH:00').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()))
                              : DateFormat('MM-dd-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()));
                          final value = touchedSpot.y;

                          LineTooltipItem first = LineTooltipItem(
                            '$date\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$value "',
                                style: textStyle,
                              )
                            ],
                          );

                          if (count == 0) {
                            count++;
                            return first;
                          } else {
                            return LineTooltipItem(
                              '$value "',
                              textStyle,
                            );
                          }
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event,
                        LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget relativeHumidityGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: dataSpot('relativeHumidity'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Relative Humidity",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          axisNameSize: 26),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          getTitlesWidget: (value, meta) {
                            if (shortTimeSpan!) {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(14, -5),
                                  child: Text(
                                    DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(10, -5),
                                  child: Text(
                                    DateFormat('MM-dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                          },
                          reservedSize: shortTimeSpan! ? 75 : 40,
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Relative Humidity [%]',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            maxIncluded: true,
                            minIncluded: true,
                          )),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        maxIncluded: true,
                        minIncluded: true,
                      ))),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright, //pick something better for colors
                  lineBarsData: [
                    LineChartBarData(
                        color: const Color.fromARGB(255, 117, 79, 65),
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        int count = 0;
                        if (touchedSpots.isEmpty) {
                          return [];
                        }
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          );
                          final date = shortTimeSpan!
                              ? DateFormat('MM-dd - HH:00').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()))
                              : DateFormat('MM-dd-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()));
                          final value = touchedSpot.y;

                          LineTooltipItem first = LineTooltipItem(
                            '$date\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$value %',
                                style: textStyle,
                              )
                            ],
                          );

                          if (count == 0) {
                            count++;
                            return first;
                          } else {
                            return LineTooltipItem(
                              '$value %',
                              textStyle,
                            );
                          }
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event,
                        LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget solarRadiationGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: dataSpot('solarRadiation'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double minY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b);
            double maxY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(
                LineChartData(
                  minY: (minY < 0 ? minY * .9 : -20),
                  maxY: maxY * 1.1,
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Solar Radiation",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          axisNameSize: 26),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          getTitlesWidget: (value, meta) {
                            if (shortTimeSpan!) {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(14, -5),
                                  child: Text(
                                    DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(10, -5),
                                  child: Text(
                                    DateFormat('MM-dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                          },
                          reservedSize: shortTimeSpan! ? 75 : 40,
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Solar Radiation [W/m²]',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            maxIncluded: false,
                            minIncluded: false,
                          )),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        maxIncluded: false,
                        minIncluded: false,
                      ))),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright, //pick something better for colors
                  lineBarsData: [
                    LineChartBarData(
                        color: const Color.fromARGB(255, 170, 67, 67),
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        int count = 0;
                        if (touchedSpots.isEmpty) {
                          return [];
                        }
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          );
                          final date = shortTimeSpan!
                              ? DateFormat('MM-dd - HH:00').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()))
                              : DateFormat('MM-dd-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()));
                          final value = touchedSpot.y;

                          LineTooltipItem first = LineTooltipItem(
                            '$date\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$value W/m²',
                                style: textStyle,
                              )
                            ],
                          );

                          if (count == 0) {
                            count++;
                            return first;
                          } else {
                            return LineTooltipItem(
                              '$value W/m²',
                              textStyle,
                            );
                          }
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event,
                        LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget windSpeedGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: dataSpot('windSpeed'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double maxY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(
                LineChartData(
                  minY: -1,
                  maxY: maxY + 1,
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Wind Speed",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          axisNameSize: 26),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          getTitlesWidget: (value, meta) {
                            if (shortTimeSpan!) {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(14, -5),
                                  child: Text(
                                    DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(10, -5),
                                  child: Text(
                                    DateFormat('MM-dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                          },
                          reservedSize: shortTimeSpan! ? 75 : 40,
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Speed [MPH]',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            maxIncluded: false,
                            minIncluded: false,
                          )),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        maxIncluded: false,
                        minIncluded: false,
                      ))),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright, //pick something better for colors
                  lineBarsData: [
                    LineChartBarData(
                        color: const Color.fromARGB(255, 168, 63, 31),
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        int count = 0;
                        if (touchedSpots.isEmpty) {
                          return [];
                        }
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          );
                          final date = shortTimeSpan!
                              ? DateFormat('MM-dd - HH:00').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()))
                              : DateFormat('MM-dd-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()));
                          final value = touchedSpot.y;

                          LineTooltipItem first = LineTooltipItem(
                            '$date\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$value MPH',
                                style: textStyle,
                              )
                            ],
                          );

                          if (count == 0) {
                            count++;
                            return first;
                          } else {
                            return LineTooltipItem(
                              '$value MPH',
                              textStyle,
                            );
                          }
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event,
                        LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget soilTempGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: Future.wait([
          dataSpot('soilTemperature5'),
          dataSpot('soilTemperature10'),
          dataSpot('soilTemperature20'),
          dataSpot('soilTemperature50'),
          dataSpot('soilTemperature100'),
        ]),
        builder: (context, AsyncSnapshot<List<List<FlSpot>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double minY = snapshot.data!
                .expand((list) => list)
                .map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b);
            double maxY = snapshot.data!
                .expand((list) => list)
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minY: (minY > 5) ? minY - 5 : -2.5,
                        maxY: maxY + 5,
                        titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                                axisNameWidget: Text(
                                  "Soil Temperature",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w700),
                                ),
                                axisNameSize: 26),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                getTitlesWidget: (value, meta) {
                                  if (shortTimeSpan!) {
                                    return Transform.rotate(
                                      angle: (pi / 4),
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(14, -5),
                                        child: Text(
                                          DateFormat('MM-dd - HH:00').format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      value.toInt())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Transform.rotate(
                                      angle: (pi / 4),
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(10, -5),
                                        child: Text(
                                          DateFormat('MM-dd').format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  value.toInt())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                reservedSize: shortTimeSpan! ? 75 : 40,
                                showTitles: true,
                                maxIncluded: false,
                                minIncluded: false,
                              ),
                            ),
                            leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Temperature [°F]',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 38,
                                  maxIncluded: false,
                                  minIncluded: false,
                                )),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              maxIncluded: false,
                              minIncluded: false,
                            ))),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceBright, //pick something better for colors
                        lineBarsData: [
                          LineChartBarData(
                              color: Colors.red,
                              spots: snapshot.data![0],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.blue,
                              spots: snapshot.data![1],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.green,
                              spots: snapshot.data![2],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.orange,
                              spots: snapshot.data![3],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.purple,
                              spots: snapshot.data![4],
                              dotData: FlDotData(show: false)),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              int count = 0;
                              if (touchedSpots.isEmpty) {
                                return [];
                              }
                              return touchedSpots.map((touchedSpot) {
                                final textStyle = TextStyle(
                                  color: touchedSpot.bar.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                                final date = shortTimeSpan!
                                    ? DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            touchedSpot.x.toInt()))
                                    : DateFormat('MM-dd-yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            touchedSpot.x.toInt()));
                                final value = touchedSpot.y;

                                LineTooltipItem first = LineTooltipItem(
                                  '$date\n',
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$value °F',
                                      style: textStyle,
                                    )
                                  ],
                                );

                                if (count == 0) {
                                  count++;
                                  return first;
                                } else {
                                  return LineTooltipItem(
                                    '$value °F',
                                    textStyle,
                                  );
                                }
                              }).toList();
                            },
                          ),
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? touchResponse) {},
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Soil Depth',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.isHydromet)
                              LegendItem(color: Colors.red, text: '2"'),
                            LegendItem(color: Colors.blue, text: '4"'),
                            LegendItem(color: Colors.green, text: '8"'),
                            LegendItem(color: Colors.orange, text: '20"'),
                            LegendItem(color: Colors.purple, text: '40"'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget soilVWCGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: Future.wait([
          dataSpot('soilVWC5'),
          dataSpot('soilVWC10'),
          dataSpot('soilVWC20'),
          dataSpot('soilVWC50'),
          dataSpot('soilVWC100'),
        ]),
        builder: (context, AsyncSnapshot<List<List<FlSpot>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double minY = snapshot.data!
                .expand((list) => list)
                .map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b);
            double maxY = snapshot.data!
                .expand((list) => list)
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minY: (minY > 5) ? minY - 5 : -2.5,
                        maxY: maxY + 5,
                        titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                                axisNameWidget: Text(
                                  "Soil VWC",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w700),
                                ),
                                axisNameSize: 26),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                getTitlesWidget: (value, meta) {
                                  if (shortTimeSpan!) {
                                    return Transform.rotate(
                                      angle: (pi / 4),
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(14, -5),
                                        child: Text(
                                          DateFormat('MM-dd - HH:00').format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      value.toInt())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Transform.rotate(
                                      angle: (pi / 4),
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(10, -5),
                                        child: Text(
                                          DateFormat('MM-dd').format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  value.toInt())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                reservedSize: shortTimeSpan! ? 75 : 40,
                                showTitles: true,
                                maxIncluded: false,
                                minIncluded: false,
                              ),
                            ),
                            leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'VWC %',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 38,
                                  maxIncluded: false,
                                  minIncluded: false,
                                )),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              maxIncluded: false,
                              minIncluded: false,
                            ))),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceBright, //pick something better for colors
                        lineBarsData: [
                          LineChartBarData(
                              color: Colors.red,
                              spots: snapshot.data![0],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.blue,
                              spots: snapshot.data![1],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.green,
                              spots: snapshot.data![2],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.orange,
                              spots: snapshot.data![3],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.purple,
                              spots: snapshot.data![4],
                              dotData: FlDotData(show: false)),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              int count = 0;
                              if (touchedSpots.isEmpty) {
                                return [];
                              }
                              return touchedSpots.map((touchedSpot) {
                                final textStyle = TextStyle(
                                  color: touchedSpot.bar.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                                final date = shortTimeSpan!
                                    ? DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            touchedSpot.x.toInt()))
                                    : DateFormat('MM-dd-yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            touchedSpot.x.toInt()));
                                final value = touchedSpot.y;

                                LineTooltipItem first = LineTooltipItem(
                                  '$date\n',
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$value %',
                                      style: textStyle,
                                    )
                                  ],
                                );

                                if (count == 0) {
                                  count++;
                                  return first;
                                } else {
                                  return LineTooltipItem(
                                    '$value %',
                                    textStyle,
                                  );
                                }
                              }).toList();
                            },
                          ),
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? touchResponse) {},
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Soil Depth',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.isHydromet)
                              LegendItem(color: Colors.red, text: '2"'),
                            LegendItem(color: Colors.blue, text: '4"'),
                            LegendItem(color: Colors.green, text: '8"'),
                            LegendItem(color: Colors.orange, text: '20"'),
                            LegendItem(color: Colors.purple, text: '40"'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget bulkECGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: Future.wait([
          dataSpot('bulkEC5'),
          dataSpot('bulkEC10'),
          dataSpot('bulkEC20'),
          dataSpot('bulkEC50'),
          dataSpot('bulkEC100'),
        ]),
        builder: (context, AsyncSnapshot<List<List<FlSpot>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double minY = snapshot.data!
                .expand((list) => list)
                .map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b);
            double maxY = snapshot.data!
                .expand((list) => list)
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minY: (minY > 0.01) ? minY * 0.9 : -.025,
                        maxY: maxY * 1.1,
                        titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                                axisNameWidget: Text(
                                  "Bulk Electrical Conductivity",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w700),
                                ),
                                axisNameSize: 26),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                minIncluded: false,
                                maxIncluded: false,
                                getTitlesWidget: (value, meta) {
                                  if (shortTimeSpan!) {
                                    return Transform.rotate(
                                      angle: (pi / 4),
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(14, -5),
                                        child: Text(
                                          DateFormat('MM-dd - HH:00').format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      value.toInt())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Transform.rotate(
                                      angle: (pi / 4),
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(10, -5),
                                        child: Text(
                                          DateFormat('MM-dd').format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  value.toInt())),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                reservedSize: shortTimeSpan! ? 75 : 40,
                                showTitles: true,
                              ),
                            ),
                            leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'mS/cm',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  maxIncluded: false,
                                  minIncluded: false,
                                )),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 38,
                              maxIncluded: false,
                              minIncluded: false,
                            ))),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceBright, //pick something better for colors
                        lineBarsData: [
                          LineChartBarData(
                              color: Colors.red,
                              spots: snapshot.data![0],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.blue,
                              spots: snapshot.data![1],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.green,
                              spots: snapshot.data![2],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.orange,
                              spots: snapshot.data![3],
                              dotData: FlDotData(show: false)),
                          LineChartBarData(
                              color: Colors.purple,
                              spots: snapshot.data![4],
                              dotData: FlDotData(show: false)),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              int count = 0;
                              if (touchedSpots.isEmpty) {
                                return [];
                              }
                              return touchedSpots.map((touchedSpot) {
                                final textStyle = TextStyle(
                                  color: touchedSpot.bar.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                                final date = shortTimeSpan!
                                    ? DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            touchedSpot.x.toInt()))
                                    : DateFormat('MM-dd-yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            touchedSpot.x.toInt()));
                                final value = touchedSpot.y;

                                LineTooltipItem first = LineTooltipItem(
                                  '$date\n',
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$value mS/cm',
                                      style: textStyle,
                                    )
                                  ],
                                );

                                if (count == 0) {
                                  count++;
                                  return first;
                                } else {
                                  return LineTooltipItem(
                                    '$value mS/cm',
                                    textStyle,
                                  );
                                }
                              }).toList();
                            },
                          ),
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? touchResponse) {},
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Soil Depth',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.isHydromet)
                              LegendItem(color: Colors.red, text: '2"'),
                            LegendItem(color: Colors.blue, text: '4"'),
                            LegendItem(color: Colors.green, text: '8"'),
                            LegendItem(color: Colors.orange, text: '20"'),
                            LegendItem(color: Colors.purple, text: '40"'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget atmosphericPressureGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder(
        future: dataSpot('atmosphericPressure'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary));
          } else {
            double minY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a < b ? a : b);
            double maxY = snapshot.data!
                .map((spot) => spot.y)
                .reduce((a, b) => a > b ? a : b);
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(
                LineChartData(
                  minY: minY - 5,
                  maxY: maxY + 5,
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Atmospheric Pressure",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                          axisNameSize: 26),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          getTitlesWidget: (value, meta) {
                            if (shortTimeSpan!) {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(14, -5),
                                  child: Text(
                                    DateFormat('MM-dd - HH:00').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            } else {
                              return Transform.rotate(
                                angle: (pi / 4),
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  offset: Offset(10, -5),
                                  child: Text(
                                    DateFormat('MM-dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt())),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                          },
                          reservedSize: shortTimeSpan! ? 75 : 40,
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Pressure [hPa]',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            maxIncluded: false,
                            minIncluded: false,
                          )),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        maxIncluded: false,
                        minIncluded: false,
                      ))),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright, //pick something better for colors
                  lineBarsData: [
                    LineChartBarData(
                        color: Colors.red,
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        int count = 0;
                        if (touchedSpots.isEmpty) {
                          return [];
                        }
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          );
                          final date = shortTimeSpan!
                              ? DateFormat('MM-dd - HH:00').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()))
                              : DateFormat('MM-dd-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpot.x.toInt()));
                          final value = touchedSpot.y;

                          LineTooltipItem first = LineTooltipItem(
                            '$date\n',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$value hPa',
                                style: textStyle,
                              )
                            ],
                          );

                          if (count == 0) {
                            count++;
                            return first;
                          } else {
                            return LineTooltipItem(
                              '$value hPa',
                              textStyle,
                            );
                          }
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event,
                        LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget precipitationGraph() {
    return Card(
      color: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: FutureBuilder<List<FlSpot>>(
        future: dataSpot('precipitation'),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            );
          } else {
            final spots = snapshot.data!;

            late final List<MapEntry<String, double>> barSpots;
            if (shortTimeSpan!) {
              barSpots = spots
                  .map((s) => MapEntry(
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(s.x.toInt())),
                        s.y,
                      ))
                  .toList();
            } else {
              final Map<String, double> dailyPrecip = {};
              for (var spot in spots) {
                final date = DateFormat('yyyy-MM-dd').format(
                  DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
                );
                dailyPrecip[date] = (dailyPrecip[date] ?? 0) + spot.y;
              }
              barSpots = dailyPrecip.entries.toList();
            }

            double maxY =
                barSpots.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

            return Padding(
                padding: const EdgeInsets.all(5.0),
                child: BarChart(BarChartData(
                  minY: -.0025,
                  maxY: maxY * 1.15,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      axisNameWidget: Text(
                        "Precipitation",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      axisNameSize: 26,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: shortTimeSpan! ? 75 : 40,
                        // compute an integer interval (~6 labels across)
                        interval: (barSpots.length <= 6)
                            ? 1.0
                            : (barSpots.length / 6).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          // treat value as an integer bar index
                          final int idx = value.round();
                          if (idx < 0 || idx >= barSpots.length) {
                            return Container();
                          }
                          final int labelInterval = (barSpots.length <= 6)
                              ? 1
                              : (barSpots.length / 6).ceil();
                          if (idx % labelInterval != 0) return Container();

                          // parse/format the stored datetime string
                          DateTime date;
                          try {
                            date = DateTime.parse(barSpots[idx].key);
                          } catch (_) {
                            // fallback: use raw string
                            return Transform.rotate(
                              angle: (pi / 4),
                              alignment: Alignment.topLeft,
                              child: Transform.translate(
                                offset: Offset(14, -5),
                                child: Text(barSpots[idx].key,
                                    style: TextStyle(fontSize: 12)),
                              ),
                            );
                          }

                          final label = shortTimeSpan!
                              ? DateFormat('MM-dd HH:00').format(date)
                              : DateFormat('MM-dd').format(date);

                          return Transform.rotate(
                            angle: (pi / 4),
                            alignment: Alignment.topLeft,
                            child: Transform.translate(
                              offset: Offset(shortTimeSpan! ? 14 : 10, -5),
                              child:
                                  Text(label, style: TextStyle(fontSize: 12)),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Precipitation [in]',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        maxIncluded: false,
                        minIncluded: false,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 48,
                        maxIncluded: false,
                        minIncluded: false,
                      ),
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                  barGroups: List.generate(barSpots.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          width: (MediaQuery.of(context).size.width * .75) /
                              (barSpots.length * 1.3),
                          fromY: 0,
                          toY: double.parse(
                              barSpots[i].value.toStringAsFixed(3)),
                          color: const Color.fromARGB(255, 0, 110, 201),
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date =
                            DateTime.parse(barSpots[group.x.toInt()].key);
                        final value = rod.toY;
                        return BarTooltipItem(
                          (shortTimeSpan!) ?
                          '${DateFormat('MM-dd - HH:mm').format(date)}\n$value in' :
                          '${DateFormat('MM-dd-yyyy').format(date)}\n$value in',
                          TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 0,
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                )));
          }
        },
      ),
    );
  }

  Widget LegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        SizedBox(width: 5),
        Text(text,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          backgroundColor: widget.isHydromet
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          child: Icon(Icons.menu),
        );
      }),

      endDrawer: Drawer(
        child: ListView(
          children: checklist(),
        ),
      ),
      //Call charts from list above
      body: GridView.count(crossAxisCount: 1, children: [
        if (airTemperature!) airTempGraph(),
        if (relativeHumidity!) relativeHumidityGraph(),
        if (precipitation!) precipitationGraph(),
        if (windSpeed!) windSpeedGraph(),
        if (soilTemperature!) soilTempGraph(),
        if (soilVWC!) soilVWCGraph(),
        if (bulkEC!) bulkECGraph(),
        if (atmosphericPressure!) atmosphericPressureGraph(),
        if (snowDepth!) snowDepthGraph(),
        if (solarRadiation!) solarRadiationGraph(),
      ]),
    );
  }
}
