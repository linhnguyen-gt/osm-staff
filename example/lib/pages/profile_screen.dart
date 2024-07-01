import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../plugins/my_login.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  static const String route = '/ProfileScreen';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final section = [
  {
    'title': 'Settings',
    'sections': [
      {'title': 'Change Password', 'icon': 'assets/ic_lock.png'},
      {'title': 'Language', 'icon': 'assets/ic_glo.png'},
      {'title': 'Notification', 'icon': 'assets/ic_noti.png'},
    ]
  },
  {
    'title': 'About Us',
    'sections': [
      {'title': 'FAQ', 'icon': 'assets/ic_help.png'},
      {'title': 'Privacy Policy', 'icon': 'assets/ic_security.png'},
      {'title': 'Contact Us', 'icon': 'assets/ic_team.png'},
    ]
  },
];

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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 215,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/background_profile.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundImage:  _data?['avatar'] != null
                                      ? NetworkImage(_data?['avatar'] as String)
                                      : null,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_data?['fullname'] ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('${_data?['address'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        )),
                                  ],
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, EditProfile.route),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: const Center(
                                      child: Text(
                                    'Edit Profile',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
              ListView(
                padding: const EdgeInsets.all(25),
                shrinkWrap: true,
                children: section
                    .map((item) {
                      final section   = item['sections']! as List;
                      return Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item['title']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Column(
                                children: section.map((e) =>  Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: const Color(0xFFF3F3F3)),
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Row(
                                      children: [
                                        Image.asset(e['icon'] as String),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text('${e['title']}')
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              )
                            ],
                          ),
                    );
                    })
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
