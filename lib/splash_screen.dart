import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'userInfo.dart';
import 'dart:async';
import 'dart:ui';
import 'main.dart';
import 'requestPage.dart';
import 'supplierPage.dart';
import 'settings.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  // ignore: must_call_super
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50.0),
              Center(
                child: Text(
                  "TaskHub",
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 10.0),
                    Text('Consumers Request Page'),
                  ],
                ),
                onPressed: () {
                  if (Provider.of<UserInfo>(context, listen: false).uuid != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RequestPage()),
                    );
                  }
                  else {
                    showDialog(
                      context: context,
                      builder: (context) => RegisterDialog()
                    );
                  }
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business),
                    SizedBox(width: 10.0),
                    Text('Suppliers Request Page'),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuppliersPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
