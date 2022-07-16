import 'dart:math';

import 'package:flutter/material.dart';

import '../../common/data/filters.dart';
import '../../common/data/thing.dart';
import '../../common/thing_manager.dart';
import '../../common/util/string_utils.dart';
import '../fl_main.dart';
import 'overlay_helper.dart';
import '../data/imageManager.dart';
import 'ui_data/theme_data.dart';


/// Main widget that displays all the Entry within the loaded [ThingManager]
class ThingManagerWidget extends StatefulWidget {
  ThingManagerWidget();

  @override
  State<ThingManagerWidget> createState() => ThingManagerState();

}

/// Main widget that displays all the Entry within the loaded [ThingManager]
class ThingManagerState extends State<ThingManagerWidget> with AutomaticKeepAliveClientMixin<ThingManagerWidget>{

  static List<Color> legendBackgroundColors = [];

  ThingManagerState();

  bool keepStateAlive = true;

  @override
  bool get wantKeepAlive => keepStateAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        createThingManagerWidget()
      ],
    );
  }

  ///
  /// Method that creates the main grid/list view of Entry's within the given [currentManager]
  ///
  static Widget createThingManagerWidget() {
    List<Thing> things = currentFlUser.currentPreset?.filterCharacters(currentManager!.things) ?? currentManager!.things;

    return Container(
      child: Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, crossAxisSpacing: 0, mainAxisSpacing: 0),
          //SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 1.0, mainAxisSpacing: 1.0),
          itemBuilder: (context, index) => createThingWidget(things[index], context),
          itemCount: things.length,
        ),
      ),
    );
  }

  ///
  /// Method that creates a single Widget based off of the given [currentThing]
  ///
  static Widget createThingWidget(Thing currentThing, BuildContext context) {
    ThingImageData? thingImageData;

    if(currentImageManager != null) {
      thingImageData = currentImageManager!.imageData[currentThing];
    }

    //-----------------------------------------

    /// The main text widget for the [currentThing]
    Container thingTextWidget = Container(
      child: Text(
        currentThing.getFormattedName(),
        style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? (Theme.of(context).brightness == Brightness.light ? Colors.white : null), fontWeight: FontWeight.w500),
      ),
      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: ThemeHandler.basicRadius(),
        color: ThemeHandler.checkThemeMode(context, Theme.of(context).primaryColor, Colors.black54)
      ),
    );

    //-----------------------------------------

    /// The main extra data widget for the [currentThing]
    ///
    /// Extra data is the given property's of the the current [currentThing]
    Column columnExtraData = Column(
      children: currentThing.getExtraData().entries.toList().map((entry) {
        Text textWidget = Text(
          "${entry.key.getFormattedName()} : ${entry.key.getFormattedValue(entry.value)}",
          style: TextStyle(color: ThemeHandler.getContrastedColor(context), fontWeight: FontWeight.w500),
        );

        if(thingImageData != null && thingImageData.hasImageData(entry.key)) {
          ImageDataHolder data = thingImageData.imageData[entry.key]!;

          return Row(
            children: [
              textWidget,
              Container(
                child: Image.file(data.imageFile, width: 24, height: 24),
                padding: EdgeInsets.only(left: 4.0),
              ),
            ],
          );
        }

        return textWidget;
      }).toList(),
    );

    //-----------------------------------------

    Widget mainThingWidget;

    /// If check to see if the given widget has any Icon for the entry and creates a row combined with the given [thingTextWidget] Variable
    if(thingImageData != null && thingImageData.hasImageData(nameProperty)){
      ImageDataHolder data = thingImageData.imageData[nameProperty]!;

      mainThingWidget = Row(
        children: [
          thingTextWidget,
          Container(
            child: Image.file(data.imageFile, width: 48, height: 48),
            margin: EdgeInsets.only(left: 2.0),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: ThemeHandler.basicRadius(),
              color: data.bqColor == -1 ? Colors.cyan : Color(data.bqColor).withAlpha(255)
            ),
          ),
        ],
      );
    } else {
      mainThingWidget = thingTextWidget;
    }

    //-----------------------------------------

    return Center(
      child: FittedBox(
        child: Container(
          child: Column(
            children: [
              Container(
                child: mainThingWidget,
                padding: EdgeInsets.only(bottom: 6.0),
              ),
              Container(child: columnExtraData)
            ],
          ),
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: ThemeHandler.basicRadius(),
            color: ThemeHandler.checkThemeMode(context, Colors.black26, Theme.of(context).primaryColor.withAlpha(150))
          )
        ),
      ),
    );
  }
}

//---------------------------------------------------------------------------------------------

/// Selection menu for Both Filters and Presets within the given [currentThing]
class SelectionMenuWidget extends StatefulWidget{

  final UpdateParentState updateStateMethod;
  final CustomListTypes type;

  SelectionMenuWidget(this.updateStateMethod, this.type);

  @override
  State<StatefulWidget> createState() => SelectionMenuState();

}

/// Selection menu for Both Filters and Presets within the given [currentThing]
class SelectionMenuState<T extends Named> extends State<SelectionMenuWidget>{

  late List<T> listOfEntries;

  SelectionMenuState(){
    listOfEntries = widget.type.getList(currentManager!, currentFlUser) as List<T>;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(filter: ColorFilter.mode(Colors.black38, BlendMode.darken),
      child: Transform.scale(scale: getScaleValue(context, 0.65, 0.90),//0.65,
        child: FittedBox(
          child: Card(
            child: FittedBox(
              child: Container(
                child: Column(
                  children: [
                    Material(
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              child: TextButton(
                                child: Text(
                                  "Add",
                                  style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? Colors.white),
                                ),
                                onPressed: () {},
                              ),
                              margin: EdgeInsets.all(4.0),
                              decoration: ThemeHandler.basicDecoration(context),
                            ),
                            Container(
                              child: TextButton(
                                child: Text(
                                  "Remove",
                                  style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? Colors.white),
                                ),
                                onPressed: () {},
                              ),
                              margin: EdgeInsets.all(4.0),
                              decoration: ThemeHandler.basicDecoration(context),
                            ),
                            Container (
                              child: TextButton (
                                child: Text (
                                  "Create",
                                  style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? Colors.white),
                                ),
                                onPressed: () {},
                              ),
                              margin: EdgeInsets.all(4.0),
                              decoration: ThemeHandler.basicDecoration(context),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: ThemeHandler.basicRadius(),
                          color: Theme.of(context).brightness == Brightness.light ? Colors.white12 : null
                        ),
                        constraints: BoxConstraints (
                          maxWidth: 250,
                          maxHeight: 300
                        ),
                      ),
                      // elevation: 10,
                      borderRadius: ThemeHandler.basicRadius(),
                    ),
                    //TODO: FIX DIVIDER!!!
                    Divider(
                      height: 10.0,
                    ),
                    Material(
                      child: Container(
                        child: ListView.separated(
                          itemCount: listOfEntries.length,
                          itemBuilder: getNameEntryWidget,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(),
                          padding: EdgeInsets.zero,
                        ),
                        constraints: BoxConstraints(
                            maxWidth: 250,
                            maxHeight: 300
                        ),
                        padding: EdgeInsets.all(4.0),
                      ),
                      //color: Theme.of(context).brightness == Brightness.light ? Colors.black26 : null,
                      borderRadius: ThemeHandler.basicRadius(),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10.0),
              ),
            ),
            color: Theme.of(context).brightness == Brightness.light ? Color.alphaBlend(Theme.of(context).primaryColor.withAlpha(100), Colors.white) : null,
            elevation: 20.0,
          ),
        ),
      ),
    );
  }

  /// Method to get a CustomWidget for a Named Entry from a given Index
  Widget getNameEntryWidget(BuildContext context, int index) {
    Named entry = listOfEntries[index];

    //-----------------------------------------

    Container nameTextWidget = Container(
      child: Text(
        entry.getFormattedName(),
        style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? Colors.white, fontWeight: FontWeight.w500),
      ),
      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      decoration: ThemeHandler.basicDecoration(context),
    );

    //-----------------------------------------

    Map<String, String> extraStringData = {};

    if(entry is AbstractFilter){
      extraStringData = entry.getExtraStringData();
    } else if (entry is Preset){
      extraStringData = entry.getExtraStringData();
    } else {
      return Container();
    }

    Column columnExtraData = Column(
      children: extraStringData.entries.map((entry) {
        Text textWidget = Text(
          "${entry.key} : ${entry.value}",
          style: TextStyle(color: ThemeHandler.getContrastedColor(context),
            fontWeight: FontWeight.w500,
            fontSize: 13
          ),
        );

        return textWidget;
      }).toList(),
    );

    //-----------------------------------------

    return Center(
      child: FittedBox(
        child: Container(
          child: ElevatedButton(
            child: Column(
              children: [
                Container(
                  child: nameTextWidget,
                  padding: EdgeInsets.only(bottom: 6.0),
                ),
                Container(child: columnExtraData)
              ],
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.black26, // Theme.of(context).brightness == Brightness.light ? Colors.black26 : null,
              padding: EdgeInsets.all(20.0),
              shape: currentFlUser.isActiveFilterOrPreset(entry) ? RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColor, width: 2.0),
                  borderRadius: ThemeHandler.basicRadius()
              ) : null,
            ),
            onPressed: () => setState(() {
              widget.type.toggleEntry(currentFlUser, entry);
              widget.updateStateMethod.call(() {});
            }),
          ),
          margin: EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
          // decoration: basicDecoration().copyWith(color: Colors.white24, border: border), //Colors.blue[800]
          width: 250,
        ),
      ),
    );
  }
}

//----------------------------------------------------------------------

///Main widget used to display the randomly Selected Thing from the [currentManager]
class PickedThingWidget extends StatefulWidget{

  PickedThingWidget();

  @override
  State<StatefulWidget> createState() => PickedThingState();

}

///Main widget used to display the randomly Selected Thing from the [currentManager]
class PickedThingState extends State<PickedThingWidget>{

  Random random = Random();

  Thing? randomlyPickedThing;

  PickedThingState();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(filter: ColorFilter.mode(Colors.black38, BlendMode.darken),
      child: Transform.scale(scale: getScaleValue(context, 0.4, 0.8),//0.4 * (MediaQuery.of(context).size.width / 1000),
        child: GestureDetector(
          child: FittedBox(
            child: Card(
              child: FittedBox(
                child: Container(
                  child: Column(
                    children: [
                      Material(
                        child: Container(
                          child: Text(
                            "You got:",
                            style: TextStyle(color: Colors.white),
                          ),
                          decoration: ThemeHandler.basicDecoration(context),
                          constraints: BoxConstraints (
                            maxWidth: 250,
                            maxHeight: 300
                          ),
                          padding: EdgeInsets.all(2.0),
                        ),
                        elevation: 2,
                        borderRadius: ThemeHandler.basicRadius(),
                      ),
                      //TODO: FIX DIVIDER!!!
                      Divider(
                        height: 10.0,
                      ),
                      Material(
                        child: getThingWidget(context),
                        elevation: 2,
                        borderRadius: ThemeHandler.basicRadius(),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                ),
              ),
              elevation: 20.0,
            ),
          ),
          onTap: () => setState(() => randomlyPickedThing = null),
        ),
      ),
    );
  }

  Widget getThingWidget(BuildContext context){
    randomlyPickedThing ??= currentManager!.pickRandomCharacter(currentFlUser, random);

    if(randomlyPickedThing != null) {
      return ThingManagerState.createThingWidget(randomlyPickedThing!, context);
    } else {
      return Container();
    }
  }
}

//---------------------------------------------------------------------------------------------------------------

double getScaleValue(BuildContext context, double minValue, double maxValue){
  return min(maxValue, max((maxValue - MediaQuery.of(context).size.width / 2500), minValue));
}

double getScaleValueTest(BuildContext context, double minValue, double minWidth, double maxValue, double maxWidth){
  double widthValue = MediaQuery.of(context).size.width;

  if(widthValue > maxWidth){
    widthValue = maxWidth;
  } else if(widthValue < minWidth){
    widthValue = minWidth;
  }

  double slope =  (maxValue - minValue) / (maxWidth - minWidth);//(minValue - maxValue) / (minWidth - maxWidth);

  return max(maxValue - widthValue * slope, minValue);
}