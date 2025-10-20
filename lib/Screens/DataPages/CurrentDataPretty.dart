import 'package:app_001/Screens/DataPages/Hero_Pages/soil_profiles.dart';
import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/heroPhotoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'JSONData.dart';
import 'Hero_Pages/Alerts.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/Precip.dart';
import 'package:flutter/services.dart';

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
      print('CurrentDataPretty: ${widget.id}');
      if (!isCurrentDate(value.datetime!) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Data is not up to date! Shown data is from ${DateFormat('MM/dd/yyyy').format(DateTime.fromMillisecondsSinceEpoch(value.datetime!))} which is the latest available data.',
                textAlign: TextAlign.center,
              ),
            ),
            duration: const Duration(seconds: 5),
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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else if (snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.isHydromet
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width /
                                (1520 / 868),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  widget.isHydromet
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HeroPhotoPage(
                                                          id: widget.id,
                                                        ))).then(
                                                (value) => setState(() {}));
                                          },
                                          child: Hero(
                                              tag: widget.id,
                                              child:
                                                  PhotoPage(id: widget.id)))
                                      : Container(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FadeTransition(
                                        opacity: Tween(begin: 1.0, end: 0.0)
                                            .animate(
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
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FadeTransition(
                                        opacity: Tween(begin: 1.0, end: 0.0)
                                            .animate(
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
                                  ),
                                ],
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                            child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: (snapshot.data!.airTemperature != null)
                              ? Text(
                                  'Air Temperature: ${snapshot.data!.airTemperature!.toStringAsFixed(2)}°F',
                                  softWrap: false,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryFixed),
                                )
                              : Text('Temperature N/A'),
                        )),
                        Flexible(
                            child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: (snapshot.data!.relativeHumidity != null)
                              ? Text(
                                  'Relative Humidity: ${snapshot.data!.relativeHumidity!.toStringAsFixed(2)}%',
                                  softWrap: false,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryFixed),
                                )
                              : Text('Humidity N/A'),
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
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Stack(children: [
                              soil_profiles(
                                data: snapshot.data!,
                                isHydromet: widget.isHydromet,
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: InfoPopupWidget(
                                      contentTitle:
                                          'We install soil sensors at various depths to monitor the flow of water.\n'
                                          'The soil profile information includes the temperature of the soil at the given depths and the volumetric water content of the soil.\n'
                                          'VWC = (volume of water/volume of soil expressed as a percentage)\n'
                                          'The soil profile is a valuable tool for understanding the movement of water through the soil and the potential for runoff.',
                                      arrowTheme: const InfoPopupArrowTheme(
                                        color: Colors.white,
                                      ),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white38,
                                          ),
                                          child: Icon(
                                            Icons.question_mark_rounded,
                                            size: 15,
                                          ))))
                            ]),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: Column(
                          children: [
                            Flexible(
                              flex: 2,
                              child: Row(
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
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Alerts(
                                            lat: widget.lat,
                                            lng: widget.lng,
                                            isHydromet: widget.isHydromet,
                                          )),
                                    ),
                                  ),
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
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Stack(children: [
                                          Precip(
                                            id: widget.id,
                                            isHydromet: widget.isHydromet,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: FadeTransition(
                                                opacity: Tween(
                                                        begin: 1.0, end: 0.0)
                                                    .animate(
                                                  CurvedAnimation(
                                                    parent:
                                                        _animationController,
                                                    curve: Interval(0.3, 1.0,
                                                        curve: Curves
                                                            .easeOutBack),
                                                  ),
                                                ),
                                                child: Icon(
                                                    Icons.arrow_downward,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: Card(
                                color: widget.isHydromet
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(padding: EdgeInsets.only(top: 3)),
                                    Center(
                                      child: Text(
                                        'Current Wind',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Image.asset(
                                                'lib/assets/cadrant.png',
                                              ),
                                              Transform.rotate(
                                                angle: snapshot.data!
                                                    .windDirection as double,
                                                child: Image.asset(
                                                  'lib/assets/compass.png',
                                                  scale: 2.0,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child:
                                          (snapshot.data!.windSpeed != null)
                                              ? Text(
                                                  '${snapshot.data!.windSpeed!.toString()} Mi/hr',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                )
                                              : Text(
                                                  'Wind Speed N/A',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                    ),
                                    Padding(padding: EdgeInsets.only(bottom: 2))
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
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
