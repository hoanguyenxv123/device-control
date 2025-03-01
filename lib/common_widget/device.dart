import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_control/common_widget/switch_button.dart';
import '../model/device/device_model.dart';
import '../data/remote/firestore_service.dart';

class Device extends StatefulWidget {
  final String roomId;
  final DeviceModel device;

  Device({super.key, required this.roomId, required this.device});

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isOn = false;
  BluetoothCharacteristic? controlCharacteristic;

  @override
  void initState() {
    super.initState();
    fetchDeviceState();
    findControlCharacteristic();
  }

  /// 🔥 Lấy trạng thái thiết bị từ Firestore
  void fetchDeviceState() {
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('deviceList')
        .doc(widget.device.devicePort.toString())
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            bool newState = snapshot.data()?['isOn'] ?? false;
            print("📡 Firestore cập nhật: $newState (trạng thái cũ: $isOn)");
            setState(() {
              isOn = snapshot.data()?['isOn'] ?? false;
            });
          }
        });
  }

  /// 🔥 Tìm đặc tính Bluetooth để gửi lệnh
  Future<void> findControlCharacteristic() async {
    List<BluetoothDevice> connectedDevices =
        await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      BluetoothDevice device = connectedDevices.first;
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            setState(() {
              controlCharacteristic = characteristic;
            });
            print("✅ Đã tìm thấy đặc tính ghi dữ liệu.");
            return;
          }
        }
      }
    }
    print("❌ Không tìm thấy đặc tính ghi dữ liệu.");
  }

  /// 🔥 Gửi lệnh Bluetooth + cập nhật Firestore
  Future<void> sendCommand(int deviceId, bool turnOn) async {
    if (controlCharacteristic != null) {
      String command = "$deviceId:${turnOn ? "1" : "0"}";
      await controlCharacteristic!.write(command.codeUnits);
      print("🔵 Gửi lệnh: $command");

      // 🔥 Cập nhật trạng thái Firestore
      await _firestoreService.updateDeviceByPort(
        widget.roomId,
        widget.device.devicePort,
        turnOn,
      );

      setState(() {
        isOn = turnOn;
      });
    } else {
      print("⚠️ Chưa tìm thấy đặc tính ghi dữ liệu!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: SizedBox(
              width: 100,
              height: 99,
              child: Image.asset(widget.device.imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.device.type,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔥 Đã sửa lỗi truyền roomId và deviceId
              SwitchButton(
                roomId: widget.roomId,
                devicePort: widget.device.devicePort, // 🔥 Sửa thành devicePort
                onChanged: (value) {
                  sendCommand(
                    widget.device.devicePort,
                    value,
                  ); // 🔥 Đảm bảo gửi đúng devicePort
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
