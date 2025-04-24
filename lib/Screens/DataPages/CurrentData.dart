import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'dart:convert';

class Currentdata extends StatefulWidget {
  final String id;
  final bool isHydromet;
  const Currentdata({super.key, required this.id, required this.isHydromet});

  @override
  State<Currentdata> createState() => _CurrentdataState();
}

class _CurrentdataState extends State<Currentdata> {
  @override
  initState() {
    super.initState();
  }

  @pragma('vm:entry-point')
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  Future<Map<String, dynamic>> getData(String url) async {
    String data = await compute(apiCall, url);
    int length = data.length;
    return compute(parseToMap, data.substring(1, length - 1));
  }

  String transformKey(String key) {
    if (key == 'station') return 'Station ID';
    if (key == 'datetime') return 'Date';
    if (key == 'VPD [mbar]') return 'Vapor Pressure Deficit [Mbar]';
    return key;
  }

  dynamic transformValue(String key, dynamic value) {
    if (key == 'datetime') {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal().toString().split(' ')[0];
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getData(
              'https://mesonet.climate.umt.edu/api/v2/latest/?type=json&stations=${widget.id}'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Placeholder();
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      String originalKey = snapshot.data!.keys.elementAt(index);
                      String transformedKey = transformKey(originalKey);
                      dynamic transformedValue = transformValue(
                          originalKey, snapshot.data![originalKey]);

                      return Card(
                        color: widget.isHydromet
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            ),
                        child: (transformedKey ==
                                'Vapor Pressure Deficit [Mbar]')
                            ? Stack(children: [
                              ListTile(
                                  trailing: Text(transformedValue.toString(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary)),
                                  title: Text(transformedKey,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary)),
                                ),

                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: InfoPopupWidget(
                                        contentTitle:
                                            'Vapour pressure-deficit, or VPD, is the difference (deficit) '
                                            'between the amount of moisture in the air and how much moisture the air can hold when it is saturated.',
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
                                            ))),
                                  ),
                                ),
                                
                              ])
                            : ListTile(
                                trailing: Text(transformedValue.toString(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                                title: Text(transformedKey,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                              ),
                      );
                    }),
              );
            } else {
              return Center(child: const CircularProgressIndicator());
            }
          }),
    );
  }
}
