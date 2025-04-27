import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../../model/device/device_model.dart';
import '../../model/room/room_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("devices");

  /// **Thêm phòng mới vào Firestore**
  Future<void> addRoom(RoomModel room) async {
    DocumentReference roomRef = _db.collection('rooms').doc();

    await roomRef.set(room.toJson());

    for (DeviceModel device in room.deviceList) {
      await roomRef.collection('deviceList').add(device.toJson());
    }

    await roomRef.update({'devices': room.deviceList.length});
  }

  /// Lấy danh sách các cổng đã được sử dụng trong toàn hệ thống
  Future<List<int>> getGlobalUsedPorts() async {
    QuerySnapshot snapshot = await _db.collectionGroup('deviceList').get();
    List<int> usedPorts =
        snapshot.docs
            .where(
              (doc) =>
                  doc.data() is Map<String, dynamic> &&
                  (doc.data() as Map<String, dynamic>).containsKey(
                    'devicePort',
                  ),
            )
            .map((doc) => doc['devicePort'] as int)
            .toList();

    debugPrint('🔌 Cổng đã được dùng (toàn hệ thống): $usedPorts');
    return usedPorts;
  }

  /// Lấy danh sách các cổng chưa được sử dụng trong toàn hệ thống
  Future<List<int>> getAvailablePortsGlobal() async {
    List<int> usedPorts = await getGlobalUsedPorts();
    List<int> allPorts = List.generate(10, (i) => i + 2); // [2, 3, ..., 12]
    return allPorts.where((port) => !usedPorts.contains(port)).toList();
  }

  /// **Thêm thiết bị vào phòng**
  Future<void> addDeviceToRoom(String roomId, DeviceModel device) async {
    try {
      DocumentReference roomRef = _db.collection('rooms').doc(roomId);
      CollectionReference deviceListRef = roomRef.collection('deviceList');

      await deviceListRef.add(device.toJson());

      QuerySnapshot updatedDevices = await deviceListRef.get();
      int totalDevices = updatedDevices.docs.length;

      await roomRef.update({'devices': totalDevices});

      print("✅ Đã thêm thiết bị vào phòng $roomId");
    } catch (e) {
      print("❌ Lỗi khi thêm thiết bị vào phòng: $e");
    }
  }

  /// Lấy danh sách phòng realtime
  Stream<List<RoomModel>> getRooms() {
    return _db.collection('rooms').snapshots().asyncMap((snapshot) async {
      List<RoomModel> rooms = [];

      for (var doc in snapshot.docs) {
        List<DeviceModel> devices = await getDevices(doc.id);

        RoomModel room = RoomModel.fromJson(doc.id, doc.data());
        room = RoomModel(
          id: doc.id,
          name: doc['name'],
          iconPath: doc['iconPath'],
          color: doc['color'],
          imagePath: doc['imagePath'],
          deviceList: devices,
        );

        rooms.add(room);
      }

      return rooms;
    });
  }

  /// Bật hoặc tắt toàn bộ thiết bị trong phòng
  Future<void> toggleAllDevices(String roomId, bool turnOn) async {
    try {
      CollectionReference deviceListRef = _db
          .collection('rooms')
          .doc(roomId)
          .collection('deviceList');

      QuerySnapshot deviceSnapshot = await deviceListRef.get();

      for (var doc in deviceSnapshot.docs) {
        await doc.reference.update({'isOn': turnOn});
      }

      print(
        "✅ Đã ${turnOn ? 'bật' : 'tắt'} tất cả thiết bị trong phòng $roomId",
      );
    } catch (e) {
      print("❌ Lỗi khi cập nhật toàn bộ thiết bị: $e");
    }
  }

  /// Lấy danh sách thiết bị của phòng
  Future<List<DeviceModel>> getDevices(String roomId) async {
    QuerySnapshot snapshot =
        await _db
            .collection('rooms')
            .doc(roomId)
            .collection('deviceList')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return DeviceModel.fromJson(data, doc.id); // 👈 truyền id từ doc
    }).toList();
  }

  /// Cập nhật trạng thái thiết bị
  Future<void> updateDeviceByPort(
    String roomId,
    int devicePort,
    bool isOn,
  ) async {
    CollectionReference deviceListRef = _db
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

  /// Cập nhật trạng thái thiết bị qua collectionGroup
  Future<void> updateDashBoard(int devicePort, bool isOn) async {
    QuerySnapshot querySnapshot =
        await _db
            .collectionGroup('deviceList')
            .where('devicePort', isEqualTo: devicePort)
            .get();

    if (querySnapshot.docs.isEmpty) {
      print("❌ Không tìm thấy thiết bị có devicePort = $devicePort");
      return;
    }

    DocumentReference deviceRef = querySnapshot.docs.first.reference;

    try {
      await deviceRef.update({'isOn': isOn});
      print("✅ Đã cập nhật trạng thái thiết bị cổng $devicePort thành $isOn");
    } catch (e) {
      print("❌ Lỗi khi cập nhật Firestore: $e");
    }
  }

  // Hàm cập nhật thông tin thiết bị (trừ isOn)
  Future<void> updateDeviceInfo(
    String roomId,
    int devicePort, {
    required String name,
    required String controllerName,
    required String type,
    required String imagePath,
  }) async {
    try {
      final querySnapshot =
          await _db
              .collection('rooms')
              .doc(roomId)
              .collection('deviceList')
              .where('devicePort', isEqualTo: devicePort)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _db
            .collection('rooms')
            .doc(roomId)
            .collection('deviceList')
            .doc(docId)
            .update({
              'name': name,
              'controllerName': controllerName,
              'type': type,
              'imagePath': imagePath,
            });
        print("✅ Đã cập nhật thiết bị $devicePort trong phòng $roomId");
      } else {
        print(
          "❌ Không tìm thấy thiết bị có devicePort = $devicePort trong phòng $roomId",
        );
      }
    } catch (e) {
      print("❌ Lỗi khi cập nhật thiết bị: $e");
    }
  }

  /// Xóa thiết bị và cập nhật số lượng
  Future<void> deleteDeviceAndUpdateCount(
    String roomId,
    String deviceId,
  ) async {
    try {
      CollectionReference deviceListRef = _db
          .collection('rooms')
          .doc(roomId)
          .collection('deviceList');

      await deviceListRef.doc(deviceId).delete();

      QuerySnapshot remainingDevices = await deviceListRef.get();
      await _db.collection('rooms').doc(roomId).update({
        'devices': remainingDevices.docs.length,
      });

      print("Đã xóa thiết bị và cập nhật số lượng còn lại");
    } catch (e) {
      print("❌ Lỗi khi xóa thiết bị: $e");
    }
  }

  /// Xóa thiết bị
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

  /// Cập nhật trạng thái toàn bộ thiết bị trong toàn hệ thống
  Future<void> updateDeviceByPortGlobal(int devicePort, bool turnOn) async {
    final roomsRef = FirebaseFirestore.instance.collection('rooms');
    final roomsSnapshot = await roomsRef.get();

    for (var roomDoc in roomsSnapshot.docs) {
      final deviceListRef = roomDoc.reference.collection('deviceList');
      final devicesSnapshot =
          await deviceListRef.where('devicePort', isEqualTo: devicePort).get();

      for (var deviceDoc in devicesSnapshot.docs) {
        await deviceDoc.reference.update({'isOn': turnOn});
        print('🔄 Đã cập nhật thiết bị có port $devicePort (isOn: $turnOn)');
      }
    }
  }

  /// Xóa phòng
  Future<void> deleteRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).delete();
  }

  /// Lắng nghe thay đổi danh sách thiết bị theo phòng
  Stream<List<DeviceModel>> getDevicesStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('deviceList')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return DeviceModel.fromJson(data, doc.id); // 👈 có id
          }).toList();
        });
  }

  /// Lấy trạng thái thiết bị (one-time)
  Future<bool?> getDeviceState(String roomId, int devicePort) async {
    try {
      var doc =
          await _db
              .collection('rooms')
              .doc(roomId)
              .collection('deviceList')
              .where('devicePort', isEqualTo: devicePort)
              .get();

      if (doc.docs.isNotEmpty) {
        return doc.docs.first['isOn'] as bool;
      }
    } catch (e) {
      print("🔥 Lỗi khi lấy trạng thái thiết bị: $e");
    }
    return null;
  }

  /// Lắng nghe thay đổi trạng thái thiết bị theo `devicePort`
  Stream<bool?> deviceStateStream(String roomId, int devicePort) {
    return _db
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
}
