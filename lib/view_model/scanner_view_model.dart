import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerViewModel extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var result = Rxn<Barcode>();
  QRViewController? controller;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _launchURL(scanData.code!);
      result.value = scanData;
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
