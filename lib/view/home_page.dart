import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_server/view/connected_devices_list.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../view_model/home_page_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomePageViewModel viewModel = Get.put(HomePageViewModel());

    return Scaffold(
      appBar: AppBar(
        title: const Text("HTTP Server"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8.0),
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            if (orientation == Orientation.portrait) {
              return _buildColumn(viewModel, context);
            } else {
              return _buildLandscape(viewModel, context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildQr(HomePageViewModel viewModel) {
    return Obx(() {
      if (viewModel.showQr.value) {
        return Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: QrImageView(
              data: "http://${viewModel.httpService.ip.value}:${viewModel.httpService.port}",
              version: QrVersions.auto,
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildColumn(HomePageViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ..._displayInfo(viewModel, context),
                const SizedBox(height: 20),
                const ConnectedDevicesList(),
              ],
            ),
          ),
        ),
        Expanded(
          child: _buildQr(viewModel),
        ),
      ],
    );
  }

  Widget _buildLandscape(HomePageViewModel viewModel, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._displayInfo(viewModel, context),
              const SizedBox(height: 20),
              const ConnectedDevicesList(),
            ],
          ),
        ),
        Obx(() {
          return viewModel.showQr.value
              ? Expanded(
            child: _buildQr(viewModel),
          )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  List<Widget> _displayInfo(HomePageViewModel viewModel, BuildContext context) {
    return [
      Obx(() {
        final ipAddress = viewModel.httpService.ip.value;
        return Text("IP: $ipAddress:${viewModel.httpService.port}");
      }),
      Obx(() => Text("Selected Folder: ${viewModel.selectedFolder.value}")),
      Padding(
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
      ),
    ];
  }
}
