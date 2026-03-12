import 'dart:convert';

import 'package:app_001/Screens/StationPage.dart';
import 'package:app_001/main.dart';
import 'package:app_001/services/data_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const Map<String, String> _unitHash = <String, String>{
  'degF': '°F',
  'millibar': 'mbar',
  'in': 'in',
  'in hr^-1': 'in/hr',
  'percent': '%',
  'mS cm^-1': 'mS/cm',
  'arcdeg': 'deg',
  'mi hr^-1': 'mi/hr',
  'mi h^-1': 'mi/hr',
  'W m^-2': 'W/m²',
};

const Map<String, _MetricPalette> _metricPalettes = <String, _MetricPalette>{
  'air_temp': _MetricPalette(
    lowSpectrum: <Color>[
      Color(0xFF0B1F6D),
      Color(0xFF245DCC),
      Color(0xFF9EC5FF),
      Color(0xFFF8FBFF),
    ],
    highSpectrum: <Color>[
      Color(0xFFFFF3D6),
      Color(0xFFF59E0B),
      Color(0xFFE85D04),
      Color(0xFFB42318),
    ],
    midpoint: 32.0,
  ),
  'soil_temp_shallow': _MetricPalette(
    lowSpectrum: <Color>[
      Color(0xFF0B1F6D),
      Color(0xFF245DCC),
      Color(0xFF9EC5FF),
      Color(0xFFF8FBFF),
    ],
    highSpectrum: <Color>[
      Color(0xFFFFF3D6),
      Color(0xFFF59E0B),
      Color(0xFFE85D04),
      Color(0xFFB42318),
    ],
    midpoint: 32.0,
  ),
  'soil_temp_mid': _MetricPalette(
    lowSpectrum: <Color>[
      Color(0xFF0B1F6D),
      Color(0xFF245DCC),
      Color(0xFF9EC5FF),
      Color(0xFFF8FBFF),
    ],
    highSpectrum: <Color>[
      Color(0xFFFFF3D6),
      Color(0xFFF59E0B),
      Color(0xFFE85D04),
      Color(0xFFB42318),
    ],
    midpoint: 32.0,
  ),
  'soil_temp_deep': _MetricPalette(
    lowSpectrum: <Color>[
      Color(0xFF0B1F6D),
      Color(0xFF245DCC),
      Color(0xFF9EC5FF),
      Color(0xFFF8FBFF),
    ],
    highSpectrum: <Color>[
      Color(0xFFFFF3D6),
      Color(0xFFF59E0B),
      Color(0xFFE85D04),
      Color(0xFFB42318),
    ],
    midpoint: 32.0,
  ),
  'bp': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFF7F4F9),
      Color(0xFFE7E1EF),
      Color(0xFFC994C7),
      Color(0xFFDD1C77),
      Color(0xFF980043),
    ],
  ),
  'ppt': _MetricPalette(
    spectrum: <Color>[
      Color(0xFF693D10),
      Color(0xFFDFC27D),
      Color(0xFF6ADB87),
      Color(0xFF018571),
    ],
  ),
  'ppt_max_rate': _MetricPalette(
    spectrum: <Color>[
      Color(0xFF693D10),
      Color(0xFFDFC27D),
      Color(0xFF6ADB87),
      Color(0xFF018571),
    ],
  ),
  'rh': _MetricPalette(
    spectrum: <Color>[
      Color(0xFF8C510A),
      Color(0xFFD8B365),
      Color(0xFFF6E8C3),
      Color(0xFFC7EAE5),
      Color(0xFF5AB4AC),
      Color(0xFF01665E),
    ],
  ),
  'snow_depth': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFF7FBFF),
      Color(0xFFC6DBEF),
      Color(0xFF6BAED6),
      Color(0xFF2171B5),
      Color(0xFF08306B),
    ],
  ),
  'soil_ec_blk_shallow': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFF7F4F9),
      Color(0xFFE7E1EF),
      Color(0xFFC994C7),
      Color(0xFFDD1C77),
      Color(0xFF980043),
    ],
  ),
  'soil_ec_blk_mid': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFF7F4F9),
      Color(0xFFE7E1EF),
      Color(0xFFC994C7),
      Color(0xFFDD1C77),
      Color(0xFF980043),
    ],
  ),
  'soil_ec_blk_deep': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFF7F4F9),
      Color(0xFFE7E1EF),
      Color(0xFFC994C7),
      Color(0xFFDD1C77),
      Color(0xFF980043),
    ],
  ),
  'soil_vwc_shallow': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFFFFFCC),
      Color(0xFFA1DAB4),
      Color(0xFF41B6C4),
      Color(0xFF2C7FB8),
      Color(0xFF253494),
    ],
  ),
  'soil_vwc_mid': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFFFFFCC),
      Color(0xFFA1DAB4),
      Color(0xFF41B6C4),
      Color(0xFF2C7FB8),
      Color(0xFF253494),
    ],
  ),
  'soil_vwc_deep': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFFFFFCC),
      Color(0xFFA1DAB4),
      Color(0xFF41B6C4),
      Color(0xFF2C7FB8),
      Color(0xFF253494),
    ],
  ),
  'sol_rad': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFFFFFCC),
      Color(0xFFFEC44F),
      Color(0xFFFD8D3C),
      Color(0xFFE31A1C),
      Color(0xFF800026),
    ],
  ),
  'wind_dir': _MetricPalette(
    spectrum: <Color>[
      Color(0xFF9E0142),
      Color(0xFFF46D43),
      Color(0xFFFEE08B),
      Color(0xFFE6F598),
      Color(0xFF66C2A5),
      Color(0xFF3288BD),
      Color(0xFF5E4FA2),
    ],
  ),
  'wind_spd': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFFFFFCC),
      Color(0xFFC7E9B4),
      Color(0xFF7FCDBB),
      Color(0xFF41B6C4),
      Color(0xFF225EA8),
    ],
  ),
  'windgust': _MetricPalette(
    spectrum: <Color>[
      Color(0xFFFFFFCC),
      Color(0xFFC7E9B4),
      Color(0xFF7FCDBB),
      Color(0xFF41B6C4),
      Color(0xFF225EA8),
    ],
  ),
};

class _MetricPalette {
  final List<Color>? spectrum;
  final List<Color>? lowSpectrum;
  final List<Color>? highSpectrum;
  final double? midpoint;

  const _MetricPalette({
    this.spectrum,
    this.lowSpectrum,
    this.highSpectrum,
    this.midpoint,
  });
}

class MetricDefinition {
  final String element;
  final String description;
  final String descriptionShort;
  final String usUnits;
  final int sortOrder;

  const MetricDefinition({
    required this.element,
    required this.description,
    required this.descriptionShort,
    required this.usUnits,
    required this.sortOrder,
  });

  factory MetricDefinition.fromJson(Map<String, dynamic> json) {
    return MetricDefinition(
      element: json['element']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionShort: json['description_short']?.toString() ?? '',
      usUnits: json['us_units']?.toString() ?? '',
      sortOrder: (json['sort_order'] is num)
          ? (json['sort_order'] as num).toInt()
          : 999,
    );
  }

  String get unitLabel => _unitHash[usUnits] ?? usUnits;

  String get observationKey => '$descriptionShort [$unitLabel]';

  String get displayLabel =>
      unitLabel.isEmpty ? descriptionShort : '$descriptionShort [$unitLabel]';
}

class StationMetadata {
  final String id;
  final String name;
  final String subNetwork;
  final double lat;
  final double lon;

  const StationMetadata({
    required this.id,
    required this.name,
    required this.subNetwork,
    required this.lat,
    required this.lon,
  });

  factory StationMetadata.fromJson(Map<String, dynamic> json) {
    return StationMetadata(
      id: json['station']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      subNetwork: json['sub_network']?.toString() ?? '',
      lat: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      lon: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
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
  final Map<String, double?> metrics;

  const StationMarker({
    required this.name,
    required this.id,
    required this.subNetwork,
    required this.lat,
    required this.lon,
    required this.air_temp,
    required this.precipSummary,
    required this.date,
    this.metrics = const <String, double?>{},
  });

  double? metricValue(String element) => metrics[element];

  factory StationMarker.fromMap(Map<String, dynamic> json) {
    final Map<String, dynamic> rawMetrics =
        Map<String, dynamic>.from(json['metrics'] as Map? ?? <String, dynamic>{});
    return StationMarker(
      name: json['name']?.toString() ?? 'Unknown',
      id: json['id']?.toString() ?? '',
      subNetwork: json['subNetwork']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      air_temp: (json['air_temp'] as num?)?.toDouble(),
      precipSummary: (json['precipSummary'] as num?)?.toDouble(),
      date: (json['date'] as num?)?.toInt(),
      metrics: <String, double?>{
        for (final MapEntry<String, dynamic> entry in rawMetrics.entries)
          entry.key: (entry.value as num?)?.toDouble(),
      },
    );
  }
}

class _MetricStats {
  final double min;
  final double max;
  final int count;

  const _MetricStats({
    required this.min,
    required this.max,
    required this.count,
  });

  factory _MetricStats.fromMap(Map<String, dynamic> json) {
    return _MetricStats(
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 1.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class _LegendGradientData {
  final List<Color> colors;
  final List<double>? stops;
  final double? midpointStop;
  final double? midpointValue;

  const _LegendGradientData({
    required this.colors,
    this.stops,
    this.midpointStop,
    this.midpointValue,
  });
}

@pragma('vm:entry-point')
List<StationMetadata> parseStationMetadata(String responseBody) {
  final List<dynamic> parsed = jsonDecode(responseBody) as List<dynamic>;
  return parsed
      .map((dynamic json) =>
          StationMetadata.fromJson(Map<String, dynamic>.from(json as Map)))
      .toList();
}

@pragma('vm:entry-point')
List<Map<String, dynamic>> parseGroupedObservations(String responseBody) {
  final List<dynamic> parsed = jsonDecode(responseBody) as List<dynamic>;
  return parsed
      .map((dynamic json) => Map<String, dynamic>.from(json as Map))
      .toList();
}

@pragma('vm:entry-point')
List<MetricDefinition> parseMetricDefinitions(String responseBody) {
  final List<dynamic> parsed = jsonDecode(responseBody) as List<dynamic>;
  return parsed
      .map((dynamic json) =>
          MetricDefinition.fromJson(Map<String, dynamic>.from(json as Map)))
      .toList();
}

double? _parseMetricValue(dynamic rawValue) {
  if (rawValue is num) {
    final double value = rawValue.toDouble();
    if (value == 999.0 || value == -999.0) {
      return null;
    }
    return value;
  }
  return null;
}

bool _isRecentTimestamp(int? timestamp) {
  if (timestamp == null) {
    return false;
  }

  final DateTime now = DateTime.now().toUtc();
  final DateTime date =
      DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

  if (date.millisecondsSinceEpoch == 999) {
    return true;
  }

  return date.isAfter(now.subtract(const Duration(hours: 2)));
}

@pragma('vm:entry-point')
Map<String, dynamic> assembleMapData(Map<String, String> payloads) {
  final List<StationMetadata> stationMetadata =
      parseStationMetadata(payloads['stations'] ?? '[]');
  final List<Map<String, dynamic>> groupedData =
      parseGroupedObservations(payloads['grouped'] ?? '[]');
  final List<MetricDefinition> rawMetrics =
      parseMetricDefinitions(payloads['elements'] ?? '[]');

  final Map<String, Map<String, dynamic>> groupedByStation =
      <String, Map<String, dynamic>>{
    for (final Map<String, dynamic> row in groupedData)
      row['station']?.toString() ?? '': row,
  };

  final List<MetricDefinition> sortedMetrics = rawMetrics
      .where((MetricDefinition metric) =>
          metric.element.isNotEmpty &&
          metric.descriptionShort.isNotEmpty &&
          metric.element != 'wind_dir')
      .toList()
    ..sort((MetricDefinition a, MetricDefinition b) {
      final int sortOrder = a.sortOrder.compareTo(b.sortOrder);
      if (sortOrder != 0) {
        return sortOrder;
      }
      return a.descriptionShort.compareTo(b.descriptionShort);
    });

  final List<Map<String, dynamic>> stationMaps = <Map<String, dynamic>>[];
  final Map<String, Map<String, dynamic>> stationMapById =
      <String, Map<String, dynamic>>{};
  final Map<String, List<String>> visibleStationIdsByMetric =
      <String, List<String>>{};
  final Map<String, Map<String, dynamic>> statsByMetric =
      <String, Map<String, dynamic>>{};

  for (final MetricDefinition metric in sortedMetrics) {
    visibleStationIdsByMetric[metric.element] = <String>[];
  }

  for (final StationMetadata metadata in stationMetadata) {
    final Map<String, dynamic> observation =
        groupedByStation[metadata.id] ?? <String, dynamic>{};
    final int? timestamp = (observation['datetime'] as num?)?.toInt();
    final bool isRecent = _isRecentTimestamp(timestamp);
    final Map<String, double?> metrics = <String, double?>{};

    for (final MetricDefinition metric in sortedMetrics) {
      metrics[metric.element] =
          _parseMetricValue(observation[metric.observationKey]);
    }

    final Map<String, dynamic> stationMap = <String, dynamic>{
      'name': metadata.name,
      'id': metadata.id,
      'subNetwork': metadata.subNetwork,
      'lat': metadata.lat,
      'lon': metadata.lon,
      'air_temp': metrics['air_temp'],
      'precipSummary': null,
      'date': timestamp,
      'metrics': metrics,
    };
    stationMaps.add(stationMap);
    stationMapById[metadata.id] = stationMap;

    if (!isRecent) {
      continue;
    }

    for (final MetricDefinition metric in sortedMetrics) {
      final double? value = metrics[metric.element];
      if (value != null) {
        visibleStationIdsByMetric[metric.element]!.add(metadata.id);
      }
    }
  }

  final List<Map<String, dynamic>> availableMetrics = <Map<String, dynamic>>[];
  for (final MetricDefinition metric in sortedMetrics) {
    final List<String> visibleStationIds =
        visibleStationIdsByMetric[metric.element]!;
    if (visibleStationIds.isEmpty) {
      continue;
    }

    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    for (final String stationId in visibleStationIds) {
      final Map<String, dynamic>? station = stationMapById[stationId];
      if (station == null) {
        continue;
      }
      final Map<String, dynamic> metrics =
          Map<String, dynamic>.from(station['metrics'] as Map);
      final double value = (metrics[metric.element] as num).toDouble();
      if (value < minValue) {
        minValue = value;
      }
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (minValue == maxValue) {
      final double padding = minValue == 0.0 ? 1.0 : minValue.abs() * 0.1;
      minValue -= padding;
      maxValue += padding;
    }

    statsByMetric[metric.element] = <String, dynamic>{
      'min': minValue,
      'max': maxValue,
      'count': visibleStationIds.length,
    };
    availableMetrics.add(<String, dynamic>{
      'element': metric.element,
      'description': metric.description,
      'description_short': metric.descriptionShort,
      'us_units': metric.usUnits,
      'sort_order': metric.sortOrder,
    });
  }

  return <String, dynamic>{
    'stations': stationMaps,
    'available_metrics': availableMetrics,
    'visible_station_ids_by_metric': visibleStationIdsByMetric,
    'stats_by_metric': statsByMetric,
  };
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const double _defaultMarkerSize = 14.0;
  static const double _largeMarkerSize = 20.0;
  static const double _zoomThresholdForLargeMarkers = 6.4;
  static const String _stationsUrl =
      'https://mesonet.climate.umt.edu/api/v2/stations?type=json&public=True';
  static const String _groupedUrl =
      'https://mesonet.climate.umt.edu/api/v2/observations/grouped?type=json';
  static const String _elementsUrl =
      'https://mesonet.climate.umt.edu/api/v2/elements?type=json&grouped=True&public=True';

  late double _markerSize;
  late Future<List<Marker>> _markersFuture;
  late MapController mapController;

  GeoJsonParser myGeoJson =
      GeoJsonParser(defaultPolygonBorderColor: Colors.black45);

  List<StationMarker> stationList = <StationMarker>[];
  final Map<String, StationMarker> _stationById = <String, StationMarker>{};
  List<StationMarker> favoriteStations = <StationMarker>[];
  List<MetricDefinition> _availableMetrics = <MetricDefinition>[];
  Map<String, List<String>> _visibleStationIdsByMetric = <String, List<String>>{};
  Map<String, _MetricStats> _metricStatsByElement = <String, _MetricStats>{};
  final Map<String, List<Marker>> _markerCache = <String, List<Marker>>{};
  MetricDefinition? _selectedMetric;
  bool _showPolygons = false;
  bool _stationDrawerRequested = false;
  bool _interactiveMarkersEnabled = false;

  double _rangeMin = 0.0;
  double _rangeMax = 1.0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _markerSize = _defaultMarkerSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadInitialData());
    _markersFuture = Future<List<Marker>>.value(<Marker>[]);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<String> loadgeojsonString() async {
    return rootBundle.loadString('lib/assets/mt_counties.geojson');
  }

  Future<void> loadInitialData() async {
    try {
      await getStations();
      _markersFuture = getMarkers();
      if (mounted) {
        setState(() {});
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDeferredMapChrome();
      });
    } catch (_) {
      // FutureBuilder handles the visible error path.
    }
  }

  Future<void> _loadDeferredMapChrome() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) {
      return;
    }
    await loadFavorites();
    if (!mounted) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) {
      return;
    }
    await loadPolygons();
    if (!mounted) {
      return;
    }
    setState(() {
      _showPolygons = true;
      _interactiveMarkersEnabled = true;
      _markerCache.clear();
      _markersFuture = getMarkers();
    });
  }

  Future<void> getStations() async {
    try {
      final List<String> responses = await Future.wait(<Future<String>>[
        DataCache.fetchWithCache(
          _stationsUrl,
          (String url) => compute(apiCall, url),
        ),
        DataCache.fetchWithCache(
          _groupedUrl,
          (String url) => compute(apiCall, url),
        ),
        DataCache.fetchWithCache(
          _elementsUrl,
          (String url) => compute(apiCall, url),
        ),
      ]);

      final Map<String, dynamic> assembled = await compute(
        assembleMapData,
        <String, String>{
          'stations': responses[0],
          'grouped': responses[1],
          'elements': responses[2],
        },
      );

      stationList = (assembled['stations'] as List<dynamic>)
          .map((dynamic json) =>
              StationMarker.fromMap(Map<String, dynamic>.from(json as Map)))
          .toList();
      _stationById
        ..clear()
        ..addEntries(
          stationList.map(
            (StationMarker station) =>
                MapEntry<String, StationMarker>(station.id, station),
          ),
        );

      _availableMetrics = (assembled['available_metrics'] as List<dynamic>)
          .map((dynamic json) => MetricDefinition.fromJson(
              Map<String, dynamic>.from(json as Map)))
          .toList();

      _visibleStationIdsByMetric = <String, List<String>>{
        for (final MapEntry<String, dynamic> entry
            in (assembled['visible_station_ids_by_metric']
                    as Map<String, dynamic>)
                .entries)
          entry.key: (entry.value as List<dynamic>)
              .map((dynamic id) => id.toString())
              .toList(),
      };

      _metricStatsByElement = <String, _MetricStats>{
        for (final MapEntry<String, dynamic> entry
            in (assembled['stats_by_metric'] as Map<String, dynamic>).entries)
          entry.key: _MetricStats.fromMap(
              Map<String, dynamic>.from(entry.value as Map)),
      };
      _markerCache.clear();
      _interactiveMarkersEnabled = false;
      _showPolygons = false;

      _selectedMetric = _availableMetrics.firstWhere(
        (MetricDefinition metric) => metric.element == 'air_temp',
        orElse: () => _availableMetrics.isNotEmpty
            ? _availableMetrics.first
            : const MetricDefinition(
                element: 'air_temp',
                description: 'Air Temperature',
                descriptionShort: 'Air Temperature',
                usUnits: 'degF',
                sortOrder: 1,
              ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading stations: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load map data. Check your connection.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                setState(() {
                  DataCache.clearUrl(_stationsUrl);
                  DataCache.clearUrl(_groupedUrl);
                  DataCache.clearUrl(_elementsUrl);
                  _markersFuture = Future<List<Marker>>(() async {
                    await getStations();
                    return getMarkers();
                  });
                });
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      rethrow;
    }
  }

  Future<void> loadPolygons() async {
    final String mygeoString = await loadgeojsonString();
    myGeoJson.parseGeoJsonAsString(mygeoString);
  }

  Future<List<Marker>> getMarkers() async {
    _recalculateRange();
    return _getCachedMarkers();
  }

  Future<void> loadFavorites() async {
    favoriteStations = await getFavoriteStationList();
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<StationMarker>> getFavoriteStationList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonStringList = prefs.getString('favorites');
    if (jsonStringList == null || jsonStringList.isEmpty) {
      return <StationMarker>[];
    }

    final Map<String, dynamic> jsonMap =
        jsonDecode(jsonStringList) as Map<String, dynamic>;
    final List<dynamic> raw = (jsonMap['stations'] is List)
        ? jsonMap['stations'] as List<dynamic>
        : <dynamic>[];

    return raw.map((dynamic item) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(item as Map);
      return StationMarker(
        name: m['name']?.toString() ?? 'Unknown',
        id: m['id']?.toString() ?? '',
        subNetwork: m['sub_network']?.toString() ?? '',
        lat: (m['lat'] is num) ? (m['lat'] as num).toDouble() : 0.0,
        lon: (m['lon'] is num) ? (m['lon'] as num).toDouble() : 0.0,
        air_temp:
            (m['air_temp'] is num) ? (m['air_temp'] as num).toDouble() : null,
        precipSummary: (m['precipSummary'] is num)
            ? (m['precipSummary'] as num).toDouble()
            : null,
        date: (m['date'] is num) ? (m['date'] as num).toInt() : null,
      );
    }).toList();
  }

  void _updateMarkerSize(double? zoom) {
    final double newSize = ((zoom ?? 0) > _zoomThresholdForLargeMarkers)
        ? _largeMarkerSize
        : _defaultMarkerSize;
    if (_markerSize != newSize) {
      setState(() {
        _markerSize = newSize;
        _markersFuture = getMarkers();
      });
    }
  }

  bool _isUsableValue(double? value) {
    return value != null && !value.isNaN && value.isFinite;
  }

  List<StationMarker> _stationsForSelectedMetric() {
    final String? element = _selectedMetric?.element;
    if (element == null) {
      return const <StationMarker>[];
    }
    final List<String> stationIds =
        _visibleStationIdsByMetric[element] ?? const <String>[];
    return stationIds
        .map((String id) => _stationById[id])
        .whereType<StationMarker>()
        .toList(growable: false);
  }

  void _recalculateRange() {
    final _MetricStats? stats =
        _selectedMetric == null ? null : _metricStatsByElement[_selectedMetric!.element];
    if (stats == null) {
      _rangeMin = 0.0;
      _rangeMax = 1.0;
      return;
    }
    _rangeMin = stats.min;
    _rangeMax = stats.max;
  }

  Color _markerColorForStation(StationMarker station) {
    final MetricDefinition? metric = _selectedMetric;
    final double? value = metric == null ? null : station.metricValue(metric.element);
    if (!_isUsableValue(value)) {
      return Colors.black54;
    }

    final _MetricPalette palette =
        _metricPalettes[metric!.element] ?? _defaultPaletteFor(metric.element);

    if (palette.midpoint != null &&
        palette.lowSpectrum != null &&
        palette.highSpectrum != null &&
        _rangeMin < palette.midpoint! &&
        _rangeMax > palette.midpoint!) {
      if (value! <= palette.midpoint!) {
        final Rainbow lowRainbow = Rainbow(
          spectrum: palette.lowSpectrum!,
          rangeStart: _rangeMin,
          rangeEnd: palette.midpoint!,
        );
        return lowRainbow[value];
      }

      final Rainbow highRainbow = Rainbow(
        spectrum: palette.highSpectrum!,
        rangeStart: palette.midpoint!,
        rangeEnd: _rangeMax,
      );
      return highRainbow[value!];
    }

    final Rainbow rainbow = Rainbow(
      spectrum: palette.spectrum ??
          palette.highSpectrum ??
          const <Color>[
            Color(0xFF245DCC),
            Color(0xFFF59E0B),
            Color(0xFFB42318),
          ],
      rangeStart: _rangeMin,
      rangeEnd: _rangeMax,
    );
    return rainbow[value!];
  }

  _MetricPalette _defaultPaletteFor(String element) {
    if (element.contains('temp')) {
      return _metricPalettes['air_temp']!;
    }

    return const _MetricPalette(
      spectrum: <Color>[
        Color(0xFFFFFFCC),
        Color(0xFFA1DAB4),
        Color(0xFF41B6C4),
        Color(0xFF225EA8),
      ],
    );
  }

  void _navigateToStation(StationMarker station) {
    final bool isHydromet = station.subNetwork == 'HydroMet';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HydroStationPage(
          station: station,
          hydroBool: isHydromet ? 1 : 0,
        ),
      ),
    ).then((_) {
      if (mounted) {
        loadFavorites();
      }
    });
  }

  void _showStationInfo(StationMarker station) {
    final MetricDefinition? metric = _selectedMetric;
    final double? selectedValue =
        metric == null ? null : station.metricValue(metric.element);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: const Text('Station Information'),
          content: Text(
            'Latest Report: ${station.date == null ? 'Unknown' : DateFormat('MM/dd/yyyy - kk:mm').format(DateTime.fromMillisecondsSinceEpoch(station.date!))}\n'
            'Station Name: ${station.name}\n'
            'Station ID: ${station.id}\n'
            'Network: ${station.subNetwork}\n'
            'Latitude: ${station.lat}*\n'
            'Longitude: ${station.lon}*\n'
            '${metric == null ? '' : '${metric.descriptionShort}: ${selectedValue == null ? 'N/A' : _formatMetricValue(selectedValue, metric)}\n'}'
            'Air Temperature: ${station.air_temp == null ? 'N/A' : '${station.air_temp!.toStringAsFixed(1)}°F'}\n\n'
            '*Latitude and Longitude are approximate.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Marker _buildStationMarker(StationMarker station) {
    final bool isHydromet = station.subNetwork == 'HydroMet';

    return Marker(
      height: _markerSize,
      width: _markerSize,
      point: LatLng(station.lat, station.lon),
      child: _interactiveMarkersEnabled
          ? GestureDetector(
              onTap: () => _navigateToStation(station),
              onLongPress: () => _showStationInfo(station),
              child: Icon(
                isHydromet ? Icons.circle_sharp : Icons.star,
                color: _markerColorForStation(station),
                size: _markerSize,
              ),
            )
          : Icon(
              isHydromet ? Icons.circle_sharp : Icons.star,
              color: _markerColorForStation(station),
              size: _markerSize,
            ),
    );
  }

  void _openStationDrawer(BuildContext context) {
    if (!_stationDrawerRequested) {
      setState(() {
        _stationDrawerRequested = true;
      });
    }
    Scaffold.of(context).openEndDrawer();
  }

  Widget _buildStationDrawer(MetricDefinition? metric) {
    if (!_stationDrawerRequested) {
      return const SizedBox.shrink();
    }

    if (stationList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: stationList.length,
      itemBuilder: (BuildContext context, int index) {
        final StationMarker station = stationList[index];
        return ListTile(
          leading: Icon(
            station.subNetwork == 'HydroMet'
                ? Icons.circle_sharp
                : Icons.star,
            color: station.subNetwork == 'HydroMet'
                ? const Color(0xFF0E4674)
                : const Color(0xFF356E5B),
          ),
          title: Text(station.name),
          subtitle:
              metric != null && _isUsableValue(station.metricValue(metric.element))
                  ? Text(
                      _formatMetricValue(
                        station.metricValue(metric.element)!,
                        metric,
                      ),
                    )
                  : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HydroStationPage(
                  station: station,
                  hydroBool: station.subNetwork == 'HydroMet' ? 1 : 0,
                ),
              ),
            ).then((_) {
              if (mounted) {
                loadFavorites();
              }
            });
          },
        );
      },
    );
  }

  String _markerCacheKey() {
    final String element = _selectedMetric?.element ?? 'none';
    final String sizeBucket = _markerSize > _defaultMarkerSize ? 'large' : 'small';
    return '$element:$sizeBucket';
  }

  List<Marker> _getCachedMarkers() {
    final String key = _markerCacheKey();
    final List<Marker>? cached = _markerCache[key];
    if (cached != null) {
      return cached;
    }

    final List<Marker> markers = _stationsForSelectedMetric()
        .map(_buildStationMarker)
        .toList()
        .reversed
        .toList();
    _markerCache[key] = markers;
    return markers;
  }

  Future<void> _showMetricSelector() async {
    if (_availableMetrics.isEmpty) {
      return;
    }

    final MetricDefinition? selected = await showModalBottomSheet<MetricDefinition>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: _availableMetrics.length,
            itemBuilder: (BuildContext context, int index) {
              final MetricDefinition metric = _availableMetrics[index];
              final bool isSelected = metric.element == _selectedMetric?.element;

              return ListTile(
                title: Text(metric.descriptionShort),
                subtitle: Text(metric.unitLabel),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(metric),
              );
            },
          ),
        );
      },
    );

    if (selected == null || selected.element == _selectedMetric?.element) {
      return;
    }

    setState(() {
      _selectedMetric = selected;
      _markersFuture = getMarkers();
    });
  }

  String _formatMetricValue(double value, MetricDefinition metric) {
    final String unit = metric.unitLabel;
    final int fractionDigits = value.abs() >= 100 ? 0 : (value.abs() >= 10 ? 1 : 2);
    return '${value.toStringAsFixed(fractionDigits)} ${unit.trim()}'.trim();
  }

  _LegendGradientData _legendGradientData() {
    final MetricDefinition? metric = _selectedMetric;
    if (metric == null) {
      return const _LegendGradientData(
        colors: <Color>[Colors.white, Colors.blue],
      );
    }

    final _MetricPalette palette =
        _metricPalettes[metric.element] ?? _defaultPaletteFor(metric.element);

    if (palette.midpoint != null &&
        palette.lowSpectrum != null &&
        palette.highSpectrum != null &&
        _rangeMin < palette.midpoint! &&
        _rangeMax > palette.midpoint!) {
      final double rawSplit =
          ((palette.midpoint! - _rangeMin) / (_rangeMax - _rangeMin))
              .clamp(0.0, 1.0);
      final double split = rawSplit.clamp(0.25, 0.75);

      return _LegendGradientData(
        colors: <Color>[
          palette.lowSpectrum!.first,
          palette.lowSpectrum![1],
          palette.lowSpectrum!.last,
          palette.highSpectrum!.first,
          palette.highSpectrum![1],
          palette.highSpectrum![2],
          palette.highSpectrum!.last,
        ],
        stops: <double>[
          0.0,
          split * 0.45,
          split,
          split,
          split + ((1 - split) * 0.33),
          split + ((1 - split) * 0.66),
          1.0,
        ],
        midpointStop: split,
        midpointValue: palette.midpoint,
      );
    }

    final double midPoint = (_rangeMin + _rangeMax) / 2;
    return _LegendGradientData(
      colors: <Color>[
        _markerColorForLegendValue(_rangeMin, metric),
        _markerColorForLegendValue((_rangeMin + midPoint) / 2, metric),
        _markerColorForLegendValue(midPoint, metric),
        _markerColorForLegendValue((_rangeMax + midPoint) / 2, metric),
        _markerColorForLegendValue(_rangeMax, metric),
      ],
    );
  }

  Widget _buildLegendLabels(
    BuildContext context,
    MetricDefinition metric,
    _LegendGradientData legendGradient,
  ) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodySmall;
    if (legendGradient.midpointStop == null || legendGradient.midpointValue == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(_formatMetricValue(_rangeMin, metric), style: labelStyle),
          Text(_formatMetricValue(_rangeMax, metric), style: labelStyle),
        ],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double freezeLabelWidth = 56;
        final double usableWidth = constraints.maxWidth - freezeLabelWidth;
        final double left =
            (usableWidth * legendGradient.midpointStop!).clamp(0.0, usableWidth);

        return SizedBox(
          height: 18,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 0,
                child: Text(_formatMetricValue(_rangeMin, metric), style: labelStyle),
              ),
              Positioned(
                left: left,
                width: freezeLabelWidth,
                child: Center(
                  child: Text('32°F', style: labelStyle),
                ),
              ),
              Positioned(
                right: 0,
                child: Text(_formatMetricValue(_rangeMax, metric), style: labelStyle),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _markerColorForLegendValue(double value, MetricDefinition metric) {
    final _MetricPalette palette =
        _metricPalettes[metric.element] ?? _defaultPaletteFor(metric.element);

    if (palette.midpoint != null &&
        palette.lowSpectrum != null &&
        palette.highSpectrum != null &&
        _rangeMin < palette.midpoint! &&
        _rangeMax > palette.midpoint!) {
      if (value <= palette.midpoint!) {
        final Rainbow lowRainbow = Rainbow(
          spectrum: palette.lowSpectrum!,
          rangeStart: _rangeMin,
          rangeEnd: palette.midpoint!,
        );
        return lowRainbow[value];
      }

      final Rainbow highRainbow = Rainbow(
        spectrum: palette.highSpectrum!,
        rangeStart: palette.midpoint!,
        rangeEnd: _rangeMax,
      );
      return highRainbow[value];
    }

    final Rainbow rainbow = Rainbow(
      spectrum: palette.spectrum ??
          palette.highSpectrum ??
          const <Color>[
            Color(0xFF245DCC),
            Color(0xFFF59E0B),
            Color(0xFFB42318),
          ],
      rangeStart: _rangeMin,
      rangeEnd: _rangeMax,
    );
    return rainbow[value];
  }

  @override
  Widget build(BuildContext context) {
    final MetricDefinition? metric = _selectedMetric;
    final int visibleStationCount =
        metric == null ? 0 : (_metricStatsByElement[metric.element]?.count ?? 0);
    final _LegendGradientData legendGradient = _legendGradientData();

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: true,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton.extended(
            tooltip: 'Select map variable',
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            onPressed: _showMetricSelector,
            icon: const Icon(Icons.tune),
            label: Text(
              metric?.descriptionShort ?? 'Variables',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.star),
                );
              },
            ),
            actions: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    onPressed: () {
                      _openStationDrawer(context);
                    },
                    icon: const Icon(Icons.list),
                  );
                },
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            centerTitle: true,
            title: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Image.asset(
                  'lib/assets/mesonet_logo_png.png',
                  fit: BoxFit.fill,
                  height: 50,
                ),
              ),
            ),
          ),
          drawer: Drawer(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: favoriteStations.isEmpty
                ? const Center(child: Text('No favorite stations yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: favoriteStations.length,
                    itemBuilder: (BuildContext context, int index) {
                      final StationMarker station = favoriteStations[index];
                      return ListTile(
                        leading: Icon(
                          station.subNetwork == 'HydroMet'
                              ? Icons.circle_sharp
                              : Icons.star,
                          color: station.subNetwork == 'HydroMet'
                              ? const Color(0xFF0E4674)
                              : const Color(0xFF356E5B),
                        ),
                        title: Text(station.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => HydroStationPage(
                                station: station,
                                hydroBool:
                                    station.subNetwork == 'HydroMet' ? 1 : 0,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              loadFavorites();
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          endDrawer: Drawer(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: _buildStationDrawer(metric),
          ),
          body: Stack(
            children: <Widget>[
              FutureBuilder<List<Marker>>(
                future: _markersFuture,
                builder: (BuildContext context, AsyncSnapshot<List<Marker>> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _markersFuture = Future<List<Marker>>(() async {
                              await getStations();
                              return getMarkers();
                            });
                          });
                        },
                        child: const Text('Reload map'),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(46.681625, -110.04365),
                      initialZoom: 5.5,
                      keepAlive: true,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                      onPositionChanged: (MapCamera position, bool hasGesture) {
                        if (hasGesture) {
                          _updateMarkerSize(position.zoom);
                        }
                      },
                    ),
                    children: <Widget>[
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'MontanaClimateOffice.app',
                      ),
                      if (_showPolygons) PolygonLayer(polygons: myGeoJson.polygons),
                      MarkerLayer(markers: snapshot.data!),
                      RichAttributionWidget(
                        popupInitialDisplayDuration: const Duration(seconds: 5),
                        popupBackgroundColor:
                            Theme.of(context).colorScheme.tertiary,
                        showFlutterMapAttribution: false,
                        alignment: AttributionAlignment.bottomLeft,
                        attributions: <SourceAttribution>[
                          TextSourceAttribution(
                            'OpenStreetMap',
                            onTap: () => launchUrl(
                              Uri.parse('https://openstreetmap.org/copyright'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              if (metric != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Material(
                        color: Colors.white.withOpacity(0.94),
                        elevation: 3,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        metric.displayLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$visibleStationCount stations',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: legendGradient.colors,
                                      stops: legendGradient.stops,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildLegendLabels(
                                  context,
                                  metric,
                                  legendGradient,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
