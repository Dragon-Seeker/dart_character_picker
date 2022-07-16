import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:io/ansi.dart';
import '../common/data/users.dart';
import '../common/util/file_ops.dart';
import '../common/util/string_utils.dart';
import 'cli_thing_manger.dart';
import '../common/thing_manager.dart';

import '../common/main_config.dart';

User commandLine = User("default", UserPerms.admin);

void main(List<String> arguments) async {
  ProgramInfoLoader.initInfoCl();
  MainConfig.initConfigCl();

  await overrideAnsiOutput(true, () async {
    var quitProgram = false;

    print(wrapWith("Character Picker by Blodhgarm (Version:${ProgramInfoLoader.getProgramVersion()})", [white]));

    initCharacterConfigsCl();

    bool reprintMainStartingInfo = true;

    while (!quitProgram) {
      if (reprintMainStartingInfo) {
        print(wrapWith("", [white]));
        print(wrapWith(
            "Please enter the name of Character Config (Type quit to leave):",
            [white]));

        for (int i = 0; i < allManagers.length; i++) {
          TextLogger.consoleOutput(allManagers[i].getDisplayName(),
              outputName: i.toString());
        }

        reprintMainStartingInfo = false;
      }

      String usrInput = await readLine();

      quitProgram = isQuitProgramCommand(usrInput);

      if (!quitProgram) {
        int? index;

        try {
          index = int.parse(usrInput);
        } on FormatException catch (e) {
          TextLogger.consoleOutput(e.toString(), debugOut: true);
        }

        CommandLineThingManger? manager;

        for (int i = 0; i < allManagers.length; i++) {
          bool isSelectedManager = false;

          if (allManagers[i].name.replaceAll("_", " ").toLowerCase() ==
              usrInput.toLowerCase()) {
            isSelectedManager = true;
          } else {
            if (index != null && index == i) {
              isSelectedManager = true;
            }
          }

          if (isSelectedManager) {
            manager = allManagers[i] as CommandLineThingManger;
          }
        }

        if (manager != null) {
          await manager.mainManagerThreadCl(commandLine);

          reprintMainStartingInfo = true;
        }
      }
    }
  });

  exit(0);
}

void initCharacterConfigsCl() {
  TextLogger.consoleOutput("Attempting to Loading Character Configs!",
      debugOut: true);

  var directory = Directory(fileDirectory + "resources/characterConfigs/");

  if (directory.existsSync()) {
    for (var file in getAllJsonFiles(directory)) {
      Map<String, dynamic> json = jsonDecode(file.readAsStringSync());

      try {
        ThingManager.parseManagerData(json, builder: (name, dataType, version) => CommandLineThingManger(name, dataType, version));
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

bool isQuitProgramCommand(String input) {
  if (input.toLowerCase() == "quit" || input.toLowerCase() == "q") {
    return true;
  } else {
    return false;
  }
}

//------------------------------------

var _stdinLines = StreamQueue(LineSplitter().bind(Utf8Decoder().bind(stdin)));

Future<String> readLine([String? query]) async {
  if (query != null) stdout.write(query);
  return _stdinLines.next;
}

//-------------------------------------


