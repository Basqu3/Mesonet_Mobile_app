import 'dart:convert';
import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart';
import 'JSONData.dart';

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
      print(e);
    }

    List<dynamic> dataMap = jsonDecode(response);

    for (int i = 0; i < dataMap.length; i++) {
      dataList.add(Data.fromJson(dataMap[i]));
    }
    return dataList;
  }

//================================================================================

//This block handles the checklist and date picker
  List<Widget> checklist() {
    List<Widget> checklist = [];

    checklist.add(ListTile(
      leading: Text(
        '${f.format(_selectedDateRange!.start)} - ${f.format(_selectedDateRange!.end)}',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      trailing: MaterialButton(
        color: widget.isHydromet
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        onPressed: _show,
        child: Icon(Icons.date_range),
      ),
    ));

    checklist.add(CheckboxListTile(
      title: Text('Air Temperature'),
      value: airTemperature,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          airTemperature = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Atmospheric Pressure'),
      value: atmosphericPressure,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          atmosphericPressure = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Bulk EC'),
      value: bulkEC,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          bulkEC = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Gust Speed'),
      value: gustSpeed,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          gustSpeed = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Maximum Precipitation Rate'),
      value: maxPrecipRate,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          maxPrecipRate = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Precipitation'),
      value: precipitation,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          precipitation = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Reference ET'),
      value: referenceET,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          referenceET = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Relative Humidity'),
      value: relativeHumidity,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          relativeHumidity = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Snow Depth'),
      value: snowDepth,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          snowDepth = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Soil Temperature'),
      value: soilTemperature,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          soilTemperature = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Soil Volumetric Water Content'),
      value: soilVWC,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          soilVWC = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Solar Radiation'),
      value: solarRadiation,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          solarRadiation = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Wind Direction'),
      value: windDirection,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          windDirection = value;
        });
      },
    ));

    checklist.add(CheckboxListTile(
      title: Text('Wind Speed'),
      value: windSpeed,
      activeColor: widget.isHydromet
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onChanged: (bool? value) {
        setState(() {
          windSpeed = value;
        });
      },
    ));

    setState(() {});
    return checklist;
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

  Future<List<FlSpot>> dataSpot(String param) async {
    List<FlSpot> airTemperatureSpotList = [];

    List<Data> data = await getDataList();
    //this ignores null checks. also really slow. Fix
    for (int i = 0; i < data.length; i++) {
      //  int x = data[i].datetime ?? 0;   //This is currently not used. consider breaking into different area?
      double y = 0;
      bool null_hit = false;

      switch (param) {
        case 'airTemperature':
          if (data[i].airTemperature == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].airTemperature!;
          }
          break;
        case 'atmosphericPressure':
          if (data[i].atmosphericPressure == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].atmosphericPressure!;
          }
          break;
        case 'gustSpeed':
          if (data[i].gustSpeed == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].gustSpeed!;
          }
          break;
        case 'maxPrecipRate':
          if (data[i].maxPrecipRate == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].maxPrecipRate!;
          }
          break;
        case 'precipitation':
          if (data[i].Precipitation == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].Precipitation!;
          }
          break;
        case 'relativeHumidity':
          if (data[i].relativeHumidity == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].relativeHumidity!;
          }
          break;
        case 'snowDepth':
          if (data[i].snowDepth == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].snowDepth!;
          }
          break;
        case 'soilTemperature5':
          if (data[i].soilTemperature5 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilTemperature5!;
          }
          break;
        case 'soilTemperature10':
          if (data[i].soilTemperature10 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilTemperature10!;
          }
          break;
        case 'soilTemperature20':
          if (data[i].soilTemperature20 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilTemperature20!;
          }
          break;
        case 'soilTemperature50':
          if (data[i].soilTemperature50 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilTemperature50!;
          }
          break;
        case 'soilTemperature100':
          if (data[i].soilTemperature100 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilTemperature100!;
          }
          break;
        case 'soilVWC5':
          if (data[i].soilVWC5 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilVWC5!;
          }
          break;
        case 'soilVWC10':
          if (data[i].soilVWC10 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilVWC10!;
          }
          break;
        case 'soilVWC20':
          if (data[i].soilVWC20 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilVWC20!;
          }
          break;
        case 'soilVWC50':
          if (data[i].soilVWC50 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilVWC50!;
          }
          break;
        case 'soilVWC100':
          if (data[i].soilVWC100 == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].soilVWC100!;
          }
          break;
        case 'solarRadiation':
          if (data[i].solarRadiation == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].solarRadiation!;
          }
          break;
        case 'windDirection':
          if (data[i].windDirection == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].windDirection!;
          }
          break;
        case 'windSpeed':
          if (data[i].windSpeed == null) {
            null_hit = true;
            break;
          } else {
            y = data[i].windSpeed!;
          }
          break;
        // default:
        //   y = 0;
      }

      if (!null_hit) {
        airTemperatureSpotList.add(FlSpot(data[i].datetime!.toDouble(), y));
      }
    }
    return airTemperatureSpotList;
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
                            color: touchedSpot.bar.color,
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
                  minY: 0,
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
                        color: Colors.red,
                        spots: snapshot.data!,
                        dotData: FlDotData(show: false))
                  ],
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
                        minY: minY - 5,
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
                    child: Row(
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
                        minY: minY - 5,
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
                    child: Row(
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
                            color: touchedSpot.bar.color,
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
            // Group data by day for bar chart
            final Map<String, double> dailyPrecip = {};
            for (var spot in spots) {
              final date = DateFormat('yyyy-MM-dd').format(
                DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
              );
              dailyPrecip[date] = (dailyPrecip[date] ?? 0) + spot.y;
            }
            final barSpots = dailyPrecip.entries.toList();

            double maxY = barSpots.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY + 0.1,
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
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < barSpots.length) {
                            final date = DateTime.parse(barSpots[index].key);
                            return Transform.rotate(
                              angle: (pi / 4),
                              alignment: Alignment.topLeft,
                              child: Transform.translate(
                                offset: Offset(shortTimeSpan! ? 14 : 10, -5),
                                child: Text(
                                  shortTimeSpan!
                                      ? DateFormat('MM-dd').format(date)
                                      : DateFormat('MM-dd').format(date),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                        reservedSize: shortTimeSpan! ? 75 : 40,
                        showTitles: true,
                        maxIncluded: false,
                        minIncluded: false,
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
                          fromY: 0,
                          toY: double.parse(barSpots[i].value.toStringAsFixed(3)),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            );
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
        if (precipitation!) precipitationGraph(),
        if (windSpeed!) windSpeedGraph(),
        if (soilTemperature!) soilTempGraph(),
        if (soilVWC!) soilVWCGraph(),
        if (atmosphericPressure!) atmosphericPressureGraph(),
      ]),
    );
  }
}
