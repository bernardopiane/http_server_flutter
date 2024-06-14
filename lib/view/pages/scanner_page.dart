import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../view_model/pages/scanner_view_model.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScannerViewModel viewModel = Get.put(ScannerViewModel());

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: viewModel.qrKey,
              onQRViewCreated: viewModel.onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Obx(() {
                final result = viewModel.result.value;
                return result != null
                    ? Text(
                        'Barcode Type: ${(result.format).name}   Data: ${result.code}')
                    : const Text('Scan a code');
              }),
            ),
          ),
        ],
      ),
    );
  }
}
