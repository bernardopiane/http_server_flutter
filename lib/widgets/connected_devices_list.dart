import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/http_service.dart';

class ConnectedDevicesList extends StatefulWidget {
  const ConnectedDevicesList({Key? key}) : super(key: key);

  @override
  State<ConnectedDevicesList> createState() => _ConnectedDevicesListState();
}

class _ConnectedDevicesListState extends State<ConnectedDevicesList> {
  final controller = Get.find<HttpService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connectedDevices = controller.connectedDevices;

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
