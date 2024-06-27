import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_example/misc/tile_providers.dart';
import 'package:flutter_map_example/widgets/drawer/floating_menu_button.dart';
import 'package:flutter_map_example/widgets/drawer/menu_drawer.dart';
import 'package:flutter_map_example/widgets/first_start_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../plugins/my_login.dart';

Future<List<dynamic>> fetchData(String token) async {
  final url = Uri.parse('http://pinkapp.lol/api/v1/vehicle/list');
  final headers = {'Authorization': 'Bearer $token'};

  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final metadata = jsonData['metadata'] as List<dynamic>;
    return metadata;
  } else {
    return [];
  }
}

class HomePage extends StatefulWidget {
  static const String route = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? _data = [];

  @override
  void initState() {
    super.initState();
    showIntroDialogIfNeeded();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final token = MyLogin.instance.token;
    final data = await fetchData(token);
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: const MenuDrawer(HomePage.route),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              // focus Nha Trang
              initialCenter: const LatLng(12.2388, 109.1967),
              initialZoom: 14,
              cameraConstraint: CameraConstraint.contain(
                // focus Nha Trang
                bounds: LatLngBounds(
                  const LatLng(12.1888, 109.1467),
                  const LatLng(12.2888, 109.2467),
                ),
              ),
            ),
            children: [
              openStreetMapTileLayer,
              RichAttributionWidget(
                popupInitialDisplayDuration: const Duration(seconds: 5),
                animationConfig: const ScaleRAWA(),
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () async => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                  const TextSourceAttribution(
                    'This attribution is the same throughout this app, except '
                    'where otherwise specified',
                    prependCopyright: false,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(12.242049, 109.187772),
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/marker_location.png',
                    ),
                  ),
                  Marker(
                    point: const LatLng(12.230290, 109.164099),
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/marker_location.png',
                    ),
                  ),
                  if (_data != null)
                    ..._data!.map((item) {
                      MaterialColor calculateIconColor(int status) {
                        switch (status) {
                          case 2:
                            return Colors.green;
                          case 3:
                            return Colors.yellow;
                          case 4:
                            return Colors.red;
                          default:
                            return Colors.grey;
                        }
                      }

                      String assetTypeCar(int type) {
                        switch (type) {
                          case 0:
                            return 'assets/type_car/vf.png';
                          case 1:
                            return 'assets/type_car/testla_model_s.png';
                          case 2:
                            return 'assets/type_car/kia_soul_ev.png';
                          case 3:
                            return 'assets/type_car/mg_zs_ev.png';
                          case 4:
                            return 'assets/type_car/volkswagen_id3.png';
                          case 4:
                            return 'assets/type_car/hyundai_kona_electric.png';
                          case 4:
                            return 'assets/type_car/honda_e.png';
                          case 4:
                            return 'assets/type_car/nissan_leaf.png';
                          case 4:
                            return 'assets/type_car/peugeot_e208.png';
                          case 4:
                            return 'assets/type_car/polestar_2.png';
                          default:
                            return 'assets/type_car/tesla_model_3.png';
                        }
                      }

                      final double latitude = item['latitude'] is double
                          ? item['latitude'] as double
                          : 0.0;
                      final double longitude = item['longitude'] is double
                          ? item['longitude'] as double
                          : 0.0;
                      final String customerName = (item['customer_name'] != null) ? item['customer_name'] as String : 'No Name';
                      final int unitPrice = (item['unit_price'] != null) ? item['unit_price'] as int : 0;
                      return Marker(
                          point: LatLng(latitude, longitude),
                          width: 40,
                          height: 40,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 400,
                                    width: screenWidth,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 30),
                                    child: Column(
                                      children: [
                                        Text(
                                          customerName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26),
                                        ),
                                        Image.asset(
                                            assetTypeCar(
                                                item['vehicle_type'] as int),
                                            height: 200),
                                        Text(
                                          'Pin: ${item['battery_status']}%',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          'Unit Price: $unitPrice',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Stack(
                              children: [
                                SvgPicture.asset(
                                  'assets/ic_car.svg',
                                  colorFilter: ColorFilter.mode(
                                      calculateIconColor(item['status'] as int),
                                      BlendMode.srcIn),
                                ),
                                Visibility(
                                  visible: item['battery_status'] as int <= 10,
                                  child: const Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.report_problem,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ));
                    }),
                ],
              ),
            ],
          ),
          const FloatingMenuButton()
        ],
      ),
    );
  }

  void showIntroDialogIfNeeded() {
    const seenIntroBoxKey = 'seenIntroBox(a)';
    if (kIsWeb && Uri.base.host.trim() == 'demo.fleaflet.dev') {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) async {
          final prefs = await SharedPreferences.getInstance();
          if (prefs.getBool(seenIntroBoxKey) ?? false) return;

          if (!mounted) return;

          await showDialog<void>(
            context: context,
            builder: (context) => const FirstStartDialog(),
          );
          await prefs.setBool(seenIntroBoxKey, true);
        },
      );
    }
  }
}
