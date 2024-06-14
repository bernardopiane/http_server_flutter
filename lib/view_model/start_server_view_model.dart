import 'package:get/get.dart';

class StartServerViewModel extends GetxController {
  // Using RxBool to hold the state of the server
  var isRunning = false.obs;

  // Method to toggle the server state
  void toggleServer(String dir) {
    if (dir.isNotEmpty) {
      // startFileServer(dir); // Call the actual server start function here
      isRunning.value = !isRunning.value;
    }
  }
}
