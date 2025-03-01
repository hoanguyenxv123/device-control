import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_control/screens/dashboard.dart';

class BluetoothControlScreen extends StatefulWidget {
  @override
  _BluetoothControlScreenState createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    checkPermissions().then((_) {
      autoConnectBluetooth();  // 🟢 Tự động kết nối lại khi mở ứng dụng
      startScan();
    });
  }


  Future<void> checkPermissions() async {
    if (await Permission.bluetoothScan.request().isDenied ||
        await Permission.bluetoothConnect.request().isDenied ||
        await Permission.locationWhenInUse.request().isDenied) {
      print("⚠️ Bạn cần cấp quyền Bluetooth & Vị trí để kết nối.");
    }
  }

  Future<void> autoConnectBluetooth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDeviceId = prefs.getString('lastConnectedDevice');

    if (lastDeviceId != null) {
      BluetoothDevice device = BluetoothDevice.fromId(lastDeviceId);

      print("🔄 Đang thử kết nối lại với: $lastDeviceId");

      try {
        await device.connect(autoConnect: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } catch (e) {
        print("❌ Không thể tự động kết nối: $e");
      }
    }
  }

  void saveDeviceId(String remoteId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastConnectedDevice', remoteId);
  }

  void startScan() async {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          scanResults = List.from(results);
        });
      }
      FlutterBluePlus.scanResults.listen((results) {
        for (var r in results) {
          print("📡 Thiết bị quét được: ${r.device.remoteId} - Tên: ${r.advertisementData.advName}");
        }
      });

    });

    await Future.delayed(Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      saveDeviceId(device.remoteId.toString()); // 🔥 Lưu lại để tự động kết nối sau này
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } catch (e) {
      print("❌ Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🔍 Quét & Kết nối Bluetooth")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : startScan,
            child: Text(isScanning ? "Đang quét..." : "🔍 Quét thiết bị"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                return ListTile(
                  title: Text(
                    result.advertisementData.advName.isNotEmpty
                        ? result.advertisementData.advName
                        : (result.device.platformName.isNotEmpty
                        ? result.device.platformName
                        : "Không tên"),
                  ),
                  subtitle: Text(result.device.remoteId.toString()),
                  onTap: () => connectToDevice(result.device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
