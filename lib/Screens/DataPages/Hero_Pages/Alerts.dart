import 'package:flutter/material.dart';
import 'package:app_001/main.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:convert';


class Alerts extends StatefulWidget {
  final double lat;
  final double lng;
  final bool isHydromet;
  const Alerts({required this.lat, required this.lng, required this.isHydromet,super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {

  @override
  initState() {
    super.initState();
    getAlerts();
  }

  Future<Map<String,dynamic>> getAlerts() async {
    Map<String, dynamic> responseMap;
    String response = await flutterCompute(
        apiCall, 'https://api.weather.gov/alerts/active?status=actual&point=${widget.lat},${widget.lng}');
    
    responseMap = parseToMap(response);
    //print(responseMap['features']['properties']['event']);

    //debugPrint(responseMap['features'][0]['properties']['event'].toString());
    return responseMap; 
  }

    @pragma('vm:entry-point') //multithread parse to map
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: getAlerts(), builder: (builder, snapshot) {
      if (snapshot.hasData) {
        return snapshot.data!['features'].length > 0 
        ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                snapshot.data!['features'].length > 0 
                ? Icon(Icons.warning, 
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
                )
                : Container(),
                
                Expanded(
                  child: Text(snapshot.data!['features'][0]['properties']['event'].toString(), style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12),
                    textAlign: TextAlign.center,),
                )
                ]
                //getting a ]response here. If statement based off
                //whether features [] is empty or not. Listview with cards maybe?
              ),
            )
          ],
        )
        : Center(child: Text('No Weather Alerts',textAlign: TextAlign.center,
        style: TextStyle(
          color: widget.isHydromet
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSecondary
          ),));
      } else {
        return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary));
      }
    });
  }
}
