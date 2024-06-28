import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'home.dart';

Future<void> showIntroduce(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 360,
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          color: Colors.white30,
          child: Column(
            children: [
              const Text(
                'Mang lại sự tiện lợi khi đến thành phố Nha Trang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Mang lại sự tiện lợi khi đến thành phố Nha Trang, Mang lại sự tiện lợi khi đến thành phố Nha Trang, Mang lại sự tiện lợi khi đến thành phố Nha Trang.',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, HomePage.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 167, 111),
                  minimumSize: Size(screenWidth, 60),
                ),
                child: const Text(
                  'Nhấn để bắt đầu',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        );
      });
}

class BeginPage extends StatefulWidget {
  static const String route = '/begin';

  const BeginPage({super.key});

  @override
  State<BeginPage> createState() => _BeginState();
}

class _BeginState extends State<BeginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showIntroduce(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    const imageBg = AssetImage('assets/background_nt.png');

    precacheImage(imageBg, context);
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(image: imageBg, fit: BoxFit.cover)),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showIntroduce(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            'assets/ic_detail.svg',
            // colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
