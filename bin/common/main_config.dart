import 'dart:convert';
import 'dart:io';

import 'util/file_ops.dart';

class MainConfig {

  static MainConfig config = MainConfig._(_defaultConfig);

  static const Map<String, dynamic> _defaultConfig = <String, dynamic>{
    "debug_output": false,
    "character_debug_output" : false
  };

  final Map<String, dynamic> _data;

  MainConfig._([this._data = const <String, dynamic>{}]);

  //---------------------------

  static bool debugOutputEnabled() {
    return config._data["debug_output"];
  }

  static bool characterDebugOutputEnabled() {
    return config._data["character_debug_output"];
  }

  //---------------------------

  static initConfigCl() {
    File file = File(fileDirectory + getPlatformPath("resources/main_config.json"));

    if (file.existsSync()) {
      config =  MainConfig._(jsonDecode(file.readAsStringSync()));
    } else {
      config._saveConfig();
    }
  }

  void _saveConfig() async {
    File file = File(fileDirectory + getPlatformPath("resources/main_config.json"));

    if (!file.existsSync()) {
      file = await file.create();
    }

    file.writeAsString(jsonEncode(config), mode: FileMode.write);
  }
}

class ProgramInfoLoader {

  static ProgramInfoLoader info = ProgramInfoLoader._();

  final Map<String, dynamic> _data;

  ProgramInfoLoader._([this._data = const <String, dynamic>{}]);
  
  static initInfoCl() {
    info = ProgramInfoLoader._(jsonDecode(File(fileDirectory + getPlatformPath("resources/version_info.json")).readAsStringSync()));
  }

  static getProgramVersion(){
    return info._data["program_ver"];
  }
}
