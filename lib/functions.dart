import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

bool isDirectory(String filePath) {
  var directory = Directory(filePath);
  return directory.existsSync();
}

String removeFileName(String input) {
  int lastSlashIndex = input.lastIndexOf('/');
  if (lastSlashIndex != -1) {
    return input.substring(0, lastSlashIndex + 1);
  } else {
    // If there is no '/' character, return the original input
    return input;
  }
}

String removeFolder(String filePath) {
  List<String> pathSegments = filePath.split('/');
  return pathSegments.last;
}

Future<void> getPermissions() async {
  final permissions = [
    Permission.storage,
    Permission.audio,
    Permission.photos,
    Permission.videos,
    Permission.mediaLibrary,
    Permission.manageExternalStorage,
  ];

  for (final permission in permissions) {
    final status = await permission.status;
    if (!status.isGranted) {
      await permission.request();
    }
  }
}

Future<bool> checkConnectionStatus() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  final isSupportedPlatform = Platform.isAndroid || Platform.isIOS;

  if (isSupportedPlatform) {
    if (connectivityResult == ConnectivityResult.wifi) {
      return true; // User is connected to WiFi
    }
    // No internet connection or not connected to WiFi
    showMessage("Please connect to a WiFi network");
  } else {
    if (connectivityResult == ConnectivityResult.none) {
      showMessage("Please connect to a network");
      return false; // No internet connection
    }
  }

  return true; // Default to having a network connection for unsupported platforms
}

void showMessage(String message) {
  Get.snackbar("Warning", message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12));
}
