import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/pages/home_page_view_model.dart';

class ServerControlButton extends StatelessWidget {
  final HomePageViewModel viewModel;

  const ServerControlButton({Key? key, required this.viewModel})
      : super(key: key);

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
          // TODO Create new widget for buttons
          child: viewModel.showQr.value
              ? KeyedSubtree(
                  key: UniqueKey(),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0), // Padding inside the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                      elevation: 2.0, // Slight shadow to indicate elevation
                    ),
                    onPressed: viewModel.stopServer,
                    child: const Text(
                      'Stop Server',
                      style: TextStyle(
                        fontSize: 16.0, // Font size
                        fontWeight: FontWeight.bold, // Font weight
                      ),
                    ),
                  ),
                )
              : KeyedSubtree(
                  key: UniqueKey(),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0), // Padding inside the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                      elevation: 2.0, // Slight shadow to indicate elevation
                    ),
                    onPressed: () => viewModel.openFilePicker(context),
                    child: const Text(
                      'Start Server',
                      style: TextStyle(
                        fontSize: 16.0, // Font size
                        fontWeight: FontWeight.bold, // Font weight
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
