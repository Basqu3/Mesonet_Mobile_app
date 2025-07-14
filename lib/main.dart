import 'package:app_001/Screens/HomeManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


/*App for the montana climate office
  Built by Jim Seielstad

  Map Bounds -116.0518, 44.35556, -104.0355, 49.00769
  Center is -110,04365, 46.681625
   */


void main() async{
  runApp(const MainApp());
}

/*DOCS: Setting global functions to be used for concurrency
        pragma points to the functions for package binding in isolate
---------------------------------------------------------- */
@pragma('vm:entry-point')
Future<String> apiCall(String url) async{  
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

/*--------------------------------------------------------

DOCS: Setting light and dark color schemes for the app.
      Adjust colors below*/

const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xff0073A2),
    onPrimary: Colors.white70,
    primaryContainer: Color(0xff8FD1E9),
    onPrimaryContainer: Colors.black54,
    onPrimaryFixed: Colors.white,

    secondary:  Color.fromARGB(255, 11, 129, 90),
    onSecondary: Colors.white70,
    secondaryContainer: Color(0xff9FD3BF),
    onSecondaryContainer: Colors.black54,

    error: Colors.redAccent,
    onError: Colors.white,

    surface: Color(0xffcbcbcb),
    onSurface: Colors.black54,

    brightness: Brightness.light,
  );

const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xff0073A2),
    onPrimary: Colors.white70,
    primaryContainer: Color(0xff8FD1E9),
    onPrimaryContainer: Colors.black54,
    onPrimaryFixed: Colors.white,

    secondary: Color.fromARGB(255, 53, 110, 91),
    onSecondary: Colors.white70,
    secondaryContainer: Color(0xff9FD3BF),
    onSecondaryContainer: Colors.black54,

    error: Colors.redAccent,
    onError: Colors.white,

    surface: Color.fromARGB(255, 150, 150, 150),
    onSurface: Colors.black87,
    
    brightness: Brightness.dark,
  );



class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  //Body is splash screen. Use to set theme colors for the app. 
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Montana Climate Office',
      themeMode: ThemeMode.system, //checks for system light or dark mode
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),

      home: const HomeManager(),
    );
  }
}
