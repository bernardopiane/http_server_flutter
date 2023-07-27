import 'package:flutter/material.dart';
import 'package:http_server/functions.dart';

class StartServerButton extends StatefulWidget {
  final String dir;
  const StartServerButton({Key? key, required this.dir}) : super(key: key);

  @override
  State<StartServerButton> createState() => _StartServerButtonState();
}

class _StartServerButtonState extends State<StartServerButton> {
  late bool isRunning;

  @override
  void initState() {
    super.initState();
    isRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if(widget.dir != null && widget.dir != ""){
            startFileServer(widget.dir);
            setState(() {
              isRunning = !isRunning;
            });
          }
        },
        child: Text(isRunning ? "Stop Server" : "Start Server"));
  }
}
