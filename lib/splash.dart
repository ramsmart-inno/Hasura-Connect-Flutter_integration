import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trailz/terms.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 15), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Terms()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.network(
                "https://cdn.freebiesupply.com/logos/large/2x/hd-logo-png-transparent.png"),
            width: 100,
            height: 100,
          ),
          Center(
            child: SpinKitDoubleBounce(
              color: Colors.white,
              size: 40.0,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Loading",
            style: TextStyle(color: Colors.yellow),
          ),
        ],
      ),
    ));
  }
}
