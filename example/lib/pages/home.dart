import 'dart:async';
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
import 'package:location/location.dart';
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

Future<List<dynamic>> fetchDataPoint(String token) async {
  final url = Uri.parse('http://pinkapp.lol/api/v1/point/list');
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  Location _locationController = new Location();

  bool _mapCentered = false;
  StreamSubscription<LocationData>? _locationSubscription;

  List<dynamic>? _data = [];
  List<dynamic>? _dataPoint = [];

  LatLng? _currentP = null;

  @override
  void initState() {
    super.initState();
    showIntroDialogIfNeeded();
    _fetchData();
    _fetchDataPoint();
    Future.delayed(const Duration(seconds: 15), _fetchData);
    getLocationUpdates().then(
      (_) => {},
    );
  }

  Future<void> _fetchData() async {
    final token = MyLogin.instance.token;
    final data = await fetchData(token);
    setState(() {
      _data = data;
    });
  }

  Future<void> _fetchDataPoint() async {
    final token = MyLogin.instance.token;
    final dataPoint = await fetchDataPoint(token);
    setState(() {
      _dataPoint = dataPoint;
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (!_mapCentered &&
          currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _animatedMapMove(
            LatLng(currentLocation.latitude!, currentLocation.longitude!), 15);
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _mapCentered = true;
        });
        _locationSubscription?.cancel();
        _locationSubscription = null;
      }
    });
  }

  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: const MenuDrawer(HomePage.route),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              // focus Nha Trang
              initialCenter: _currentP ?? const LatLng(12.1888, 109.1467),
              initialZoom: _currentP != null ? 14 : 12,

              // cameraConstraint: CameraConstraint.contain(
              //   // focus Nha Trang
              //   bounds: _currentP != null
              //       ? LatLngBounds(_currentP!, _currentP!)
              //       : LatLngBounds(
              //           const LatLng(12.1888, 109.1467),
              //           const LatLng(12.2888, 109.2467),
              //         ),
              // ),
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
                  if (_currentP != null)
                    Marker(
                      point: LatLng(_currentP!.latitude, _currentP!.longitude),
                      width: 70,
                      height: 70,
                      child: Image.asset(
                        'assets/marker_location.png',
                      ),
                    ),
                  if (_dataPoint != null)
                    ..._dataPoint!.map((item) {
                      final double latitude = item['latitude'] is double
                          ? item['latitude'] as double
                          : 0.0;
                      final double longitude = item['longitude'] is double
                          ? item['longitude'] as double
                          : 0.0;

                      return Marker(
                          point: LatLng(latitude, longitude),
                          child: InkWell(
                            onTap: () {},
                            child: SvgPicture.asset(
                              'assets/ic_energy.svg',
                              colorFilter: const ColorFilter.mode(
                                  Colors.orange, BlendMode.srcIn),
                            ),
                          ));
                    }),
                  if (_data != null)
                    ..._data!.map((item) {
                      final double latitude = item['latitude'] is double
                          ? item['latitude'] as double
                          : 0.0;
                      final double longitude = item['longitude'] is double
                          ? item['longitude'] as double
                          : 0.0;
                      final String customerName =
                          (item['customer_name'] != null)
                              ? item['customer_name'] as String
                              : 'Xe Đang Trống';
                      final int unitPrice = (item['unit_price'] != null)
                          ? item['unit_price'] as int
                          : 0;
                      final int time = (item['rental_duration'] != null)
                          ? item['rental_duration'] as int
                          : 0;

                      final int status = item['status'] as int;
                      final int batteryStatus = (item['battery_status'] != null)
                          ? item['battery_status'] as int
                          : 0;
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
                                    height: 700,
                                    width: screenWidth,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 30),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView(
                                            children: [
                                              Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  image: DecorationImage(
                                                    image: AssetImage(assetTypeCar(
                                                            item['vehicle_type']
                                                                as int)['icon']
                                                        as String),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                assetTypeCar(
                                                        item['vehicle_type']
                                                            as int)['name']
                                                    as String,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        'Status:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    Text(
                                                      generateTextStatus(
                                                          status),
                                                      style: TextStyle(
                                                          fontSize: 24,
                                                          color:
                                                              calculateIconColor(
                                                                  status)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        'Tên KH:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    Text(
                                                      customerName,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        'Pin:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    Text(
                                                      '$batteryStatus%',
                                                      style: TextStyle(
                                                          fontSize: 24,
                                                          color:
                                                              generateClassStatusBattery(
                                                                  batteryStatus)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        'Giá thuê:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    Text(
                                                      '\$$unitPrice',
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        'Thời gian:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    Text(
                                                      '$time/h',
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            showBookCarDialog(context);
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                  color: status != 1
                                                      ? Colors.grey
                                                      : const Color(0xFF283FB1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: const Center(
                                                  child: Text(
                                                'Đặt xe',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ))),
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
                                      generateClassStatusBattery(batteryStatus),
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

  MaterialColor calculateIconColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String generateTextStatus(int status) {
    switch (status) {
      case 1:
        return 'Free';
      case 2:
        return 'Đã có khách';
      case 3:
        return 'Hết pin';
      case 4:
        return 'Hỏng';
      default:
        return 'Free';
    }
  }

  Map<String, dynamic> assetTypeCar(int type) {
    switch (type) {
      case 0:
        return {'icon': 'assets/type_car/vf.png', 'name': 'Vinfast VF e34'};
      case 1:
        return {
          'icon': 'assets/type_car/testla_model_s.png',
          'name': 'Tesla Model S'
        };
      case 2:
        return {
          'icon': 'assets/type_car/kia_soul_ev.png',
          'name': 'Kia Soul EV'
        };
      case 3:
        return {'icon': 'assets/type_car/mg_zs_ev.png', 'name': 'MG ZS EV'};
      case 4:
        return {
          'icon': 'assets/type_car/volkswagen_id3.png',
          'name': 'Volkswagen ID.3'
        };
      case 5:
        return {
          'icon': 'assets/type_car/hyundai_kona_electric.png',
          'name': 'Hyundai Kona Electric'
        };
      case 6:
        return {'icon': 'assets/type_car/honda_e.png', 'name': 'Honda E'};

      case 7:
        return {
          'icon': 'assets/type_car/nissan_leaf.png',
          'name': 'Nissan Leaf'
        };
      case 8:
        return {
          'icon': 'assets/type_car/peugeot_e208.png',
          'name': 'Peugeot E-208'
        };
      case 9:
        return {'icon': 'assets/type_car/polestar_2.png', 'name': 'Polestar 2'};
      default:
        return {
          'icon': 'assets/type_car/tesla_model_3.png',
          'name': 'Tesla Model 3'
        };
    }
  }

  Color generateClassStatusBattery(int status) {
    if (status >= 80) {
      return Colors.green;
    } else if (status > 20) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
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

  Future<void> showBookCarDialog(BuildContext context) async {
    final double screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ĐẶT XE THÀNH CÔNG',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SvgPicture.asset(
                  'assets/ic_success.svg',
                  width: 100,
                  height: 100,
                  colorFilter:
                      const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 167, 111),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size(screenWidth, 50),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
