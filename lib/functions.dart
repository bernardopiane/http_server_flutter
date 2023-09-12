import 'dart:io';

bool isDirectory(String filePath) {
  var directory = Directory(filePath);
  return directory.existsSync();
}

String removeFileName(String input) {
  int lastSlashIndex = input.lastIndexOf('/');
  if (lastSlashIndex != -1) {
    return input.substring(0, lastSlashIndex + 1);
  } else {
    // If there is no '/' character, return the original input
    return input;
  }
}

String removeFolder(String filePath) {
  List<String> pathSegments = filePath.split('/');
  return pathSegments.last;
}
