import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';

import '../../common/data/filters.dart';
import '../../common/data/property.dart';
import '../../common/data/thing.dart';
import '../../common/thing_manager.dart';
import '../../common/util/string_utils.dart';
import '../fl_main.dart';
import 'selection_menu_widget.dart';
import 'util/overlay_helper.dart';
import 'thing_manager_widgets.dart';
import 'ui_data/theme_data.dart';
import 'util/snack_bar_helper.dart';

class CreateMenuWidget extends StatefulWidget {

  final CustomListTypes type;
  final UpdateParentState updateStateMethod;
  final Key originKey;

  final Map<String, dynamic>? startingData;

  CreateMenuWidget(this.originKey, this.type, this.updateStateMethod, {this.startingData}){
    closeOriginOverlay();
  }

  void closeOriginOverlay(){
    dataManager.getOverlayHelperSafe(originKey).closeOverlay();
  }

  @override
  State<StatefulWidget> createState() => (type == CustomListTypes.preset ? PresetCreateMenuState(startingData) : FilterCreateMenuState(startingData));
}

abstract class CreateMenuState extends State<CreateMenuWidget>{

  String? identifier;

  Map<String, dynamic> extraData = {};
  Map<String, dynamic> entryData = {};

  bool editMode = false;

  final Map<String, dynamic>? startingData;

  double customWidgetBackgroundHeight = (414 + 48.5);

  CreateMenuState(this.startingData);

  @override
  void initState() {
    super.initState();

    updatePosition();
  }

  Offset position = Offset.zero;
  Size widgetSize = Size.zero;

  void updatePosition(){
    MediaQueryData data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    position = Offset((data.size.width / 2) - (widgetSize.width / 2), (data.size.height / 2) - (widgetSize.height / 2));
  }

  void onBuild(){
    if(startingData != null){
      editMode = startingData!.containsKey("editMode");
      identifier ??= startingData!["identifier"];
    }
  }

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
                        constraints: BoxConstraints(maxWidth: 249.4 + 13, maxHeight: customWidgetBackgroundHeight), //29.4
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
                  Container(
                    child: Column(
                      children: [
                        Material(
                          child: Container(
                            child: Text((editMode ? "Editing existing " : "Create a new ") + StringUtils.capitalize(widget.type.name),
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
                            child: TextFormField (
                              initialValue: identifier,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter ${StringUtils.capitalize(widget.type.name)} Name',
                                  isDense: true
                                //contentPadding: EdgeInsets.all(4.0)
                              ),
                              onChanged: (text) {
                                identifier = text;
                              },
                              validator: (input) {
                                if(input != null && !currentManager!.getPreset(input, user: currentFlUser).isEmpty()) {
                                  if(startingData != null && startingData!["identifier"] == input){
                                    return null;
                                  }

                                  return "That Name Already Exists for A Preset";
                                }

                                return null;
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
                                  OutlinedButton(child: Text(editMode ? "Save" : "Create"),
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
    List<Widget> columnDataList = [];

    List<Widget> extraDataEntry = getMainSelectionWidgets(context);

    if(extraDataEntry.length > 1){
      columnDataList.addAll([
        Material(
          child: Container(
              child: extraDataEntry.first,
              constraints: BoxConstraints(
                maxWidth: 250,
                //maxHeight: 75
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.all(6.0)
          ),
          borderRadius: ThemeHandler.basicRadius(),
        ),
        Container(
          constraints: BoxConstraints(
              maxWidth: 250,
              maxHeight: 4
          ),
        ),
      ]);
    }

    columnDataList.add(Material(
      child: Container(
        child: extraDataEntry.last,
        constraints: BoxConstraints(
            maxWidth: 250,
            maxHeight: 300
        ),
        padding: EdgeInsets.all(2.0),
      ),
      borderRadius: ThemeHandler.basicRadius(),
    ));

    return columnDataList;
  }


  List<Widget> getMainSelectionWidgets(BuildContext context);

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

  PresetCreateMenuState(Map<String, dynamic>? startingData) : super(startingData);

  @override
  void onBuild() {
    super.onBuild();

    if(startingData != null){
      entryData["selected_filters"] ??= startingData!["selected_filters"] ?? <AbstractFilter>[];
    }

    extraData["all_filters"] ??= currentManager!.getAllFilters(currentFlUser);
  }

  @override
  List<Widget>? getExtraWidgets(BuildContext context){
    return null;
  }

  @override
  List<Widget> getMainSelectionWidgets(BuildContext context) {
    entryData["selected_filters"] ??= <AbstractFilter>[];

    return [
      //Text("Available Filters"),
      ListView.separated(
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
      ),
    ];
  }

  @override
  void createNewEntry<T>(){
    List<dynamic> entrys = entryData["selected_filters"];

    if(entrys.isEmpty){
      SnackBarMaker.sendSnackBar(SnackBarMaker.warningSnack("A minimum of one filter is needed to create a Preset."));

      TextLogger.consoleOutput("There was no entry's within the filter List so no present will be created");

      return;
    }

    if(identifier == null || identifier!.isEmpty){
      SnackBarMaker.sendSnackBar(SnackBarMaker.warningSnack("A Preset needs a name in order to be created."));

      TextLogger.consoleOutput("There seems to be no name given to the Preset being saved.");

      return;
    }

    identifier = identifier!.replaceAll(" ", "_").toLowerCase().trim();

    if(editMode) {
      Preset preset = currentFlUser.getUserPreset(startingData!["identifier"]);

      bool presetChanged = false;

      if(preset.id != identifier){
        preset.id = identifier!;

        presetChanged = true;
      }

      for(AbstractFilter<T> entry in entrys){
        if(!preset.activeFilters.contains(entry)){
          preset.activeFilters.add(entry);
          presetChanged = true;
        }
      }

      if(presetChanged){
        currentFlUser.savePresets(currentManager!);

        TextLogger.consoleOutput("Saved Edits on existing Preset.");
      } else {
        TextLogger.consoleOutput("Nothing was changed on exists preset.");
      }

      closeOverlay();
    }

    if (currentFlUser.createPreset(identifier!, currentManager!, entrys as List<AbstractFilter<T>>)) {
      currentFlUser.savePresets(currentManager!);

      TextLogger.consoleOutput("Creating new User Preset");

      closeOverlay();
    } else {
      SnackBarMaker.sendSnackBar(SnackBarMaker.warningSnack("A Preset with that name already Exists!"));

      TextLogger.consoleOutput("A Preset with that name already Exists!");
    }

  }
}

class FilterCreateMenuState extends CreateMenuState {

  List<AbstractProperty> listOfProperties = [];

  AbstractProperty currentSelectedProperty = currentManager!.properties.first;

  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();

  Map<String, dynamic> filterData = {};

  FilterCreateMenuState(Map<String, dynamic>? startingData) : super(startingData);

  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();

    super.dispose();
  }

  @override
  void onBuild() {
    super.onBuild();

    if(listOfProperties.isEmpty){
      listOfProperties = currentManager!.properties;
    }

    if(filterData.isEmpty){
      setupValues(currentSelectedProperty);
    }
  }

  void setupValues(AbstractProperty property){
    if(currentSelectedProperty is BooleanProperty){
      return;
    }

    if(currentSelectedProperty is NumberProperty){
      RangeValues startingRange;

      if(contains("starting_range")) {
        startingRange = getData("starting_range");
      } else {
        List<double> rangeValues = (currentSelectedProperty as NumberProperty).getMinAndMaxValues(currentManager!);

        TextLogger.consoleOutput(rangeValues.toString());

        startingRange = RangeValues(rangeValues[0].toDouble(), rangeValues[1].toDouble());

        setData("starting_range", startingRange);
      }

      //if(!contains("user_selected_range")){
      setData("user_selected_range", RangeValues(startingRange.start, startingRange.end));
      //}
    }

    if(!contains("available_values")){
      setData("available_values", currentManager!.things.map((e) {
        dynamic value = e.properties[currentSelectedProperty];
        String formattedName = currentSelectedProperty.getFormattedValue(value);

        return WrappedNamed(value, name: formattedName);
      }).toSet().toList());
    }

    setData("user_selected_values", <dynamic>[]);

  }

  @override
  List<Widget> buildCustomCreationWidget(BuildContext context){
    ScrollBehavior behavior = ScrollConfiguration.of(context).copyWith(dragDevices: { PointerDeviceKind.touch, PointerDeviceKind.mouse, });

    return [
      Material(
        child: Container(
          child: ImprovedScrolling(
            scrollController: controller2,
            enableCustomMouseWheelScrolling: true,
            enableKeyboardScrolling: true,
            enableMMBScrolling: true,
            keyboardScrollConfig: KeyboardScrollConfig(),
            child: ScrollConfiguration(
              behavior: behavior,
              child: ListView.separated(
                itemCount: listOfProperties.length,
                scrollDirection: Axis.horizontal,
                controller: controller2,
                itemBuilder: (context, index) {
                  return SelectionMenuWidget.getNameEntryBaseWidget<AbstractProperty>(context, entry: listOfProperties[index],
                    toggleFunction: (entry) => setState(() {
                        currentSelectedProperty = entry;

                        setupValues(currentSelectedProperty);

                        //currentSelectedProperties = currentSelectedProperties == entry ? null : entry;
                      }),
                    isActive: (entry) => currentSelectedProperty == entry,
                    slimVersion: true,
                  ).first;
                },
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          constraints: BoxConstraints(
              maxWidth: 250,
              maxHeight: 75
          ),
          padding: EdgeInsets.all(2.0),
        ),
        borderRadius: ThemeHandler.basicRadius(),
      ),
      ...getMainSelectionWidgets(context)
    ];
  }

  @override
  List<Widget> getMainSelectionWidgets(BuildContext context) {
    List<Widget> mainSelectionWidget = [];

    if(currentSelectedProperty is BooleanProperty){
      return mainSelectionWidget;
    }

    if(currentSelectedProperty is NumberProperty<num>){
      RangeValues currentValues = getData("user_selected_range");
      NumberProperty property = currentSelectedProperty as NumberProperty;

      mainSelectionWidget.addAll([
        Container(
          constraints: BoxConstraints(
              maxWidth: 250,
              maxHeight: 4
          ),
        ),
        Material(
          child: Container(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                valueIndicatorShape: RoundSliderThumbShape(),
              ),
              child: RangeSlider(
                min: (getData("starting_range") as RangeValues).start,
                max: (getData("starting_range") as RangeValues).end,
                values: getData("user_selected_range"),
                divisions: property is IntegerProperty ? (getData("starting_range") as RangeValues).end.round() : null,
                onChanged: (RangeValues value) => {
                  if(value.end != value.start){
                    setState(() => setData("user_selected_range", value))
                  }
                },
                activeColor: ThemeHandler.getPrimaryColor(),
                labels: RangeLabels(property.getFormattedValueAsDouble(currentValues.start), property.getFormattedValueAsDouble(currentValues.end)),
              ),
            ),
            constraints: BoxConstraints(
                maxWidth: 250,
                maxHeight: 50
            ),
          ),
          borderRadius: ThemeHandler.basicRadius(),
        ),
        ]
      );
    }

    mainSelectionWidget.addAll([
      Container(
        constraints: BoxConstraints(
            maxWidth: 250,
            maxHeight: 4
        ),
      ),
      Material(
        child: Container(
          child: ImprovedScrolling(
            scrollController: controller,
            //enableCustomMouseWheelScrolling: true,
            enableKeyboardScrolling: true,
            enableMMBScrolling: true,
            child: ListView.separated(
              itemCount: getData("available_values").length,
              scrollDirection: Axis.vertical,
              controller: controller,
              //physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return SelectionMenuWidget.getNameEntryBaseWidget<WrappedNamed>(context, entry: getData("available_values")[index],
                  toggleFunction: (entry) => setState(() {
                    List<dynamic> selectedData = getData("user_selected_values");

                    if(selectedData.contains(entry.getValue())){
                      selectedData.remove(entry.getValue());
                    } else {
                      selectedData.add(entry.getValue());
                    }
                  }),
                  isActive: (entry) => (getData("user_selected_values") as List<dynamic>).contains(entry.getValue()),
                  slimVersion: true,
                ).first;
              },
              shrinkWrap: true,
              separatorBuilder: (context, index) => Divider(),
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
          ),
          constraints: BoxConstraints(
              maxWidth: 250,
              maxHeight: 150
          ),
        ),
        borderRadius: ThemeHandler.basicRadius(),
      ),
    ]);


    return mainSelectionWidget;
  }

  dynamic getData(String location, {AbstractProperty? property}){
    return filterData[location + ":" + (property ?? currentSelectedProperty).getName()];
  }

  void setData(String location, dynamic value, {AbstractProperty? property}){
    filterData[location + ":" + (property ?? currentSelectedProperty).getName()] = value;
  }

  bool contains(String location, {AbstractProperty? property}){
    return filterData.containsKey(location + ":" + (property ?? currentSelectedProperty).getName());
  }

  @override
  void createNewEntry<T>(){
    dynamic entry = entryData["selected_property"];
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {




  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // etc.
  };
}