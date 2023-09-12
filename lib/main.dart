import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_server/pages/home_page.dart';

import 'model/http_service.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await initializeService();
  // runApp(const MyApp());
  final httpService = Get.put(HttpService());
  runApp(const GetMaterialApp(home: HomePage()));
}

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String text = "Stop Service";
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Service App'),
//         ),
//         body: Column(
//           children: [
//             StreamBuilder<Map<String, dynamic>?>(
//               stream: FlutterBackgroundService().on('update'),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//                 final data = snapshot.data!;
//                 String? device = data["device"];
//                 DateTime? date = DateTime.tryParse(data["current_date"]);
//                 return Column(
//                   children: [
//                     Text(device ?? 'Unknown'),
//                     Text(date.toString()),
//                   ],
//                 );
//               },
//             ),
//             ElevatedButton(
//               child: const Text("Foreground Mode"),
//               onPressed: () {
//                 FlutterBackgroundService().invoke("setAsForeground");
//               },
//             ),
//             ElevatedButton(
//               child: const Text("Background Mode"),
//               onPressed: () {
//                 FlutterBackgroundService().invoke("setAsBackground");
//               },
//             ),
//             ElevatedButton(
//               child: Text(text),
//               onPressed: () async {
//                 final service = FlutterBackgroundService();
//                 var isRunning = await service.isRunning();
//                 if (isRunning) {
//                   service.invoke("stopService");
//                 } else {
//                   service.startService();
//                 }
//
//                 if (!isRunning) {
//                   text = 'Stop Service';
//                 } else {
//                   text = 'Start Service';
//                 }
//                 setState(() {});
//               },
//             ),
//             const Expanded(
//               child: LogView(),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {},
//           child: const Icon(Icons.play_arrow),
//         ),
//       ),
//     );
//   }
// }
//
// class LogView extends StatefulWidget {
//   const LogView({Key? key}) : super(key: key);
//
//   @override
//   State<LogView> createState() => _LogViewState();
// }
//
// class _LogViewState extends State<LogView> {
//   late final Timer timer;
//   List<String> logs = [];
//
//   @override
//   void initState() {
//     super.initState();
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       final SharedPreferences sp = await SharedPreferences.getInstance();
//       await sp.reload();
//       logs = sp.getStringList('log') ?? [];
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: logs.length,
//       itemBuilder: (context, index) {
//         final log = logs.elementAt(index);
//         return Text(log);
//       },
//     );
//   }
// }
