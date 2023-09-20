import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_server/pages/home_page.dart';
import 'package:http_server/pages/scanner_page.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const HomePage());
                },
                child: Container(
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      "Send Files",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const ScannerPage());
                },
                child: Container(
                  color: Colors.green,
                  child: const Center(
                    child: Text(
                      "Receive Files",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
