import 'package:flutter/material.dart';
import 'package:app_001/Screens/map.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeManager extends StatefulWidget {
  const HomeManager({super.key});

  @override
  State<HomeManager> createState() => _HomeManagerState();
}

class _HomeManagerState extends State<HomeManager> {
  int _currentIndex = 1;
  final List _screens = [
    const feedback(),
    map(),
    const about(),
    const Streamflow(), //Add as soon as zach optimizes for mobile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onTertiary,
          selectedItemColor: Theme.of(context).colorScheme.tertiary,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.question_answer,
              ),
              label: 'Feedback',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Map",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: "About",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water),
              label: "Streamflow",
            ),
          ]),
    );
  }
}

class about extends StatefulWidget {
  const about({super.key});

  @override
  State<about> createState() => _aboutState();
}

class _aboutState extends State<about> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://climate.umt.edu/about/?theme=dark'));

    NavigationDelegate(onNavigationRequest: (NavigationRequest request) {
      if (request.url.startsWith('https://climate.umt.edu.com')) {
        return NavigationDecision.navigate;
      }
      return NavigationDecision.prevent;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.loadRequest(Uri.parse('about:blank'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: WebViewWidget(controller: controller));
  }
}

class feedback extends StatefulWidget {
  //https://airtable.com/appUacO5Pq7wZYoJ3/pag3YMFrQcZAnaifj/form
  const feedback({super.key});

  @override
  State<feedback> createState() => _feedbackState();
}

class _feedbackState extends State<feedback> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://airtable.com/appUacO5Pq7wZYoJ3/pag3YMFrQcZAnaifj/form'));
    NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://airtable.com')) {
          return NavigationDecision.navigate;
        }
        return NavigationDecision.prevent;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.loadRequest(Uri.parse('about:blank'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WebViewWidget(
      controller: controller,
    ));
  }
}
class Streamflow extends StatefulWidget {
  const Streamflow({super.key});

  @override
  State<Streamflow> createState() => _StreamflowState();
}

class _StreamflowState extends State<Streamflow> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://streamflow.climate.umt.edu/'));
    NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://streamflow.climate.umt.edu/')) {
          return NavigationDecision.navigate;
        }
        return NavigationDecision.prevent;
      },
    );
  }

  @override
  void dispose() {
    controller.loadRequest(Uri.parse('about:blank'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WebViewWidget(
      controller: controller,
    ));
  }
}
