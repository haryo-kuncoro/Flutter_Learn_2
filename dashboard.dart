import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:family/login_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:family/modul.dart';
import 'package:flutter/rendering.dart';
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
  List listheadline = List.empty();

  int _selectedIndex = 0;
  var data = '';

  late TabController _controller;

  // static List<Widget> _views = [];

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        getListNews();
        getListHeadline();
        this._selectedIndex = index;
        _controller.animateTo(_selectedIndex);
      });
    } else if (index == 1) {
      setState(() {
        getListNews();
        this._selectedIndex = index;
        _controller.animateTo(_selectedIndex);
      });
    } else if (index == 2) {
      setState(() {
        getListFamily();
        this._selectedIndex = index;
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

  Future<void> getListHeadline() async {
    final prefs = await SharedPreferences.getInstance();
    var _token = prefs.getString("tokenApi");

    final host = UniversalPlatform.isAndroid ? mdl_get.host.value : 'localhost';
    var endUri = '?token=$_token';
    final url = Uri.parse('http://$host:8080/family/headline$endUri');

    var response = await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      this.setState(() {
        listheadline = json.decode(response.body);
      });
    } else {
      setState(() {
        listheadline = List.empty();
      });
    }
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
          new homePage(listNews, listheadline),
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
              icon: Icon(Icons.home_sharp),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed_sharp),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom_sharp),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_sharp),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_sharp),
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
  List headline;
  homePage(this.news, this.headline);
  // int totalNews = news.isEmpty ? 0 : news.length;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty || headline.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Home'),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          extendBodyBehindAppBar: true,
          body: Center(
            heightFactor: 1,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 50,
                ),
                CarouselSlider.builder(
                  itemCount: headline.isEmpty ? 0 : headline.length,
                  itemBuilder: (context, int i, int p) => Container(
                    decoration: BoxDecoration(
                      // color: Color.fromARGB(255, 243, 243, 243),
                      image: DecorationImage(
                        image: new NetworkImage(
                            'https://images.tokopedia.net/img/cache/1208/NsjrJu/2022/8/11/c6805701-17ac-40ab-a2f7-fd1d907fd077.jpg'),
                        // image: AssetImage('images/banner-500-min.png'),
                        fit: BoxFit.cover,
                      ),
                      // border:
                      //     Border.all(color: Colors.lightBlueAccent, width: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Text(''),
                    // child: Text(
                    //     news[i]["JUDUL"]
                    //         .replaceAll('&amp;', '&')
                    //         .toString()
                    //         .toUpperCase(),
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold, fontSize: 17),
                    //     textAlign: TextAlign.center,
                    //     textScaleFactor: 0.9),
                  ),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 3.9,
                    initialPage: 0,
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
                  children: indicators(
                      headline.isEmpty ? 0 : headline.length, activePage),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 243, 243),
                    image: DecorationImage(
                      // image: new NetworkImage(
                      //     'https://images.tokopedia.net/img/cache/1208/NsjrJu/2022/8/11/442b5088-36c9-4b4e-b8e8-38ecbcb98171.jpg?ect=3g'),
                      image: AssetImage('images/banner-500-min.png'),
                      fit: BoxFit.cover,
                      // scale: 0.5,
                    ),
                  ),
                  height: 250,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '   Berita Terbaru',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          // physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: news.isEmpty ? 0 : news.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          itemBuilder: (context, index) {
                            return GridTile(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                shadowColor: Colors.grey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Color.fromARGB(255, 221, 242, 252),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.grey, width: 0.3),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                      bottom: Radius.circular(15),
                                    ), //BorderRadius.all
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 8,
                                          ),
                                          Text(
                                            ' ' +
                                                news[index]["PUBLISHDATE"]
                                                    .toString(),
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 8),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        news[index]["JUDUL"]
                                            .replaceAll('&amp;', '&')
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                        textScaleFactor: 0.9,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 6,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  // height: MediaQuery.of(),
                  height: news.isEmpty ? 0 : news.length * 30 * 3 / 2,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: news.isEmpty ? 0 : news.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemBuilder: (context, index) {
                      return GridTile(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          shadowColor: Colors.grey,
                          child: Container(
                            decoration: BoxDecoration(
                              // color: Color.fromARGB(255, 221, 242, 252),
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.grey, width: 0.3),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                                bottom: Radius.circular(15),
                              ), //BorderRadius.all
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 8,
                                    ),
                                    Text(
                                      ' ' +
                                          news[index]["PUBLISHDATE"].toString(),
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 8),
                                    ),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  news[index]["JUDUL"]
                                      .replaceAll('&amp;', '&')
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                  textScaleFactor: 0.9,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
                        ),
                      );
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
}

class newsPage extends StatelessWidget {
  List news;
  newsPage(this.news);

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title:
                Text('Feed', style: TextStyle(color: Colors.lightBlueAccent)),
            backgroundColor: Colors.white,
          ),
          body: Center(
            child: Text('Feed'),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            title:
                Text('Feed', style: TextStyle(color: Colors.lightBlueAccent)),
            backgroundColor: Colors.white,
          ),
          body: Center(
            heightFactor: 1,
            child: ListView(
              shrinkWrap: true,
              // scrollDirection: Axis.vertical,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  // height: MediaQuery.of(),
                  height: news.isEmpty ? 0 : news.length * 100 * 2 / 2.5,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: news.isEmpty ? 0 : news.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            childAspectRatio: 2 / 2.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemBuilder: (context, index) {
                      return GridTile(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          shadowColor: Colors.grey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 221, 242, 252),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                                bottom: Radius.circular(15),
                              ), //BorderRadius.all
                            ),
                            alignment: Alignment.center,
                            child: SizedBox(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 221, 242, 252),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15),
                                    bottom: Radius.circular(15),
                                  ), //BorderRadius.all
                                ),
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 204, 204, 204),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15),
                                            bottom: Radius.circular(0),
                                          ), //BorderRadius.all
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 10),
                                        // color: Color.fromARGB(255, 204, 204, 204),
                                        child: Text('image')),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 221, 242, 252),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(0),
                                          bottom: Radius.circular(15),
                                        ), //BorderRadius.all
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 8,
                                              ),
                                              Text(
                                                ' ' +
                                                    news[index]["PUBLISHDATE"]
                                                        .toString(),
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 8),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            news[index]["JUDUL"]
                                                .replaceAll('&amp;', '&')
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                            textScaleFactor: 0.9,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 4,
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
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
}

class familyPage extends StatelessWidget {
  List family;
  familyPage(this.family);

  @override
  Widget build(BuildContext context) {
    if (family.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title:
                Text('Family', style: TextStyle(color: Colors.lightBlueAccent)),
            backgroundColor: Colors.white,
          ),
          body: Center(
            child: Text('Family'),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            title:
                Text('Family', style: TextStyle(color: Colors.lightBlueAccent)),
            backgroundColor: Colors.white,
          ),
          body: Center(
            heightFactor: 1,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: new ListView.builder(
                      itemCount: family.isEmpty ? 0 : family.length,
                      itemBuilder: (BuildContext context, int index) {
                        return new Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          shadowColor: Colors.grey,
                          child: new SizedBox(
                            height: 80.0,
                            child: Container(
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 221, 242, 252),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                  bottom: Radius.circular(15),
                                ), //BorderRadius.all
                              ),
                              // color: Color.fromARGB(255, 221, 242, 252),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 221, 242, 252),
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(15),
                                        left: Radius.circular(15),
                                      ), //BorderRadius.all
                                    ),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 15, 0),
                                    child: Container(
                                      width: 100,
                                      alignment: Alignment.topLeft,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 204, 204, 204),
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(15),
                                          left: Radius.circular(15),
                                        ), //BorderRadius.all
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 10, 15, 10),
                                      // color: Color.fromARGB(255, 204, 204, 204),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Color.fromARGB(255, 241, 241, 241),
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color.fromARGB(
                                              255, 204, 204, 204),
                                        ),
                                        radius: 50,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          family[index]["NAMA_LENGKAP"]
                                              .toString(),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            mini: false,
            backgroundColor: Colors.blueAccent,
            onPressed: () => {},
            tooltip: 'Add Family',
            child: const Icon(Icons.add),
          ),
        ),
      );
    }
  }
}

class messagePage extends StatelessWidget {
  final String token;
  messagePage(this.token);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:
              Text('Message', style: TextStyle(color: Colors.lightBlueAccent)),
          backgroundColor: Colors.white,
        ),
        // body: Center(
        //   child: Text('Message'),
        // ),
        body: Center(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 0.3),
              image: DecorationImage(
                // image: new NetworkImage(
                //     'https://images.tokopedia.net/img/cache/1208/NsjrJu/2022/8/11/442b5088-36c9-4b4e-b8e8-38ecbcb98171.jpg?ect=3g'),
                image: AssetImage('images/banner.png'),
                fit: BoxFit.fill,
                // scale: 0.5,
              ),
            ),
            child: Text('Message'),
          ),

          // child: Column(
          //   children: <Widget>[
          //     Image.asset("assets/images/banner.png",
          //         fit: BoxFit.cover,

          //         // color: Color.fromARGB(255, 15, 147, 59),
          //         opacity:
          //             const AlwaysStoppedAnimation<double>(0.5)), //Image.asset
          //     Image.asset(
          //       'assets/images/family.png',
          //       height: 400,
          //       width: 400,
          //     ), // Image.asset
          //   ], //<Widget>[]
          // ), //Column
          // child: Image.asset('assets/images/banner-1-min.png',
          //     fit: BoxFit.cover,

          //     // color: Color.fromARGB(255, 15, 147, 59),
          //     opacity: const AlwaysStoppedAnimation<double>(0.5)),
          // child: Image.network(
          //   'https://1.bp.blogspot.com/-71ix6DOpyno/Xd2pVKrpvHI/AAAAAAAABmE/wyyvjZj_OuYCyMpIEaxOapmHhFIvaeHSgCK4BGAYYCw/s1600/body.bg.png',
          //   fit: BoxFit.cover,
          // ),
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
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title:
              Text('Profile', style: TextStyle(color: Colors.lightBlueAccent)),
          backgroundColor: Colors.white,
        ),
        body: Center(
          heightFactor: 1,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
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
              SizedBox(
                height: 30,
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
              SizedBox(
                height: 70,
              ),
              Container(
                height: 80,
                alignment: Alignment.topRight,
                // height: 100,
                padding: const EdgeInsets.fromLTRB(0, 10, 15, 0),
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
              Expanded(
                child: Container(),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                child: Text(
                  'beta v 1.0.0',
                  style: TextStyle(
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
