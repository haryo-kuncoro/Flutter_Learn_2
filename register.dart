import 'dart:convert';

import 'package:family/login_api.dart';
import 'package:family/modul.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:http/http.dart' as http;

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  State<MyRegister> createState() => _MyRegister();
}

class _MyRegister extends State<MyRegister> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController namalengkapController = TextEditingController();

  var modul = Modul();

  Future<void> submit(
      BuildContext context, String user, String password, String nama) async {
    try {
      if (user.isEmpty || password.isEmpty || nama.isEmpty) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            'Lengkapi data terlebih dahulu.',
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
            UniversalPlatform.isAndroid ? modul.host.value : 'localhost';
        var endUri =
            '?register=1&namalengkap=$nama&username=$user&password=$password';
        // endUri = '';
        final url = Uri.parse('http://$host:8080/family$endUri');
        final http.Response response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          // body: json.encode(
          //   {
          //     'username': user,
          //     'password': password,
          //     'namalengkap': nama,
          //     'register': '1'
          //   },
          // ),
        ).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response(
                'Error', 408); // Request Timeout response status code
          },
        );

        if (response.statusCode == 201) {
          AlertDialog alert = AlertDialog(
            title: Text("Register ..."),
            content: Container(
              child: Text('Registrasi berhasil'),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MyLoginApi();
                    },
                  ),
                ),
              ),
            ],
          );

          showDialog(context: context, builder: (context) => alert);
          return;
        } else if (response.statusCode == 204) {
          AlertDialog alert = AlertDialog(
            title: Text("Timeout ..."),
            content: Container(
              child: Text('Server tidak terhubung'),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );

          showDialog(context: context, builder: (context) => alert);
          return;
        } else {
          AlertDialog alert = AlertDialog(
            title: Text("Register ..."),
            content: Container(
              child: Text('Terjadi masalah'),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );

          showDialog(context: context, builder: (context) => alert);
          return;
        }
      }
    } catch (e) {
      AlertDialog alert = AlertDialog(
        title: Text("Error"),
        content: Container(
          child: Text('$e'),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      showDialog(context: context, builder: (context) => alert);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: Text(
                'Register family account:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
              child: TextFormField(
                controller: namalengkapController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
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
                onEditingComplete: () => submit(context, nameController.text,
                    passwordController.text, namalengkapController.text),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 50, maxWidth: 50),
              height: 80,
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                ),
                label: const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                icon: Icon(Icons.login_outlined),
                onPressed: () => submit(context, nameController.text,
                    passwordController.text, namalengkapController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
