import 'dart:convert';

import 'package:app_001/Screens/DataPages/pptData.dart';
import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class Precip extends StatefulWidget {
  final String id;
  final bool isHydromet;

  const Precip({
    required this.id,
    required this.isHydromet,
    super.key,
  });

  @override
  State<Precip> createState() => _PrecipState();
}

class _PrecipState extends State<Precip> {
  late Future<pptData> _precipFuture;

  @override
  void initState() {
    super.initState();
    _precipFuture = getData(
      'https://mesonet.climate.umt.edu/api/v2/derived/ppt/?type=json&stations=${widget.id}',
    );
  }

  @pragma('vm:entry-point')
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  Future<pptData> getData(String url) async {
    final String data = await flutterCompute(apiCall, url);
    final List<dynamic> dataMap = jsonDecode(data) as List<dynamic>;
    return pptData.fromJson(dataMap[0] as Map<String, dynamic>);
  }

  Widget _buildMetricCard(BuildContext context, String label, String value) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isHydromet) {
      return Center(
        child: Text(
          'Derived precipitation summaries are unavailable for AgriMet stations.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    return FutureBuilder<pptData>(
      future: _precipFuture,
      builder: (BuildContext context, AsyncSnapshot<pptData> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Precipitation summaries are unavailable right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pptData data = snapshot.data!;
        return ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: <Widget>[
            if (data.twentyFourHourPPT != null)
              _buildMetricCard(
                context,
                '24-hour precipitation',
                '${data.twentyFourHourPPT} in',
              ),
            if (data.sevenDayPPT != null)
              _buildMetricCard(
                context,
                '7-day precipitation',
                '${data.sevenDayPPT} in',
              ),
            if (data.fourteenDayPPT != null)
              _buildMetricCard(
                context,
                '14-day precipitation',
                '${data.fourteenDayPPT} in',
              ),
            if (data.thirtyDayPPT != null)
              _buildMetricCard(
                context,
                '30-day precipitation',
                '${data.thirtyDayPPT} in',
              ),
            if (data.ninetyDayPPT != null)
              _buildMetricCard(
                context,
                '90-day precipitation',
                '${data.ninetyDayPPT} in',
              ),
            if (data.PPTsinceMidnight != null)
              _buildMetricCard(
                context,
                'Precipitation since midnight',
                '${data.PPTsinceMidnight} in',
              ),
            if (data.YTDPPT != null)
              _buildMetricCard(
                context,
                'Year-to-date precipitation',
                '${data.YTDPPT} in',
              ),
          ],
        );
      },
    );
  }
}
