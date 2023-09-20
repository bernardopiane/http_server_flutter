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
      if (controller.connectedDevices.isNotEmpty) {
        return SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Recently connected devices:"),
              Expanded(
                child: ListView.builder(
                    itemCount: controller.connectedDevices.length,
                    itemBuilder: (context, index) {
                      return Text(controller.connectedDevices.elementAt(index));
                    }),
              ),
            ],
          ),
        );
      }

      return const SizedBox(
        height: 0,
        width: 0,
      );
    });
  }
}
