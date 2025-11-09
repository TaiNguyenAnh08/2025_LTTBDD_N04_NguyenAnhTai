import 'package:flutter/material.dart';
import 'package:wallpaperhub/views/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}