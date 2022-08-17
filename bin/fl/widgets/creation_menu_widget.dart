import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';

import '../../common/data/filters.dart';
import '../../common/data/thing.dart';
import '../../common/thing_manager.dart';
import '../../common/util/string_utils.dart';
import '../fl_main.dart';
import 'selection_menu_widget.dart';
import 'overlay_helper.dart';
import 'thing_manager_widgets.dart';
import 'ui_data/theme_data.dart';

class CreateMenuWidget extends StatefulWidget {

  final CustomListTypes type;
  final UpdateParentState updateStateMethod;
  final Key originKey;

  CreateMenuWidget(this.originKey, this.type, this.updateStateMethod){
    closeOriginOverlay();
  }

  void closeOriginOverlay(){
    dataManager.getOverlayHelperSafe(originKey).closeOverlay();
  }

  @override
  State<StatefulWidget> createState() => (type == CustomListTypes.preset ? PresetCreateMenuState() : FilterCreateMenuState());
}

abstract class CreateMenuState extends State<CreateMenuWidget>{

  String? identfier;

  Map<String, dynamic> extraData = {};

  Map<String, dynamic> entryData = {};

  CreateMenuState();

  Offset position = Offset.zero;

  Size widgetSize = Size.zero;

  @override
  void initState() {
    super.initState();

    updatePosition();
  }

  void updatePosition(){
    MediaQueryData data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    position = Offset((data.size.width / 2) - (widgetSize.width / 2), (data.size.height / 2) - (widgetSize.height / 2));
  }

  void onBuild();

  @override
  Widget build(BuildContext context) {
    onBuild();

    return Transform.scale(scale: getScaleValue(context, 0.65, 0.90),
      child: GestureDetector(
        child: FittedBox(
          child: Card(
            child: FittedBox(
              child: Stack(
                children: [
                  Positioned(
                    child: FittedBox(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 249.4 + 13, maxHeight: 414 + 48.5), //29.4
                        decoration: BoxDecoration(
                            color: Color.lerp(Theme.of(context).canvasColor, Colors.black, 0.2), //Colors.cyan,
                            borderRadius: ThemeHandler.basicRadius()
                        ),
                        padding: EdgeInsets.all(2),
                      ),
                    ),
                    top: 3.4,
                    left: 3.80
                  ),
                  Container(child:
                  Column(
                    children: [
                      Material(
                        child: Container(
                          child: Text("Create a new ${StringUtils.capitalize(widget.type.name)}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          alignment: Alignment.center,
                          constraints: BoxConstraints(maxWidth: 250), //,
                          padding: EdgeInsets.all(6.0)//EdgeInsets.only(left: 2.0, right: 2.0, bottom: 4.0),
                          //margin: EdgeInsets.all(6.0),
                        ),
                        borderRadius: ThemeHandler.basicRadius(),
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: 250,
                            maxHeight: 4
                        ),
                      ),
                      Material(
                        child: Container(
                          child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter ${StringUtils.capitalize(widget.type.name)} Name',
                                isDense: true
                              //contentPadding: EdgeInsets.all(4.0)
                            ),
                            onChanged: (text) {
                              identfier = text;
                            },
                            // onSubmitted: (text) {
                            //   identfier = text;
                            // },
                          ),
                          constraints: BoxConstraints(
                            maxWidth: 250,
                            //maxHeight: 60
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        borderRadius: ThemeHandler.basicRadius(),
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: 250,
                            maxHeight: 4
                        ),
                      ),
                      // Material(
                      //   child: Container(
                      //     child: ,
                      //     constraints: BoxConstraints(
                      //         maxWidth: 250,
                      //         maxHeight: 300
                      //     ),
                      //   )
                      // ),
                      ...buildCustomCreationWidget(context),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: 250,
                            maxHeight: 4
                        ),
                      ),
                      Material(
                        child: Container(
                          child: Row(
                            children: [
                              Expanded(child:
                                OutlinedButton(child: Text("Cancel"),
                                  onPressed: closeOverlay,
                                ),
                              ),
                              VerticalDivider(
                                width: 6,
                              ),
                              Expanded(child:
                                OutlinedButton(child: Text("Create"),
                                  onPressed: createNewEntry,
                                )
                              )
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxWidth: 250,
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        borderRadius: ThemeHandler.basicRadius(),
                      ),
                    ],
                  ),
                    padding: EdgeInsets.all(10.0),
                  ),
                ]
              ),
            ),
            color: Theme.of(context).brightness == Brightness.light ? Color.alphaBlend(Theme.of(context).primaryColor.withAlpha(100), Colors.white) : null,
            elevation: 20.0,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  List<Widget> buildCustomCreationWidget(BuildContext context){
    List<Widget> columnWidgets = [];

    Widget extraDataEntry = getCustomCreationWidget(context);

    columnWidgets.add(Material(
      child: Container(
        child: extraDataEntry,
        constraints: BoxConstraints(
            maxWidth: 250,
            maxHeight: 300
        ),
        padding: EdgeInsets.all(2.0),
      ),
      borderRadius: ThemeHandler.basicRadius(),
    )
    );

    return columnWidgets;
  }

  Widget getCustomCreationWidget(BuildContext context);

  void createNewEntry<T>();

  void reopenOriginOverlay(){
    OverlayHelper helper = dataManager.getOverlayHelperSafe(widget.originKey);

    helper.openOverlay(context, widget.updateStateMethod);
  }

  void closeOverlay(){
    dataManager.getOverlayHelperSafe(SelectionMenuWidget.createMenuKey).closeOverlay();

    reopenOriginOverlay();
  }
}

class PresetCreateMenuState extends CreateMenuState {

  PresetCreateMenuState();

  @override
  void onBuild() {
    extraData["all_filters"] ??= currentManager!.getAllFilters(currentFlUser);
  }

  @override
  Widget getCustomCreationWidget(BuildContext context) {
    entryData["selected_filters"] ??= <AbstractFilter>[];

    return ListView.separated(
      itemCount: extraData["all_filters"]!.length,
      itemBuilder: (context, index) {
        return SelectionMenuWidget.getNameEntryBaseWidget<AbstractFilter>(context, entry: extraData["all_filters"]![index],
          toggleFunction: (entry) =>
            setState(() {
              List<AbstractFilter> list = (entryData["selected_filters"] as List<AbstractFilter>);

              if(!list.contains(entry)){
                list.add(entry);
              } else {
                list.remove(entry);
              }
            }),
          isActive: (entry) => (entryData["selected_filters"] as List<AbstractFilter>).contains(entry)
        ).first;
      },
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(),
      padding: EdgeInsets.zero,
    );
  }

  @override
  void createNewEntry<T>(){
    List<dynamic> entrys = entryData["selected_filters"];

    for (var element in entrys) {
      TextLogger.consoleOutput(element.runtimeType.toString());
    }

    if(entrys.isNotEmpty){
      currentFlUser.createPreset(identfier!, entrys as List<AbstractFilter<T>>);

      TextLogger.consoleOutput("Creating new User Preset");

      closeOverlay();
    } else {
      TextLogger.consoleOutput("There was no entry's within the filter List so no present will be created");

      closeOverlay();
    }
  }
}

class FilterCreateMenuState extends CreateMenuState {

  FilterCreateMenuState();

  @override
  void onBuild() {
    extraData["list_of_things"] ??= currentManager!.things;
  }

  @override
  Widget getCustomCreationWidget(BuildContext context) {
    entryData["selected_things"] ??= <Thing>[];

    return ListView.separated(
      itemCount: extraData["list_of_things"]!.length,
      itemBuilder: (context, index) {
        return SelectionMenuWidget.getNameEntryBaseWidget<Thing>(context, entry: extraData["list_of_things"]![index],
          toggleFunction: (entry) =>
            setState(() {
              List<Thing> list = (entryData["selected_things"] as List<Thing>);

              if(!list.contains(entry)){
                list.add(entry);
              } else {
                list.remove(entry);
              }
            }),
          isActive: (entry) => (entryData["selected_things"] as List<AbstractFilter>).contains(entry)
        ).first;
      },
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(),
      padding: EdgeInsets.zero,
    );
  }

  @override
  void createNewEntry<T>(){
    List<dynamic> entrys = entryData["selected_things"];


  }
}