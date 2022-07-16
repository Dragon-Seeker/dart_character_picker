import 'dart:io';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';

import 'package:io/ansi.dart';

import '../main_config.dart';

class TextLogger{

  static bool disableAnsiOutput = false;

  static void errorOutput(String output, {bool debugOut = false}){
    consoleOutput(output, outputName: "Error", nameAnsiCodes: [red], outputAnsiCodes: [red], debugOut: debugOut);
  }

  static void warningOutput(String output, {bool debugOut = false}){
    consoleOutput(output, outputName: "Warning", nameAnsiCodes: [yellow], debugOut: debugOut);
  }

  static void consoleOutput(String output, {String outputName = "Info", Iterable<AnsiCode> nameAnsiCodes = const[white], Iterable<AnsiCode> outputAnsiCodes = const[white], bool debugOut = false}){
    if(debugOut && !MainConfig.debugOutputEnabled()) {
      return;
    }

    String stringOutput = webSafeConsoleOut("[", [lightBlue]) + (debugOut ? webSafeConsoleOut("Debug", [styleBold, ...nameAnsiCodes]) + " " : "") + webSafeConsoleOut(outputName, nameAnsiCodes.toList()) + webSafeConsoleOut("]: ", [lightBlue]) + webSafeConsoleOut(output, outputAnsiCodes.toList());

    print(stringOutput);
  }

  static String webSafeConsoleOut(String string, List<AnsiCode> ansiCodes){
    if(disableAnsiOutput){
      return string;
    } else {
      return wrapWith(string, ansiCodes)!;
    }
  }
}

abstract class Named {

  static String arrowOutput = "    ┗━> ";

  static Map<String, String> boxChars = {
    "upper_left_corner" : "┏",
    "upper_right_corner" :  "┓",
    "bottom_left_corner" :  "┗",
    "bottom_right_corner" :  "┛",
    "upward_line" :  "━",
    "side_line" :  "┃",
    "side_line_left" :  "┣",
    "side_line_right" :  "┫"
  };

  //-------------------------------------------

  String getName();

  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0});

  //-------------------------------------------

  String getFormattedName(){
    return StringUtils.capitalize(getName().replaceAll("_", " "), allWords: true);
  }

  static List<StringAnsiHelper> createAnsiHelperList(List<Named> namedList, {bool debugInfo = false}){
    List<StringAnsiHelper> lines = [];

    for(int i = 0; i < namedList.length; i++){
      Named namedObject = namedList[i];

      List<StringAnsiHelper> extraDataList = namedObject.getExtraFormattedData();

      String lineChar = extraDataList.isNotEmpty ? "┳" : "━";

      lines.add(StringAnsiHelper(wrapWith("[#]━$lineChar> ", [blue])! +
          wrapWith("Name: ", [white])! +
          wrapWith((debugInfo ? namedObject.getName() : namedObject.getFormattedName()), [styleBold, lightGreen])!,
          [[blue], [white], [styleBold, lightGreen]]));

      lines.addAll(extraDataList);
    }
    return lines;
  }

  static void printSingleDataBox(String title, List<Named> data){
    Named.printDataBox([{StringAnsiHelper(wrapWith(title, [white])!, [[white]]) : data}]);
  }

  static void printDataBox(List<Map<StringAnsiHelper, List<Named>>> dataGroups, {bool debugInfo = false}){
    for(Map<StringAnsiHelper, List<Named>> dataGroup in dataGroups) {
      List<MapEntry<StringAnsiHelper, List<Named>>> dataEntries = dataGroup.entries.toList();

      List<StringAnsiHelper> formattedLines = [];
      List<int> indexCutoffValues = [];

      for (var mapEntry in dataEntries) {
        formattedLines.addAll(createAnsiHelperList(mapEntry.value));

        indexCutoffValues.add(formattedLines.length);
      }

      int maxLineLength = StringAnsiHelper.getMaxStringLength(formattedLines);

      int pastIndexCutoff = 0;

      for(int i = 0; i < indexCutoffValues.length; i++) {
        int currentIndexCutoff = indexCutoffValues[i];

        StringAnsiHelper titleString = dataEntries[i].key;

        double upwardLineCount = (maxLineLength - titleString.getLengthWithoutAnsi()) / 2;

        print(wrapWith((i == 0 ? boxChars["upper_left_corner"]! : boxChars["side_line_left"]!) +
            getUpwardLines(upwardLineCount.floor()) + "[", [blue])! +
            titleString.outputString +
            wrapWith("]" + getUpwardLines(upwardLineCount.ceil()) +
            (i == 0 ? boxChars["upper_right_corner"]! : boxChars["side_line_right"]!), [blue])!);

        for (int lineCount = pastIndexCutoff; lineCount < currentIndexCutoff; lineCount++) {
          print(wrapWith(boxChars["side_line"]!, [blue])! + " " +
              formattedLines[lineCount].toString().padRight(maxLineLength + formattedLines[lineCount].getAnsiLength()) + " " +
              wrapWith(boxChars["side_line"]!, [blue])!);
        }

        pastIndexCutoff = currentIndexCutoff;
      }

      print(wrapWith(boxChars["bottom_left_corner"]! +
          getUpwardLines(maxLineLength + 2) +
          boxChars["bottom_right_corner"]!, [blue])!);
    }
  }

  static String getUpwardLines(int amount){
    return boxChars["upward_line"]! * amount;
  }
}

class StringAnsiHelper {

  List<String> includedAnsiSequences = [];

  String outputString;

  StringAnsiHelper(this.outputString, [List<List<AnsiCode>> ansiCodeSequences = const[]]){
    addAnsiCodes(ansiCodeSequences);
  }

  static StringAnsiHelper ofArrow(String string, [List<List<AnsiCode>> ansiCodeSequences = const[]]){
    return StringAnsiHelper(wrapWith(Named.arrowOutput, [blue])! + string, [[blue], ...ansiCodeSequences]);
  }

  //------------------------

  void addBefore(String string, [List<List<AnsiCode>> ansiCodeSequences = const[]]) {
    outputString = string + outputString;

    addAnsiCodes(ansiCodeSequences);
  }

  void addAfter(String string, [List<List<AnsiCode>> ansiCodeSequences = const[]]) {
    outputString += string;

    addAnsiCodes(ansiCodeSequences);
  }

  void addAnsiCodes(List<List<AnsiCode>> ansiCodeSequences){
    for(var ansiCodes in ansiCodeSequences){
      includedAnsiSequences.add(wrapWith("1", ansiCodes)!);
    }
  }

  //------------------------

  int getAnsiLength(){
    int totalAnsiCharacters = 0;

    for (var stringSequence in includedAnsiSequences) {
      totalAnsiCharacters += stringSequence.length - 1;
    }

    return totalAnsiCharacters;
  }

  int getLengthWithoutAnsi(){
    return outputString.length - getAnsiLength();
  }

  static int getMaxStringLength(List<StringAnsiHelper> lines){
    int maxLineLength = 0;

    for (var line in lines) {
      maxLineLength = max(maxLineLength, line.getLengthWithoutAnsi());
    }

    return maxLineLength;
  }

  //--------------------

  @override
  String toString() {
    return outputString;
  }
}

class NamedImpl with Named{

  String name;

  NamedImpl(this.name);

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [];
  }

  @override
  String getName() {
    return name;
  }

  static void printSingleDataBox(String title, List<String> data){
    Named.printDataBox([{StringAnsiHelper(wrapWith(title, [white])!, [[white]]) : data.map((string) => NamedImpl(string)).toList()}]);
  }

}

class Pair<K, V>{
  K left;
  V right;

  Pair(this.left, this.right);
}

