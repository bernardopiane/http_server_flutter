import 'package:get/get.dart';

class ConnectedDevicesViewModel extends GetxController {
  // Using RxList to hold the list of connected devices
  var connectedDevices = <String>[].obs;

  // Method to add a new connected device
  void addDevice(String device) {
    connectedDevices.add(device);
  }

  // Method to remove a connected device
  void removeDevice(String device) {
    connectedDevices.remove(device);
  }

  // Method to clear all connected devices
  void clearDevices() {
    connectedDevices.clear();
  }

// Other business logic methods can be added here
}
