import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_server/functions.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool showQr = false;

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
      body: SafeArea(
        minimum: const EdgeInsets.all(8.0),
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            if (orientation == Orientation.portrait) {
              return _buildColumn();
            } else {
              return _buildLandscape();
            }
          },
        ),
      ),
    );
  }

  void openFilePicker(BuildContext context) async {
    Directory? rootDirectory;

    if (Platform.isAndroid) {
      // Use the platform plugin to get external storage directory
      try {
        rootDirectory = await getExternalStorageDirectory();
      } catch (e) {
        debugPrint('Error accessing external storage directory: $e');
      }
    } else if (Platform.isIOS) {
      // Use the platform plugin to get application documents directory
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

    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      debugPrint('Permission to access storage not granted.');
      Fluttertoast.showToast(
        msg: "Permission to access storage not granted.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final result = await FilePicker.platform.getDirectoryPath();
    setState(() {
      selectedFolder = result!;
    });

    Directory dir = Directory(selectedFolder);
    final files = dir.listSync();
    bool hasFiles = false;

    for (var file in files) {
      if (file is File) {
        hasFiles = true;
      }
    }

    // Saf saf = Saf(rootDirectory.path);
    // bool? isGranted = await saf.getDirectoryPermission(isDynamic: true);
    //
    // if (isGranted != null && isGranted) {
    //   // Fetch the files from the SAF storage
    //   fetchFiles(saf);
    //
    //   // Get the list of file paths
    //   List<String>? paths = await saf.getFilesPath();
    //
    //   for (var element in paths!) {
    //     if (await File(element).exists()) {
    //       hasFiles = true;
    //     }
    //   }

    if (hasFiles) {
      setState(() {
        showQr = true;
      });
      // Start the file server
      startFileServer(selectedFolder);
    } else {
      if (!Platform.isWindows) {
        Fluttertoast.showToast(
          msg: "No files in folder",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
      setState(() {
        showQr = false;
        selectedFolder = "No folder selected";
      });
      return;
    }
    // } else {
    //   debugPrint("Permission to access the storage was denied.");
    //   Fluttertoast.showToast(
    //     msg: "Permission to access the storage was denied.",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.redAccent,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // }
  }

  Future<void> getIP() async {
    String? ip;

    if (Platform.isWindows) {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ip = addr.address;
          }
        }
      }
    } else {
      // Mobile
      ip = await info.getWifiIP();
    }

    setState(() {
      ipAddr = ip;
    });
  }

  Widget _buildQr() {
    if (showQr) {
      return Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: QrImageView(
            data: "http://$ipAddr:8080",
            version: QrVersions.auto,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              children: _displayInfo(),
            ),
          ),
        ),
        Expanded(
          child: _buildQr(),
        ),
      ],
    );
  }

  Widget _buildLandscape() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _displayInfo(),
          ),
        ),
        _buildQr()
      ],
    );
  }

  List<Widget> _displayInfo() {
    return [
      Text("IP: ${ipAddr.toString()}"),
      Text("Selected Folder: $selectedFolder"),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 125),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: showQr
              ? KeyedSubtree(
                  key: UniqueKey(),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: showQr
                        ? () {
                            if (showQr) {
                              stopFileServer();
                              setState(() {
                                showQr = false;
                              });
                            }
                          }
                        : null,
                    child: const Text('Stop Server'),
                  ),
                )
              : KeyedSubtree(
                  key: UniqueKey(),
                  child: ElevatedButton(
                    onPressed: () {
                      openFilePicker(context);
                    },
                    child: const Text('Start Server'),
                  ),
                ),
        ),
      ),
    ];
  }
}
