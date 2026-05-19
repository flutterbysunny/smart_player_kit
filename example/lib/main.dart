import 'package:flutter/material.dart';
import 'package:smart_player_kit/smart_player_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SmartPlayer.network(
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          ),
        ),
      ),
    );
  }
}