import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../common/thing_manager.dart';
import '../common/util/file_ops.dart';
import '../common/util/string_utils.dart';
import 'data/imageManager.dart';
import 'widgets/overlay_helper.dart';

typedef CustomWidgetBuilder = Widget Function(BuildContext context, {List<dynamic>? inputs});

class UIDataManger {

  ThingManager? currentManager;
  ImageManager? currentImageManager;

  Map<Key, OverlayHelper> overlayMap = Map();

  UIDataManger();

  void initCharacterConfigsFl() {
    TextLogger.consoleOutput("Attempting to Loading Character Configs!",
        debugOut: true);

    var directory = Directory(fileDirectory + getPlatformPath("resources/characterConfigs/"));

    if (directory.existsSync()) {
      for (var file in getAllJsonFiles(directory)) {
        Map<String, dynamic> json = jsonDecode(file.readAsStringSync());

        try {
          ThingManager.parseManagerData(json);
        } catch(e){
          TextLogger.warningOutput("It seems that there might have been a issue reading a config, skipping over such");
          print(e);
        }
      }

      TextLogger.consoleOutput("Finished Character Config Loading!",
          debugOut: true);
    } else {
      TextLogger.errorOutput(
          "Issue with a Loading process for CharacterConfigs as there is currently no configs found! Please make sure you put them within the '${Directory.current}/resources/characterConfigs/' directory!");

      directory.createSync();

      exit(0);
    }
  }

  void registerOverlayHelper(Key key, OverlayHelper helper){
    overlayMap[key] = helper;
  }

  void createAndRegisterOverlayHelper(Key key, WidgetBuilder Function(UpdateParentState, {List<dynamic>? inputs}) builder, {bool overwriteAccess = true, bool removeOnClose = false}){
    if(overlayMap.containsKey(key) && !overwriteAccess) return;

    overlayMap[key] = OverlayHelper(key, (UpdateParentState updateStateMethod, {List<dynamic>? inputs}) => OverlayEntry(builder: builder.call(updateStateMethod, inputs: inputs)), removeOnClose: removeOnClose);

  }

  OverlayHelper getOverlayHelperSafe(Key key){
    OverlayHelper helper = overlayMap[key]
        ?? OverlayHelper.emptyOverlayHelper(() => TextLogger.errorOutput("Attempting to open Overlay {} and was not found within the UIDataManager", args: [key]));

    if(helper.isAnEmptyOverlay()) {
      TextLogger.errorOutput("There was a attempt to get a Overlay with a key of {} but instead a empty overlay was given since it wasn't found.", args: [key]);
    }

    return helper;
  }

  OverlayHelper? getOverlayHelper(Key key){
    return overlayMap[key];
  }

  void removeOverlayHelper(Key key){
    overlayMap.remove(key);
  }


}