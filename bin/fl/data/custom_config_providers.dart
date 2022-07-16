import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../../common/data/users.dart';
import '../../common/util/string_utils.dart';

class MultiConfigCache extends CacheProvider{

  List<ConfigData> caches;

  MultiConfigCache(this.caches);

  @override
  Future<void> init() {
    for (var element in caches) {
      element.init();
    }

    return Future.value();
  }

  @override
  Future<void> remove(String key) {
    // TODO: implement remove
    return Future.value();
  }

  @override
  Future<void> removeAll() {
    // TODO: implement removeAll
    return Future.value();
  }

  @override
  bool containsKey(String key) {
    return caches.any((element) => element.containsKey(key));
  }

  @override
  Set getKeys() {
    Set<String> keys = {};

    for (var element in caches.map((e) => e.getKeys())) {
      keys.addAll(element);
    }

    return keys;
  }

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    return getValue(key, defaultValue: defaultValue);
  }

  @override
  double? getDouble(String key, {double? defaultValue}) {
    return getValue(key, defaultValue: defaultValue);
  }

  @override
  int? getInt(String key, {int? defaultValue}) {
    return getValue(key, defaultValue: defaultValue);
  }

  @override
  String? getString(String key, {String? defaultValue}) {
    return getValue(key, defaultValue: defaultValue);
  }

  @override
  T? getValue<T>(String key, {T? defaultValue}) {
    debugPrint("Key: $key");

    for(ConfigData configData in caches){
      if(configData.containsKey(key)) {
        T? value = configData.getValue(key, defaultValue: defaultValue);

        if (value != null) return value;
      }
    }

    return null;
  }

  @override
  Future<void> setBool(String key, bool? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setDouble(String key, double? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setInt(String key, int? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setString(String key, String? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setObject<T>(String key, T? value) async {
    debugPrint(key);

    for(ConfigData configData in caches){
      if(configData.containsKey(key)) {
        return configData.setObject(key, value);
      } else {
        debugPrint("doubleShit");
      }
    }
  }

}

Map<String, dynamic> defaultThemeData = {
  "main_theme_color" : Colors.blue.value, //Color.fromARGB(255, 255, 255, 255).value,
  "brightness_mode" : 0,
  "full_black_text_icons": false
};

class ConfigData extends CacheProvider{

  Map<String, dynamic> defaultSettingsData = {};
  Map<String, dynamic> settingsData = {};

  File dataFileToRead;

  bool forceConfigReset;

  ConfigData(this.dataFileToRead, this.defaultSettingsData, {this.forceConfigReset = false});

  @override
  Future<void> init() async {
    if (dataFileToRead.existsSync() && !forceConfigReset) {
      settingsData = jsonDecode(dataFileToRead.readAsStringSync());
    } else {
      settingsData = defaultSettingsData;

      encodeData();
    }
  }

  Future<void> encodeData() async {
    if (!dataFileToRead.existsSync()) {
      
      dataFileToRead = await dataFileToRead.create(recursive: true);
    }

    dataFileToRead.writeAsStringSync(jsonEncode(settingsData));
  }

  @override
  Future<void> remove(String key) {
    // TODO: implement remove
    return Future.value();
  }

  @override
  Future<void> removeAll() {
    // TODO: implement removeAll
    return Future.value();
  }

  //----------------------------------------------------------------------

  @override
  bool containsKey(String key) {
    return settingsData.containsKey(key);
  }

  @override
  Set<String> getKeys() {
    return settingsData.keys.toSet();
  }

  //----------------------------------------------------------------------

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    return getValue(key, defaultValue: defaultValue) as bool;
  }

  @override
  double? getDouble(String key, {double? defaultValue}) {
    return getValue(key, defaultValue: defaultValue) as double;
  }

  @override
  int? getInt(String key, {int? defaultValue}) {
    return getValue(key, defaultValue: defaultValue) as int;
  }

  @override
  String? getString(String key, {String? defaultValue}) {
    return getValue(key, defaultValue: defaultValue) as String;
  }

  @override
  T? getValue<T>(String key, {T? defaultValue}) {
    Object? value = settingsData[key] ?? defaultValue ?? defaultSettingsData[key];

    if(value != null) {
      //TODO: Why dose this not work!!!
      if (T.toString() == "Color") {
        value as int;

        Color color = Color.fromARGB(
            (value & 0xFF000000) >> 24,
            (value & 0x00FF0000) >> 16,
            (value & 0x0000FF00) >> 8,
            (value & 0x000000FF),
        );

        TextLogger.consoleOutput(color.toString());

        return color as T;
      } else if(T.toString() == "ThemeMode"){
        value as String;

        switch(value){
          case "light":
            return ThemeMode.light as T;
          case "dark":
            return ThemeMode.dark as T;
          default:
            return ThemeMode.system as T;
        }
      }
    }

    return value as T;
  }

  //----------------------------------------------------------------------

  @override
  Future<void> setBool(String key, bool? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setDouble(String key, double? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setInt(String key, int? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setString(String key, String? value) {
    return setObject(key, value);
  }

  @override
  Future<void> setObject<T>(String key, T? value) {
    debugPrint("Value is being set");

    if(value != null) {
      bool valueSet = false;

      if(T.toString() == "Color") {
        settingsData[key] = (value as Color).value;
        valueSet = true;
      } else {
        if(settingsData[key] is T){
          settingsData[key] = value;
          valueSet = true;
        } else {
          debugPrint("A value that was about to be set did not fit the value stored within the data map: $T");
        }
      }

      if(valueSet) {
        encodeData();
      }
    }

    return Future.value();
  }

  //----------------------------------------------------------------------

}