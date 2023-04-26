
import 'dart:collection';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:io/ansi.dart';

import '../util/string_utils.dart';
import 'property.dart';

StringProperty nameProperty = StringProperty("name");

class Thing extends Named {

  static Thing errorCharacter = Thing("error");

  Map<AbstractProperty, dynamic> properties = {};

  Thing(String name){
    properties[nameProperty] = name;
  }

  @override
  String getName(){
    return properties[nameProperty];
  }

  static Thing parseThing(List<AbstractProperty> dataTypes, MapEntry<String, dynamic> characterInfo){
    Thing character = Thing(characterInfo.key);
    Map<String, dynamic> extraData = characterInfo.value;

    bool validCharacter = true;

    if(extraData.isEmpty && dataTypes.length > 1) {
      TextLogger.errorOutput("A character was found to be missing data based on the given dataTypes, such will be skipped! [Name: ${character.getName()}]");

      validCharacter = false;
    } else if(extraData.isNotEmpty && dataTypes.length == 1) {
      TextLogger.warningOutput("A character was found have extra data and such data will be not be added! [Name: ${character.getName()}]");
    } else {
      for(AbstractProperty abstractDataType in dataTypes){
        if(abstractDataType == nameProperty){
          continue;
        }

        if(extraData.containsKey(abstractDataType.id)) {
          dynamic propertyValue = extraData[abstractDataType.id];

          abstractDataType.evaluateLength(propertyValue.toString());

          character.properties[abstractDataType] = propertyValue;
        } else {
          TextLogger.errorOutput("It seems that there is a malformed Character Entry without the need CharacterData: [CharacterEntry: $characterInfo, FailedDataType: $abstractDataType ]");

          validCharacter = false;

          break;
        }
      }
    }

    if(validCharacter) {
      return character;
    } else {
      return errorCharacter;
    }
  }

  Map<AbstractProperty, dynamic> getExtraData(){
    return Map.of(properties)..remove(nameProperty);
  }

  Map<String, String> getExtraStringData(){
    return Map.of(properties).map((key, value) {
      return MapEntry(key.id, value.toString());
    });
  }

  //----------------------------------------------------------

  @override
  String toString() {
    StringBuffer buffer = StringBuffer()..write("[Name: $getName()]");

    buffer.write(mapToString(getExtraData(), true));

    return buffer.toString();
  }

  static String mapToString(Map<dynamic, dynamic> entryMap, [bool newLineAfterEachEntry = false]){
    StringBuffer buffer = StringBuffer();

    if(newLineAfterEachEntry){
      buffer.write("\n");
    }

    Iterable iterable = entryMap.entries;
    int i = 0;

    for(MapEntry<dynamic, dynamic> mapEntry in iterable) {
      buffer.write("[Name: ${mapEntry.key.toString()}, Value: ${mapEntry.value.toString()}]");

      if(i < iterable.length - 1){
        buffer.write(", ");

        if(newLineAfterEachEntry){
          buffer.write("\n");
        }
      }

      i++;
    }

    return buffer.toString();
  }

  String formattedName({int characterPadding = 0}){
    return StringUtils.capitalize(getName());
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    List<StringAnsiHelper> lines = [];

    if(properties.length > 1) {
      int i = 0;
      int mapLength = getExtraData().length;

      StringAnsiHelper line = StringAnsiHelper.ofArrow("");

      for (var entry in getExtraData().entries) {
        if(debugInfo) {
          lines.add(StringAnsiHelper.ofArrow("[${entry.key.toString()}, value = ${entry.value}]"));
        } else {
          line.addAfter(
              wrapWith("[", [lightBlue])! +
                  wrapWith("${entry.key.getFormattedName()}: ", [white])! +
                  wrapWith(entry.key.getFormattedValue(entry.value).toString().padRight(entry.key.getMaxStringLength()), [lightYellow])! +
                  wrapWith("]", [lightBlue])!
          ,[[lightBlue], [white], [lightRed], [lightBlue]]);

          if (i < mapLength - 1) {
            line.addAfter(wrapWith(" / ", [lightBlue])!, [[lightBlue]]);
          }
        }

        i++;
      }

      if(line.outputString != Named.arrowOutput){
        lines.add(line);
      }
    }

    return lines;
  }
}