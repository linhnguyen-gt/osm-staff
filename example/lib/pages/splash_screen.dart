import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/login.dart';

class SplashScreen extends StatefulWidget {
  static const String route = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3),
        () => Navigator.pushReplacementNamed(context, Login.route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Flexible(
          child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              color: const Color(0xFF1D272F),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'OSM',
                    style: TextStyle(
                        color: Color(0xFFFD683D),
                        fontWeight: FontWeight.bold,
                        fontSize: 50),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'FOR STAFF',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ],
              ))),
    ]));
  }
}
