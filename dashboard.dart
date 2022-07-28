import 'dart:convert';

import 'package:family/login_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:family/modul.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:http/http.dart' as http;

class MyDashboard extends StatefulWidget {
  const MyDashboard({Key? key}) : super(key: key);

  @override
  // _MyDashboardState createState() => _MyDashboardState();
  State<MyDashboard> createState() => _MyDashboardState();
}

// class _MyDashboardState extends State<MyDashboard> {
class _MyDashboardState extends State<MyDashboard>
    with SingleTickerProviderStateMixin {
  Modul mdl_put = Get.put(Modul());
  Modul mdl_get = Get.find<Modul>();

  List listFamily = List.empty();

  int _selectedIndex = 0;
  var data = '';

  late TabController _controller;
  // static List<Widget> _views = [];

  void _onItemTapped(int index) {
    if (index == 2 || index == 1) {
      setState(() {
        this._selectedIndex = index;
        _controller.animateTo(_selectedIndex);
        getListFamily();
      });
    } else {
      setState(() {
        this._selectedIndex = index;
        _controller.animateTo(_selectedIndex);
      });
    }
  }

  void initState() {
    super.initState();
    mdl_get = Get.find<Modul>();
    _controller = TabController(length: 5, vsync: this);
  }

  Future<void> _deleteSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.clear();
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MyLoginApi();
        },
      ),
    );
  }

  Future<void> getListFamily() async {
    final prefs = await SharedPreferences.getInstance();
    var _token = prefs.getString("tokenApi");

    final host = UniversalPlatform.isAndroid ? mdl_get.host.value : 'localhost';
    var endUri = '?token=$_token';
    final url = Uri.parse('http://$host:8080/family$endUri');

    var response = await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      this.setState(() {
        listFamily = json.decode(response.body);
      });
    } else {
      setState(() {
        listFamily = List.empty();
        data = 'Data Family empty';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: <Widget>[
          new homePage(_selectedIndex),
          new newsPage(_selectedIndex, listFamily),
          new familyPage(_selectedIndex, listFamily),
          new messagePage(_selectedIndex, mdl_get.token.value),
          new profilePage(_selectedIndex, mdl_get.nmuser.value,
              mdl_get.level.value, _deleteSession),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlueAccent, width: 0.3)),
        height: 50,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          showSelectedLabels: true,
          selectedFontSize: 8,
          showUnselectedLabels: false,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.lightBlueAccent,
          iconSize: 25,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom_outlined),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class homePage extends StatelessWidget {
  final int index;
  homePage(this.index);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('Home, index: $index'),
    );
  }
}

class newsPage extends StatelessWidget {
  final int index;
  List family;
  newsPage(this.index, this.family);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: GridView.count(
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 2,
              // Generate 100 widgets that display their index in the List.
              children: List.generate(family.length, (index) {
                return Container(
                  child: new Card(
                    child: new SizedBox(
                      // height: 80.0,
                      child: Container(
                        alignment: Alignment.center,
                        color: Color.fromARGB(255, 221, 242, 252),
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ListView(
                          children: <Widget>[
                            Container(
                              height: 100,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              color: Color.fromARGB(255, 204, 204, 204),
                              child: Text(
                                'image',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  Text(
                                    family[index]["NAMA_LENGKAP"].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                  Text(
                                    family[index]["STATUS"].toString(),
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12),
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class familyPage extends StatelessWidget {
  final int index;
  List family;
  familyPage(this.index, this.family);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          // color: Colors.white,
          child: new ListView.builder(
            itemCount: family == null ? 0 : family.length,
            itemBuilder: (BuildContext context, int index) {
              return new Card(
                child: new SizedBox(
                  height: 80.0,
                  child: Container(
                    alignment: Alignment.topLeft,
                    color: Color.fromARGB(255, 221, 242, 252),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                          // color: Colors.red,
                          child: Container(
                            width: 100,
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            color: Color.fromARGB(255, 204, 204, 204),
                            // decoration: new BoxDecoration(
                            //   image: new DecorationImage(
                            //     image:
                            //         new AssetImage("assets/images/family.png"),
                            //     // fit: BoxFit.fill,
                            //   ),
                            // ),
                            child: CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 241, 241, 241),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Color.fromARGB(255, 204, 204, 204),
                              ),
                              radius: 50,
                            ),
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              Text(
                                family[index]["NAMA_LENGKAP"].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text(
                                family[index]["STATUS"].toString(),
                                style: TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 12),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.blueAccent,
        onPressed: () => {},
        tooltip: 'Add Family',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class messagePage extends StatelessWidget {
  final int index;
  final String token;
  messagePage(this.index, this.token);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('Message, index: $index'),
    );
  }
}

class profilePage extends StatelessWidget {
  final int index;
  final String nmuser;
  final String level;
  Function _deleteSession;
  profilePage(this.index, this.nmuser, this.level, this._deleteSession);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          color: Colors.white,
          child: ListView(
            children: [
              ListTile(
                leading: Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                ),
                trailing: Icon(Icons.edit),
                title: Text(
                  '$nmuser',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color.fromARGB(255, 108, 130, 141),
                  ),
                ),
                onTap: () {},
              ),
              Divider(
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              ),
              ListTile(
                leading: Icon(Icons.family_restroom),
                trailing: Icon(Icons.navigate_next),
                title: Text(
                  'Family List',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 108, 130, 141),
                  ),
                ),
                onTap: () {},
              ),
              Divider(
                thickness: 1,
                indent: 55,
                endIndent: 10,
              ),
              ListTile(
                leading: Icon(Icons.message),
                trailing: Icon(Icons.navigate_next),
                title: Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 108, 130, 141),
                  ),
                ),
                onTap: () {},
              ),
              Divider(
                thickness: 1,
                indent: 55,
                endIndent: 10,
              ),
              // SizedBox(height: MediaQuery.of(context).size.height - 250),
              Container(
                // constraints: const BoxConstraints(minWidth: 50, maxWidth: 50),
                alignment: Alignment.topRight,
                // height: 100,
                padding: const EdgeInsets.fromLTRB(0, 50, 15, 0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  icon: Icon(Icons.logout),
                  onPressed: () => {
                    _deleteSession(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
