import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_b2b/presentation/screens/video_player_screen.dart';

import 'core/binding/initial_binding.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialBinding: InitialBindings(),
      home: const VideoPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
