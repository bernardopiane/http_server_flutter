import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_server/globals.dart';
import 'package:network_info_plus/network_info_plus.dart';

Future<void> startFileServer(String folderPath) async {
  final info = NetworkInfo();
  final ipAddr = await info.getWifiIP();

  if (server != null) {
    // Server is already running, stop it first
    await server!.close(force: true);
    debugPrint('Server stopped.');
    server = null;
    return;
  }

  try {
    server = await HttpServer.bind(ipAddr, 8080);
    debugPrint('Server started on port 8080');

    await for (var request in server!) {
      handleRequest(request, folderPath);
    }
  } catch (e) {
    debugPrint('Error starting the server: $e');
  }
}

void handleRequest(HttpRequest request, String folderPath) async {
  final requestedPath = request.uri.path;

  if (requestedPath == '/') {
    // List all files in the folder and generate an HTML page
    final files = Directory(folderPath).listSync();
    final fileLinks = files.map((file) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      return '<li><a href="/download/${Uri.encodeComponent(fileName)}">$fileName</a></li>';
    }).join();

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
    final filePath = '$folderPath${Platform.pathSeparator}$fileName';
    final file = File(filePath);

    if (file.existsSync()) {
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
