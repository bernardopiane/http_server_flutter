import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_server/pages/home_page.dart';

import 'model/http_service.dart';

Future<void> main() async {
  Get.put(HttpService());
  runApp(const GetMaterialApp(home: HomePage()));
}