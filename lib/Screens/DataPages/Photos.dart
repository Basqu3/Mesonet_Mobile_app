// ignore: file_names
import 'package:flutter/material.dart';

class PhotoPage extends StatefulWidget {
  final String id;
  final double? width;
  final double? height;
  const PhotoPage({super.key, required this.id, this.width, this.height});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: PageScrollPhysics(),
      shrinkWrap: true,
      children: [
        FittedBox(
          fit:BoxFit.scaleDown,
          child: Image.network(
              'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/n/?force=True',
              height: widget.height,
              width: widget.width,
              ),
        ),
        FittedBox(
          fit:BoxFit.scaleDown,
          child: Image.network(
            'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/w/?force=True',
            height: widget.height,
            width: widget.width,
            errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
            return Image.network(
              'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/ns/?force=True',
              height: widget.height,
              width: widget.width,
            );
          }
          ),
        ),
        FittedBox(
          fit:BoxFit.scaleDown,
          child: Image.network(
              'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/s/?force=True',
              height: widget.height,
              width: widget.width,
              ),
        ),
        FittedBox(
          fit:BoxFit.scaleDown,
          child: Image.network(
            'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/e/?force=True',
            height: widget.height,
            width: widget.width,
            errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
            return Image.network(
              'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/ss/?force=True',
              height: widget.height,
              width: widget.width,
            );
          }
          ),
        ),
      ],
    );
  }
}
