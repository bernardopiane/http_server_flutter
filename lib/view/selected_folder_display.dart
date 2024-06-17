import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/pages/home_page_view_model.dart';

class SelectedFolderDisplay extends StatelessWidget {
  final HomePageViewModel viewModel;

  const SelectedFolderDisplay({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text("Selected Folder: ${viewModel.selectedFolder.value}"));
  }
}
