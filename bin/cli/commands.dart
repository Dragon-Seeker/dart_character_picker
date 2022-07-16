import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:io/ansi.dart';

import 'cli_main.dart';

import '../common/util/string_utils.dart';
import '../common/data/filters.dart';
import '../common/data/property.dart';
import '../common/data/thing.dart';
import '../common/data/users.dart';
import 'cli_thing_manger.dart';

CommandRunner<bool> commandRunner = CommandRunner<bool>("", "");

Map<String, CommandRunner> userCommandsMap = {};

initUserCommands(User user){
  CommandRunner userCommands = CommandRunner<bool>("", "");

  userCommands.addCommand(QuitCommand());

  userCommands.addCommand(ViewCommand(user));

  userCommands.addCommand(PresetCommand()
    ..addSubcommand(ViewActivePresetCommand(user))
    ..addSubcommand(PresetSelectCommand(user))
    ..addSubcommand(PresetCreateCommand(user))
    ..addSubcommand(PresetDeleteCommand(user))
  );

  userCommands.addCommand(FilterCommand()
      ..addSubcommand(ViewActiveFilterCommand(user))
      ..addSubcommand(FilterAddCommand(user))
      ..addSubcommand(FilterRemoveCommand(user))
      ..addSubcommand(FilterCreateCommand(user))
      ..addSubcommand(FilterDeleteCommand(user))
  );

  userCommands.addCommand(PickCommand(user));

  if(user.perms == UserPerms.admin){

  }

  userCommandsMap[user.userName] = userCommands;
}

class PickCommand extends Command<bool> {

  User user;

  PickCommand(this.user) {
    argParser.addFlag("allow-repeats", abbr: "a", negatable: false, help: "Prevents the same character from appearing again");
  }

  @override String get description => "Used to pick a character at random based off the current preset";
  @override String get name => "pick";

  @override
  FutureOr<bool> run() async {
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    await manager.pickCharacterLooped(user, argResults!.wasParsed("allow-repeats"));

    manager.lastCachedThing = null;

    return false;
  }
}

//---------------------------------------------------------------

class FilterCommand extends Command<bool> {
  @override String get description => "Used to interact with filters";
  @override String get name => "filter";
}

class ViewActiveFilterCommand extends Command<bool> {

  User user;

  ViewActiveFilterCommand(this.user);

  @override String get description => "Used to view the active filters";
  @override String get name => "view";

  @override
  FutureOr<bool> run() {
    if(user.currentPreset != null && user.currentPreset!.activeFilters.isNotEmpty) {
      TextLogger.consoleOutput("Currently Active filters are ${user.currentPreset!.activeFilters}");
    } else {
      TextLogger.consoleOutput("There isn't any active filters.");
    }

    return false;
  }
}

class FilterAddCommand extends Command<bool> {

  User user;

  FilterAddCommand(this.user);

  @override String get description => "Used to add a filter to the active Preset";
  @override String get name => "add";

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    user.currentPreset ??= Preset(Preset.unsavedPreset, [])..state = OriginState.unsaved;

    if(user.currentPreset!.state != OriginState.internal){
      bool quitLoop = false;

      String filterId = "";

      if(args.rest.isNotEmpty && args.rest.join().trim().isNotEmpty){
        filterId = args.rest.join("_").toLowerCase();
      } else {
        manager.printCharacterInfo(user, filterInfo: true);
      }

      stdout.write(wrapWith("Enter a name for filter you want to add: ", [white]));

      if(filterId != "" && filterId.isNotEmpty){
        stdout.writeln(wrapWith(args.rest.join(" "), [green]));
      }

      AbstractFilter? addedFilter;

      while(!quitLoop){
        bool emptyName = false;

        if(filterId.trim().isNotEmpty) {
          for (AbstractFilter filter in manager.getAllFilters(user)) {
            if (filter.id == filterId) {
              addedFilter = filter;
            }
          }
        } else {
          emptyName = true;
        }

        if(addedFilter != null) {
          quitLoop = true;
        } else {
          if(!emptyName) {
            stdout.write(wrapWith("It seems that Filter name doesn't exist, please enter a valid name: ", [white]));
          }

          filterId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

          if(isQuitProgramCommand(filterId)){
            return false;
          }
        }
      }

      if(!user.currentPreset!.activeFilters.contains(addedFilter)){
        user.currentPreset!.activeFilters.add(addedFilter!);
        user.savePresets(manager);

        TextLogger.consoleOutput("Added Filter to current Preset!");

        if(user.currentPreset!.state == OriginState.unsaved){
          TextLogger.warningOutput("If you want to keep this current preset, you will need to save it before closing using the 'preset create' command!");
        }

      } else {
        TextLogger.warningOutput("The given Filter already exists in the current Preset!");
      }

    } else {
      TextLogger.warningOutput("You can't modify internal Presets!");
    }

    return false;
  }
}

class FilterRemoveCommand extends Command<bool> {

  User user;

  FilterRemoveCommand(this.user);

  @override String get description => "Used to remove a filter from the active Preset";
  @override String get name => "remove";

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]!;

    if(user.currentPreset != null) {
      if(user.currentPreset!.state != OriginState.internal){
        bool quitLoop = false;

        String filterId = "";

        if(args.rest.isNotEmpty && args.rest.join().trim().isNotEmpty){
          filterId = args.rest.join("_").toLowerCase();
        } else {
          Named.printSingleDataBox("Currently Active Filters", user.currentPreset!.activeFilters);
        }

        stdout.write(wrapWith("Enter a name for filter you want to remove: ", [white]));

        if(filterId != ""){
          stdout.writeln(wrapWith(args.rest.join(" "), [green]));
        }

        AbstractFilter? removedFilter;

        while(!quitLoop){
          bool emptyName = false;

          if(filterId.trim().isNotEmpty) {
            for(AbstractFilter filter in user.currentPreset!.activeFilters){
              if(filter.id == filterId){
                removedFilter = filter;
              }
            }
          } else {
            emptyName = true;
          }

          if(removedFilter != null) {
            quitLoop = true;
          } else {
            if(!emptyName) {
              stdout.write(wrapWith("It seems that Filter name doesn't exist, please enter a valid name: ", [white]));
            }

            filterId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

            if(isQuitProgramCommand(filterId)){
              return false;
            }
          }
        }

        user.currentPreset!.activeFilters.remove(removedFilter!);
        user.savePresets(manager);

        TextLogger.consoleOutput("Remove Filter to current Preset!");

        if(user.currentPreset!.state == OriginState.unsaved){
          TextLogger.warningOutput("If you want to keep this current preset, you will need to save it before closing using the 'preset create' command!");
        }
      } else {
        TextLogger.warningOutput("You can't modify internal Presets!");
      }
    } else {
      TextLogger.consoleOutput("There isn't any active filters to remove.");
    }

    return false;
  }
}

class FilterDeleteCommand extends Command<bool> {

  User user;

  FilterDeleteCommand(this.user);

  @override String get description => "Delete a given User filter";
  @override String get name => "delete";

  @override List<String> get aliases => ["d"];

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    bool quitLoop = false;

    String filterId = "";

    if(args.rest.isNotEmpty && args.rest.join().trim().isNotEmpty){
      filterId = args.rest.join("_").toLowerCase();
    }else {
      manager.printCharacterInfo(user, filterInfo: true, userInfoOnly: true);
    }

    stdout.write(wrapWith("Enter a name for filter you want to delete: ", [white]));

    if(filterId != ""){
      stdout.writeln(wrapWith(args.rest.join(" "), [green]));
    }

    bool internalPresetDeletionAttempted = false;

    while(!quitLoop){
      bool emptyName = false;
      bool validPresetName = false;

      if(filterId.trim().isNotEmpty) {
        for (AbstractFilter filter in manager.getAllFilters(user)) {
          if (filter.id == filterId) {
            validPresetName = true;

            internalPresetDeletionAttempted = filter.state == OriginState.internal;

            break;
          }
        }
      } else {
        emptyName = true;
      }

      if(validPresetName) {
        quitLoop = true;
      } else {
        if(!emptyName) {
          stdout.write(wrapWith("It seems that Filter name dose not exists, please enter a valid name: ", [white]));
        }

        filterId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(isQuitProgramCommand(filterId)){
          return false;
        }
      }
    }

    if(!internalPresetDeletionAttempted) {
      quitLoop = false;

      print(wrapWith("Are you sure you want to delete [${StringUtils.capitalize(filterId.replaceAll(" ", "_"), allWords: true)}] (Yes or No)? ", [white]));

      bool deletePreset = false;

      while (!quitLoop) {
        String usrInput = (await readLine()).toLowerCase();

        if (usrInput == "yes" || usrInput == "y") {
          deletePreset = true;

          quitLoop = true;

          TextLogger.consoleOutput("Removed ${StringUtils.capitalize(filterId.replaceAll(" ", "_"), allWords: true)} from ${user.userName}.");
        } else if (usrInput == "no" || usrInput == "n") {
          quitLoop = true;
        }
      }

      if (deletePreset) {
        user.filters.removeWhere((filter) => filter.id == filterId);
        user.saveFilters(manager);
      }
    } else {
      TextLogger.warningOutput("You can't delete Internal Filter, only user created ones!");
    }

    return false;
  }
}

enum FilterType {
  singleValue,
  multiValue,
  numberRange
}

class FilterCreateCommand extends Command<bool> {

  User user;

  FilterCreateCommand(this.user);

  @override String get description => "Used to create a new user preset";
  @override String get name => "create";

  @override List<String> get aliases => ["c"];

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]!;

    bool quitLoop = false;

    //----------------------------[Get Filter ID from user]----------------------------

    String filterId = "";

    stdout.write(wrapWith("Enter a name for filter you want to create: ", [white]));

    if(args.rest.isNotEmpty && args.rest.join().trim().isNotEmpty && !isQuitProgramCommand(args.rest.join())){
      filterId = args.rest.join("_").toLowerCase();

      if(filterId != "") {
        stdout.writeln(wrapWith(args.rest.join(" "), [green]));
      }
    }

    while(!quitLoop){
      bool validFilterName = true;
      bool emptyInput = false;

      if(filterId.trim().isNotEmpty) {
        for (AbstractFilter filter in manager.getAllFilters(user)) {
          if (filter.id == filterId) {
            validFilterName = false;
          }
        }
      } else {
        emptyInput = true;
      }

      if(!validFilterName || emptyInput) {
        if(!emptyInput) {
          stdout.write(wrapWith("It seems that Filter name has been taken already, please enter a different name: ", [white]));
        }

        filterId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(isQuitProgramCommand(filterId)){
          return false;
        }
      } else {
        quitLoop = true;
      }
    }

    quitLoop = false;

    //----------------------------[Get Property for the Filter from user]----------------------------

    Named.printSingleDataBox("Available Properties", manager.properties);

    stdout.write(wrapWith("Enter the name of the given property you want this filter to apply too: ", [white]));

    AbstractProperty? selectedProperty;

    while (!quitLoop) {
      String propertyName = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

      if(isQuitProgramCommand(propertyName)){
        return false;
      }

      for (AbstractProperty property in manager.properties) {
        if (property.id == propertyName) {
          selectedProperty = property;

          quitLoop = true;

          break;
        }
      }

      if (selectedProperty == null) {
        stdout.write(wrapWith("It seems that Property name isn't valid, please re-enter a valid name: ", [white]));
      }
    }

    quitLoop = false;

    //----------------------------[Get Filter Type from user]----------------------------

    Map<String, FilterType> availableFilterTypes = {};

    availableFilterTypes["single_value"] = FilterType.singleValue;
    availableFilterTypes["multi_value"] = FilterType.multiValue;

    if(selectedProperty!.type == int || selectedProperty.type == double){
      availableFilterTypes["number_range"] = FilterType.numberRange;
    }

    NamedImpl.printSingleDataBox("Available Filter Types", availableFilterTypes.keys.toList());

    stdout.write(wrapWith("Enter the filter type you want to use: ", [white]));

    FilterType? filterType;

    while (!quitLoop) {
      String filterTypeId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

      if(isQuitProgramCommand(filterTypeId)){
        return false;
      }

      if(availableFilterTypes.containsKey(filterTypeId)){
        filterType = availableFilterTypes[filterTypeId];

        quitLoop = true;
      } else {
        stdout.write(wrapWith("It seems that Filter Type isn't valid, please re-enter a valid type: ", [white]));
      }
    }

    quitLoop = false;

    //----------------------------[Get Values that will be filtered from user]----------------------------

    Map<String, dynamic> thingPropertyValues = {};

    for (var thing in manager.things) {
      String propertyValueString = thing.properties[selectedProperty].toString();

      if(selectedProperty == nameProperty) {
        propertyValueString = propertyValueString.toLowerCase().replaceAll(" ", "_");
      }

      if(!thingPropertyValues.containsKey(propertyValueString)){
        thingPropertyValues[propertyValueString] = thing.properties[selectedProperty];
      }
    }

    NamedImpl.printSingleDataBox("Available Values", thingPropertyValues.keys.toList());

    AbstractFilter? filter;

    if(filterType == FilterType.singleValue) {

      stdout.write(wrapWith("Enter the filter value you want to use: ", [white]));

      dynamic propertyValue;

      while (!quitLoop) {

        String usrInput = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(isQuitProgramCommand(usrInput)){
          return false;
        }

        if(thingPropertyValues.containsKey(usrInput)){
          propertyValue = thingPropertyValues[usrInput];

          quitLoop = true;
        } else {
          stdout.write(wrapWith("It seems that value isn't valid, please re-enter a valid value: ", [white]));
        }
      }

      filter = SingleValueFilter(filterId, selectedProperty, propertyValue);

    } else if(filterType == FilterType.multiValue) {

      stdout.write(wrapWith("Enter the filter value you want to use (Type 'done' when finished): ", [white]));

      List<dynamic> propertyValues = [];

      while (!quitLoop) {

        String usrInput = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(usrInput == "done" || usrInput == "d"){
          quitLoop = true;
        } else {
          if (isQuitProgramCommand(usrInput)) {
            return false;
          }

          if (thingPropertyValues.containsKey(usrInput)) {
            propertyValues.add(thingPropertyValues[usrInput]);

            quitLoop = true;
          } else {
            stdout.write(wrapWith("It seems that value isn't valid, please re-enter a valid value: ", [white]));
          }
        }
      }

      filter = MultipleValueFilter(filterId, selectedProperty, propertyValues);

    } else {

      stdout.write(wrapWith("Enter the min starting range for the filter: ", [white]));

      (selectedProperty as NumberProperty);

      dynamic minValue;

      while (!quitLoop) {
        String usrInput = await readLine();

        if(isQuitProgramCommand(usrInput)){
          return false;
        }

        if(selectedProperty.validStringNum(usrInput)) {
          if (selectedProperty.type == int) {
            minValue = int.parse(usrInput);
          } else {
            minValue = double.parse(usrInput);
          }

          quitLoop = true;
        } else {
          stdout.write(wrapWith("It seems that value isn't in the given Property Range valid, please re-enter a valid value: ", [white]));
        }
      }

      dynamic maxValue;

      while (!quitLoop) {
        String usrInput = await readLine();

        if(isQuitProgramCommand(usrInput)){
          return false;
        }

        if(selectedProperty.validStringNum(usrInput)) {
          if (selectedProperty.type == int) {
            maxValue = int.parse(usrInput);
          } else {
            maxValue = double.parse(usrInput);
          }
        }


        if(maxValue != null){
          if(maxValue > minValue) {
            quitLoop = true;
          } else {
            stdout.write(wrapWith("It seems that value isn't above the previous minimum value, please re-enter a higher value: ", [white]));
          }
        } else {
          stdout.write(wrapWith("It seems that value isn't in the given Property Range valid, please re-enter a valid value: ", [white]));
        }
      }

      filter = NumberRangeFilter(filterId, selectedProperty, minValue, maxValue);
    }

    user.addFilter(filter);
    user.saveFilters(manager);

    return false;
  }
}

//---------------------------------------------------------------

class PresetCommand extends Command<bool> {
  @override String get description => "Used to interact with presets";
  @override String get name => "preset";
}

class ViewActivePresetCommand extends Command<bool> {

  User user;

  ViewActivePresetCommand(this.user);

  @override String get description => "Used to view the current preset";
  @override String get name => "view";

  @override
  FutureOr<bool> run() {
    if(user.currentPreset != null) {
      TextLogger.consoleOutput("Currently Selected Preset is " + wrapWith(user.currentPreset!.getFormattedName(), [green])!);
    } else {
      TextLogger.consoleOutput("There isn't any active preset.");
    }

    return false;
  }
}

class PresetSelectCommand extends Command<bool> {

  User user;

  PresetSelectCommand(this.user);

  @override String get description => "Used to select a preset";
  @override String get name => "select";

  @override List<String> get aliases => ["s"];

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    bool foundPreset = false;

    String presetId = "";

    if(args.rest.isNotEmpty && args.rest.join().trim().isNotEmpty){
      if(!isQuitProgramCommand(args.rest.join())) {
        presetId = args.rest.join("_").toLowerCase();
      }
    } else {
      manager.printCharacterInfo(user, presetInfo: true);
    }

    stdout.write(wrapWith("Enter a name for a preset you want to use: ", [white]));

    if(presetId != ""){
      stdout.writeln(wrapWith(args.rest.join(" "), [green]));
    }

    bool quitLoop = false;

    while(!quitLoop) {
      bool emptyInput = false;

      if(presetId.trim().isNotEmpty) {
        for (var preset in manager.getAllPresets(user)) {
          if (preset.id == presetId) {
            user.currentPreset = preset;
            foundPreset = true;

            break;
          }
        }
      } else {
        emptyInput = true;
      }

      if(!foundPreset){
        if(!emptyInput) {
          stdout.write(wrapWith("It seems that Preset name doesn't exist, please enter a valid name: ", [white]));
        }

        presetId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(isQuitProgramCommand(presetId)){
          return false;
        }
      } else {
        quitLoop = true;
      }
    }

    TextLogger.consoleOutput("Preset ${user.currentPreset!.getFormattedName()} has been selected.");

    return false;
  }
}

class PresetCreateCommand extends Command<bool> {

  User user;

  PresetCreateCommand(this.user);

  @override String get description => "Used to create a new user preset";
  @override String get name => "create";

  @override List<String> get aliases => ["c"];

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    bool quitLoop = false;

    String presetId = "";

    stdout.write(wrapWith("Enter a name for preset you want to create: ", [white]));

    if(args.rest.isNotEmpty && !isQuitProgramCommand(args.rest.join())){
      presetId = args.rest.join("_").toLowerCase();

      stdout.writeln(wrapWith(args.rest.join(" "), [green]));
    }

    while(!quitLoop){
      bool validPresetName = true;

      for(Preset preset in manager.getAllPresets(user)){
        if(preset.id == presetId){
          validPresetName = false;
        }
      }

      if(validPresetName) {
        quitLoop = true;
      } else {
        stdout.write(wrapWith("It seems that Preset name has been taken already, please enter a different name: ", [white]));

        presetId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(isQuitProgramCommand(presetId)){
          return false;
        }
      }
    }

    List<AbstractFilter> filters = [];

    if(user.currentPreset != null && user.currentPreset!.id == Preset.unsavedPreset) {
      filters = user.currentPreset!.activeFilters;
    } else {
      quitLoop = false;

      manager.printCharacterInfo(user, filterInfo: true);

      stdout.write(wrapWith("Enter the name of the given filter you want to add (Type 'done' when finished): ", [white]));

      while (!quitLoop) {
        String filterName = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if (filterName == "done" || filterName == "d") {
          quitLoop = true;

          continue;
        }

        AbstractFilter? selectedFilter;

        for (AbstractFilter filter in manager.getAllFilters(user)) {
          if (filter.id == filterName) {
            selectedFilter = filter;

            break;
          }
        }

        if (selectedFilter == null) {
          stdout.write(wrapWith("It seems that Filter name isn't valid, please re-enter a valid name: ", [white]));
        } else {
          TextLogger.consoleOutput("Filter Added!");
          filters.add(selectedFilter);
        }
      }
    }

    user.currentPreset = user.createPreset(presetId, filters);
    user.savePresets(manager);

    return false;
  }
}

class PresetDeleteCommand extends Command<bool> {

  User user;

  PresetDeleteCommand(this.user);

  @override String get description => "Delete a given User preset";
  @override String get name => "delete";

  @override List<String> get aliases => ["d"];

  @override
  FutureOr<bool> run() async {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    bool quitLoop = false;

    String presetId = "";

    manager.printCharacterInfo(user, presetInfo: true, userInfoOnly: true);

    stdout.write(wrapWith("Enter a name for preset you want to delete: ", [white]));

    if(args.rest.isNotEmpty){
      presetId = args.rest.join("_").toLowerCase();

      stdout.writeln(wrapWith(args.rest.join(" "), [green]));
    }

    bool internalPresetDeletionAttempted = false;

    while(!quitLoop){
      bool validPresetName = false;

      for(Preset preset in manager.getAllPresets(user)){
        if(preset.id == presetId){
          validPresetName = true;
        }

        if(preset.state == OriginState.internal){
          internalPresetDeletionAttempted = true;
        }
      }

      if(validPresetName) {
        quitLoop = true;
      } else {
        stdout.write(wrapWith("It seems that Preset name dose not exists, please enter a different name: ", [white]));

        presetId = (await readLine()).replaceAll(" ", "_").toLowerCase().trim();

        if(isQuitProgramCommand(presetId)){
          return false;
        }
      }
    }

    if(!internalPresetDeletionAttempted) {
      quitLoop = false;

      print(wrapWith("Are you sure you want to delete [${StringUtils.capitalize(presetId.replaceAll(" ", "_"), allWords: true)}] (Yes or No)? ", [white]));

      bool deletePreset = false;

      while (!quitLoop) {
        String usrInput = (await readLine()).toLowerCase();

        if (usrInput == "yes" || usrInput == "y") {
          deletePreset = true;

          quitLoop = true;

          TextLogger.consoleOutput("Removed ${StringUtils.capitalize(presetId.replaceAll(" ", "_"), allWords: true)} from ${user.userName}.");
        } else if (usrInput == "no" || usrInput == "n") {
          quitLoop = true;
        }
      }

      if (deletePreset) {
        user.presets.removeWhere((preset) => preset.id == presetId);
        user.savePresets(manager);
      }
    } else {
      TextLogger.warningOutput("You can't delete Internal Presets, only user created ones!");
    }

    return false;
  }
}

//---------------------------------------------------------------

class ViewCommand extends Command<bool> {

  User user;

  ViewCommand(this.user) {
    argParser.addFlag("characters", abbr: "c", negatable: false, help: "Show Characters");
    argParser.addFlag("filters", abbr: "f", negatable: false, help: "Show Filters");
    argParser.addFlag("presets", abbr: "p", negatable: false, help: "Show presets");
  }

  @override String get description => "View all data (Characters, filters, presets)";
  @override String get name => "view";

  @override
  FutureOr<bool> run() {
    var args = argResults!;
    var manager = User.usersActiveManagers[user]! as CommandLineThingManger;

    manager.printCharacterInfo(user, characterInfo: args.wasParsed("characters"), filterInfo: args.wasParsed("filters"), presetInfo: args.wasParsed("presets"));

    return false;
  }
}

class QuitCommand extends Command<bool> {

  @override String get description => "Exit the Current Character Picker";
  @override String get name => "quit";

  @override List<String> get aliases => ["q"];

  @override
  FutureOr<bool> run() {
    return true;
  }
}
