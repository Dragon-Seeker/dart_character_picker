import 'dart:convert';
import 'dart:io';

import '../../cli/commands.dart';
import '../thing_manager.dart';
import '../util/file_ops.dart';
import '../util/string_utils.dart';
import 'filters.dart';

class User with Filterable {

  static List<User> allActiveUsers = [];
  
  static Map<User, ThingManager> usersActiveManagers = {};

  final String userName;
  final UserPerms perms;

  @override List<AbstractFilter> filters = [];
  @override List<Preset> presets = [];

  Preset? currentPreset;

  User(this.userName, this.perms);

  void initUser(ThingManager manager) {
    if(!userCommandsMap.containsKey(userName)){
      initUserCommands(this);
    }

    File filterFile = File(fileDirectory + getPlatformPath("resources/users/$userName/${manager.name}/filters.json"));
    File presetsFile = File(fileDirectory + getPlatformPath("resources/users/$userName/${manager.name}/presets.json"));

    Map<String, dynamic> filterData = {};

    if(filterFile.existsSync()) {
      try {
        filterData = jsonDecode(filterFile.readAsStringSync());
      } on FormatException catch(e){
        TextLogger.errorOutput("$userName filter file seems to be corrupted, such will be skipped");
      }
    } else {
      filterFile.createSync(recursive: true);
      filterFile.writeAsString("{\n}");

      TextLogger.consoleOutput("Creating custom filters file for $userName!", debugOut: true);
    }

    Map<String, dynamic> presetData = {};

    if(presetsFile.existsSync()) {
      try {
        presetData = jsonDecode(presetsFile.readAsStringSync());
      } on FormatException catch(e){
        TextLogger.errorOutput("$userName preset file seems to be corrupted, such will be skipped");
      }
    } else {
      presetsFile.createSync(recursive: true);
      presetsFile.writeAsString("{\n}");

      TextLogger.consoleOutput("Creating custom presets file for $userName!", debugOut: true);
    }

    setupFiltersAndPresets(manager, manager.properties, filterData, presetData);

    currentPreset = null;
    usersActiveManagers[this] = manager;
  }

  bool createPreset(String presetName, ThingManager manager, List<AbstractFilter> filters){
    if(manager.getPreset(presetName, user: this) == Preset.emptyPreset) {
      Preset userPreset = Preset(presetName, filters);

      presets.add(userPreset);

      TextLogger.consoleOutput("Created ${userPreset.getFormattedName()} for $userName!");

      return true;
    }

    return false;
  }

  Preset getUserPreset(String presetId){
    return presets.firstWhere((element) => element.id == presetId, orElse: () => Preset.emptyPreset);
  }

  void addFilter(AbstractFilter filter){
    filters.add(filter);

    TextLogger.consoleOutput("Created ${filter.getFormattedName()} for $userName!");
  }
  
  void savePresets(ThingManager manager){
    File presetsFile = File(fileDirectory + getPlatformPath("resources/users/$userName/${manager.name}/presets.json"));

    if(currentPreset != null && currentPreset!.state == OriginState.user){
      for (var preset in presets) {
        if(preset.id == currentPreset!.id){
            preset.activeFilters = currentPreset!.activeFilters;
            break;
        }
      }
    }

    if(!presetsFile.existsSync()) {
      presetsFile.createSync();
    }
    
    if(presets.isNotEmpty){
      presetsFile.writeAsStringSync(JsonEncodable.encodeJsonFancyFromList(presets));
    } else {
      presetsFile.writeAsStringSync("{}");
    }
  }

  void saveFilters(ThingManager manager){
    File filtersFile = File(fileDirectory + getPlatformPath("resources/users/$userName/${manager.name}/filters.json"));

    if(!filtersFile.existsSync()) {
      filtersFile.createSync();
    }

    if(filters.isNotEmpty){
      filtersFile.writeAsStringSync(JsonEncodable.encodeJsonFancyFromList(filters));
    } else {
      filtersFile.writeAsStringSync("{}");
    }
  }

  bool isActiveFilterOrPreset(Named entry){
    if(currentPreset != null) {
      if (entry.getName() == currentPreset!.getName() || (currentPreset!.activeFilters.isNotEmpty && currentPreset!.activeFilters.any((filter) => entry.getName() == filter.getName()))) {
        return true;
      }
    }

    return false;
  }

  @override
  String toString() {
    return userName;
  }
}

enum UserPerms {
  admin,
  user
}