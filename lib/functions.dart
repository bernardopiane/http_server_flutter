import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http_server/globals.dart';
import 'package:network_info_plus/network_info_plus.dart';

// void startFileServer(String folderPath) async {
//   final info = NetworkInfo();
//   final ipAddr = await info.getWifiIP();
//   server = await HttpServer.bind(ipAddr, 8080);
//   // TODO test real w/ device
//   debugPrint("Running");
//
//   await for (HttpRequest request in server!) {
//     final requestedPath = request.uri.path;
//
//     if (requestedPath == '/') {
//       // List all files in the folder and generate an HTML page
//       final files = Directory(folderPath).listSync();
//       final fileLinks = files.map((file) {
//         final fileName = file.path.split(Platform.pathSeparator).last;
//         return '<li><a href="/download/${Uri.encodeComponent(fileName)}">$fileName</a></li>';
//       }).join();
//
//       final html = '''
//         <!DOCTYPE html>
//         <html>
//           <head>
//             <title>File List</title>
//           </head>
//           <body>
//             <h1>Files in the Selected Folder:</h1>
//             <ul>
//               $fileLinks
//             </ul>
//           </body>
//         </html>
//       ''';
//
//       request.response
//         ..statusCode = HttpStatus.ok
//         ..headers.contentType = ContentType.html
//         ..write(html);
//       await request.response.close();
//     } else if (requestedPath.startsWith('/download/')) {
//       // Handle file download
//       final fileName = Uri.decodeComponent(requestedPath.split('/').last);
//       final filePath = '$folderPath${Platform.pathSeparator}$fileName';
//       final file = File(filePath);
//
//       if (file.existsSync()) {
//         request.response
//           ..statusCode = HttpStatus.ok
//           ..headers.contentType = ContentType.binary
//           ..headers
//               .set('Content-Disposition', 'attachment; filename="$fileName"')
//           ..add(await file.readAsBytes());
//       } else {
//         request.response
//           ..statusCode = HttpStatus.notFound
//           ..write('File not found');
//       }
//
//       await request.response.close();
//     } else {
//       request.response
//         ..statusCode = HttpStatus.notFound
//         ..write('Page not found');
//       await request.response.close();
//     }
//   }
// }
//
// void stopFileServer() async {
//   final info = NetworkInfo();
//   final ipAddr = await info.getWifiIP();
//   final server = await HttpServer.bind(ipAddr, 8080);
//
//   server.close();
// }

Future<void> startFileServer(String folderPath) async {
  if (server != null && server!.isBroadcast) {
    // Server is already running, stop it first
    await server!.close(force: true);
    debugPrint('Server stopped.');
    server = null;
    return;
  }

  try {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
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
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.binary
        ..headers.set('Content-Disposition', 'attachment; filename="$fileName"')
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
