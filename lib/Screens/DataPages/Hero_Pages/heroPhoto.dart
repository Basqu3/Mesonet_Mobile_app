import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class heroPhoto extends StatelessWidget {
  final String id;
  const heroPhoto({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Hero(
        tag: id,
        child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: NetworkImage(
                'https://mesonet.climate.umt.edu/api/v2/photos/$id')),
      ),
    );
  }
}
