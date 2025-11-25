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
    const FeedbackPage(),
    MapPage(),
    const About(),
    const Streamflow(),
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

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://climate.umt.edu')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        }),
      )
      ..loadRequest(Uri.parse('https://climate.umt.edu/about/?theme=dark'));
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

class FeedbackPage extends StatefulWidget {
  //https://airtable.com/appUacO5Pq7wZYoJ3/pag3YMFrQcZAnaifj/form
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://airtable.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://airtable.com/appUacO5Pq7wZYoJ3/pag3YMFrQcZAnaifj/form'));
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://streamflow.climate.umt.edu/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://streamflow.climate.umt.edu/'));
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
