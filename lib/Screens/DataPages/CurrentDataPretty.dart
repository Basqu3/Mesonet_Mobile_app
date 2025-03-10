import 'package:app_001/Screens/DataPages/Hero_Pages/soil_profiles.dart';
import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'JSONData.dart';
import 'Hero_Pages/Alerts.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/Precip.dart';

class CurrentDataPretty extends StatefulWidget {
  final String id;
  final double lat;
  final double lng;
  final bool isHydromet;
  const CurrentDataPretty(
      {super.key,
      required this.id,
      required this.lat,
      required this.lng,
      required this.isHydromet});

  @override
  State<CurrentDataPretty> createState() => _CurrentDataPrettyState();
}

class _CurrentDataPrettyState extends State<CurrentDataPretty>
    with SingleTickerProviderStateMixin {
  late Future<Data> _dataFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    super.initState();
    _animationController.forward();
    _dataFuture = getData(
        'https://mesonet.climate.umt.edu/api/v2/latest/?type=json&stations=${widget.id}');
    _dataFuture.then((value) {
      if (!isCurrentDate(value.datetime!) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Data is not up to date! Shown data is from ${DateFormat('MM/dd/yyyy').format(DateTime.fromMillisecondsSinceEpoch(value.datetime!))} which is the latest available data.',
                textAlign: TextAlign.center,
              ),
            ),
            duration: const Duration(seconds: 7),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @pragma('vm:entry-point')
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  Future<Data> getData(String url) async {
    Data dataList;
    String data = await flutterCompute(apiCall, url);
    List<dynamic> dataMap = jsonDecode(data);

    dataList = (Data.fromJson(dataMap[0]));

    return dataList;
  }

  bool isCurrentDate(int dateFromData) {
    DateTime now = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateFromData);

    return now.day == date.day &&
        now.month == date.month &&
        now.year == date.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                widget.isHydromet
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: AspectRatio(
                              aspectRatio: 1.75,
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        width: 1.0)),
                                child: Stack(
                                  children: [
                                    widget.isHydromet
                                        ? PhotoPage(id: widget.id)
                                        : Container(),
                                    Positioned(
                                      left: 10,
                                      top: 0,
                                      bottom: 0,
                                      child: FadeTransition(
                                        opacity:
                                            Tween(begin: 1.0, end: 0.0).animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: Interval(0.3, 1.0,
                                                curve: Curves.easeOutBack),
                                          ),
                                        ),
                                        child: Icon(Icons.arrow_back,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 0,
                                      bottom: 0,
                                      child: FadeTransition(
                                        opacity:
                                            Tween(begin: 1.0, end: 0.0).animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: Interval(0.3, 1.0,
                                                curve: Curves.easeOutBack),
                                          ),
                                        ),
                                        child: Icon(Icons.arrow_forward,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Container(),
                Flexible(
                  flex: widget.isHydromet ? 1 : 1,
                  child: Card(
                    color: widget.isHydromet
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          width: 1.0,
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                            child: Text(
                          'Air Temperature: ${snapshot.data!.airTemperature.toString()}[°F]',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.onPrimaryFixed),
                        )),
                        Flexible(
                            child: Text(
                          'Relative Humidity: ${snapshot.data!.relativeHumidity.toString()}[%]',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.onPrimaryFixed),
                        )),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Card(
                          color: widget.isHydromet
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                width: 1.0,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: soil_profiles(
                              data: snapshot.data!,
                              isHydromet: widget.isHydromet,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Card(
                                      color: widget.isHydromet
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            width: 1.0,
                                          )),
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Alerts(
                                            lat: widget.lat,
                                            lng: widget.lng,
                                          )),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Card(
                                        color: widget.isHydromet
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Placeholder()),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: Card(
                                      color: widget.isHydromet
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            width: 1.0,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Stack(children: [
                                          Precip(
                                            id: widget.id,
                                            isHydromet: widget.isHydromet,
                                          ),
                                          Positioned(
                                            right: 40,
                                            top: 300,
                                            bottom: 10,
                                            child: FadeTransition(
                                              opacity:
                                                  Tween(begin: 1.0, end: 0.0)
                                                      .animate(
                                                CurvedAnimation(
                                                  parent: _animationController,
                                                  curve: Interval(0.2, 1.0,
                                                      curve:
                                                          Curves.easeOutBack),
                                                ),
                                              ),
                                              child: Icon(Icons.arrow_downward,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Card(
                                      color: widget.isHydromet
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            width: 1.0,
                                          )),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: AspectRatio(
                                              aspectRatio: 1 / 1,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Image.asset(
                                                    'lib/assets/cadrant.png',
                                                  ),
                                                  Transform.rotate(
                                                    angle: snapshot
                                                            .data!.windDirection
                                                        as double,
                                                    child: Image.asset(
                                                      'lib/assets/compass.png',
                                                      scale: 2.5,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Center(
                                            child: Text(
                                              '${snapshot.data!.windSpeed!.toString()} Mi/hr',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
