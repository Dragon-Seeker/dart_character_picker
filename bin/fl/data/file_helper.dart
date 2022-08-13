import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../../common/util/file_ops.dart';
import 'custom_config_providers.dart';
import '../fl_main.dart';

class FileHelper {

  static bool alwaysCopyOverFiles = false;

  static Future<void> initFiles() async {
    Directory directory = Directory(fileDirectory);

    if(!directory.existsSync() || directory.listSync().isEmpty || alwaysCopyOverFiles){
      print(fileDirectory);

      await copyAssetsToDocFolder(directory);
    }

    setupConfigs();
  }

  static Future<void> copyAssetsToDocFolder(Directory directory) async {
    print("Base Asset files are beginning to be copied over!");

    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    List<String> fileKeys = [];

    (jsonDecode(manifestContent) as Map<String, dynamic>).forEach((key, value) => fileKeys.add((value as List<dynamic>).first));

    directory.createSync();

    for (var fileKey in fileKeys) {
      ByteData data = await rootBundle.load(fileKey);

      File file = File(fileDirectory + fileKey);

      Platform.pathSeparator;

      file.createSync(recursive: true);

      file.writeAsBytesSync(data.buffer.asInt8List());
    }

    print("Base Asset files have been copied over!");
  }

  static Future<void> setupConfigs() async {

    List<ConfigData> configs = [];

    configs.add(ConfigData(File(fileDirectory + getPlatformPath("resources/users/$currentFlUser/themeSettings.json")), defaultThemeData, forceValueSets: true));

    await Settings.init(cacheProvider: MultiConfigCache(configs));
  }
}