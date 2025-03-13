import 'dart:convert';

import 'package:app_001/Screens/DataPages/ChartManager.dart';
import 'package:app_001/Screens/DataPages/CurrentData.dart';
import 'package:app_001/Screens/DataPages/CurrentDataPretty.dart';
import 'package:app_001/Screens/Forcast.dart';
import 'package:app_001/Screens/map.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HydroStationPage extends StatefulWidget {
  final StationMarker station;
  final int hydroBool;
  const HydroStationPage(
      {super.key, required this.station, required this.hydroBool});

  @override
  State<HydroStationPage> createState() => _HydroStationPageState();
}

class _HydroStationPageState extends State<HydroStationPage> {
  late bool remove;
  late List<Widget> _pages;

  @override
  void initState() {
    remove = false;
    //set _pages list here to pass station Id to them with constructor injection
    setPages(widget.station.id, widget.hydroBool);
    WidgetsBinding.instance.addPostFrameCallback((_) => checkIfFavorite());

    super.initState();
  }

  void setPages(String id, int hydroBool) {
    //setting pages for viewing agrimet
    if (hydroBool == 1) {
      _pages = [
        Forcast(
          lat: widget.station.lat,
          lng: widget.station.lon,
          isHydromet: true,
        ), //setting pages
        Currentdata(
          id: id,
          isHydromet: true,
        ),
        CurrentDataPretty(
            id: id,
            lat: widget.station.lat,
            lng: widget.station.lon,
            isHydromet: true),
        Chartmanager(
          id: id,
          isHydromet: true,
        ),
        //PhotoPage(id: id),
      ];
    } else {
      _pages = [
        Forcast(
          lat: widget.station.lat,
          lng: widget.station.lon,
          isHydromet: false,
        ),
        Currentdata(
          id: id,
          isHydromet: false,
        ),
        CurrentDataPretty(
          id: id,
          lat: widget.station.lat,
          lng: widget.station.lon,
          isHydromet: false,
        ),
        Chartmanager(
          id: id,
          isHydromet: false,
        ),
      ];
    }
  }

  final _pageController = PageController(
    initialPage:
        2, //initial page for the marker. index starts at 0 and follows the lists above. Don't index out of range for the shorter list
    viewportFraction: 1,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('favorites');
    Map<String, dynamic> favoritesJson;

    if (favoritesString != null) {
      favoritesJson = jsonDecode(favoritesString);
    } else {
      favoritesJson = {'stations': []};
    }

    for (int i = 0; i < favoritesJson['stations'].length; i++) {
      favoritesJson['stations'][i].forEach((key, value) {
        //check for id in all stations
        if (value == widget.station.id) {
          setState(() {
            remove = true;
          });
        }
      });
    }
  }

  //Create favorites json for shared preferences
  //Need to pull the json from shared preferences, modify it and then resave
  void createFavoritesJson() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('favorites');
    Map<String, dynamic> favoritesJson;

    if (favoritesString != null) {
      favoritesJson = jsonDecode(favoritesString);
    } else {
      favoritesJson = {'stations': []};
    }

    if (remove) {
      favoritesJson['stations'].removeWhere((element) =>
          element['id'] ==
          widget.station.id); //remove everywhere we find the id
    } else {
      favoritesJson['stations'].add({
        'name': widget.station.name,
        'id': widget.station.id,
        'sub_network': widget.station.subNetwork,
        'lat': widget.station.lat,
        'lon': widget.station.lon,
        'air_temp': widget.station.air_temp,
        'precipSummary': widget.station.precipSummary,
      });
    }

    setState(() {
      prefs.setString('favorites', jsonEncode(favoritesJson));
      remove = !remove;
    });
  }

  int _activePage = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(
                Icons.star,
                color: remove
                    ? Colors.yellow
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                createFavoritesJson(); //saving to favorites
              },
            )
          ],
          title: Text(
            widget.station.name,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onPrimaryFixed),
          ),
          centerTitle: true,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          backgroundColor: (widget.station.subNetwork == 'HydroMet')
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
        ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _activePage = page;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (BuildContext context, int index) {
                return _pages[index % _pages.length];
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                          _pages.length,
                          (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: InkWell(
                                  onTap: () {
                                    _pageController.animateToPage(index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeIn);
                                  },
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: _activePage == index
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                  ),
                                ),
                              ))),
                ),
              ),
            )
          ],
        ));
  }
}