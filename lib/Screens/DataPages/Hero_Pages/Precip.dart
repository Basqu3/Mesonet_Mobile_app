import 'package:flutter/material.dart';
import 'package:app_001/Screens/DataPages/pptData.dart';
import 'dart:convert';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:app_001/main.dart';

class Precip extends StatefulWidget {
  final String id;
    final bool isHydromet; 
  const Precip({required this.id,required this.isHydromet,super.key});

  @override
  State<Precip> createState() => _PrecipState();
}
 
class _PrecipState extends State<Precip> {
// Define the variable

  @override
  void initState() {
    super.initState();
    getData('https://mesonet.climate.umt.edu/api/v2/derived/ppt/?type=json&stations=${widget.id}');
  }

   @pragma('vm:entry-point')
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  Future<pptData> getData(String url) async {
    pptData responseMap;
    String data = await flutterCompute(apiCall, url);
    List<dynamic> dataMap = jsonDecode(data);
    responseMap = pptData.fromJson(dataMap[0]);
    return responseMap;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isHydromet  // avoid the derived call for agrimet stations

    ? FutureBuilder(
      future: getData('https://mesonet.climate.umt.edu/api/v2/derived/ppt/?type=json&stations=${widget.id}'),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData){
            return ListView(
            padding: EdgeInsets.only(bottom: 0),
          shrinkWrap: true,
          children: [
            
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('24 Hour Precipitation:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.twentyFourHourPPT} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('7 Day Precipitation:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.sevenDayPPT} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('14 Day Precipitation:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.fourteenDayPPT} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('30 Day Precipitation:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.thirtyDayPPT} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('90 Day Precipitation:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.ninetyDayPPT} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Precipitation Since Midnight:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.PPTsinceMidnight} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
                Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                children: [
                FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Precipitation Year to Date:', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                Text('${snapshot.data!.YTDPPT} in', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ],
                ),
                ),
                ),
            ]
          
          
                    );
        } else {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary));
        }
      },
      
    ) //Switch case for agrimet stations. Have to derive the precip manually
    : Center(child: Text('No Precip Data Available',textAlign: TextAlign.center,
    style: TextStyle(
      color: widget.isHydromet
      ? Theme.of(context).colorScheme.onPrimary
      : Theme.of(context).colorScheme.onPrimaryContainer
    ),));
  }
}