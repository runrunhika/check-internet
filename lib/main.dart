import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Check Internet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;

  bool hasInternet = false;
  ConnectivityResult result = ConnectivityResult.none;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        this.result = result;
      });
    });
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;

      setState(() {
        this.hasInternet = hasInternet;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    internetSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = hasInternet ? Colors.green : Colors.red;
    final text = hasInternet ? 'Internet' : 'No Internet';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Internet'),
        centerTitle: true,
      ),
      body: Center(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        child: const Text('Check Internet'),
        onPressed: () async {
          hasInternet = await InternetConnectionChecker().hasConnection;

          result = await Connectivity().checkConnectivity();

          final color = hasInternet ? Colors.green : Colors.red;
          final text = hasInternet ? 'Internet' : 'No Internet';

          if (result == ConnectivityResult.mobile) {
            showSimpleNotification(
                Text(
                  '$text : Mobile Network',
                  style: TextStyle(fontSize: 21),
                ),
                background: color);
          } else if (result == ConnectivityResult.wifi) {
            showSimpleNotification(
                Text(
                  '$text : Wifi Network',
                  style: TextStyle(fontSize: 21),
                ),
                background: color);
          } else {
            showSimpleNotification(
                Text(
                  '$text : No Network',
                  style: TextStyle(fontSize: 21),
                ),
                background: color);
          }
        },
      )),
    );
  }
}
