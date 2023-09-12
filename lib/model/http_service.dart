import 'package:get/get.dart';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../functions.dart';

class HttpService extends GetxController {
  final Rx<HttpServer?> _server = Rx<HttpServer?>(null);
  RxString ip = "".obs;
  final info = NetworkInfo();

  HttpServer? get server => _server.value;

  Future<void> startFileServer(String selectedFolder) async {
    final info = NetworkInfo();
    late final String? ipAddress;

    if (Platform.isWindows) {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ipAddress = addr.address;
          }
        }
      }
    } else {
      ipAddress = await info.getWifiIP();
    }

    if (server != null) {
      // Server is already running, stop it first
      await server!.close(force: true);
      _server.value = null;
    }

    try {
      _server.value = await HttpServer.bind(ipAddress, 8080);

      await for (var request in server!) {
        handleRequest(request, selectedFolder);
      }
    } catch (e) {
      // Handle the case when the server fails to bind to the IP address
      if (!Platform.isWindows) {

      }
    }
  }

  Future<String> fetchFiles(String selectedFolder) async {
    try {
      Directory dir = Directory(selectedFolder);
      final files = dir.listSync();

      final links = files.map((e) {
        final fileName = e.path.toString().split(Platform.pathSeparator).last;

        if(isDirectory(e.path)){
          // TODO handle if folder is clicked
          return "";
        }

        return '<div class="grid-item"><a href="/download/$fileName">$fileName</a></div>';
      }).join();

      return links;
    } catch (e) {
      return ''; // Return an empty string in case of an error.
    }
  }

  void handleRequest(HttpRequest request, String selectedFolder) async {
    final requestedPath = request.uri.path;
    // TODO add and display list of recently connected IPs

    if (requestedPath == '/') {
      final files = await fetchFiles(selectedFolder);

      final html = '''
        <!DOCTYPE html>
        <html>
          <head>
            <title>File List</title>
          </head>
          <style>
            .grid-container {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
              gap: 20px;
              padding: 20px;
            }
          
            .grid-item {
              background-color: #ccc;
              padding: 20px;
              text-align: center;
              border: 1px solid #333;
            }
          </style>
          <body>
            <h1>Files in the Selected Folder:</h1>
            <div class="grid-container">
              $files
              <div class="grid-item">Item 8</div>
            </div>
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
      final filePath = "$selectedFolder\\$fileName";

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

  Future<void> stopServer() async {
    final httpServer = _server.value;
    if (httpServer != null) {
      await httpServer.close(force: true);
      _server.value = null;
    }
  }

  @override
  void onClose() {
    // Make sure to stop the server when the HttpService is disposed
    stopServer();
    super.onClose();
  }

  Future<void> getIP() async {
    if (Platform.isWindows) {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ip.value = addr.address;
          }
        }
      }
    } else {
      // Mobile
      ip.value = (await info.getWifiIP())!;
    }
  }
}
