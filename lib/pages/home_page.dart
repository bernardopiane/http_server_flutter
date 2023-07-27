import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_server/widgets/start_server_button.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFolder = "";
  final info = NetworkInfo();
  String? ipAddr;

  @override
  void initState() {
    super.initState();
    getIP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HTTP Server"),
      ),
      body: Column(
        children: [
          Flexible(
            child: Column(
              children: [
                const Text("Information: "),
                Text("Selected Folder: $selectedFolder"),
                ElevatedButton(
                  onPressed: () {
                    openFilePicker(context);
                  },
                  child: const Text('Select Folder'),
                ),
                StartServerButton(dir: selectedFolder),
              ],
            ),
          ),
          if (ipAddr != null && ipAddr != "")
            QrImageView(
              data: "http://${ipAddr}:8080",
              version: QrVersions.auto,
            ),
        ],
      ),
    );
  }

  void openFilePicker(BuildContext context) async {
    Directory? rootDirectory;

    if (Platform.isAndroid) {
      // rootDirectory = await getExternalStorageDirectory();
      rootDirectory = Directory("/storage/emulated/0");
    } else if (Platform.isIOS) {
      rootDirectory = await getApplicationDocumentsDirectory();
    }

    if (rootDirectory == null) {
      debugPrint('Unable to access the starting directory.');
      return;
    }

    String? filePath = await FilesystemPicker.open(
      title: 'Select a folder',
      rootDirectory: rootDirectory,
      fsType: FilesystemType.folder,
      pickText: 'Select',
      folderIconColor: Colors.teal,
      context: context,
    );

    if (filePath != null) {
      // Do something with the selected file path
      debugPrint('Selected file: $filePath');
      setState(() {
        selectedFolder = filePath;
      });
    }
  }

  Future<void> getIP() async {
    String? ip = await info.getWifiIP();
    debugPrint("IP: $ip");
    setState(() {
      ipAddr = ip;
    });
  }
}
