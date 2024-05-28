import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'splash_screen.dart';
import 'home.dart';
import 'settings.dart';
import 'userInfo.dart';
import 'history.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  int _currentPageIndex = 0;
  Widget _currPage = const HomePageWidget();
  final List<String> _navi = [
    'Home', 
    'Jobs', 
    'History', 
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(_navi[_currentPageIndex],
            style: const TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.blue,
          child: Consumer<UserInfo>(
            builder: (context, value, constraints) => ListView.builder(
              itemCount: value.settings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      child: Text(
                        value.settings[index],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () { 
                        if (value.settings[index] != "Register") {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => SettingPages(title: value.settings[index], index: index),
                            ),
                          );
                        }
                        else {
                          showDialog(
                            context: context,
                            builder: (context) => const RegisterDialog()
                          );
                        }
                      }
                    )
                  ),
                );
              },
            ),
          )
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              selectedIcon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment),
              selectedIcon: Icon(Icons.assignment_outlined),
              label: "Jobs",
            ),
            NavigationDestination(
              icon: Icon(Icons.work_history),
              selectedIcon: Icon(Icons.work_history_outlined),
              label: "History",
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.settings),
            //   selectedIcon: Icon(Icons.settings_outlined),
            //   label: "Settings",
            // )
          ],
          selectedIndex: _currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
              switch(index) {
                case 0:
                  _currPage = const HomePageWidget();
                  break;
                case 1:
                  _currPage = Splash();
                  break;
                case 2: 
                  _currPage = HistoryPage();
              }
            });
          },
          backgroundColor: Colors.white10,
        ),
        body: _currPage,
      )
    );
  }
}