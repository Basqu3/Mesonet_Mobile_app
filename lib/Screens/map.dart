import 'package:app_001/Screens/StationPage.dart';
import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:rainbow_color/rainbow_color.dart';

class map extends StatefulWidget {
  const map({super.key});

  @override
  State<map> createState() => _mapState();
}

class StationMarker {
  final String name;
  final String id;
  final String subNetwork;
  final double lat;
  final double lon;
  final double? air_temp;
  final double? precipSummary;
  final int? date;

  const StationMarker({
    required this.name,
    required this.id,
    required this.subNetwork,
    required this.lat,
    required this.lon,
    required this.air_temp,
    required this.precipSummary, //agrimet does not have precip summary yet!
    required this.date,
  });

  //Use type casting as a saftey check
  //agrimet does not have precip summary, so have to check in factory
  factory StationMarker.fromJson(Map<String, dynamic> json) {
    return StationMarker(
      name: json['name'] as String,
      id: json['station'] as String,
      subNetwork: json['sub_network'] as String,
      lat: json['latitude'] as double,
      lon: json['longitude'] as double,
      air_temp: json['Air Temperature [°F]'] as double,
      precipSummary: json['7-day Precipitation [in]'],
      date: json['datetime'],
    );
  }
}

class _mapState extends State<map> {
  late double _markerSize;
  late double maxTemp;
  late double minTemp;
  late double maxPrecip;
  late bool showAggragateDataMarkers;
  late bool showPrecipAggragateDataMarker;
  late List<StationMarker> stationList;

  int markerindex = 0;

  late MapController mapController;
  late Icon hydrometStations;
  late Icon agrimetStations;
  GeoJsonParser myGeoJson =
      GeoJsonParser(defaultPolygonBorderColor: Colors.black45);
  bool showHydroMet = true;

  //Defaults are set in initState
  @override
  void initState() {
    super.initState();
    stationList = [];
    WidgetsBinding.instance.addPostFrameCallback((_) => loadPolygons());
    WidgetsBinding.instance.addPostFrameCallback((_) => getStations());
    mapController = MapController();
    _markerSize = 16.0; // Default marker size

    hydrometStations = Icon(
      Icons.circle_sharp,
      color: Color.fromARGB(255, 14, 70, 116),
      size: _markerSize,
    );

    agrimetStations = Icon(
      Icons.star,
      color: Color.fromARGB(255, 53, 110, 91),
      size: _markerSize,
    );

    getFavoriteStationList();

    maxTemp = -999.99; //force these to change when called by findRange
    minTemp = 999.99; //need to init to avoid error
    maxPrecip = 0;

    showAggragateDataMarkers = true;
    showPrecipAggragateDataMarker = true;
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<String> loadgeojsonString() async {
    return await rootBundle.loadString('lib/assets/mt_counties.geojson');
  }

  @pragma('vm:entry-point')
  static List<StationMarker> parseToStationMarkers(String responseBody) {
    final parsed =
        (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
    return parsed
        .map<StationMarker>((json) => StationMarker.fromJson(json))
        .toList();
  }

  List<Marker> parseToMarkers(List<StationMarker> stationList) {
    List<Marker> markers = [];
    for (StationMarker station in stationList) {
      if (showHydroMet && station.subNetwork == "HydroMet") {
        markers.add(Marker(
          height: _markerSize,
          width: _markerSize,
          point: LatLng(station.lat, station.lon),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HydroStationPage(station: station, hydroBool: 1),
                ),
              );
            },
            child: Icon(
              Icons.circle_sharp,
              color: isCurrentDate(station.date!) //is current date
                  ? showAggragateDataMarkers //show temp or precip data
                      ? showPrecipAggragateDataMarker
                          ? setMarkerColor(station.precipSummary!, false)
                          : setMarkerColor(
                              station.air_temp!, true) //show precip data
                      : Color.fromARGB(255, 14, 70, 116)
                  : Colors.black54,
              size: _markerSize,
            ),
          ),
        ));
      } else if (!showHydroMet && station.subNetwork == "AgriMet") {
        markers.add(Marker(
          point: LatLng(station.lat, station.lon),
          height: _markerSize,
          width: _markerSize,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HydroStationPage(station: station, hydroBool: 0),
                ),
              );
            },
            child: Icon(
              Icons.star,
              color: showAggragateDataMarkers
                  ? setMarkerColor(station.air_temp!, true)
                  : Color.fromARGB(255, 53, 110, 91),
              size: _markerSize,
            ),
          ),
        ));
      }
    }
    return markers;
  }

  Future<List<StationMarker>> getStations() async {
    String url = 'https://mesonet.climate.umt.edu/api/v2/app/?type=json';
    String response = '';
    try {
      response = await compute(apiCall, url);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    final List<StationMarker> stationListTemp =
        await compute(parseToStationMarkers, response);
    stationList = stationListTemp;
    return stationListTemp;
  }

  void loadPolygons() async {
    String mygeoString = await loadgeojsonString();
    myGeoJson.parseGeoJsonAsString(mygeoString); //pull from asset
  }

  Future<List<Marker>> getMarkers() async {
    findRange(stationList); //setting max and min for markerColor
    List<Marker> markers = parseToMarkers(stationList);
    //List<Marker> markers = await compute(parseToMarkers, stationList);
    return markers;
  }

  Future<List<StationMarker>> returnStations() async {
    return stationList;
  }

  Future<List<StationMarker>> getFavoriteStationList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonStringList = prefs.getString('favorites');
    Map<String, dynamic> jsonMAP = jsonDecode(jsonStringList!); //no null safe
    List<StationMarker> jsonStationList = [];
    for (int i = 0; i < (jsonMAP['stations'].length); i++) {
      jsonStationList.add(StationMarker(
        name: jsonMAP['stations'][i]['name'],
        id: jsonMAP['stations'][i]['id'],
        subNetwork: jsonMAP['stations'][i]['sub_network'],
        lat: jsonMAP['stations'][i]['lat'],
        lon: jsonMAP['stations'][i]['lon'],
        air_temp: jsonMAP['stations'][i]['air_temp'],
        precipSummary: jsonMAP['stations'][i]['precipSummary'],
        date: jsonMAP['stations'][i]['date'],
      ));
    }
    setState(() {}); // Call setState once after the loop
    return jsonStationList;
  }

  void _updateMarkerSize(double zoom) {
    if (zoom > 6.4) {
      setState(() {
        //_markerSize = 50.0 * (zoom / 13.0);
        _markerSize = 20;
      });
    } else {
      setState(() {
        _markerSize = 20;
      });
    }
  }

  bool isCurrentDate(int dateFromData) {
    DateTime now = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateFromData);

    return now.day == date.day &&
        now.month == date.month &&
        now.year == date.year;
  }

  void findRange(List<StationMarker> stationList) {
    minTemp = 999.00;
    maxTemp = -999.00;
    maxPrecip = -1;
    //set global variables. Call from get markers
    for (StationMarker station in stationList) {
      if (station.air_temp == null || station.air_temp == 999.00) {
        continue;
      }

      if (station.precipSummary == null || station.precipSummary == 999.00) {
        continue;
      }

      if (station.air_temp! > maxTemp &&
          station.subNetwork == 'HydroMet' &&
          isCurrentDate(station.date!)) {
        //check max temp
        maxTemp = station.air_temp!;
      }

      if (station.air_temp! < minTemp &&
          station.subNetwork == 'HydroMet' &&
          isCurrentDate(station.date!)) {
        //check min temp
        minTemp = station.air_temp!;
      }

      if (station.precipSummary! > maxPrecip &&
          station.subNetwork == 'HydroMet' &&
          isCurrentDate(station.date!)) {
        //check precip
        maxPrecip = station.precipSummary!;
      }
    }
  }

  Color setMarkerColor(double input, bool tempOrPrecip) {
    Rainbow rbColorTemp;

    if (input < 32) {
      //dynamic color range with hard break at 32 F
      rbColorTemp = Rainbow(
        spectrum: [
          Colors.blue.shade900,
          Color.fromARGB(255, 43, 140, 190),
          Color.fromARGB(255, 189, 201, 225),
          Colors.white,
        ], //cold to hot
        rangeStart:
            minTemp, //min and max set in findRange() func called in getMarkers
        rangeEnd: (maxTemp < 32) ? maxTemp : 32,
      );
    } else {
      rbColorTemp = Rainbow(
        spectrum: [
          Color.fromARGB(255, 255, 255, 120),
          Color.fromARGB(255, 253, 141, 60),
          Color.fromARGB(255, 240, 59, 32),
        ], //cold to hot
        rangeStart: (minTemp > 32) ? minTemp : 32,
        rangeEnd: maxTemp,
      );
    }

    var rbColorPrecip = Rainbow(
      //static range showing precip
      spectrum: [
        Color.fromARGB(255, 105, 61, 16),
        Color.fromARGB(255, 223, 194, 125),
        Color.fromARGB(255, 106, 219, 135),
        Color.fromARGB(255, 1, 133, 113),
      ],
      rangeStart: 0, //no rain
      rangeEnd:
          maxPrecip, //max amount of rain expected in a 7-day period in in. Fine if broken
    );

    if (tempOrPrecip) {
      return rbColorTemp[input];
    } else {
      return rbColorPrecip[input];
    }
  }

  IconData FABReturnIcon(int index) {
    //0 = temp, 1 = normal, 2 = precip
    if (index == 0) {
      setState(() {
        showAggragateDataMarkers = true;
        showPrecipAggragateDataMarker = false;
      });

      return Icons.thermostat;
    } else if (index == 1) {
      setState(() {
        showAggragateDataMarkers = false;
        showPrecipAggragateDataMarker = false;
      });

      return Icons.circle;
    } else {
      setState(() {
        showAggragateDataMarkers = true;
        showPrecipAggragateDataMarker = true;
      });

      return Icons.water_drop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: true,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                markerindex += 1;
                if (showHydroMet) {
                  markerindex = markerindex % 3;
                } else {
                  markerindex = markerindex % 2;
                }
              });
            },
            child: Icon(FABReturnIcon(markerindex)),
          ),
          appBar: AppBar(
            leading: Builder(builder: (context) {
              return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.star));
            }),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            centerTitle: true,
            title: Center(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    'lib/assets/MCO_logo.png',
                    fit: BoxFit.fill,
                    height: 50,
                  ),
                ),
              ),
            ),
          ),
          drawer: Drawer(
            child: FutureBuilder(
                future: getFavoriteStationList(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    //print(snapshot.data);
                    return const Center(
                      child: Text('An error has occurred!'),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<StationMarker> stationList =
                        snapshot.data as List<StationMarker>;

                    return (stationList.isEmpty)
                        ? const Center(
                            child: Text('No Favorites'),
                          )
                        :
                    
                    ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: stationList.length,
                        itemBuilder: (context, index) {
                          StationMarker station = stationList[index];

                          return ListTile(
                            leading: Icon(
                              station.subNetwork == "HydroMet"
                                  ? hydrometStations.icon
                                  : agrimetStations.icon,
                              color: station.subNetwork == "HydroMet"
                                  ? hydrometStations.color
                                  : agrimetStations.color,
                            ),
                            title: Text(station.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HydroStationPage(
                                    station: station,
                                    hydroBool: station.subNetwork == "HydroMet"
                                        ? 1
                                        : 0,
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  }
                }),
          ),
          endDrawer: Drawer(
            child: FutureBuilder(
              future: returnStations(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                } else if (snapshot.hasData) {
                  List<StationMarker> stationList =
                      snapshot.data as List<StationMarker>;
                  return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: stationList.length,
                      itemBuilder: (context, index) {
                        StationMarker station = stationList[index];
                        return ListTile(
                          leading: Icon(
                            station.subNetwork == "HydroMet"
                                ? hydrometStations.icon
                                : agrimetStations.icon,
                            color: station.subNetwork == "HydroMet"
                                ? hydrometStations.color
                                : agrimetStations.color,
                          ),
                          title: Text(station.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HydroStationPage(
                                  station: station,
                                  hydroBool:
                                      station.subNetwork == "HydroMet" ? 1 : 0,
                                ),
                              ),
                            );
                          },
                        );
                      });
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          body: Stack(
            children: [
              FutureBuilder(
                future: getMarkers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text('Refresh')),
                    );
                  } else if (snapshot.hasData) {
                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(46.681625, -110.04365),
                        initialZoom: 5.5,
                        keepAlive: true,
                        interactionOptions: const InteractionOptions(
                          flags:
                              InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        ),
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture) {
                            //_updateMarkerSize(position.zoom);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'MontanaClimateOffice.app',
                        ),
                        PolygonLayer(polygons: myGeoJson.polygons),
                        MarkerLayer(markers: snapshot.data as List<Marker>),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: SimpleAttributionWidget(
                            backgroundColor: Colors.transparent,
                            source: Text('OpenStreetMap contributors'),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        showAggragateDataMarkers
                            ? Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      //   side: BorderSide(  //adds black border to card
                                      //   color:
                                      //       Theme.of(context).colorScheme.onPrimaryContainer,
                                      //   width: 1.0,
                                      // )
                                    ),
                                    color: Colors.white38,
                                    child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: IntrinsicWidth(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(showPrecipAggragateDataMarker
                                                ? '14 Day Precipitation'
                                                : 'Temperature'),
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                      gradient: LinearGradient(
                                                    colors:
                                                        !showPrecipAggragateDataMarker
                                                            ? [
                                                                setMarkerColor(
                                                                    minTemp, true),
                                                                !(minTemp >= 32 ||
                                                                        maxTemp <=
                                                                            32)
                                                                    ? setMarkerColor(
                                                                        31, true)
                                                                    : setMarkerColor(
                                                                        (2.25 *
                                                                            (minTemp +
                                                                                maxTemp) /
                                                                            5),
                                                                        true),
                                                                !(minTemp >= 32 ||
                                                                        maxTemp <=
                                                                            32)
                                                                    ? setMarkerColor(
                                                                        33, true)
                                                                    : setMarkerColor(
                                                                        (2.75 *
                                                                            (minTemp +
                                                                                maxTemp) /
                                                                            5),
                                                                        true),
                                                                setMarkerColor(
                                                                    maxTemp, true)
                                                              ]
                                                            : [
                                                                setMarkerColor(
                                                                    0, false),
                                                                setMarkerColor(
                                                                    maxPrecip / 2,
                                                                    false),
                                                                setMarkerColor(
                                                                    maxPrecip,
                                                                    false),
                                                              ],
                                                  )),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 5),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children:
                                                          showPrecipAggragateDataMarker
                                                              ? [
                                                                  Text('0 in',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white)),
                                                                  Text(
                                                                    '$maxPrecip in',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ]
                                                              : [
                                                                  Text(
                                                                    '${minTemp.toStringAsFixed(0)}°F',
                                                                    style: TextStyle(
                                                                        color: (minTemp >= 32)
                                                                            ? Colors
                                                                                .black
                                                                            : Colors
                                                                                .white),
                                                                  ),
                                                                  !(minTemp >=
                                                                          32.00)
                                                                      ? Text('32°F')
                                                                      : Text(''),
                                                                  Text(
                                                                      '${maxTemp.toStringAsFixed(0)}°F'),
                                                                ]),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ),
                            )
                            : Container(),
                        Card(
                          color: Colors.white38,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child:  Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Switch(
                                value: showHydroMet,
                                onChanged: (value) {
                                  setState(() {
                                    showPrecipAggragateDataMarker = false;
                                    showHydroMet = value;
                                    showAggragateDataMarkers = false;
                                  });
                                },
                                activeColor: Theme.of(context).colorScheme.onPrimary,
                                activeTrackColor: hydrometStations.color,
                                inactiveThumbColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                inactiveTrackColor: agrimetStations.color,
                              ),
                          
                              Center(
                                child: Text(
                                  showHydroMet ? 'HydroMet' : 'AgriMet',
                                  style: TextStyle(
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),)
                         
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
