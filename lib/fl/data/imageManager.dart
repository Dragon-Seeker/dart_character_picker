import 'dart:convert';
import 'dart:io';

import '../../common/thing_manager.dart';
import '../../common/data/property.dart';
import '../../common/data/thing.dart';
import '../../common/util/file_ops.dart';
import '../../common/util/string_utils.dart';

List<ImageManager> allImageManagers = [];

class ImageManager {

  late String id;

  Map<Thing, ThingImageData> imageData = {};

  ImageManager(ThingManager manager) {
    id = manager.name;

    parseImageData(manager);
  }

  static ImageManager getOrCreateManager(ThingManager manager){
    return getImageManager(manager.name) ?? ImageManager(manager);
  }

  void parseImageData(ThingManager manager) {
    String filePathString = fileDirectory + getPlatformPath("resources/ui_info/${manager.name}");

    Directory directory = Directory(filePathString);

    if (directory.existsSync()) {
      Map<String, dynamic> jsonData = {};

      for (var file in getAllJsonFiles(directory)) {
        try {
          jsonData = jsonDecode(file.readAsStringSync());

          if(jsonData.isNotEmpty){
            break;
          }
        } on FormatException catch(e){}
      }

      if(jsonData.containsKey("data_set")){
        Map<String, dynamic> thingData = jsonData["data_set"];

        for(var entry in thingData.entries){
          try {
            Thing thing = manager.things.firstWhere((thing) => thing.getName() == entry.key);

            imageData[thing] = ThingImageData.parseData(filePathString, manager, entry.value, thing);
          } on StateError catch(e){}
        }
      }

      allImageManagers.add(this);
    } else {

    }
  }

  bool hasAnyImageData() {
    return imageData.isNotEmpty;
  }

  static ImageManager? getImageManager(String id){
    ImageManager? manager;

    try {
      manager = allImageManagers.firstWhere((imageManager) => imageManager.id == id);
    } on StateError catch(e) {}

    return manager;
  }

}

class ThingImageData {
  Map<AbstractProperty<dynamic>, ImageDataHolder> imageData;

  ThingImageData(this.imageData);

  bool hasImageData(AbstractProperty<dynamic> property) {
    return imageData.containsKey(property);
  }

  bool hasAnyImageData() {
    return imageData.isNotEmpty;
  }

  static ThingImageData parseData(String dirPathString, ThingManager manager, Map<String, dynamic> thingData, Thing thing){
    Map<AbstractProperty<dynamic>, ImageDataHolder> imageDataSet = {};

    if(thingData.isNotEmpty){
      for(MapEntry<String, dynamic> entry in thingData.entries){
        dynamic imagePropertyData = entry.value;

        try {
          AbstractProperty property = manager.properties.firstWhere((property) => property.getName() == entry.key);

          File imageFile;

          int color = -1;

          if(imagePropertyData is String) {
            imageFile = File(dirPathString + getPlatformPath("/images/${property.id}/$imagePropertyData"));
          } else if(imagePropertyData is Map<String, dynamic>) {
            imageFile = File(dirPathString + getPlatformPath("/images/${property.id}/${imagePropertyData["icon"]}"));

            if(imagePropertyData.containsKey("bg_color")) {
              String colorStringData = imagePropertyData["bg_color"];

              try {
                if (colorStringData.contains("#")) {
                  color = int.parse(colorStringData.replaceAll("#", ""), radix: 16);
                } else {
                  color = int.parse(colorStringData);
                }

              } on FormatException catch (e) {
                TextLogger.warningOutput("It seems there was defined color data but it wasn't able to be parsed! [Thing Id: ${thing.getName()}]", debugOut: true);
              }
            }
          } else {
            TextLogger.warningOutput("It seems there was defined image data in a invalid type data. [Thing Id: ${thing.getName()}, Image Properties: ${imagePropertyData.toString()}]]", debugOut: true);
            break;
          }

          if (imageFile.existsSync()) {
            imageDataSet[property] = ImageDataHolder(imageFile, bqColor: color);
          } else{
            TextLogger.warningOutput("A image file was not found so such data will not be saved. [Thing Id: ${thing.getName()}", debugOut: true);
          }
        } on StateError catch (e) {}
      }
    }

    return ThingImageData(imageDataSet);
  }

}

class ImageDataHolder {
  File imageFile;

  int bqColor;
  
  ImageDataHolder(this.imageFile, {this.bqColor = -1});
}
