import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:family/login_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
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
  List listNews = List.empty();

  int _selectedIndex = 0;
  var data = '';

  late TabController _controller;

  // static List<Widget> _views = [];

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        this._selectedIndex = index;
        getListNews();
        _controller.animateTo(_selectedIndex);
      });
    } else if (index == 1) {
      setState(() {
        this._selectedIndex = index;
        getListNews();
        _controller.animateTo(_selectedIndex);
      });
    } else if (index == 2) {
      setState(() {
        this._selectedIndex = index;
        getListFamily();
        _controller.animateTo(_selectedIndex);
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
      mdl_put.nmuser('');
      mdl_put.token('');
      mdl_put.level('');
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

  Future<void> getListNews() async {
    final prefs = await SharedPreferences.getInstance();
    var _token = prefs.getString("tokenApi");

    final host = UniversalPlatform.isAndroid ? mdl_get.host.value : 'localhost';
    var endUri = '?token=$_token';
    final url = Uri.parse('http://$host:8080/family/news$endUri');

    var response = await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      this.setState(() {
        listNews = json.decode(response.body);
      });
    } else {
      setState(() {
        listNews = List.empty();
        data = 'News empty';
      });
    }
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
        data = 'Family empty';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getListNews();

    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: <Widget>[
          new homePage(listNews),
          new newsPage(listNews),
          new familyPage(listFamily),
          new messagePage(mdl_get.token.value),
          new profilePage(
              mdl_get.nmuser.value, mdl_get.level.value, _deleteSession),
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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

List<Widget> indicators(imagesLength, currentIndex) {
  return List<Widget>.generate(imagesLength, (index) {
    return Container(
      margin: EdgeInsets.all(3),
      width: 5,
      height: 5,
      decoration: BoxDecoration(
          color: currentIndex == index
              ? Colors.black
              : Color.fromARGB(66, 102, 102, 102),
          shape: BoxShape.circle),
    );
  });
}

int activePage = 1;

class homePage extends StatelessWidget {
  List news;
  homePage(this.news);
  // int totalNews = news.isEmpty ? 0 : news.length;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return CupertinoApp(
        home: Scaffold(
          body: Center(
            child: Text('News'),
          ),
        ),
      );
    } else {
      return CupertinoApp(
        home: Scaffold(
          body: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                CarouselSlider.builder(
                  itemCount: news.isEmpty ? 0 : news.length,
                  itemBuilder: (context, int i, int p) => Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 221, 242, 252),
                      border:
                          Border.all(color: Colors.lightBlueAccent, width: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                    child: Text(
                        news[i]["JUDUL"]
                            .replaceAll('&amp;', '&')
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                        textAlign: TextAlign.center,
                        textScaleFactor: 0.9),
                  ),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 2.7,
                    initialPage: 1,
                    onPageChanged: (index, reason) {
                      activePage = index;
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      indicators(news.isEmpty ? 0 : news.length, activePage),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 400,
                  color: Color.fromARGB(255, 221, 242, 252),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Text('Home page'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class newsPage extends StatelessWidget {
  List news;
  newsPage(this.news);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: Scaffold(
        body: Center(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                news.isEmpty ? 0 : news.length,
                (index) {
                  return Card(
                    shadowColor: Colors.grey,
                    child: new SizedBox(
                      // height: 80.0,
                      child: Container(
                        alignment: Alignment.center,
                        color: Color.fromARGB(255, 221, 242, 252),
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: 80,
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                color: Color.fromARGB(255, 204, 204, 204),
                                child: Text('image')),
                            Container(
                              alignment: Alignment.topLeft,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 12,
                                      ),
                                      Text(
                                        ' ' +
                                            news[index]["PUBLISHDATE"]
                                                .toString(),
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    news[index]["JUDUL"]
                                        .replaceAll('&amp;', '&')
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                    textScaleFactor: 0.9,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
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
                  );
                },
              ),
            ),
          ),
          // ],
        ),
      ),
    );
  }
}

class familyPage extends StatelessWidget {
  List family;
  familyPage(this.family);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: Scaffold(
        body: Center(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: new ListView.builder(
              itemCount: family.isEmpty ? 0 : family.length,
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
                            child: Container(
                              width: 100,
                              alignment: Alignment.topLeft,
                              padding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
      ),
    );
  }
}

class messagePage extends StatelessWidget {
  final String token;
  messagePage(this.token);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: Scaffold(
        body: Center(
          child: Text('Message'),
        ),
      ),
    );
  }
}

class profilePage extends StatelessWidget {
  final String nmuser;
  final String level;
  Function _deleteSession;
  profilePage(this.nmuser, this.level, this._deleteSession);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: Scaffold(
        body: Center(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            color: Colors.white,
            child: ListView(
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      height: 70,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color.fromARGB(255, 241, 241, 241),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color.fromARGB(255, 204, 204, 204),
                        ),
                      ),
                    ),
                    ListTile(
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
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                          color: Color.fromARGB(255, 108, 130, 141),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                Container(
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
      ),
    );
  }
}
