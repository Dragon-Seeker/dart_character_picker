import 'dart:io';

String fileDirectory = "";

String Function(String) getPlatformPathFunc = <String>(String path) => path;

List<File> getAllJsonFiles(Directory directory){
  List<File> files = [];

  if(directory.existsSync()){
    files = directory.listSync().whereType<File>().where((file) => file.path.endsWith(".json")).toList();
  }

  return files;
}

String getPlatformPath(String path){
  return getPlatformPathFunc.call(path);
}