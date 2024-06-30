import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../plugins/my_login.dart';
import 'begin.dart';

Future<dynamic> login({required String email, required String password}) async {
  final url = Uri.parse('http://103.82.195.138:3105/api/v1/auth/login');

  final requestBody = json.encode({'email': email, 'password': password});

  final response = await http.post(url,
      headers: {'Content-Type': 'application/json'}, body: requestBody);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final metadata = jsonData['metadata'];
    return metadata;
  } else {
    return null;
  }
}

final title = ['Sign Up', 'Sign In'];

class Login extends StatefulWidget {
  static const String route = '/login';

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'staff@gmail.com');
  final _passwordController = TextEditingController(text: 'staff@password');

  bool isLoading = false;

  Future<void> onLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await login(
          email: _emailController.text, password: _passwordController.text);
      if (data == null) return;
      MyLogin.instance.token = data['access_token'] as String;
      Navigator.pushReplacementNamed(context, BeginPage.route);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFE),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Shipping and Track Anytime',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Get great experience with track',
                style: TextStyle(color: Color(0xFFA7A9B7)),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFFF8F9F8),
              ),
              child: Row(
                children: title.map((item) {
                  final index = title.indexOf(item);
                  return Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        color: index == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      item,
                      textAlign: TextAlign.center,
                    ),
                  ));
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Email',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  TextFormField(
                    enabled: !isLoading,
                    controller: _emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFF3F3F3)),
                          borderRadius: BorderRadius.circular(20)),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFF3F3F3)),
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFF3F3F3)),
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Password',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  TextFormField(
                    enabled: !isLoading,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFF3F3F3)),
                          borderRadius: BorderRadius.circular(20)),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFF3F3F3)),
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFF3F3F3)),
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        onLogin();
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFD683D),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ))),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                      child: Text(
                        'Or Sign In With',
                        style: TextStyle(color: Color(0xFFA7A9B7)),
                      ),
                    ),
                  ),
                  InkWell(
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google_icon.png'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Sign Up with Google',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ],
                        ))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFD683D),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/apple_icon.png'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Sign Up with Apple',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
