import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bluetooth/bluetooth_control_screen.dart';

class HeaderPart extends StatefulWidget {
  const HeaderPart({super.key});

  @override
  _HeaderPartState createState() => _HeaderPartState();
}

class _HeaderPartState extends State<HeaderPart> {
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkBluetoothConnection();
  }

  void checkBluetoothConnection() async {
    bool status = await isBluetoothConnected();
    if (!status) {
      autoConnectBluetooth();
    } else {
      setState(() {
        isConnected = true;
      });
    }
  }

  Future<bool> isBluetoothConnected() async {
    List<BluetoothDevice> connectedDevices =
        await FlutterBluePlus.connectedDevices;
    return connectedDevices.isNotEmpty;
  }

  void autoConnectBluetooth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDeviceId = prefs.getString('lastConnectedDevice');
    if (lastDeviceId != null) {
      BluetoothDevice device = BluetoothDevice.fromId(lastDeviceId);
      try {
        await device.connect();
        await Future.delayed(
          Duration(seconds: 2),
        ); // Đợi 2 giây để kiểm tra trạng thái
        List<BluetoothDevice> connectedDevices =
            await FlutterBluePlus.connectedDevices;
        if (connectedDevices.any((d) => d.remoteId.str == lastDeviceId)) {
          setState(() {
            isConnected = true;
          });
          print("✅ Đã kết nối lại với $lastDeviceId");
        } else {
          print("⚠️ Kết nối thất bại, không tìm thấy thiết bị.");
        }
      } catch (e) {
        print("❌ Không thể kết nối lại: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        image: DecorationImage(
          image: AssetImage('assets/images/home.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Hi, Hoamuathu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueGrey, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),

            /// 🔹 Kiểm tra trạng thái Bluetooth mỗi giây và cập nhật giao diện
            StreamBuilder<bool>(
              stream: Stream.periodic(
                Duration(seconds: 1),
                (_) => isBluetoothConnected(),
              ).asyncMap((event) async => await event),
              builder: (context, snapshot) {
                bool isConnected = snapshot.data ?? false;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BluetoothControlScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white70,
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children:
                              isConnected
                                  ? [
                                    TextSpan(
                                      text: 'Bluetooth ',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'connected',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ]
                                  : [
                                    TextSpan(
                                      text: 'Connect ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'bluetooth ',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'to the application',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
