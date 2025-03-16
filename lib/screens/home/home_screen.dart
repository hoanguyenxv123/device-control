import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_control/screens/home/widgets/header_part.dart';
import 'package:test_control/screens/home/widgets/your_room.dart';
import 'package:test_control/common_widget/mic_control.dart';

import '../../data/remote/firestore_service.dart';
import '../../model/room/room_model.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: Column(children: [HeaderPart(), Expanded(child: YourRoom())]),
      floatingActionButton: StreamBuilder<List<RoomModel>>(
        stream: _firestoreService.getRooms(), // 🔹 Lắng nghe danh sách phòng
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.red,
              child: Icon(Icons.error, color: Colors.white),
            );
          }

          List<RoomModel> rooms = snapshot.data!;
          return MicControl(rooms: rooms);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
