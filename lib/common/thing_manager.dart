import 'dart:math';

import 'package:basic_utils/basic_utils.dart';

import 'data/filters.dart';
import 'data/property.dart';
import 'data/thing.dart';
import 'data/users.dart';
import 'util/string_utils.dart';

List<ThingManager> allManagers = <ThingManager>[];

class ThingManager with Filterable {

  String name;
  String dataType;
  String versionInfo;

  List<AbstractProperty> properties = [nameProperty];
  List<Thing> things = [];

  @override List<AbstractFilter> filters = [];
  @override List<Preset> presets = [];

  ThingManager(this.name, this.dataType, this.versionInfo);

  @override
  String toString() {
    return "[Manager: $name]";
  }

  //---------------------------------------------------

  Thing? pickRandomCharacter(User user, Random random) {
    List<Thing> characters;

    if(user.currentPreset != null) {
      characters = user.currentPreset!.filterCharacters(things);
    } else {
      characters = things;
    }

    if(characters.isNotEmpty) {
      return characters[random.nextInt(characters.length)];
    } else {
      return null;
    }
  }

  List<AbstractFilter> getAllFilters(User? user){
    if(user != null){
      return List.of(filters)..addAll(user.filters);
    } else {
      return filters;
    }
  }

  List<Preset> getAllPresets(User? user){
    if(user != null){
      return List.of(presets)..addAll(user.presets);
    } else {
      return presets;
    }
  }

  Preset getPreset(String presetId, {User? user}){
    return getAllPresets(user).firstWhere((element) => element.id == presetId, orElse: () => Preset.emptyPreset);
  }


  String getFormattedName() {
    return StringUtils.capitalize(name.replaceAll("_", " "));
  }

  String getDisplayName() {
    return "${getFormattedName()} ${StringUtils.capitalize(dataType)}s [Ver: $versionInfo]";
  }

  //--------------------------------------------------------------------

  static void parseManagerData(Map<String, dynamic> characterConfig, { ThingManager Function(String, String, String)? builder } ) {
    ThingManager manager = builder == null ? ThingManager(characterConfig["identifier"], characterConfig["stored_data_type"], characterConfig["version"]) : builder.call(characterConfig["identifier"], characterConfig["stored_data_type"], characterConfig["version"]);

    if(characterConfig.containsKey("properties")) {
      manager.parseProperties(characterConfig["properties"]);
    } else {
      TextLogger.consoleOutput("No new dataTypes were found within a given character config");
    }

    if(characterConfig.containsKey("data_set")) {
      manager.parseDataSet(characterConfig["data_set"]);

      if(manager.things.isNotEmpty) {
        allManagers.add(manager);
      } else {
        TextLogger.errorOutput("A character Config was found to have a empty character list, such will be skipped!");
      }
    } else {
      TextLogger.errorOutput("A character Config was found to be missing characters field, such will be skipped!");
    }

    Map<String, dynamic> filterData = characterConfig["filters"] ?? {};
    Map<String, dynamic> presetData = characterConfig["presets"] ?? {};

    manager.setupFiltersAndPresets(manager, manager.properties, filterData, presetData);
  }
  
  void parseProperties(Map<String, dynamic> embeddedProperties) {
    for(MapEntry<String, dynamic> propertyTypeEntry in embeddedProperties.entries) {
      String id = propertyTypeEntry.key;
      Map<String, dynamic> propertyTypeData = propertyTypeEntry.value;

      if(!propertyTypeData.containsKey("value_type")) {
        TextLogger.errorOutput("A propertyType has a malformed json as it was either formatted wrong or missing data_type field, Skipping DataType! [PropertyType: ${propertyTypeEntry.key}]");
      } else {
        AbstractProperty? property = (AbstractProperty.parseDataTypeMap[propertyTypeData["value_type"]] ?? (id, map) => null)(id, propertyTypeEntry.value);

        if(property == null) {
          TextLogger.errorOutput("A invalid Value Type was used for a dataType, Skipping DataType! [DataType: ${propertyTypeEntry.key}, ValueType: ${propertyTypeEntry.key}]");
        } else if(property != AbstractProperty.errorDataType) {
          properties.add(property);
        }
      }
    }
  }

  void parseDataSet(Map<String, dynamic> thingDataJson) {
    for(MapEntry<String, dynamic> thingInfo in thingDataJson.entries) {
      Thing thing = Thing.parseThing(properties, thingInfo);

      if(thing != Thing.errorCharacter){
        things.add(thing);
      }
    }
  }

}

typedef PresetManipulator<T> = void Function(User, T);

enum CustomListTypes<T> {
  filter,
  preset;

  List<T> getList(ThingManager manager, User? user){
    if(this == filter){
      return manager.getAllFilters(user) as List<T>;
    } else {
      return manager.getAllPresets(user) as List<T>;
    }
  }

  void toggleEntry(User user, T entry){
    if(this == filter){
      (entry as AbstractFilter);

      if(user.currentPreset != null){
        if(user.currentPreset!.id == Preset.unsavedPreset){
          if(!user.currentPreset!.activeFilters.contains(entry)){
            user.currentPreset!.activeFilters.add(entry);
          } else {
            user.currentPreset!.activeFilters.remove(entry);

            if(user.currentPreset!.activeFilters.isEmpty){
              user.currentPreset = null;
            }
          }
        } else {
          if(user.currentPreset!.activeFilters.contains(entry)){
            if(user.currentPreset!.activeFilters.length == 1){
              user.currentPreset = null;
            } else {
              user.currentPreset = user.currentPreset!.copyFilters()..activeFilters.remove(entry);
            }
          } else {
            user.currentPreset = user.currentPreset!.copyFilters([entry]);
          }
        }
      } else {
        user.currentPreset = Preset(Preset.unsavedPreset, [entry]);
      }
    } else {
      (entry as Preset);

      if(user.currentPreset == entry){
        user.currentPreset = null;
      } else {
        user.currentPreset = entry;
      }
    }
  }
}

abstract class Filterable {

  List<AbstractFilter> get filters;

  List<Preset> get presets;

  void parseFilterData(List<AbstractProperty> properties, Map<String, dynamic> filtersJson) {
    for(MapEntry<String, dynamic> filterEntry in filtersJson.entries) {
      String id = filterEntry.key;
      Map<String, dynamic> filterData = filterEntry.value;

      if(!filterData.containsKey("filter_type")) {
        TextLogger.errorOutput("A filter has a malformed json as it was either formatted wrong or missing filter_type field, Skipping filter! [Filter: $id]");
      } else if(!filterData.containsKey("data_type")) {
        TextLogger.errorOutput("A filter has a malformed json as it was either formatted wrong or missing data_type field, Skipping filter! [Filter: $id]");
      } else {
        AbstractProperty dataType = properties.firstWhere((dataType) => dataType.id == filterData["data_type"], orElse: () => AbstractProperty.errorDataType);

        if (dataType != AbstractProperty.errorDataType) {

          AbstractFilter? filter = (AbstractFilter.parseFilterMap[filterData["filter_type"]] ?? (id, type, map) => null)(id, dataType, filterData);

          if (filter == null) {
            TextLogger.errorOutput("A invalid Filter Type was used in a filter, Skipping filter! [Filter: $id, FilterType: ${filterData["filter_type"]}]");
          } else if (filter != AbstractFilter.errorFilter) {
            if(this is! User){
              filter.state = OriginState.internal;
            }

            filters.add(filter);
          }
        } else {
          TextLogger.errorOutput("A filter seems to have contained a Invalid dataType not found within the Manger, Skipping filter! [Filter: $id, DataType: ${filterData["data_type"]}]");
        }
      }
    }
  }

  void parsePresets(ThingManager manager, Map<String, dynamic> presetsJson) {
    for(MapEntry<String, dynamic> presetEntry in presetsJson.entries) {
      Map<String, dynamic> presetData = presetEntry.value;

      if(presetData.containsKey("filters")) {
        bool isUser = (this is User);

        Preset preset = Preset.parsePreset(presetEntry.key, presetData["filters"], manager, (isUser ? this as User : null));

        if(preset.activeFilters.isNotEmpty) {
          if(!isUser){
            preset.state = OriginState.internal;
          }

          presets.add(preset);
        } else {
          TextLogger.errorOutput("A preset either was had a empty filters field or had troubles loading them, such will be skipped by the manger! [Preset: ${presetEntry.key}]");
        }
      } else {
        TextLogger.errorOutput("A preset doesn't seem to contain a filters field, such will be skipped by the manger! [Preset: ${presetEntry.key}]");
      }
    }
  }

  void setupFiltersAndPresets(ThingManager manager, List<AbstractProperty> properties, Map<String, dynamic> filterData, Map<String, dynamic> presetData) {
    if(filterData.isNotEmpty) {
      parseFilterData(properties, filterData);
    } else {
      TextLogger.consoleOutput("Seems that a Empty filterData was attempted to be parsed for ${toString()}", debugOut: true);
    }

    if(presetData.isNotEmpty) {
      parsePresets(manager, presetData);
    } else {
      TextLogger.consoleOutput("Seems that a Empty presetData was attempted to be parsed for ${toString()}", debugOut: true);
    }
  }
}

