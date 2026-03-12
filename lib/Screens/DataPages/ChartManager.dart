import 'dart:convert';

import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

import 'JSONData.dart';

const Color _chartRed = Color(0xFFB42318);
const Color _chartBlue = Color(0xFF0073A2);
const Color _chartGreen = Color(0xFF2E7D62);
const Color _chartOrange = Color(0xFFE67E22);
const Color _chartPurple = Color(0xFF6B4FB3);

typedef _ChartRow = Map<String, Object?>;
typedef _MetricExtractor = double? Function(Data data);

class _ChartSeries {
  const _ChartSeries({
    required this.key,
    required this.label,
    required this.color,
  });

  final String key;
  final String label;
  final Color color;
}

class _ValueRange {
  const _ValueRange(this.min, this.max);

  final double min;
  final double max;
}

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
  final DateFormat _queryDateFormat = DateFormat('yyyy-MM-dd');
  DateTimeRange? _selectedDateRange;
  late Future<List<Data>> _dataFuture;

  bool shortTimeSpan = false;

  bool? airTemperature = true;
  bool? atmosphericPressure = false;
  bool? bulkEC = false;
  bool? precipitation = true;
  bool? relativeHumidity = false;
  bool? snowDepth = false;
  bool? soilTemperature = true;
  bool? soilVWC = true;
  bool? solarRadiation = false;
  bool? windSpeed = false;

  static const Color _hydrometSelectorBlue = Color(0xFFD8ECF8);

  final Map<String, _MetricExtractor> _extractors = <String, _MetricExtractor>{
    'airTemperature': (Data d) => d.airTemperature,
    'precipitation': (Data d) => d.Precipitation,
    'atmosphericPressure': (Data d) => d.atmosphericPressure,
    'relativeHumidity': (Data d) => d.relativeHumidity,
    'soilTemperature5': (Data d) => d.soilTemperature5,
    'soilTemperature10': (Data d) => d.soilTemperature10,
    'soilTemperature20': (Data d) => d.soilTemperature20,
    'soilTemperature50': (Data d) => d.soilTemperature50,
    'soilTemperature100': (Data d) => d.soilTemperature100,
    'soilVWC5': (Data d) => d.soilVWC5,
    'soilVWC10': (Data d) => d.soilVWC10,
    'soilVWC20': (Data d) => d.soilVWC20,
    'soilVWC50': (Data d) => d.soilVWC50,
    'soilVWC100': (Data d) => d.soilVWC100,
    'bulkEC5': (Data d) => d.bulkEC5,
    'bulkEC10': (Data d) => d.bulkEC10,
    'bulkEC20': (Data d) => d.bulkEC20,
    'bulkEC50': (Data d) => d.bulkEC50,
    'bulkEC100': (Data d) => d.bulkEC100,
    'solarRadiation': (Data d) => d.solarRadiation,
    'windSpeed': (Data d) => d.windSpeed,
    'snowDepth': (Data d) => d.snowDepth,
  };

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    _refreshChartData();
  }

  List<String> calculateDaysInterval(DateTime startDate, DateTime endDate) {
    final List<String> days = <String>[];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(_queryDateFormat.format(startDate.add(Duration(days: i))));
    }
    return days;
  }

  bool _computeShortTimeSpan() {
    final DateTimeRange range = _selectedDateRange!;
    return range.duration.inDays <= 15;
  }

  void _refreshChartData() {
    shortTimeSpan = _computeShortTimeSpan();
    _dataFuture = getDataList();
  }

  String parseURL() {
    final List<String> dayArr = calculateDaysInterval(
      _selectedDateRange!.start,
      _selectedDateRange!.end,
    );
    if (shortTimeSpan) {
      return 'https://mesonet.climate.umt.edu/api/v2/observations/hourly/?type=json&stations=${widget.id}&dates=${dayArr.join(',')}&premade=true&rm_na=true';
    }
    return 'https://mesonet.climate.umt.edu/api/v2/observations/daily/?type=json&stations=${widget.id}&dates=${dayArr.join(',')}&premade=true&rm_na=true';
  }

  Future<List<Data>> getDataList() async {
    final String url = parseURL();
    try {
      final String response = await flutterCompute(apiCall, url);
      final List<dynamic> dataMap = jsonDecode(response) as List<dynamic>;
      return dataMap
          .map((dynamic row) => Data.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chart data: $e');
      }
      return <Data>[];
    }
  }

  List<Map<String, dynamic>> _metricOptions() {
    return <Map<String, dynamic>>[
      {
        'title': 'Air temperature',
        'value': airTemperature ?? false,
        'setter': (bool v) => airTemperature = v,
      },
      {
        'title': 'Precipitation',
        'value': precipitation ?? false,
        'setter': (bool v) => precipitation = v,
      },
      {
        'title': 'Atmospheric pressure',
        'value': atmosphericPressure ?? false,
        'setter': (bool v) => atmosphericPressure = v,
      },
      {
        'title': 'Relative humidity',
        'value': relativeHumidity ?? false,
        'setter': (bool v) => relativeHumidity = v,
      },
      {
        'title': 'Soil temperature',
        'value': soilTemperature ?? false,
        'setter': (bool v) => soilTemperature = v,
      },
      {
        'title': 'Soil VWC',
        'value': soilVWC ?? false,
        'setter': (bool v) => soilVWC = v,
      },
      {
        'title': 'Bulk EC',
        'value': bulkEC ?? false,
        'setter': (bool v) => bulkEC = v,
      },
      {
        'title': 'Solar radiation',
        'value': solarRadiation ?? false,
        'setter': (bool v) => solarRadiation = v,
      },
      {
        'title': 'Wind speed',
        'value': windSpeed ?? false,
        'setter': (bool v) => windSpeed = v,
      },
      {
        'title': 'Snow depth',
        'value': snowDepth ?? false,
        'setter': (bool v) => snowDepth = v,
      },
    ];
  }

  List<String> _selectedMetricLabels() {
    return _metricOptions()
        .where((Map<String, dynamic> option) => option['value'] as bool)
        .map((Map<String, dynamic> option) => option['title'] as String)
        .toList();
  }

  String _dateRangeLabel() {
    return '${_queryDateFormat.format(_selectedDateRange!.start)} - ${_queryDateFormat.format(_selectedDateRange!.end)}';
  }

  Future<void> _showMetricSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            final List<Map<String, dynamic>> options = _metricOptions();
            final Color selectedChipColor = widget.isHydromet
                ? _hydrometSelectorBlue
                : Theme.of(context).colorScheme.secondaryContainer;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Visible charts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((Map<String, dynamic> option) {
                        return FilterChip(
                          label: Text(option['title'] as String),
                          selected: option['value'] as bool,
                          selectedColor: selectedChipColor,
                          checkmarkColor:
                              Theme.of(context).colorScheme.onSurface,
                          onSelected: (bool selected) {
                            setState(() {
                              (option['setter'] as void Function(bool))(selected);
                            });
                            modalSetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      builder: (BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: widget.isHydromet
              ? Theme.of(context).colorScheme.copyWith(
                  primary: _hydrometSelectorBlue,
                  onPrimary: Theme.of(context).colorScheme.onSurface,
                  primaryContainer: _hydrometSelectorBlue,
                  onPrimaryContainer: Theme.of(context).colorScheme.onSurface,
                  secondaryContainer: _hydrometSelectorBlue,
                  onSecondaryContainer: Theme.of(context).colorScheme.onSurface,
                )
              : Theme.of(context).colorScheme,
          dialogTheme: DialogThemeData(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            surfaceTintColor: Colors.transparent,
          ),
          scaffoldBackgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
        child: child!,
      ),
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
      helpText: 'Select a date range',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (result != null) {
      setState(() {
        _selectedDateRange = result;
        _refreshChartData();
      });
    }
  }

  DateTime? _chartTime(Data data) {
    if (data.datetime == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(data.datetime!);
  }

  List<_ChartRow> _singleSeriesRows(List<Data> data, String metricKey) {
    final _MetricExtractor? extractor = _extractors[metricKey];
    if (extractor == null) {
      return <_ChartRow>[];
    }

    final List<_ChartRow> rows = <_ChartRow>[];
    for (final Data datum in data) {
      final DateTime? time = _chartTime(datum);
      final double? value = extractor(datum);
      if (time == null || value == null || value.isNaN) {
        continue;
      }
      rows.add(<String, Object?>{
        'time': time,
        'value': value,
      });
    }
    return rows;
  }

  List<_ChartRow> _multiSeriesRows(
    List<Data> data,
    List<_ChartSeries> series,
  ) {
    final List<_ChartRow> rows = <_ChartRow>[];
    for (final Data datum in data) {
      final DateTime? time = _chartTime(datum);
      if (time == null) {
        continue;
      }
      for (final _ChartSeries entry in series) {
        final _MetricExtractor? extractor = _extractors[entry.key];
        final double? value = extractor?.call(datum);
        if (value == null || value.isNaN) {
          continue;
        }
        rows.add(<String, Object?>{
          'time': time,
          'value': value,
          'series': entry.label,
        });
      }
    }
    return rows;
  }

  List<_ChartRow> _precipitationRows(List<Data> data) {
    final List<_ChartRow> rawRows = _singleSeriesRows(data, 'precipitation');
    if (shortTimeSpan) {
      return rawRows;
    }

    final Map<DateTime, double> dailyTotals = <DateTime, double>{};
    for (final _ChartRow row in rawRows) {
      final DateTime time = row['time'] as DateTime;
      final DateTime day = DateTime(time.year, time.month, time.day);
      final double value = (row['value'] as num).toDouble();
      dailyTotals[day] = (dailyTotals[day] ?? 0) + value;
    }

    final List<DateTime> days = dailyTotals.keys.toList()..sort();
    return days
        .map(
          (DateTime day) => <String, Object?>{
            'time': day,
            'value': dailyTotals[day],
          },
        )
        .toList();
  }

  _ValueRange? _valueRange(List<_ChartRow> rows) {
    if (rows.isEmpty) {
      return null;
    }
    double minValue = (rows.first['value'] as num).toDouble();
    double maxValue = minValue;
    for (final _ChartRow row in rows.skip(1)) {
      final double value = (row['value'] as num).toDouble();
      if (value < minValue) {
        minValue = value;
      }
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return _ValueRange(minValue, maxValue);
  }

  LinearScale _numericScale(
    List<_ChartRow> rows, {
    double? minOverride,
    double? maxOverride,
    bool clampMinToZero = false,
    bool clampMaxToHundred = false,
    int tickCount = 5,
    int decimals = 0,
  }) {
    final _ValueRange? range = _valueRange(rows);
    if (range == null) {
      return LinearScale(min: 0, max: 1, tickCount: tickCount);
    }

    double minValue = minOverride ?? range.min;
    double maxValue = maxOverride ?? range.max;

    if (clampMinToZero) {
      minValue = 0;
    }
    if (clampMaxToHundred) {
      maxValue = 100;
    }

    if (minValue == maxValue) {
      final double padding = minValue == 0 ? 1 : minValue.abs() * 0.1;
      minValue -= padding;
      maxValue += padding;
    } else if (minOverride == null || maxOverride == null) {
      final double padding = (maxValue - minValue) * 0.12;
      if (minOverride == null) {
        minValue -= padding;
      }
      if (maxOverride == null) {
        maxValue += padding;
      }
    }

    return LinearScale(
      min: minValue,
      max: maxValue,
      niceRange: true,
      tickCount: tickCount,
      formatter: (num value) => _formatNumeric(value, decimals: decimals),
    );
  }

  String _formatNumeric(num value, {int decimals = 0}) {
    if (decimals <= 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(decimals);
  }

  String _formatTimeAxis(DateTime value) {
    if (shortTimeSpan) {
      return DateFormat('MM/dd\nHH:mm').format(value);
    }
    return DateFormat('MM/dd').format(value);
  }

  Color get _cardColor => widget.isHydromet
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.secondary;

  Color get _loadingColor => widget.isHydromet
      ? Theme.of(context).colorScheme.onPrimary
      : Theme.of(context).colorScheme.onSecondary;

  Color get _chartSurfaceColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF0F1720)
      : Colors.white;

  TextStyle get _chartTitleStyle => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(color: Colors.white, fontWeight: FontWeight.w700);

  TextStyle get _chartSubtitleStyle => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(color: Colors.white.withOpacity(0.8));

  TextStyle get _legendTextStyle => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(color: Colors.white, fontWeight: FontWeight.w600);

  TextStyle _axisTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          fontSize: shortTimeSpan ? 10 : 11,
        );
  }

  PaintStyle _gridStyle(BuildContext context) {
    return PaintStyle(
      strokeColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35),
      strokeWidth: 1,
    );
  }

  AxisGuide _timeAxis(BuildContext context) {
    return AxisGuide(
      variable: 'time',
      line: PaintStyle(
        strokeColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.65),
        strokeWidth: 1,
      ),
      label: LabelStyle(
        textStyle: _axisTextStyle(context),
        offset: const Offset(0, 10),
      ),
      tickLine: TickLine(
        style: PaintStyle(
          strokeColor:
              Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          strokeWidth: 1,
        ),
        length: 4,
      ),
    );
  }

  AxisGuide _valueAxis(BuildContext context) {
    return AxisGuide(
      variable: 'value',
      line: PaintStyle(
        strokeColor: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.65),
        strokeWidth: 1,
      ),
      label: LabelStyle(
        textStyle: _axisTextStyle(context),
        offset: const Offset(-10, 0),
      ),
      grid: _gridStyle(context),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      color: _cardColor,
      child: Center(
        child: CircularProgressIndicator(color: _loadingColor),
      ),
    );
  }

  Widget _buildEmptyChartCard({
    required String title,
    required String subtitle,
  }) {
    return Card(
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: _chartTitleStyle),
            const SizedBox(height: 4),
            Text(subtitle, style: _chartSubtitleStyle),
            const Spacer(),
            Center(
              child: Text(
                'No observations are available for this range.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white.withOpacity(0.92),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartShell({
    required String title,
    required String subtitle,
    required Widget chart,
    List<_ChartSeries>? legend,
  }) {
    return Card(
      color: _cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: _chartTitleStyle),
            const SizedBox(height: 4),
            Text(subtitle, style: _chartSubtitleStyle),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _chartSurfaceColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                  child: chart,
                ),
              ),
            ),
            if (legend != null && legend.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: legend.map(_legendChip).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendChip(_ChartSeries series) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: series.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(series.label, style: _legendTextStyle),
        ],
      ),
    );
  }

  Widget _lineChart({
    required List<_ChartRow> rows,
    required Color color,
    required LinearScale valueScale,
  }) {
    return Chart<_ChartRow>(
      data: rows,
      variables: <String, Variable<_ChartRow, dynamic>>{
        'time': Variable<_ChartRow, DateTime>(
          accessor: (_ChartRow row) => row['time'] as DateTime,
          scale: TimeScale(
            formatter: _formatTimeAxis,
            tickCount: shortTimeSpan ? 6 : 5,
          ),
        ),
        'value': Variable<_ChartRow, num>(
          accessor: (_ChartRow row) => row['value'] as num,
          scale: valueScale,
        ),
      },
      marks: <Mark>[
        LineMark(
          position: Varset('time') * Varset('value'),
          color: ColorEncode(value: color),
          size: SizeEncode(value: 2.5),
        ),
      ],
      axes: <AxisGuide>[
        _timeAxis(context),
        _valueAxis(context),
      ],
      padding: (Size size) => const EdgeInsets.fromLTRB(56, 8, 10, 36),
    );
  }

  Widget _multiLineChart({
    required List<_ChartRow> rows,
    required List<_ChartSeries> series,
    required LinearScale valueScale,
  }) {
    return Chart<_ChartRow>(
      data: rows,
      variables: <String, Variable<_ChartRow, dynamic>>{
        'time': Variable<_ChartRow, DateTime>(
          accessor: (_ChartRow row) => row['time'] as DateTime,
          scale: TimeScale(
            formatter: _formatTimeAxis,
            tickCount: shortTimeSpan ? 6 : 5,
          ),
        ),
        'value': Variable<_ChartRow, num>(
          accessor: (_ChartRow row) => row['value'] as num,
          scale: valueScale,
        ),
        'series': Variable<_ChartRow, String>(
          accessor: (_ChartRow row) => row['series'] as String,
        ),
      },
      marks: <Mark>[
        LineMark(
          position: Varset('time') * Varset('value') / Varset('series'),
          color: ColorEncode(
            variable: 'series',
            values: series.map((e) => e.color).toList(),
          ),
          size: SizeEncode(value: 2.2),
        ),
      ],
      axes: <AxisGuide>[
        _timeAxis(context),
        _valueAxis(context),
      ],
      padding: (Size size) => const EdgeInsets.fromLTRB(56, 8, 10, 36),
    );
  }

  Widget _barChart({
    required List<_ChartRow> rows,
    required Color color,
    required LinearScale valueScale,
  }) {
    return Chart<_ChartRow>(
      data: rows,
      variables: <String, Variable<_ChartRow, dynamic>>{
        'time': Variable<_ChartRow, DateTime>(
          accessor: (_ChartRow row) => row['time'] as DateTime,
          scale: TimeScale(
            formatter: _formatTimeAxis,
            tickCount: shortTimeSpan ? 6 : 5,
          ),
        ),
        'value': Variable<_ChartRow, num>(
          accessor: (_ChartRow row) => row['value'] as num,
          scale: valueScale,
        ),
      },
      marks: <Mark>[
        IntervalMark(
          position: Varset('time') * Varset('value'),
          color: ColorEncode(value: color),
          size: SizeEncode(value: 12),
        ),
      ],
      axes: <AxisGuide>[
        _timeAxis(context),
        _valueAxis(context),
      ],
      padding: (Size size) => const EdgeInsets.fromLTRB(56, 8, 10, 36),
    );
  }

  Widget _buildSingleSeriesChart({
    required List<Data> data,
    required String title,
    required String subtitle,
    required String metricKey,
    required Color color,
    bool bar = false,
    bool clampMinToZero = false,
    double? minOverride,
    double? maxOverride,
    int decimals = 0,
  }) {
    final List<_ChartRow> rows =
        bar ? _precipitationRows(data) : _singleSeriesRows(data, metricKey);
    if (rows.isEmpty) {
      return _buildEmptyChartCard(title: title, subtitle: subtitle);
    }

    final LinearScale scale = _numericScale(
      rows,
      minOverride: minOverride,
      maxOverride: maxOverride,
      clampMinToZero: clampMinToZero,
      tickCount: 5,
      decimals: decimals,
    );

    return _buildChartShell(
      title: title,
      subtitle: subtitle,
      chart: bar
          ? _barChart(rows: rows, color: color, valueScale: scale)
          : _lineChart(rows: rows, color: color, valueScale: scale),
    );
  }

  Widget _buildMultiSeriesChart({
    required List<Data> data,
    required String title,
    required String subtitle,
    required List<_ChartSeries> series,
    double? minOverride,
    double? maxOverride,
    int decimals = 0,
  }) {
    final List<_ChartRow> rows = _multiSeriesRows(data, series);
    if (rows.isEmpty) {
      return _buildEmptyChartCard(title: title, subtitle: subtitle);
    }

    final LinearScale scale = _numericScale(
      rows,
      minOverride: minOverride,
      maxOverride: maxOverride,
      tickCount: 5,
      decimals: decimals,
    );

    return _buildChartShell(
      title: title,
      subtitle: subtitle,
      legend: series,
      chart: _multiLineChart(
        rows: rows,
        series: series,
        valueScale: scale,
      ),
    );
  }

  Widget _soilTemperatureChart(List<Data> data) {
    final List<_ChartSeries> series = <_ChartSeries>[
      const _ChartSeries(key: 'soilTemperature5', label: '2"', color: _chartRed),
      const _ChartSeries(key: 'soilTemperature10', label: '4"', color: _chartBlue),
      const _ChartSeries(key: 'soilTemperature20', label: '8"', color: _chartGreen),
      const _ChartSeries(key: 'soilTemperature50', label: '20"', color: _chartOrange),
      const _ChartSeries(key: 'soilTemperature100', label: '40"', color: _chartPurple),
    ];
    return _buildMultiSeriesChart(
      data: data,
      title: 'Soil temperature',
      subtitle: 'Temperature [°F]',
      series: series,
      decimals: 0,
    );
  }

  Widget _soilVwcChart(List<Data> data) {
    final List<_ChartSeries> series = <_ChartSeries>[
      const _ChartSeries(key: 'soilVWC5', label: '2"', color: _chartRed),
      const _ChartSeries(key: 'soilVWC10', label: '4"', color: _chartBlue),
      const _ChartSeries(key: 'soilVWC20', label: '8"', color: _chartGreen),
      const _ChartSeries(key: 'soilVWC50', label: '20"', color: _chartOrange),
      const _ChartSeries(key: 'soilVWC100', label: '40"', color: _chartPurple),
    ];
    return _buildMultiSeriesChart(
      data: data,
      title: 'Soil VWC',
      subtitle: 'Volumetric water content [%]',
      series: series,
      minOverride: 0,
      decimals: 0,
    );
  }

  Widget _bulkEcChart(List<Data> data) {
    final List<_ChartSeries> series = <_ChartSeries>[
      const _ChartSeries(key: 'bulkEC5', label: '2"', color: _chartRed),
      const _ChartSeries(key: 'bulkEC10', label: '4"', color: _chartBlue),
      const _ChartSeries(key: 'bulkEC20', label: '8"', color: _chartGreen),
      const _ChartSeries(key: 'bulkEC50', label: '20"', color: _chartOrange),
      const _ChartSeries(key: 'bulkEC100', label: '40"', color: _chartPurple),
    ];
    return _buildMultiSeriesChart(
      data: data,
      title: 'Bulk EC',
      subtitle: 'Electrical conductivity [mS/cm]',
      series: series,
      minOverride: 0,
      decimals: 1,
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    final Color accentColor = widget.isHydromet
        ? _hydrometSelectorBlue
        : Theme.of(context).colorScheme.secondary;
    final List<String> selectedLabels = _selectedMetricLabels();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _show,
                    icon: const Icon(Icons.date_range),
                    label: Text(_dateRangeLabel()),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonalIcon(
                  onPressed: _showMetricSelector,
                  icon: const Icon(Icons.tune),
                  label: const Text('Charts'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${selectedLabels.length} charts selected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedLabels
                  .map(
                    (String label) => Chip(
                      label: Text(label),
                      backgroundColor: accentColor.withOpacity(0.12),
                      side: BorderSide(
                        color: accentColor.withOpacity(0.24),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartSection(Widget child, {double height = 380}) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  List<Widget> _buildChartSections(List<Data> data) {
    return <Widget>[
      if (airTemperature ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Air temperature',
            subtitle: 'Temperature [°F]',
            metricKey: 'airTemperature',
            color: _chartRed,
          ),
        ),
      if (relativeHumidity ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Relative humidity',
            subtitle: 'Relative humidity [%]',
            metricKey: 'relativeHumidity',
            color: const Color(0xFF8C5B3E),
            minOverride: 0,
            maxOverride: 100,
          ),
        ),
      if (precipitation ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Precipitation',
            subtitle: 'Accumulation [in]',
            metricKey: 'precipitation',
            color: const Color(0xFF1D70D2),
            bar: true,
            clampMinToZero: true,
            decimals: 2,
          ),
        ),
      if (windSpeed ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Wind speed',
            subtitle: 'Speed [mph]',
            metricKey: 'windSpeed',
            color: const Color(0xFFC15A24),
            clampMinToZero: true,
            decimals: 0,
          ),
        ),
      if (soilTemperature ?? false)
        _chartSection(_soilTemperatureChart(data), height: 440),
      if (soilVWC ?? false) _chartSection(_soilVwcChart(data), height: 440),
      if (bulkEC ?? false) _chartSection(_bulkEcChart(data), height: 440),
      if (atmosphericPressure ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Atmospheric pressure',
            subtitle: 'Pressure [hPa]',
            metricKey: 'atmosphericPressure',
            color: _chartPurple,
            decimals: 0,
          ),
        ),
      if (snowDepth ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Ultrasonic snow depth',
            subtitle: 'Snow depth [in]',
            metricKey: 'snowDepth',
            color: const Color(0xFF355F76),
            clampMinToZero: true,
            decimals: 1,
          ),
        ),
      if (solarRadiation ?? false)
        _chartSection(
          _buildSingleSeriesChart(
            data: data,
            title: 'Solar radiation',
            subtitle: 'Solar radiation [W/m²]',
            metricKey: 'solarRadiation',
            color: const Color(0xFFBC5447),
            decimals: 0,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Data>>(
        future: _dataFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Data>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              children: <Widget>[
                _buildFilterHeader(context),
                _chartSection(_buildLoadingCard()),
              ],
            );
          }

          final List<Data> data = snapshot.data ?? <Data>[];
          final List<Widget> chartSections = _buildChartSections(data);

          return ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            children: <Widget>[
              _buildFilterHeader(context),
              if (chartSections.isEmpty)
                SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      'Select at least one chart to display.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (data.isEmpty)
                SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      'No chart data is available for the selected range.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...chartSections,
            ],
          );
        },
      ),
    );
  }
}
