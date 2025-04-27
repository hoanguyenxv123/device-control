import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/provider/user_provider.dart';
import '../../bluetooth/bluetooth_control_screen.dart';

class HeaderPart extends StatefulWidget {
  const HeaderPart({super.key});

  @override
  _HeaderPartState createState() => _HeaderPartState();
}

class _HeaderPartState extends State<HeaderPart> {
  bool isConnected = false; // Biến trạng thái kết nối Bluetooth

  @override
  void initState() {
    super.initState();
    checkBluetoothConnection(); // Kiểm tra trạng thái kết nối khi widget được khởi tạo
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
  }

  /// 🔹 Kiểm tra trạng thái kết nối Bluetooth
  void checkBluetoothConnection() async {
    bool status = await isBluetoothConnected();
    if (!status) {
      autoConnectBluetooth(); // Thử tự động kết nối lại nếu chưa kết nối
    } else {
      setState(() {
        isConnected = true;
      });
    }
  }

  /// 🔹 Kiểm tra xem có thiết bị Bluetooth nào đang kết nối không
  Future<bool> isBluetoothConnected() async {
    List<BluetoothDevice> connectedDevices =
        await FlutterBluePlus.connectedDevices;
    return connectedDevices.isNotEmpty;
  }

  /// 🔹 Tự động kết nối lại với thiết bị đã kết nối trước đó
  void autoConnectBluetooth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDeviceId = prefs.getString('lastConnectedDevice');

    // Nếu có thiết bị đã kết nối trước đó, thực hiện kết nối lại
    if (lastDeviceId != null) {
      BluetoothDevice device = BluetoothDevice.fromId(lastDeviceId);
      try {
        await device.connect();
        await Future.delayed(
          Duration(seconds: 2),
        ); // Đợi 2 giây để kiểm tra trạng thái kết nối

        // Kiểm tra danh sách thiết bị đang kết nối
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
    final userProvider = Provider.of<UserProvider>(context);
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
            // 🔹 Phần hiển thị avatar, lời chào và biểu tượng thông báo
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${userProvider.user?.name[0]}',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
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
                        'Hi, ${userProvider.user?.name}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                // 🔹 Biểu tượng thông báo
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
                    // Chuyển đến màn hình điều khiển Bluetooth khi nhấn vào
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
