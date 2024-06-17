import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/pages/home_page_view_model.dart';

class IPAddressDisplay extends StatelessWidget {
  final HomePageViewModel viewModel;

  const IPAddressDisplay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ipAddress = viewModel.httpService.ip.value;
      return Text("IP: $ipAddress:${viewModel.httpService.port}");
    });
  }
}
