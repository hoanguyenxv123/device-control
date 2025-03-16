import 'package:flutter/material.dart';
import 'package:test_control/common_widget/title_add_new.dart';
import 'package:test_control/screens/home/widgets/room_card.dart';
import '../../../data/remote/firestore_service.dart';
import '../../../model/room/room_model.dart';
import '../../room/room_screen.dart';

class YourRoom extends StatefulWidget {
  const YourRoom({super.key});

  @override
  _YourRoomState createState() => _YourRoomState();
}

class _YourRoomState extends State<YourRoom> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0,right: 20,left: 20),
          child: TitleAddNew(title: 'Your Room', addNew: () {}),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: StreamBuilder<List<RoomModel>>(
              stream: _firestoreService.getRooms(),
              builder: (context, snapshot) {
                print("Snapshot Data: ${snapshot.data}");

                if (snapshot.hasError) {
                  print("Firestore Error: ${snapshot.error}");
                  return const Center(
                    child: Text("Lỗi khi tải dữ liệu phòng!"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No rooms available"));
                }

                List<RoomModel> rooms = snapshot.data!;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return RoomCard(
                      room: room,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RoomScreen(room: room),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
