import 'package:flutter/material.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:flutter/services.dart';

class HeroPhotoPage extends StatefulWidget {
  final String id;
  const HeroPhotoPage({super.key, required this.id});

  @override
  _HeroPhotoPageState createState() => _HeroPhotoPageState();
}

class _HeroPhotoPageState extends State<HeroPhotoPage> {
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(
            children:[ 
              Center(
                child: AspectRatio(
                  aspectRatio: 1520/855,
                  child: Hero(
                    tag: widget.id,
                    child: PhotoPage(id: widget.id,
                    ),
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    onPressed: () {
                        Navigator.of(context).pop(true);
                    },
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              )
      
              
              ]
          ),
        ),
      ),
    );
  }
}