import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_server/globals.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saf/saf.dart';

Future<void> startFileServer(Saf saf, String rootDirectory) async {
  final info = NetworkInfo();
  final ipAddr = await info.getWifiIP();

  if (server != null) {
    // Server is already running, stop it first
    await server!.close(force: true);
    debugPrint('Server stopped.');
    server = null;
  }

  try {
    server = await HttpServer.bind(ipAddr, 8080);
    debugPrint('Server started on port 8080');

    await for (var request in server!) {
      handleRequest(request, saf, rootDirectory);
    }
  } catch (e) {
    debugPrint('Error starting the server: $e');
  }
}

Future<String> fetchFiles(Saf saf) async {
  List<String>? paths = await saf.getFilesPath();
  for (var path in paths!) {
    debugPrint("Files Paths: $path");
  }
  final link = paths.map((e){
    final fileName = e.split(Platform.pathSeparator).last;
    return '<li><a href="/download/${Uri.encodeComponent(fileName)}">$fileName</a></li>';
  }).join();

  debugPrint(link);

  return link;

  // return '<li><a href="/download/${Uri.encodeComponent(fileName)}">$fileName</a></li>';
}

void handleRequest(HttpRequest request, Saf saf, String rootDirectory) async {
  final requestedPath = request.uri.path;

  if (requestedPath == '/') {
    // List all files in the folder and generate an HTML page
    // final files = Directory("$folderPath/").listSync();
    // final fileLinks = files.map((file) {
    //   debugPrint(file.path);
    //   final fileName = file.path.split(Platform.pathSeparator).last;
    //   return '<li><a href="/download/${Uri.encodeComponent(fileName)}">$fileName</a></li>';
    // }).join();

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
    debugPrint(saf.toString());
    // final test = saf.getFilesPath();
    final fileName = Uri.decodeComponent(requestedPath.split('/').last);

    List<String>? listFolderPath = await saf.getFilesPath();
    String folderPath = removeFileName(listFolderPath!.elementAt(0));

    // final filePath = '$rootDirectory${Platform.pathSeparator}$fileName';
    // final filePath = '$folderPath${Platform.pathSeparator}$fileName';
    debugPrint("Request Path: $requestedPath");
    debugPrint("File: ${request.uri.toString()}");

    final filePath = folderPath + fileName;

    debugPrint("FilePath: $filePath");


    final file = File(filePath);
    // TODO find file

    if (file.existsSync()) {
      debugPrint("File exists");
      var status = await Permission.manageExternalStorage.status;
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

