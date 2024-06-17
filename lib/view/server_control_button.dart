import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/pages/home_page_view_model.dart';

class ServerControlButton extends StatelessWidget {
  final HomePageViewModel viewModel;

  const ServerControlButton({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 125),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: viewModel.showQr.value
              ? KeyedSubtree(
            key: UniqueKey(),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: viewModel.stopServer,
              child: const Text('Stop Server'),
            ),
          )
              : KeyedSubtree(
            key: UniqueKey(),
            child: ElevatedButton(
              onPressed: () => viewModel.openFilePicker(context),
              child: const Text('Start Server'),
            ),
          ),
        );
      }),
    );
  }
}
