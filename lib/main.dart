import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kumohbada_ver2/firebase_options.dart';

import 'login.dart';
import 'backend.dart';
import 'homepage.dart';
import 'chatpage.dart';
import 'profilepage.dart';
import 'registitempage.dart';
import 'myitem.dart';
import 'category.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentBottomIndex = 0;
  String? _selectedLocation = '양호동';
  bool _showAdditionalButtons = false;

  void _tapBottomTab(int index) {
    setState(() => _currentBottomIndex = index);
  }

  void _toggleAdditionalButtons() {
    setState(() => _showAdditionalButtons = !_showAdditionalButtons);
  }

  @override
  Widget build(BuildContext context) {
    //위젯 생성 함수
    List<PopupMenuEntry<dynamic>> buildPopupMenu(BuildContext context) {
      List<PopupMenuEntry<dynamic>> popUpList = [];
      for (var temp in availableLocations) {
        popUpList.add(PopupMenuItem(value: temp, child: Text(temp)));
      }
      return popUpList;
    }

    List<Widget> tabs = [
      const HomePage(),
      const ChatPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: PopupMenuButton(
          itemBuilder: buildPopupMenu,
          initialValue: _selectedLocation,
          onSelected: (value) {
            setState(() => _selectedLocation = value);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_selectedLocation!),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return Category();
                }),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: tabs[_currentBottomIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: _tapBottomTab,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
      floatingActionButton: _currentBottomIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showAdditionalButtons)
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) {
                          return MyItemPage();
                        },
                      ));
                    },
                    tooltip: '내 글 보기',
                    child: const Icon(Icons.notes),
                  ),
                const SizedBox(height: 16.0),
                if (_showAdditionalButtons)
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return RegistItemPage();
                        }),
                      );
                    },
                    tooltip: '글쓰기',
                    child: const Icon(Icons.edit_sharp),
                  ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    _toggleAdditionalButtons();
                  },
                  child: _showAdditionalButtons
                      ? const Icon(Icons.remove)
                      : const Icon(Icons.add),
                ),
              ],
            )
          : null,
    );
  }
}
