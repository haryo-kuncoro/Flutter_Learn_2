import 'dart:convert';

import 'package:family/dashboard.dart';
import 'package:family/modul.dart';
import 'package:family/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:universal_platform/universal_platform.dart';

class MyLoginApi extends StatefulWidget {
  const MyLoginApi({Key? key}) : super(key: key);

  @override
  State<MyLoginApi> createState() => _MyLogin();
  // _MyLogin createState() => _MyLogin();
}

class _MyLogin extends State<MyLoginApi> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // var modul = Modul();
  Modul mdl_put = Get.put(Modul());
  Modul mdl_get = Get.find<Modul>();

  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool is_login = false;

    setState(() {
      mdl_put.nmuser(prefs.getString("nmUser")!);
      mdl_put.token(prefs.getString("tokenApi")!);
      mdl_put.level(prefs.getString("level")!);
      is_login = prefs.getBool("is_login")!;
    });

    if (is_login == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MyDashboard();
          },
        ),
      );
    }
  }

  Future<void> _saveSession(String token, String nmuser, String level) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("tokenApi", token);
      prefs.setString("nmUser", nmuser);
      prefs.setString("level", level);
      prefs.setBool("is_login", true);
      mdl_put.nmuser(nmuser);
      mdl_put.token(token);
      mdl_put.level(level);
    });
  }

  Future<void> submit(
      BuildContext context, String user, String password) async {
    try {
      if (user.isEmpty || password.isEmpty) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            'Username dan password harus diisi',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else {
        final host =
            UniversalPlatform.isAndroid ? mdl_get.host.value : 'localhost';
        var endUri = '?username=$user&password=$password';
        final url = Uri.parse('http://$host:8080/family/login$endUri');
        final http.Response response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
          },
        ).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response(
                'Error', 408); // Request Timeout response status code
          },
        );

        final output = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (output['logged_in'] == true) {
            _saveSession(
                output['token'], output['nama_lengkap'], output['level']);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return MyDashboard();
                },
              ),
            );
          }
        } else if (response.statusCode == 408) {
          AlertDialog alert = AlertDialog(
            title: Text("Timeout ..."),
            content: Container(
              child: Text('Server tidak terhubung'),
            ),
            actions: [
              TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          );

          showDialog(context: context, builder: (context) => alert);
          return;
        } else {
          AlertDialog alert = AlertDialog(
            title: Text("Login ..."),
            content: Container(
              child: Text('Username dan password salah'),
            ),
            actions: [
              TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          );

          showDialog(context: context, builder: (context) => alert);
          return;
        }
      }
    } catch (e) {
      AlertDialog alert = AlertDialog(
        title: Text("Timeout ..."),
        content: Container(
          child: Text('Server tidak terhubung'),
        ),
        actions: [
          TextButton(
              child: Text('OK'), onPressed: () => Navigator.of(context).pop()),
        ],
      );

      showDialog(context: context, builder: (context) => alert);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                child: Image.asset(
                  'assets/images/family.png',
                  width: 150.0,
                  height: 150.0,
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_clock_outlined),
                  ),
                  onEditingComplete: () => submit(
                      context, nameController.text, passwordController.text),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 50),
                height: 80,
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                  ),
                  label: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  icon: Icon(Icons.login_outlined),
                  onPressed: () => submit(
                      context, nameController.text, passwordController.text),
                ),
              ),
              Row(
                children: <Widget>[
                  const Text('Create family account '),
                  TextButton(
                    child: const Text(
                      'Click here',
                      // style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return MyRegister();
                        },
                      ),
                    ),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
