import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_server/globals.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saf/saf.dart';

Future<void> stopFileServer() async {
  await server!.close(force: true);
  Fluttertoast.showToast(
    msg: "Server has been stopped",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.white,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

Future<void> startFileServer(Saf saf, String rootDirectory) async {
  final info = NetworkInfo();
  final ipAddress = await info.getWifiIP();

  if (server != null) {
    // Server is already running, stop it first
    await server!.close(force: true);
    debugPrint('Server stopped.');
    server = null;
    Fluttertoast.showToast(
      msg: "Server has been stopped",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  try {
    server = await HttpServer.bind(ipAddress, 8080);
    debugPrint('Server started on port 8080');

    // Show a success message when the server is started successfully
    Fluttertoast.showToast(
      msg: "Server started on port 8080",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    await for (var request in server!) {
      handleRequest(request, saf, rootDirectory);
    }
  } catch (e) {
    // Handle the case when the server fails to bind to the IP address
    Fluttertoast.showToast(
      msg: "Error starting the server: $e",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    debugPrint('Error starting the server: $e');
  }
}

Future<String> fetchFiles(Saf saf) async {
  try {
    List<String>? paths = await saf.getFilesPath();

    if (paths == null || paths.isEmpty) {
      debugPrint("No files found.");
      return ''; // Return an empty string if no files are found.
    }

    for (var path in paths) {
      debugPrint("Files Paths: $path");
    }

    final links = paths.map((e) {
      final fileName = e.split(Platform.pathSeparator).last;
      return '<li><a href="/download/${Uri.encodeComponent(fileName)}">$fileName</a></li>';
    }).join();

    debugPrint(links);

    return links;
  } catch (e) {
    debugPrint('Error fetching files: $e');
    return ''; // Return an empty string in case of an error.
  }
}

void handleRequest(HttpRequest request, Saf saf, String rootDirectory) async {
  final requestedPath = request.uri.path;
  // TODO add and display list of recently connected IPs

  if (requestedPath == '/') {
    final fileLinks = await fetchFiles(saf);

    final html = '''
        <!DOCTYPE html>
        <html>
          <head>
            <title>File List</title>
          </head>
          <body>
            <h1>Files in the Selected Folder:</h1>
            <ul>
              $fileLinks
            </ul>
          </body>
        </html>
      ''';

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(html);
    await request.response.close();
  } else if (requestedPath.startsWith('/download/')) {
    // Handle file download
    final fileName = Uri.decodeComponent(requestedPath.split('/').last);

    List<String>? listFolderPath = await saf.getFilesPath();
    String folderPath = removeFileName(listFolderPath!.elementAt(0));

    final filePath = folderPath + fileName;
    final file = File(filePath);

    if (file.existsSync()) {
      final status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        await Permission.manageExternalStorage.request();
      }

      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType('application', 'octet-stream')
        ..headers.set('Content-Disposition', 'attachment; filename="$fileName"')
        ..headers.set('Content-Length', fileSize.toString())
        ..add(fileBytes);
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('File not found');
    }

    await request.response.close();
  } else {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Page not found');
    await request.response.close();
  }
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
