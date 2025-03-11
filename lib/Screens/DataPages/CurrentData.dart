import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getData(
              'https://mesonet.climate.umt.edu/api/v2/latest/?type=json&stations=${widget.id}'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              //waiting on the future
              return const Placeholder();
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: widget.isHydromet
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            width: 1.0,
                          )),
                      child: ListTile(
                        trailing: Text(snapshot
                            .data![snapshot.data!.keys.elementAt(index)]
                            .toString(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary)),
                        title: Text(snapshot.data!.keys.elementAt(index),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary)),
                      ),
                    );
                  });
            } else {
              return Center(child: const CircularProgressIndicator());
            }
          }),
    );
  }
}
