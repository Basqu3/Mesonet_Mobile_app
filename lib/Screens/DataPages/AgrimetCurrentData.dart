import 'package:app_001/Screens/DataPages/Hero_Pages/soil_profiles.dart';
import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'JSONData.dart';
import 'Hero_Pages/Alerts.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/Precip.dart';

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
  late bool hasPhoto;

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
    }
    );
  WidgetsBinding.instance.addPostFrameCallback((_){
    hasPhotoCheck(widget.id);
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

  void hasPhotoCheck(String id) async {
    http.Response request = await http.get(Uri.parse('https://mesonet.climate.umt.edu/api/v2/photos/$id'));
    if (request.statusCode == 200) {
      hasPhoto = true;
      } else {
        hasPhoto = false;
      }
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
            return Row(
              children: [
                Column(),
                Column(),
              ],
            );
          }
        },
      )
    );
  }
}
