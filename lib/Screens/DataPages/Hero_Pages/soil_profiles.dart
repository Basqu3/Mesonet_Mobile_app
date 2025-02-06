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
  const soil_profiles({super.key, required this.data});

  @override
  State<soil_profiles> createState() => _soil_profilesState();
}

class _soil_profilesState extends State<soil_profiles> {

  List<double> getTempRange() {
    List<double> range = [
      (widget.data.soilTemperature5 ?? 0) as double,
      (widget.data.soilTemperature10 ?? 0) as double,
      (widget.data.soilTemperature20 ?? 0) as double,
      (widget.data.soilTemperature50 ?? 0) as double,
      (widget.data.soilTemperature100 ?? 0) as double,
    ];

    return [range.reduce(max) + 5 , range.reduce(min) - 5];
  }

  Color getGradientColors(double input, bool temperatureBool) {
    // Define color ranges

    Rainbow rbColorTemp;

    if (input < 32) {
      rbColorTemp = Rainbow(
        spectrum: [
          Colors.blue.shade900,
          Colors.blue.shade700,
          Colors.blue.shade500,
          Colors.blue.shade300,
          Colors.blue.shade100,
          Colors.white,
        ], //cold to hot
        rangeStart: getTempRange()[1],
        rangeEnd: getTempRange()[0],
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
        rangeStart: getTempRange()[1],
        rangeEnd: getTempRange()[0],
      );
    }

    /// This class represents the soil profiles page in the application.
    /// It utilizes a rainbow color scheme for visualizing volumetric water content (VWC).
    ///
    /// The `rbColorVWC` variable is used to create a rainbow color gradient for the VWC data.
    var rbColorVWC = Rainbow(
      spectrum: [
        Colors.brown,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
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
                flex: 2,
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                verticalDirection: VerticalDirection.up,
                children: [
                  Text('40"', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,fontWeight: FontWeight.w500)),
                  Text('20"', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,fontWeight: FontWeight.w500)),
                  Text(' 8"', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,fontWeight: FontWeight.w500)),
                  Text(' 4"', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,fontWeight: FontWeight.w500)),
                  Text(' 2"', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,fontWeight: FontWeight.w500)),
                ],
              )),
              Flexible(
                flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color:Theme.of(context).colorScheme.onPrimaryContainer, width: 1),),
                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                    Expanded(
                        child: Container(
                          color: getGradientColors(
                          (widget.data.soilTemperature5 ?? 0) as double, true),
                          child: Center(child: Text('${widget.data.soilTemperature5?.toString() ?? 'N/A'}°F',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          (widget.data.soilTemperature10 ?? 0) as double, true),
                          child: Center(child: Text('${widget.data.soilTemperature10?.toString() ?? 'N/A'}°F',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          (widget.data.soilTemperature20 ?? 0) as double, true),
                          child: Center(child: Text('${widget.data.soilTemperature20?.toString() ?? 'N/A'}°F',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          (widget.data.soilTemperature50 ?? 0) as double, true),
                          child: Center(child: Text('${widget.data.soilTemperature50?.toString() ?? 'N/A'}°F',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          (widget.data.soilTemperature100 ?? 0) as double, true),
                          child: Center(child: Text('${widget.data.soilTemperature100?.toString() ?? 'N/A'}°F',
                          style: TextStyle(fontSize: 10),),),
                    )),
                                    ],
                                  ),
                  )),
              
              Flexible(
                flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color:Theme.of(context).colorScheme.onPrimaryContainer, width: 1),),
                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          widget.data.soilVWC5 as double, false),
                          child: Center(child: Text('${widget.data.soilVWC5.toString()}%',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          widget.data.soilVWC10 as double, false),
                          child: Center(child: Text('${widget.data.soilVWC10.toString()}%',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          widget.data.soilVWC20 as double, false),
                          child: Center(child: Text('${widget.data.soilVWC20.toString()}%',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          widget.data.soilVWC50 as double, false),
                          child: Center(child: Text('${widget.data.soilVWC50.toString()}%',
                          style: TextStyle(fontSize: 10),),),
                    )),
                    Expanded(
                        child: Container(
                      color: getGradientColors(
                          widget.data.soilVWC100 as double, false),
                          child: Center(child: Text('${widget.data.soilVWC100.toString()}%',
                          style: TextStyle(fontSize: 10),),),
                    )),
                                    ],
                                  ),
                  )),

            ],
          ),
        ))
      ],
    );
  }
}
