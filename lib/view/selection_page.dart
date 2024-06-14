import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/selection_view_model.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SelectionViewModel viewModel = Get.put(SelectionViewModel());

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: viewModel.goToHomePage,
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
                onTap: viewModel.goToScannerPage,
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
