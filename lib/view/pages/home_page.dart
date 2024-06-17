import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_server/view/connected_devices_list.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../view_model/pages/home_page_view_model.dart';
import '../ip_address_display.dart';
import '../selected_folder_display.dart';
import '../server_control_button.dart';

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
              data:
                  "http://${viewModel.httpService.ip.value}:${viewModel.httpService.port}",
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
      IPAddressDisplay(viewModel: viewModel),
      SelectedFolderDisplay(viewModel: viewModel),
      ServerControlButton(viewModel: viewModel),
    ];
  }
}
