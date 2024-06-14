import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/start_server_view_model.dart';

class StartServerButton extends StatelessWidget {
  final String dir;
  const StartServerButton({Key? key, required this.dir}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StartServerViewModel viewModel = Get.put(StartServerViewModel());

    return Obx(() {
      final isRunning = viewModel.isRunning.value;

      return ElevatedButton(
        onPressed: () {
          if (dir.isNotEmpty) {
            viewModel.toggleServer(dir);
          }
        },
        child: Text(isRunning ? "Stop Server" : "Start Server"),
      );
    });
  }
}
