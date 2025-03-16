import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'bluetooth_control.dart';

class VoiceControl {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  final Function(String) onCommandReceived;
  final BluetoothControl _bluetoothControl = BluetoothControl();

  VoiceControl({required this.onCommandReceived});

  void startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Trạng thái: $status"),
      onError: (error) => print("Lỗi: $error"),
    );

    if (available) {
      isListening = true;
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            // Chỉ xử lý khi kết quả cuối cùng
            String commandText = result.recognizedWords;
            print("📢 Lệnh nhận được: $commandText");
            onCommandReceived(commandText);
          }
        },
      );
    }
  }

  void stopListening() {
    _speech.stop();
    isListening = false;
  }

  void processVoiceCommand(
    String command,
    List<int> deviceIds,
    Function(int, bool) sendCommand,
    Function(int, bool) updateUI, // ✅ Thêm callback cập nhật UI
  ) async {
    command = command.toLowerCase();
    print("📢 Xử lý lệnh giọng nói: $command");

    Map<int, String> deviceMap = {
      2: "đèn phòng khách", // khách
      3: "đèn phòng bếp", //ngủ
      4: "đèn phòng học", //ngủ
      5: "đèn phòng tắm", // bếp
      6: "đèn phòng ngủ", // office
      7: "tivi", // tắm
    };

    int? detectedDeviceId;
    for (var entry in deviceMap.entries) {
      if (command.contains(entry.value)) {
        detectedDeviceId = entry.key;
        print("✅ Phát hiện thiết bị: ${entry.value} (ID: $detectedDeviceId)");
        break;
      }
    }

    if (detectedDeviceId != null) {
      if (_bluetoothControl.controlCharacteristic == null) {
        print("⚠️ Đặc tính chưa được xác định, tìm kiếm...");
        await _bluetoothControl.findControlCharacteristic();
      }

      bool? newState;
      if (command.contains("bật")) {
        print("✅ Phát hiện hành động: Bật");
        newState = true;
      } else if (command.contains("tắt")) {
        print("✅ Phát hiện hành động: Tắt");
        newState = false;
      }

      if (newState != null) {
        await _bluetoothControl.sendCommand(detectedDeviceId, newState);
        sendCommand(detectedDeviceId, newState);
        updateUI(detectedDeviceId, newState); // ✅ Cập nhật UI thiết bị
      } else {
        print("⚠️ Không nhận diện được hành động (bật/tắt)");
      }
    } else {
      print("⚠️ Không nhận diện được thiết bị");
    }
  }
}
