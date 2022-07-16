import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'package:package_config/src/util_io.dart';

import '../common/data/users.dart';
import '../common/thing_manager.dart';
import '../common/main_config.dart';
import '../common/util/file_ops.dart';
import '../common/util/string_utils.dart';
import 'data/file_helper.dart';
import 'widgets/thing_manager_widgets.dart';
import 'widgets/overlay_helper.dart';
import 'data/imageManager.dart';
import 'widgets/ui_data/theme_data.dart';
import 'widgets/custom_settings_widgets.dart';

bool showPresetAndFilterData = false;

ThingManager? currentManager;
ImageManager? currentImageManager;

User currentFlUser = User("flutter", UserPerms.user);

void initCharacterConfigsFl() {
  TextLogger.consoleOutput("Attempting to Loading Character Configs!",
      debugOut: true);

  var directory = Directory(fileDirectory + getPlatformPath("resources/characterConfigs/"));

  if (directory.existsSync()) {
    for (var file in getAllJsonFiles(directory)) {
      Map<String, dynamic> json = jsonDecode(file.readAsStringSync());

      try {
        ThingManager.parseManagerData(json);
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  fileDirectory = (await getApplicationSupportDirectory()).path + Platform.pathSeparator;

  getPlatformPathFunc = (path) => pathJoinAll(path.split("/"));

  await FileHelper.initFiles();

  ProgramInfoLoader.initInfoCl();
  MainConfig.initConfigCl();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Character Picker by Blodhgarm (Version:${ProgramInfoLoader.getProgramVersion()})');
  }

  TextLogger.disableAnsiOutput = kIsWeb;

  initCharacterConfigsFl();

  runApp(MyApp());
}

//-----------------------------------

OverlayHelper settingsMenuHelper = OverlayHelper(LabeledGlobalKey("SettingsMenu"), (UpdateParentState updateStateMethod) {
  return OverlayEntry(
    builder: (context) {
      return SettingsWidget(updateStateMethod);
    }
  );
});

Widget Function(BuildContext, UpdateParentState) _buildSettingsWidget = (context, updateParentState) {
  return IconButton(
    icon: Icon(Icons.settings),
    tooltip: 'Settings',
    color: Theme.of(context).primaryColor,
    onPressed: () {
      updateParentState.call(() {
        settingsMenuHelper.interactWithOverlay(context, updateParentState);
      });
    },
  );
};

//-----------------------------------

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {

  _MyAppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      themeMode: ThemeHandler.getThemeMode(),
      theme: ThemeHandler.themeData(),
      darkTheme: ThemeHandler.darkThemeData(),
      home: MainPageWidget(),
      navigatorObservers: [
        routeObserver
      ],
    );
  }

}


class MainPageWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MainPageState();

}

class MainPageState extends State<MainPageWidget> with RouteAware {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text("Thing Picker",
              textScaleFactor: 0.8,
              style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? ThemeHandler.checkThemeMode(context, Theme.of(context).primaryColor, null)),
            ),
            padding: EdgeInsets.all(6.0),//EdgeInsets.only(left: 4.0, right: 4.0, top: 1.0, bottom: 1.0),
            decoration: BoxDecoration(
                borderRadius: ThemeHandler.basicRadius(),
                color: ThemeHandler.checkThemeMode(context, Colors.white, Theme.of(context).primaryColor)
            ),
          ),
          actions: [
            _buildSettingsWidget.call(context, setState)
          ],
          backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : null, //Theme.of(context).primaryColor,
        ),
        body: Container(
          child: ListView.builder(
            itemCount: allManagers.length,
            itemBuilder: (context, index) {
              return Container(
                child: TextButton(
                  child: Text(
                    allManagers[index].getDisplayName(),
                    style: TextStyle(color: ThemeHandler.getContrastedColor(context)),
                  ),
                  onPressed: () async {
                    currentManager = allManagers[index];

                    TextLogger.consoleOutput(currentManager.toString(), debugOut: true);

                    currentImageManager = ImageManager.getOrCreateManager(currentManager!);

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return ManagerPageWidget();
                        }
                      )
                    );
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.all(32.0)).merge(ThemeHandler.whiteTextButtonStyle()),
                ),
                margin: EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              );
            },
          ),
        ),
      ),
      onTap: () {
        if(settingsMenuHelper.removeOverlay(forcedClosed: true)) settingsMenuHelper.toggleOverlay();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    super.dispose();

    routeObserver.unsubscribe(this);
  }

  @override
  void didPushNext() {
    if(settingsMenuHelper.removeOverlay(forcedClosed: true)) settingsMenuHelper.toggleOverlay();
  }
}

//--------------------------------------------------------------------------------

class ManagerPageWidget extends StatefulWidget {
  
  @override State<StatefulWidget> createState() => ManagerPageState();

}

class ManagerPageState extends State<ManagerPageWidget> with RouteAware {

  static bool linkOverlays = false;

  static OverlayHelper presetMenuHelper = OverlayHelper(LabeledGlobalKey("PresetMenu"),
      (UpdateParentState updateStateMethod) => OverlayEntry(builder: (context) => SelectionMenuWidget(updateStateMethod, CustomListTypes.preset))
  );

  static OverlayHelper filterMenuHelper = OverlayHelper(LabeledGlobalKey("FilterMenu"),
      (UpdateParentState updateStateMethod) => OverlayEntry(builder: (context) => SelectionMenuWidget(updateStateMethod, CustomListTypes.filter))
  );

  static OverlayHelper pickMenuHelper = OverlayHelper(LabeledGlobalKey("PickMenu"),
      (UpdateParentState updateStateMethod) => OverlayEntry(builder: (context) => PickedThingWidget())
  );

  static List<OverlayHelper> overlays = [presetMenuHelper, filterMenuHelper, pickMenuHelper, settingsMenuHelper];

  ManagerPageState(){
    if(!linkOverlays) {
      OverlayHelper.linkHelpers(overlays);

      linkOverlays = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea (
      child: GestureDetector (
        child: Scaffold(
          appBar: AppBar(
            title: Container(
              child: Text(
                currentManager!.getDisplayName(),
                textScaleFactor: 0.8,
                style: TextStyle(color: ThemeHandler.getContrastedColor(context) ?? Colors.white),
              ),
              padding: EdgeInsets.all(6.0),
              decoration: ThemeHandler.basicDecoration(context),
            ),
            actions: [
              _buildSettingsWidget.call(context, setState)
            ],
            backgroundColor: ThemeHandler.checkThemeMode(context, Colors.white, null),
            iconTheme: IconTheme.of(context).copyWith(color: Theme.of(context).primaryColor),
          ),
          body: ThingManagerWidget(),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.api,
              color: ThemeHandler.getContrastedColor(context) ?? Colors.white,
            ),
            onPressed: () {
              setState(() {
                pickMenuHelper.interactWithOverlay(context, setState);
              });
            },
            backgroundColor: Theme.of(context).primaryColor,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            // Fix for issue with notch in debug env
            shape: !kDebugMode ? CircularNotchedRectangle() : null,
            notchMargin: 10,
            child: Row(
              children:[
                Container (
                  child: TextButton (
                    key: filterMenuHelper.overlayKey,
                    child: Text (
                      "Filters",
                      style: TextStyle(color: ThemeHandler.getContrastedColor(context)),
                    ),
                    onPressed: () => setState(() => filterMenuHelper.interactWithOverlay(context, setState)),
                    style: ThemeHandler.whiteTextButtonStyle(),
                  ),
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  decoration: ThemeHandler.basicDecoration(context),//.copyWith(color: Colors.red),
                ),
                Container (width: 60, height: 0),
                Container (
                  child: TextButton (
                    key: presetMenuHelper.overlayKey,
                    child: Text (
                      "Presets",
                      style: TextStyle(color: ThemeHandler.getContrastedColor(context)),
                    ),
                    onPressed: () => setState(() => presetMenuHelper.interactWithOverlay(context, setState)),
                    style: ThemeHandler.whiteTextButtonStyle(),
                  ),
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  decoration: ThemeHandler.basicDecoration(context),//.copyWith(color: Colors.red),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          ),
          //backgroundColor: Theme.of(context).brightness == Brightness.light ? Color.alphaBlend(Theme.of(context).primaryColor.withAlpha(50), Colors.white) : null,
        ),
        onTap: closeAllOverlays,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    super.dispose();

    routeObserver.unsubscribe(this);
  }

  @override
  void didPop() {
    closeAllOverlays();
  }

  void closeAllOverlays(){
    for (var overlay in overlays) {
      if(overlay.removeOverlay(forcedClosed: true)) {
        overlay.toggleOverlay();
      }
    }
  }
}

//---------------------------------------------------------------------------

class SettingsWidget extends StatefulWidget{

  final UpdateParentState updateStateMethod;

  SettingsWidget(this.updateStateMethod);

  @override
  State<StatefulWidget> createState() => _SettingsState();

}

class _SettingsState extends State<SettingsWidget>{

  _SettingsState();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(filter: ColorFilter.mode(Colors.black38, BlendMode.darken),
      child: GestureDetector(
        child: FractionallySizedBox(widthFactor: getScaleValueTest(context, 0.3, 250, 1.5, 1080), //Transform.scale(scaleX: getScaleValue(context, 0.4, 0.9),//0.35,
          child: FittedBox(
            child: Card(
              child: FittedBox(
                child: Container(
                  child: Column(
                    children: [
                    Material(
                      child: Container(
                        child: Text("Main Settings"),
                        // width: 500,
                        alignment: Alignment.center,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white12
                    ),
                    Divider(),
                    CustomColorSettingsWidget(widget.updateStateMethod,
                      title: 'Main Theme Color',
                      subtitleBuilder: (color) => '${ColorTools.materialNameAndCode(color)} aka ${ColorTools.nameThatColor(color)}',
                      settingKey: "main_theme_color",
                      onChange: (color) {
                        updateMainAppWidget(context);
                      },
                    ),
                    RadioSettingsTile(
                      title: "Brightness Mode",
                      settingKey: "brightness_mode",
                      values: <int, String>{
                        0: 'System',
                        1: 'Light Mode',
                        2: 'Dark Mode',
                      },
                      onChange: (color) {
                        updateMainAppWidget(context);
                      },
                      selected: Settings.getValue<int>("brightness_mode", defaultValue: 0),
                    ),
                    CheckboxSettingsTile( //CheckboxSettingsTile
                      leading: Icon(Icons.contrast),
                      settingKey: 'full_black_text_icons',
                      title: 'Black Text And Icon Color',
                      onChange: (value) {
                        ThemeHandler.fullBlackTextIcons = Settings.getValue("full_black_text_icons") ?? ThemeHandler.fullBlackTextIcons;
                        updateMainAppWidget(context);
                      },
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10.0),
                width: 450,
                ),
              ),
              elevation: 20.0,
            ),
          ),
        ),
      ),
    );
  }

  static void updateMainAppWidget(BuildContext context){
    MyApp.of(context).setState(() {});
  }

}

