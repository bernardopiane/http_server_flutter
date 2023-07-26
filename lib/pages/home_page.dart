import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final info = NetworkInfo();

  @override
  void initState() {
    super.initState();
    const selectedFolderPath =
        '/'; // Replace with the path to your selected folder
    startFileServer(selectedFolderPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HTTP Server"),
      ),
      body: const Text("Information: "),
    );
  }

  void startFileServer(String folderPath) async {
    final ipAddr = await info.getWifiIP();
    final server = await HttpServer.bind(ipAddr, 8080);
    debugPrint('Server running on port ${server.port}');
    debugPrint("Server running on IP: $ipAddr");

    await for (HttpRequest request in server) {
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
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.binary
            ..headers
                .set('Content-Disposition', 'attachment; filename="$fileName"')
            ..add(await file.readAsBytes());
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
  }
}
