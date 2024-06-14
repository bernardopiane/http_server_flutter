import 'package:get/get.dart';
import '../view/home_page.dart';
import '../view/scanner_page.dart';

class SelectionViewModel extends GetxController {
  // Method to navigate to the HomePage
  void goToHomePage() {
    Get.to(() => const HomePage());
  }

  // Method to navigate to the ScannerPage
  void goToScannerPage() {
    Get.to(() => const ScannerPage());
  }
}
