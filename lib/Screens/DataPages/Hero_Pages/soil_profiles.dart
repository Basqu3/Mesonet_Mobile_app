// ignore_for_file: camel_case_types

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:app_001/Screens/DataPages/JSONData.dart';
import 'package:rainbow_color/rainbow_color.dart';

/*Returns a column with graphical representations of soil VWC and Temp
Use a hero widget to allow for tap to expand in this.
FL Charts should be able to make my graphs? */

class soil_profiles extends StatefulWidget {
  final Data data;
  final bool isHydromet;
  const soil_profiles(
      {super.key, required this.isHydromet, required this.data});

  @override
  State<soil_profiles> createState() => _soil_profilesState();
}

class _soil_profilesState extends State<soil_profiles> {
  List<double> getTempRange() {
    List<double> range = [
      widget.data.soilTemperature5 ?? 0.0,
      widget.data.soilTemperature10 ?? 0.0,
      widget.data.soilTemperature20 ?? 0.0,
      widget.data.soilTemperature50 ?? 0.0,
      widget.data.soilTemperature100 ?? 0.0,
    ];

    return [range.reduce(max) + 5, range.reduce(min) - 5];
  }

  Color getGradientColors(double input, bool temperatureBool) {
    // Define color ranges

    Rainbow rbColorTemp;

    if (input < 32) {
      rbColorTemp = Rainbow(
        spectrum: [
          Colors.blue.shade900,
          Color.fromARGB(255, 43, 140, 190),
          Color.fromARGB(255, 189, 201, 225),
          Colors.white,
        ], //cold to hot
        rangeStart: getTempRange()[1],
        rangeEnd: getTempRange()[0],
      );
    } else {
      rbColorTemp = Rainbow(
        spectrum: [
          Color.fromARGB(255, 255, 255, 120),
          Color.fromARGB(255, 253, 141, 60),
          Color.fromARGB(255, 240, 59, 32),
        ], //cold to hot
        rangeStart: getTempRange()[1],
        rangeEnd: getTempRange()[0],
      );
    }

    /// This class represents the soil profiles page in the application.
    /// It utilizes a rainbow color scheme for visualizing volumetric water content (VWC).
    /// Will be modified to show percent saturation once available for all stations.
    /// The `rbColorVWC` variable is used to create a rainbow color gradient for the VWC data.
    var rbColorVWC = Rainbow(
      spectrum: [
        Color.fromARGB(255, 166, 96, 26),
        Color.fromARGB(255, 223, 194, 125),
        Color.fromARGB(255, 245, 245, 245),
        Color.fromARGB(255, 106, 219, 135),
        Color.fromARGB(255, 1, 133, 113),
      ], //cold to hot
      rangeStart: 0,
      rangeEnd: 50,
    );

    if (temperatureBool) {
      return rbColorTemp[input];
    } else {
      return rbColorVWC[input];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Text at the top of the card
        Text(
          'Soil Profiles',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed),
        ),
        //=================================================================
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    verticalDirection: VerticalDirection.up,
                    children: widget.isHydromet
                        ? [
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text('40"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text('20"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text(' 8"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text(' 4"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text(' 2"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                          ]
                        : [ //agrimet labels. no 2" sensor
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text('40"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSecondary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text('20"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSecondary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text(' 8"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSecondary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text(' 4"',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSecondary)),
                          ),
                          ],
                  )),
              Flexible(
                  flex: 6,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children:[Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.isHydromet
                        ? [
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature5 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature5.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature10 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature10.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature20 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature20.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature50 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature50.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature100 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature100.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                        ]
                        : [ //agrimet temp profiles
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature10 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature10.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature20 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature20.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature50 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature50.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilTemperature100 ?? 999.99, true),
                            child: Center(
                              child: Text(
                                '${widget.data.soilTemperature100.toString()}°F',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                        ]
                      ),
                      
                      Text("Temp",style: TextStyle(
                        fontSize: 10
                      ),),
                      ] 
                    ),
                  )),
              Flexible(
                  flex: 6,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children:[

                        

                        Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.isHydromet
                        ?[
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC5 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC5.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC10 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC10.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC20 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC20.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC50 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC50.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC100 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC100.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                        ]
                        : [ //agrimet VWC profiles
                        
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC10 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC10.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC20 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC20.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC50 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC50.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            color: getGradientColors(
                                widget.data.soilVWC100 ?? 999.99, false),
                            child: Center(
                              child: Text(
                                '${widget.data.soilVWC100.toString()}%',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )),
                        ],
                      ),

                      Text("VWC",style: TextStyle(
                        fontSize: 10
                      ),),

                      ] 
                    ),
                  )),
            ],
          ),
        ))
      ],
    );
  }
}
