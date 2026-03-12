import 'dart:convert';

import 'package:app_001/Screens/DataPages/ChartManager.dart';
import 'package:app_001/Screens/DataPages/CurrentData.dart';
import 'package:app_001/Screens/DataPages/CurrentDataPretty.dart';
import 'package:app_001/Screens/DataPages/AgrimetCurrentData.dart';
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
  static const Color _favoriteActiveColor = Color(0xFFFFC857);
  static const Color _favoriteInactiveColor = Colors.white;
  static const Color _pageIndicatorActiveColor = Color(0xFFFFC857);
  static const Color _pageIndicatorInactiveColor = Color(0xFFF8FAFC);

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
        Currentdata(
          id: id,
          isHydromet: false,
        ),
        AgrimetCurrentData(
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
    initialPage: 1,
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

  int _activePage = 1;

  @override
  Widget build(BuildContext context) {
    final Color headerColor = widget.station.subNetwork == 'HydroMet'
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: headerColor,
          actions: [
            IconButton(
              tooltip: remove ? 'Remove from favorites' : 'Add to favorites',
              icon: Icon(
                Icons.star,
                color:
                    remove ? _favoriteActiveColor : _favoriteInactiveColor,
                shadows: remove
                    ? const <Shadow>[
                        Shadow(
                          blurRadius: 10,
                          color: Color(0x99000000),
                        ),
                      ]
                    : const <Shadow>[
                        Shadow(
                          blurRadius: 6,
                          color: Color(0x66000000),
                        ),
                      ],
              ),
              onPressed: () {
                createFavoritesJson(); //saving to favorites
              },
            )
          ],
          title: Text(
            widget.station.name,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
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
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _activePage == index
                                          ? _pageIndicatorActiveColor
                                          : _pageIndicatorInactiveColor,
                                      border: Border.all(
                                        color: const Color(0xB3000000),
                                        width: 1.2,
                                      ),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          blurRadius: 6,
                                          color: Color(0x40000000),
                                        ),
                                      ],
                                    ),
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
