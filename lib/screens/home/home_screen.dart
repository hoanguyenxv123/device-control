import 'package:flutter/material.dart';
import 'package:test_control/screens/home/widgets/header_part.dart';
import 'package:test_control/screens/home/widgets/your_room.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [HeaderPart(), Expanded(child: YourRoom())]),
    );
  }
}
