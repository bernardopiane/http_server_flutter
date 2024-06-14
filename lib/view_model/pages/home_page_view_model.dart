import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/http_service.dart';
import '../../functions.dart';

class HomePageViewModel extends GetxController {
  var selectedFolder = "".obs;
  var showQr = false.obs;
  final httpService = Get.find<HttpService>();

  @override
  void onInit() {
    super.onInit();
    getPermissions();
    httpService.getIP();
  }

  void openFilePicker(BuildContext context) async {
    Directory? rootDirectory;

    if (Platform.isAndroid) {
      try {
        rootDirectory = await getExternalStorageDirectory();
      } catch (e) {
        debugPrint('Error accessing external storage directory: $e');
      }
    } else if (Platform.isIOS) {
      try {
        rootDirectory = await getApplicationDocumentsDirectory();
      } catch (e) {
        debugPrint('Error accessing application documents directory: $e');
      }
    } else if (Platform.isWindows) {
      try {
        rootDirectory = await getDownloadsDirectory();
      } catch (e) {
        debugPrint('Error accessing application documents directory: $e');
      }
    }

    if (rootDirectory == null) {
      debugPrint('Unable to access the starting directory.');
      return;
    }

    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    selectedFolder.value = result;
    Directory dir = Directory(selectedFolder.value);
    final files = dir.listSync();
    bool hasFiles = files.any((file) => file is File);

    if (hasFiles) {
      showQr.value = true;
      httpService.startFileServer(selectedFolder.value);
    } else {
      if (!Platform.isWindows) {
        displaySnackbar("Warning", "No files in folder", warning: true);
      }
      showQr.value = false;
      selectedFolder.value = "No folder selected";
    }
  }

  void stopServer() {
    httpService.stopServer();
    showQr.value = false;
  }
}
