import 'package:app_001/Screens/DataPages/Hero_Pages/soil_profiles.dart';
import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/heroPhoto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'JSONData.dart';
import 'Hero_Pages/Alerts.dart';

class AgrimetCurrentData extends StatefulWidget {
  final String id;
  final double lat;
  final double lng;
  final bool isHydromet;
  const AgrimetCurrentData(
      {super.key,
      required this.id,
      required this.lat,
      required this.lng,
      required this.isHydromet});

  @override
  State<AgrimetCurrentData> createState() => _AgrimetCurrentDataState();
}

class _AgrimetCurrentDataState extends State<AgrimetCurrentData>
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
    return Scaffold(
        body: FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        } else {
          Data data = snapshot.data!;
          return Column(
            children: [
              Flexible(
                flex: 24,
                child: Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            Flexible(
                                flex: 6,
                                child: Card(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: Stack(children: [
                                        // Center(
                                        //   child: CircularProgressIndicator(
                                        //     color: Theme.of(context)
                                        //         .colorScheme
                                        //         .onPrimary,
                                        //   ),
                                        // ),
                                        Center(
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        heroPhoto(id: widget.id),
                                                  ),
                                                );
                                              },
                                              child: Hero(
                                                  tag: widget.id,
                                                  child: Image.network(
                                                    'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}',
                                                    fit: BoxFit.cover,
                                                    loadingBuilder:
                                                        (BuildContext context,
                                                            Widget child,
                                                            ImageChunkEvent?
                                                                loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSecondary,
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (BuildContext
                                                            context,
                                                        Object exception,
                                                        StackTrace? stackTrace) {
                                                      return Center(
                                                          child: Text(
                                                              'Image does not exist or could not be loaded.',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSecondary,)
                                                              ));
                                                    },
                                                  ))),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: InfoPopupWidget(
                                                  contentTitle:
                                                      'All photos are static images taken at the installation of the station.\n'
                                                      'Photos may not be available for all stations.\n'
                                                      'We are adding new photos of agrimets all the time.',
                                                  arrowTheme:
                                                      const InfoPopupArrowTheme(
                                                    color: Colors.white,
                                                  ),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white38,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .question_mark_rounded,
                                                        size: 15,
                                                      )))),
                                        ),
                                      ])),
                                )),
                            // if photo, then photo,temp,wind
                            //if not photo, then alerts, temp, wind

                            Flexible(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        clipBehavior: Clip.hardEdge,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: (snapshot.data!
                                                          .airTemperature !=
                                                      null)
                                                  ? Text(
                                                      'Air Temperature: ${snapshot.data!.airTemperature!.toStringAsFixed(2)}°F',
                                                      softWrap: false,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryFixed),
                                                    )
                                                  : Text('Temperature N/A'),
                                            )),
                                            Flexible(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: (snapshot.data!
                                                          .relativeHumidity !=
                                                      null)
                                                  ? Text(
                                                      'Relative Humidity: ${snapshot.data!.relativeHumidity!.toStringAsFixed(2)}%',
                                                      softWrap: false,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onPrimaryFixed),
                                                    )
                                                  : Text('Humidity N/A'),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),

                            Flexible(
                              flex: 6,
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                    Expanded(
                                        child: Center(
                                      child: Text(
                                        '${snapshot.data!.windSpeed!.toString()} Mi/hr',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Card(
                              color: Theme.of(context).colorScheme.secondary,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Alerts(
                                lat: widget.lat,
                                lng: widget.lng,
                                isHydromet: widget.isHydromet,
                              ),
                            ),
                          ),
                          //if photo. then alerts and soil
                          //if not photo, then soil only
                          Flexible(
                            flex: 4,
                            child: Card(
                              color: Theme.of(context).colorScheme.secondary,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(children: [
                                soil_profiles(
                                  data: data,
                                  isHydromet: false,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Align(
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
                                              )))),
                                )
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(
                flex: 1,
              ),
            ],
          );
        }
      },
    ));
  }
}
