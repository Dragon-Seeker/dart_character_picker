import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';

import '../common/data/thing.dart';
import '../common/data/users.dart';
import '../common/util/string_utils.dart';
import 'cli_main.dart';

import 'commands.dart';
import '../common/thing_manager.dart';

class CommandLineThingManger extends ThingManager {

  CommandLineThingManger(super.name, super.dataType, super.versionInfo);

  Future<void> mainManagerThreadCl(User user) async {
    bool closeManager = false;

    TextLogger.consoleOutput("Loaded ${getDisplayName()} Character Config!");

    user.initUser(this);

    while(!closeManager){
      String usrInput = await readLine();

      try {
        bool? commandBool = await userCommandsMap[user.userName]!.run(usrInput.split(" "));

        if (commandBool != null) {
          closeManager = commandBool;
        }
      } on UsageException catch(e){
        print(e);
      }
    }
  }

  //---------------------------------------------------

  Thing? lastCachedThing;

  Future<void> pickCharacterLooped(User user, bool allowRepeats) async {
    bool quitLoop = false;

    pickCharacterCl(user, allowRepeats);
    TextLogger.consoleOutput("If you would like to exit the pick loop, type 'quit' to go back to the manager.");

    while(!quitLoop) {
      String usrInput = await readLine();

      if(isQuitProgramCommand(usrInput)) {
        quitLoop = true;
      } else {
        pickCharacterCl(user, allowRepeats);
      }
    }
  }

  void pickCharacterCl(User user, bool allowRepeats) {
    Random random = Random();

    Thing? selectedThing = pickRandomCharacter(user, random);

    if(selectedThing != null) {
      if(!allowRepeats){
        while(selectedThing == lastCachedThing && selectedThing != null){
          selectedThing = pickRandomCharacter(user, random);
        }
      }

      lastCachedThing = selectedThing;

      print("Choosing a random $dataType... Drum Roll Please!");
      print("You got: ${selectedThing!.formattedName()}");
    } else {
      TextLogger.errorOutput("It seems that a preset has no characters included with it, could be a bad filter or a empty preset.");
    }
  }

  //---------------------------------------------------

  void printCommandList(){
    print("""
    ┏━━━━━━━━━━━━━━━━━━[Picker Command List]━━━━━━━━━━━━━━━━━━━┓
    ┃  View[v]: View all data (Characters, filters, presets)   ┃
    ┃      -c : Only characters                                ┃
    ┃      -f : Only filters                                   ┃
    ┃      -p : Only presets                                   ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ┃  Pick[p]: Pick a Random Character using current settings ┃
    ┃   -p arg: using a certain preset                         ┃
    ┃   -f arg: using a certain filter                         ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ┃Filter[f]: Show active filters                            ┃
    ┃   -c arg: Create a new Filter                            ┃
    ┃   -d arg: Delete a existing filter                       ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ┃Preset[f]: Show active preset                             ┃
    ┃   -a arg: Add a filter from the current preset           ┃
    ┃   -r arg: Remove filter from the current preset          ┃
    ┃   -c arg: Create a new Preset                            ┃
    ┃   -s arg: Select a new Preset                            ┃
    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ┃  Quit[q]: Exit the Current Character Picker              ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
    """);
  }

  void printCharacterInfo(User user, {bool characterInfo = false, bool filterInfo = false, bool presetInfo = false, bool userInfoOnly = false}){
    List<Map<StringAnsiHelper, List<Named>>> dataGroups = [];

    bool outputAll = !characterInfo && !filterInfo && !presetInfo;

    if(characterInfo || outputAll && !userInfoOnly) {
      dataGroups.add({StringAnsiHelper(wrapWith("Current Available Characters", [white])!, [[white]]) : things});
    }

    if(filterInfo || outputAll) {
      Map<StringAnsiHelper, List<Named>> filterGroup = {};

      if(!userInfoOnly){
        filterGroup[StringAnsiHelper(wrapWith("Current Available Filters", [white])!, [[white]])] = filters;
      }

      if(user.filters.isNotEmpty){
        filterGroup[StringAnsiHelper(wrapWith("User Available Filters", [white])!, [[white]])] = user.filters;
      }

      if(filterGroup.isNotEmpty) {
        dataGroups.add(filterGroup);
      }
    }

    if(presetInfo || outputAll) {
      Map<StringAnsiHelper, List<Named>> presetGroup = {};

      if(!userInfoOnly){
        presetGroup[StringAnsiHelper(wrapWith("Current Available Presets", [white])!, [[white]])] = presets;
      }

      if(user.presets.isNotEmpty){
        presetGroup[StringAnsiHelper(wrapWith("User Available Presets", [white])!, [[white]])] = user.presets;
      }

      if(presetGroup.isNotEmpty) {
        dataGroups.add(presetGroup);
      }
    }

    Named.printDataBox(dataGroups);
  }
}