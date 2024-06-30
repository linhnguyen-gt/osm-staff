import 'dart:convert';

import 'package:flutter/material.dart';

import '../plugins/my_login.dart';
import '../widgets/drawer/menu_drawer.dart';
import 'package:http/http.dart' as http;

Future<dynamic> fetchData(String token) async {
  final url = Uri.parse('http://103.82.195.138:3105/api/v1/user/profile');
  final headers = {'Authorization': 'Bearer $token'};

  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final metadata = jsonData['metadata'] as dynamic;
    return metadata;
  } else {
    return null;
  }
}

class ProfileScreen extends StatefulWidget {
  static const String route = '/ProfileScreen';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic _data;

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const MenuDrawer(ProfileScreen.route),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.2,
                backgroundImage: _data?['avatar'] != null ? NetworkImage(_data?['avatar'] as String) : null,
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('${_data?['fullname'] ?? ''}')
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('${_data?['email'] ?? ''}')
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('${_data?['address'] ?? ''}')
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
