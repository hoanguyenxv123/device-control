import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/device/device_model.dart';
import '../../model/room/room_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// **Thêm phòng mới vào Firestore**
  Future<void> addRoom(RoomModel room) async {
    DocumentReference roomRef = _db.collection('rooms').doc();

    await roomRef.set({
      'name': room.name,
      'iconPath': room.iconPath,
      'devices': room.devices,
      'id': room.id,
      'color': room.color,
      'imagePath': room.imagePath,
    });

    // Lưu danh sách thiết bị vào subcollection
    for (DeviceModel device in room.deviceList) {
      await roomRef
          .collection('deviceList')
          .doc(device.devicePort.toString())
          .set(device.toJson());
    }
  }
  /// Lắng nghe thay đổi trạng thái thiết bị theo `devicePort`
  Stream<bool?> deviceStateStream(String roomId, int devicePort) {
    return FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('deviceList')
        .where('devicePort', isEqualTo: devicePort)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['isOn'] as bool;
      }
      return null;
    });
  }


  /// Lấy trạng thái thiết bị
  Future<bool?> getDeviceState(String roomId, int devicePort) async {
    try {
      var doc =
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomId)
              .collection('deviceList')
              .where('devicePort', isEqualTo: devicePort)
              .get();

      if (doc.docs.isNotEmpty) {
        return doc.docs.first['isOn'] as bool;
      }
    } catch (e) {
      print(
        "🔥 Lỗi khi lấy trạng thái thiết bị: ${roomId.toString()}''''''$devicePort",
      );
      // print('🔥 Lỗi khi lấy trạng thái thiết bị: $e');
    }
    return null;
  }

  /// **Lấy danh sách phòng**
  Stream<List<RoomModel>> getRooms() {
    return _db.collection('rooms').snapshots().asyncMap((snapshot) async {
      List<RoomModel> rooms = [];

      for (var doc in snapshot.docs) {
        List<DeviceModel> devices = await getDevices(doc.id);

        RoomModel room = RoomModel.fromJson(doc.id, doc.data());
        room = RoomModel(
          id: doc.id,
          // Lấy ID từ Firestore document
          name: doc['name'],
          iconPath: doc['iconPath'],
          devices: doc['devices'],
          color: doc['color'],
          imagePath: doc['imagePath'],
          deviceList: devices,
        );

        rooms.add(room);
      }

      return rooms;
    });
  }

  /// **Lấy danh sách thiết bị của phòng**
  Future<List<DeviceModel>> getDevices(String roomId) async {
    QuerySnapshot deviceSnapshot =
        await _db
            .collection('rooms')
            .doc(roomId)
            .collection('deviceList')
            .get();

    return deviceSnapshot.docs.map((doc) {
      return DeviceModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// **Cập nhật trạng thái thiết bị**
  Future<void> updateDeviceByPort(
    String roomId,
    int devicePort,
    bool isOn,
  ) async {
    CollectionReference deviceListRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('deviceList');

    QuerySnapshot querySnapshot =
        await deviceListRef.where('devicePort', isEqualTo: devicePort).get();

    if (querySnapshot.docs.isEmpty) {
      print("❌ Không tìm thấy thiết bị có devicePort = $devicePort");
      return;
    }

    String realDeviceId = querySnapshot.docs.first.id;
    DocumentReference deviceRef = deviceListRef.doc(realDeviceId);

    try {
      await deviceRef.update({'isOn': isOn});
      print("✅ Đã cập nhật trạng thái thiết bị cổng $devicePort thành $isOn");
    } catch (e) {
      print("❌ Lỗi khi cập nhật Firestore: $e");
    }
  }

  /// **Xóa thiết bị**
  Future<void> deleteDevice(String roomId, String deviceId) async {
    try {
      await _db
          .collection('rooms')
          .doc(roomId)
          .collection('deviceList')
          .doc(deviceId)
          .delete();
      print("Thiết bị $deviceId đã được xóa khỏi phòng $roomId");
    } catch (e) {
      print("Lỗi khi xóa thiết bị: $e");
    }
  }

  /// **Xóa thiết bị và cập nhật số lượng thiết bị còn lại**
  Future<void> deleteDeviceAndUpdateCount(
    String roomId,
    String deviceId,
  ) async {
    try {
      await _db
          .collection('rooms')
          .doc(roomId)
          .collection('deviceList')
          .doc(deviceId)
          .delete();

      // Lấy danh sách thiết bị còn lại
      QuerySnapshot deviceSnapshot =
          await _db
              .collection('rooms')
              .doc(roomId)
              .collection('deviceList')
              .get();
      int remainingDevices = deviceSnapshot.docs.length;

      // Cập nhật số lượng thiết bị trong phòng
      await _db.collection('rooms').doc(roomId).update({
        'devices': remainingDevices,
      });

      print(
        "Thiết bị $deviceId đã được xóa, số lượng còn lại: $remainingDevices",
      );
    } catch (e) {
      print("Lỗi khi xóa thiết bị: $e");
    }
  }

  /// **Xóa phòng**
  Future<void> deleteRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).delete();
  }
}
