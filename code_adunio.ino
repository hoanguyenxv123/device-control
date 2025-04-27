#include <EEPROM.h>

int devices[] = {2, 3, 4, 5, 6, 7, 8, 9, 10};

void setup() {
  Serial.begin(9600);
  Serial.println("Hệ thống đã sẵn sàng. Chờ lệnh từ Bluetooth...");

  // Khôi phục trạng thái từ EEPROM
  for (int i = 0; i < 9; i++) {
    pinMode(devices[i], OUTPUT);
    int state = EEPROM.read(i);
    digitalWrite(devices[i], state == 1 ? HIGH : LOW);
  }
}

void loop() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    
    Serial.println("Nhận lệnh: " + command);

  int deviceId = command.substring(0, command.indexOf(':')).toInt();
  int state = command.substring(command.indexOf(':') + 1).toInt();

  for (int i = 0; i < 9; i++) {
    if (devices[i] == deviceId) {
      digitalWrite(devices[i], state == 1 ? HIGH : LOW);
      EEPROM.write(i, state);
      Serial.println("✅ " + String(state == 1 ? "Bật" : "Tắt") + " thiết bị " + String(deviceId));
      return;
    }
  }
  
  Serial.println("❌ Không tìm thấy thiết bị: " + String(deviceId));
  }
}