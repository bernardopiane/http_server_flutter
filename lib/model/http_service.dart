import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HttpService extends GetxController {
  final Rx<HttpServer?> _server = Rx<HttpServer?>(null);
  RxString ip = "".obs;
  final info = NetworkInfo();
  final int port = 64578;
  RxList<String> connectedDevices = RxList<String>.empty();

  HttpServer? get server => _server.value;

  Future<void> startFileServer(String selectedFolder) async {
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
      final info = NetworkInfo();
      ipAddress = await info.getWifiIP();
    }

    if (_server.value != null) {
      // Server is already running, stop it first
      await _server.value!.close(force: true);
      _server.value = null;
    }

    try {
      _server.value = await HttpServer.bind(ipAddress, port);

      Get.snackbar("Message", "Server has been started",
          snackPosition: SnackPosition.BOTTOM);

      await for (var request in _server.value!) {
        handleRequest(request, selectedFolder);
      }
    } catch (e) {
      // Handle the case when the server fails to bind to the IP address
      if (!Platform.isWindows) {
        // Handle the error on non-Windows platforms here
      }
    }
  }

  //           return '<tr><td>$fileName</td><td>Data</td><td>Type</td><td>$fileSize</td></tr>';

  Future<String> fetchFiles(String selectedFolder) async {
    try {
      Directory dir = Directory(selectedFolder);
      final files = dir.listSync();

      final links = await Future.wait(files.map((e) async {
        final fileName = e.path.split(Platform.pathSeparator).last;

        if (FileSystemEntity.isFileSync(e.path)) {
          final file = File(e.path);
          final fileLength = file.lengthSync() / 1024.0;

          final fileSize = fileLength.toStringAsFixed(2);
          final fileType = _getFileType(fileName);
          final modifiedDate = await _getFormattedModifiedDate(file);

          return '''
         <div class="table-row">
            <div class="table-cell" data-key="fileName"><a href="/download/$fileName">$fileName</a></div>
            <div class="table-cell" data-key="modifiedDate">$modifiedDate</div>
            <div class="table-cell" data-key="fileType">$fileType</div>
            <div class="table-cell" data-key="fileSize">$fileSize KB</div>
        </div>
          ''';
        }

        return '';
      }));

      return links.join();
    } catch (e) {
      return ''; // Return an empty string in case of an error.
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last;
    return extension.isEmpty ? 'Unknown' : extension.toUpperCase();
  }

  Future<String> _getFormattedModifiedDate(File file) async {
    final modifiedDate = await file.lastModified();
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormatter.format(modifiedDate);
  }

  void handleRequest(HttpRequest request, String selectedFolder) async {
    final requestedPath = request.uri.path;
    // TODO add and display list of recently connected IPs

    final String? clientIP = request.connectionInfo?.remoteAddress.address;

    if (!connectedDevices.contains(clientIP!)) {
      connectedDevices.add(clientIP);
    }

    if (requestedPath == '/') {
      final files = await fetchFiles(selectedFolder);

      final html = '''
      <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Share</title>
     <style>
        /* Default styles for the table */
        .table-container {
            display: flex;
            flex-direction: column;
        }
        .table-header {
            cursor: pointer;
        }

        .table-header.sorted-asc::after {
            content: ' ↑';
        }

        .table-header.sorted-desc::after {
            content: ' ↓';
        }

        .table-row {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #ddd;
            padding: 16px 0;
        }

        .table-cell {
            flex: 1;
            padding: 8px;
            word-break: break-all;
        }

        /* Media query for screens smaller than 600px (phones) */
        @media screen and (max-width: 600px) {
            .table-row {
                flex-direction: column;
                align-items: flex-start;
            }

            .table-cell {
                width: 100%;
                padding: 8px 0;
            }
        }
        
        /* Additional styles for the first cell on larger screens */
        @media screen and (min-width: 601px) {
            .table-cell:first-child {
                flex: 0 0 60%; /* Set a fixed width of 60% of the viewport */
            }
        }
    </style>
</head>
<body>
    <div class="table-container">
        <div class="table-row">
            <div class="table-header table-cell sortable" data-key="fileName">Name</div>
            <div class="table-header table-cell sortable" data-key="modifiedDate">Modified date</div>
            <div class="table-header table-cell sortable" data-key="fileType">Type</div>
            <div class="table-header table-cell sortable" data-key="fileSize">Size</div>
        </div>
        $files
        </table>
    </div>
     <script>
        // JavaScript for sorting the table
        const tableContainer = document.querySelector('.table-container');
        const sortableHeaders = tableContainer.querySelectorAll('.sortable');

        sortableHeaders.forEach(header => {
            header.addEventListener('click', () => {
                const key = header.getAttribute('data-key');
                const ascending = !header.classList.contains('sorted-asc');

                // Remove sorting indicators from all headers
                sortableHeaders.forEach(otherHeader => {
                    otherHeader.classList.remove('sorted-asc', 'sorted-desc');
                });

                // Sort the table rows based on the selected key and order
                const rows = Array.from(tableContainer.querySelectorAll('.table-row')).slice(1); // Exclude the header row
               rows.sort((a, b) => {
                  let aValue = a.querySelector(`[data-key="\${key}"]`);
                  let bValue = b.querySelector(`[data-key="\${key}"]`);
                  
                  // Check if aValue and bValue are defined, and if not, use empty strings
                  aValue = aValue ? aValue.textContent : '';
                  bValue = bValue ? bValue.textContent : '';
                  
                  // Check if sorting the last cell (file size)
                  if (key === 'fileSize') {
                      // Parse the values as integers for the last cell
                      const aSize = parseInt(aValue);
                      const bSize = parseInt(bValue);
              
                      if (ascending) {
                          return aSize - bSize; // Sort as integers in ascending order
                      } else {
                          return bSize - aSize; // Sort as integers in descending order
                      }
                  } else {
                      // Sort the other cells as strings
                      if (ascending) {
                          return aValue.localeCompare(bValue);
                      } else {
                          return bValue.localeCompare(aValue);
                      }
                  }
              });



                // Apply sorting order class to the header
                header.classList.toggle('sorted-asc', ascending);
                header.classList.toggle('sorted-desc', !ascending);

                // Reorder the rows in the table container
                rows.forEach(row => {
                    tableContainer.appendChild(row);
                });
            });
        });
    </script>
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
          ..headers
              .set('Content-Disposition', 'attachment; filename="$fileName"')
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
      Get.snackbar("Message", "Server has been stopped",
          snackPosition: SnackPosition.BOTTOM);
      connectedDevices.clear();
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
