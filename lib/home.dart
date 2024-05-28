import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'userInfo.dart';

class Clipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    double length = min(size.height, size.width);
    return Rect.fromCenter(
      center: Offset(size.width / 2.0, size.height / 2.0),
      width: length / 2, 
      height: length / 2,
    );
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePageWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
    _opacityAnimation = Tween<double>(begin: 0.1, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _rotationAnimation,
                child: ClipOval(
                  clipper: Clipper(),
                  child: Image.asset('images/raccoon.jpg')
                ),
              ),
              FadeTransition(
                opacity: _opacityAnimation,
                child: Text("Hello, ${Provider.of<UserInfo>(context, listen: true).username ?? "Guest"}",
                  style: const TextStyle(
                    fontFamily: "Times",
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
