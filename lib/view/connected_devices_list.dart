import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/connected_devices_view_model.dart';

class ConnectedDevicesList extends StatelessWidget {
  const ConnectedDevicesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConnectedDevicesViewModel viewModel = Get.put(ConnectedDevicesViewModel());

    return Obx(() {
      final connectedDevices = viewModel.connectedDevices;

      if (connectedDevices.isEmpty) {
        // Return an empty SizedBox if there are no connected devices.
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Recently connected devices:"),
            Expanded(
              child: ListView.builder(
                itemCount: connectedDevices.length,
                itemBuilder: (context, index) {
                  return Text(
                    connectedDevices[index],
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
