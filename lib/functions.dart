import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true; // User is connected to WiFi
    }
    // No internet connection or not connected to WiFi
    displaySnackbar("Warning", "Please connect to a WiFi network", warning: true);
  } else {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      displaySnackbar("Warning", "Please connect to a network", warning: true);
      return false; // No internet connection
    }
  }

  return true; // Default to having a network connection for unsupported platforms
}

void displaySnackbar(String title, String message, {bool warning = false}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: warning ? Colors.orange[900] : Colors.grey[900], // Dark background for warning, otherwise grey
    colorText: Colors.white, // Light text color
    margin: const EdgeInsets.all(16.0), // Margin around the snackbar
    borderRadius: 4.0, // Rounded corners
    icon: warning ? const Icon(Icons.warning, color: Colors.white) : const Icon(Icons.info_outline, color: Colors.white), // Warning icon if applicable, otherwise info icon
    shouldIconPulse: false, // No pulsing icon
    barBlur: 0, // No blur
    isDismissible: true, // Allow dismissal by swiping
    duration: const Duration(seconds: 4), // Visible for 4 seconds
    snackStyle: SnackStyle.FLOATING, // Floating snackbar
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding inside the snackbar
    overlayColor: Colors.black.withOpacity(0.5), // Background overlay color
  );
}
