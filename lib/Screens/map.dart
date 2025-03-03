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
    WidgetsBinding.instance.addPostFrameCallback((_) => loadPolygons());

    mapController = MapController();
    _markerSize = 16.0; // Default marker size

    hydrometStations = Icon(
      Icons.circle_sharp,
      color: Color.fromARGB(255, 14, 70, 116),
      size: _markerSize,
    );

    agrimetStations = Icon(
      Icons.star,
      color: Color.fromARGB(255, 46, 155, 18),
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
              color: showAggragateDataMarkers //show temp or precip data
                  ? showPrecipAggragateDataMarker
                      ? setMarkerColor(station.precipSummary!, false)
                      : setMarkerColor(
                          station.air_temp!, true) //show precip data
                  : Color.fromARGB(255, 14, 70, 116),
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
                  : Color.fromARGB(255, 46, 155, 18),
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

    final List<StationMarker> stationList =
        await compute(parseToStationMarkers, response);
    return stationList;
  }

  void loadPolygons() async {
    String mygeoString = await loadgeojsonString();
    myGeoJson.parseGeoJsonAsString(mygeoString); //pull from asset
  }

  Future<List<Marker>> getMarkers() async {
    List<StationMarker> stationList = await getStations();
    findRange(stationList); //setting max and min for markerColor
    List<Marker> markers = parseToMarkers(stationList);
    //List<Marker> markers = await compute(parseToMarkers, stationList);
    return markers;
  }

  Future<List<StationMarker>> getFavoriteStationList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonStringList = prefs.getString('favorites');
    Map<String, dynamic> jsonMAP = jsonDecode(jsonStringList!); //no null safe
    //print(jsonMAP['stations'][0]['name']);
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
    // setState(() {

    // });
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

      if (station.air_temp! < minTemp && station.subNetwork == 'HydroMet') {
        //check min temp
        minTemp = station.air_temp!;
      }

      if (station.precipSummary! > maxPrecip &&
          station.subNetwork == 'HydroMet') {
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
          Colors.blue.shade700,
          Colors.blue.shade500,
          Colors.blue.shade300,
          Colors.blue.shade100,
          Colors.white,
        ], //cold to hot
        rangeStart:
            minTemp, //min and max set in findRange() func called in getMarkers
        rangeEnd: (maxTemp < 32) ? maxTemp : 32,
      );
    } else {
      rbColorTemp = Rainbow(
        spectrum: [
          Colors.white,
          Colors.red.shade100,
          Colors.red.shade300,
          Colors.red.shade500,
          Colors.red.shade700,
          Colors.red.shade900,
        ], //cold to hot
        rangeStart: (minTemp > 32) ? minTemp : 32,
        rangeEnd: maxTemp,
      );
    }

    var rbColorPrecip = Rainbow(
      //static range showing precip
      spectrum: [
        Colors.white,
        Colors.blue.shade100,
        Colors.blue.shade200,
        Colors.blue.shade300,
        Colors.blue.shade400,
        Colors.blue.shade500,
        Colors.blue.shade600,
        Colors.blue.shade700,
        Colors.blue.shade800,
        Colors.blue.shade900,
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
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: (){
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.star));
              }
            ),

            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 5,
            centerTitle: true,
            title: Center(
              child: Image.asset(
                'lib/assets/MCO_logo.png',
                fit: BoxFit.fill,
                height: 50,
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

                    // print(snapshot.data);

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
              future: getStations(),
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
                          bottom: 10,
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
              Positioned(
                top: 10,
                right: 10,
                child: Switch(
                  value: showHydroMet,
                  onChanged: (value) {
                    setState(() {
                      showHydroMet = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.onPrimary,
                  activeTrackColor: hydrometStations.color,
                  inactiveThumbColor: Theme.of(context).colorScheme.onSecondary,
                  inactiveTrackColor: agrimetStations.color,
                ),
              ),

              Positioned(
                top: 10,
                left: 10,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width-20,
                  height: 10,
                  child: Container(
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
