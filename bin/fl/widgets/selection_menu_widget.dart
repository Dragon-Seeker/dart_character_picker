import 'package:basic_utils/basic_utils.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:flutter/material.dart';

import '../../common/data/filters.dart';
import '../../common/thing_manager.dart';
import '../../common/util/string_utils.dart';
import '../fl_main.dart';
import 'confirmation_widget.dart';
import 'creation_menu_widget.dart';
import 'selection_menu_widget.dart';
import 'overlay_helper.dart';
import 'thing_manager_widgets.dart';
import 'ui_data/theme_data.dart';

/// Selection menu for Both Filters and Presets within the given [currentThing]
class SelectionMenuWidget extends StatefulWidget {

  static Key createMenuKey = ValueKey("CreateMenu");
  static Key confirmDeletionKey = ValueKey("ConfirmationOverlay");

  final UpdateParentState updateStateMethod;
  final CustomListTypes type;

  SelectionMenuWidget(Key key, this.updateStateMethod, this.type) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    if(!dataManager.overlayMap.containsKey(createMenuKey)) {
      dataManager.registerOverlayHelper(createMenuKey, OverlayHelper(createMenuKey,
        (UpdateParentState updateStateMethod, {List<dynamic>? inputs}) => OverlayEntry(builder: (context) => CreateMenuWidget(key!, type, updateStateMethod)), linkedOverlay: ManagerPageWidget.pickMenuKey, removeOnClose: true));
    }

    return (type == CustomListTypes.preset) ? PresetSelectionMenuState() : FilterSelectionMenuState();
  }

  static List<Widget> getNameEntryBaseWidget<T extends Named>(BuildContext context, {required T entry, required void Function(T) toggleFunction, required bool Function(T) isActive}) {
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
      return [Container()];
    }

    Column columnExtraData = Column(
      children: extraStringData.entries.map((entry) {
        return Text("${entry.key} : ${entry.value}",
          style: TextStyle(color: ThemeHandler.getContrastedColor(context),
              fontWeight: FontWeight.w500,
              fontSize: 13
          ),
        );
      }).toList(),
    );

    //-----------------------------------------

    bool isEntryActive = isActive.call(entry);//;

    List<Widget> stackList = [
      Center(
        child: FittedBox(
          child: Container(
            child:ElevatedButton(
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
                shape: isEntryActive ? RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: ThemeHandler.basicRadius()
                ) : null,
              ),
              onPressed: () => toggleFunction.call(entry),
            ),
            margin: EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
            // decoration: basicDecoration().copyWith(color: Colors.white24, border: border), //Colors.blue[800]
            width: 250,
          ),
        ),
      ),
    ];

    return stackList;
  }
}

/// Selection menu for Both Filters and Presets within the given [currentThing]
abstract class SelectionMenuState<T extends Named> extends State<SelectionMenuWidget>{

  List<T>? listOfEntries;

  void onBuild();

  @override
  Widget build(BuildContext context) {
    onBuild();

    final GlobalKey bottomAppBarCopyButton = LabeledGlobalKey("bottomAppBarCopyButton");

    return BackdropFilter(filter: ColorFilter.mode(Colors.black38, BlendMode.darken),
      child: GestureDetector(
        child: Transform.scale(scale: getScaleValue(context, 0.65, 0.90),//0.65,
          child: FittedBox(
            child: Card(
              child: FittedBox(
                child: Stack(
                  children: [
                    Positioned(
                      child: FittedBox(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 249.4 + 13, maxHeight: 376.6), //29.4
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
                              child: Container(
                                child: Text(
                                  "${StringUtils.capitalize(widget.type.name)} Menu",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                alignment: Alignment.center,
                              ),
                              constraints: BoxConstraints(maxWidth: 250), //,
                              padding: EdgeInsets.only(left: 2.0, right: 2.0, bottom: 4.0),
                            ),
                            borderRadius: ThemeHandler.basicRadius(),
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 250, maxHeight: 6),
                          ),
                          Material(
                            child: Container(
                              child: ListView.separated(
                                itemCount: listOfEntries!.length,
                                itemBuilder: (context, index) {
                                  return getNameEntryWidgetTest(context,
                                    entry: listOfEntries![index],
                                    toggleFunction: (entry) => setState(() {
                                      toggleEntry(entry);
                                    }),
                                    isActive: currentFlUser.isActiveFilterOrPreset,
                                  );
                                },
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
                          Container(
                            constraints: BoxConstraints(maxWidth: 250, maxHeight: 6),
                          ),
                          NotchedBarClipper.getCustomClippedWidget(
                              context: context,
                              buttonKey: bottomAppBarCopyButton,
                              notchMargin: 4,
                              width: 250,
                              height: 27.5,
                              shape: CircularNotchedRectangle()
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10.0),
                    ),
                    Positioned(
                      child: Container(
                        child: FittedBox(
                          child: Material(
                            key: bottomAppBarCopyButton,
                            child: IconButton(
                              //key: bottomAppBarCopyButton,
                              icon: Icon(
                                Icons.add,
                                size: 25,
                              ),
                              //color: Theme.of(context).primaryColor,
                              splashRadius: 20,
                              onPressed: () {
                                setState(() => dataManager.getOverlayHelperSafe(SelectionMenuWidget.createMenuKey).openOverlay(context, setState));
                              },
                            ),
                            shape: CircleBorder(),
                            color: Color.lerp(Theme.of(context).primaryColor, Colors.black, 0.16),
                            elevation: 8,
                          ),
                          fit: BoxFit.fitHeight,
                        ),
                        constraints: BoxConstraints.tightFor(height: 37.5),
                      ),
                      bottom: 17.5,
                      right: 0, left: 0,
                    ),
                  ]
                ),
              ),
              color: Theme.of(context).brightness == Brightness.light ? Color.alphaBlend(Theme.of(context).primaryColor.withAlpha(100), Colors.white) : null,
              elevation: 20.0,
            ),
          ),
        ),
        onTap: () {}, // closeAllOverlays
      ),
    );
  }

  /// Method to get a CustomWidget for a Named Entry from a given Index
  Widget getNameEntryWidgetTest(BuildContext context, {required T entry, required void Function(T) toggleFunction, required bool Function(T) isActive, bool editAndDeleteButtons = true}) {
    bool isEntryActive = isActive.call(entry);//;

    List<Widget> stackList = SelectionMenuWidget.getNameEntryBaseWidget(context, entry: entry, toggleFunction: toggleFunction, isActive: isActive);

    if(editAndDeleteButtons){
      stackList.addAll([
        Positioned(
          child: Container(
            child: IconButton(
              iconSize: 12,
              icon: Icon(
                Icons.edit,
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                editEntry(entry);
              },
              splashRadius: 10.0,
            ),
            alignment: Alignment.topLeft,
          ),
          top: -4.0,
        ),
        Positioned(
          child: Container(
            child: IconButton(
              iconSize: 12,
              icon: Icon(
                Icons.delete,
              ),
              color: Colors.red,
              disabledColor: Colors.white12,
              padding: EdgeInsets.zero,
              onPressed: isEntryActive ? () {
                removeEntry(entry);
              } : null,
              splashRadius: 10.0,
            ),
          ),
          top: -4.0,
          right: -1.0,
        ),
      ]);
    }

    return Stack(children: stackList);
  }

  void updateManagerWidget({void Function()? func}){
    ManagerPageWidget.managerPageKey.currentState!.setState(func ?? () {});
  }

  void toggleEntry(T entry);

  void editEntry(T entry);

  void removeEntry(T entry);

  void closeAllOverlays(){
    dataManager.getOverlayHelper(SelectionMenuWidget.createMenuKey)?.closeOverlay();
  }

}

class PresetSelectionMenuState extends SelectionMenuState<Preset>{

  @override
  void onBuild(){
    listOfEntries ??= currentManager!.getAllPresets(currentFlUser);
  }

  @override
  void toggleEntry(Preset entry){
    if(currentFlUser.currentPreset == entry){
      currentFlUser.currentPreset = null;
    } else {
      currentFlUser.currentPreset = entry;
    }

    updateManagerWidget();
  }

  @override
  void editEntry(Preset entry) {
    // TODO: implement editEntry
  }

  @override
  void removeEntry(Preset entry) {
    if(entry.state == OriginState.user){
      dataManager.createAndRegisterOverlayHelper(SelectionMenuWidget.confirmDeletionKey,
        (UpdateParentState method, {List<dynamic>? inputs}) =>
          (context) => ConfirmationWidget(SelectionMenuWidget.confirmDeletionKey, setState,
            title: Text("Delete Preset: ${entry.getName()}"),
            bodyWidget: Text("Are you sure that you want to delete it forever?", softWrap: true),
            confirmFunc: (UpdateParentState updateParentState) {
              currentFlUser.presets.remove(entry);

              currentFlUser.savePresets(currentManager!);

              dataManager.getOverlayHelperSafe(SelectionMenuWidget.confirmDeletionKey).closeOverlay();

              updateParentState.call(() {});
            },
            cancelFunc: () => dataManager.getOverlayHelperSafe(SelectionMenuWidget.confirmDeletionKey).closeOverlay(),
          ),
        overwriteAccess: false,
        removeOnClose: true
      );

      dataManager.getOverlayHelperSafe(SelectionMenuWidget.confirmDeletionKey).openOverlay(context, setState);
    }
  }

}

class FilterSelectionMenuState extends SelectionMenuState<AbstractFilter>{

  @override
  void onBuild(){
    listOfEntries ??= currentManager!.getAllFilters(currentFlUser);
  }

  @override
  void toggleEntry(AbstractFilter entry){
    if(currentFlUser.currentPreset == null){
      currentFlUser.currentPreset = Preset(Preset.unsavedPreset, [entry]);

    } else {
      if(currentFlUser.currentPreset!.id != Preset.unsavedPreset){
        currentFlUser.currentPreset = currentFlUser.currentPreset!.copyFilters();
      }

      if(currentFlUser.currentPreset!.activeFilters.contains(entry)){
        currentFlUser.currentPreset!.activeFilters.remove(entry);

        if(currentFlUser.currentPreset!.activeFilters.isEmpty){
          currentFlUser.currentPreset = null;
        }
      } else {
        currentFlUser.currentPreset!.activeFilters.add(entry);
      }
    }

    updateManagerWidget();
  }

  @override
  void editEntry(AbstractFilter entry) {
    // TODO: implement editEntry
  }

  @override
  void removeEntry(AbstractFilter entry) {
    // TODO: implement removeEntry
  }

}


class NotchedBarClipper extends CustomClipper<Path> {
  const NotchedBarClipper({
    required this.shape,
    required this.materialKey,
    required this.buttonKey,
    required this.notchMargin,
    this.xOffset
  }) : super();

  final double? xOffset;

  final NotchedShape shape;
  final GlobalKey materialKey;
  final GlobalKey buttonKey;
  final double notchMargin;

  double get bottomNavigationBarTop {
    final RenderBox? box = materialKey.currentContext?.findRenderObject() as RenderBox?;

    return box?.localToGlobal(Offset.zero).dy ?? 0;
  }

  @override
  Path getClip(Size size) {
    double buttonWidth = buttonKey.currentContext!.size!.width ?? 0;
    double buttonHeight = buttonKey.currentContext!.size!.height ?? 0;

    double barWidth = materialKey.currentContext!.size!.width ?? 0;

    Rect? button = buttonKey.currentContext?.size != null ?
    Rect.fromPoints(Offset.zero, Offset(buttonWidth, buttonHeight)) : null;

    if(button != null){
      button = button.inflate(notchMargin).translate((xOffset ?? ((barWidth - buttonWidth) / 2)), 0 - (buttonHeight / 2)); //localPositionButton.dx.abs() + (buttonKey.currentContext!.size!.width / 2)

    } else {
      debugPrint("not to be expected...");
    }

    return Path.combine(PathOperation.intersect, shape.getOuterPath(Offset.zero & size, button), OutlineInputBorder(borderRadius: ThemeHandler.basicRadius()).getOuterPath(Offset.zero & size)) ;
  }

  @override
  bool shouldReclip(NotchedBarClipper oldClipper) {
    return /* oldClipper.geometry != geometry || */
      oldClipper.shape != shape ||
          oldClipper.notchMargin != notchMargin;
  }

  static Widget getCustomClippedWidget({required BuildContext context, required GlobalKey buttonKey, required double width, required double height, double notchMargin = 4.0, double? xOffset, Clip clipBehavior = Clip.none, double? elevation, Color? color, NotchedShape? shape}){
    elevation ??= BottomAppBarTheme.of(context).elevation ?? 8.0;
    color ??= BottomAppBarTheme.of(context).color ?? Theme.of(context).canvasColor;

    shape ??= BottomAppBarTheme.of(context).shape;

    final GlobalKey materialKey = LabeledGlobalKey("material_key");

    final CustomClipper<Path> clipper = shape != null
        ? NotchedBarClipper(
      shape: shape,
      buttonKey: buttonKey,
      materialKey: materialKey,
      notchMargin: notchMargin,
      xOffset: xOffset,
    ) : const ShapeBorderClipper(shape: RoundedRectangleBorder());

    return PhysicalShape(
      clipper: clipper,
      elevation: elevation,
      color: ElevationOverlay.applyOverlay(context, color, elevation),
      clipBehavior: clipBehavior,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          key: materialKey,
          constraints: BoxConstraints(
              maxWidth: width,
              maxHeight: height
          ),
          //color: Theme.of(context).canvasColor
        ),
      ),
    );
  }
}

