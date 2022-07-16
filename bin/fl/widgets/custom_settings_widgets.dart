import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_settings_screens/src/utils/widget_utils.dart';

import '../../common/util/string_utils.dart';
import 'overlay_helper.dart';

class CustomColorSettingsWidget extends StatefulWidget{

  final UpdateParentState updateStateMethod;

  /// Settings Key string for storing the state of checkbox in cache (assumed to be unique)
  final String settingKey;

  /// initial value to be used as state of the checkbox, default = false
  final Color defaultValue;

  /// title for the settings tile
  final String title;

  /// subtitle for the settings tile, default = ''
  final String subtitle;

  /// title for the settings tile
  late final String Function(Color) titleBuilder;

  /// subtitle for the settings tile, default = ''
  late final String Function(Color) subtitleBuilder;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// flag which represents the state of the settings, if false the the tile will
  /// ignore all the user inputs, default = true
  final bool enabled;

  /// on change callback for handling the value change
  final OnChanged<Color>? onChange;

  CustomColorSettingsWidget(this.updateStateMethod, {
    required this.title,
    required this.settingKey,
    titleBuilder,
    subtitleBuilder,
    this.defaultValue = Colors.white,
    this.onChange,
    this.enabled = true,
    this.subtitle = '',
    this.titleTextStyle,
    this.subtitleTextStyle
  }){
    this.titleBuilder = titleBuilder ??  (color) => title;
    this.subtitleBuilder = subtitleBuilder ?? (color) => subtitle;
  }

  @override
  State<StatefulWidget> createState() => _CustomColorSettingsState();

}

class _CustomColorSettingsState extends State<CustomColorSettingsWidget>{

  OverlayHelper? colorMenuHelper;

  late UpdateParentState updateStateMethod;

  //-----------

  late Color currentDisplayedColor;

  //-----------

  _CustomColorSettingsState(){
    updateStateMethod = setState;
  }


  @override
  void dispose() {
    super.dispose();

    if(colorMenuHelper != null && colorMenuHelper!.removeOverlay(forcedClosed: true)) {
      colorMenuHelper!.toggleOverlay();
    }
  }

  @override
  void initState() {
    super.initState();

    currentDisplayedColor = Settings.getValue<Color>(widget.settingKey) ?? widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return ValueChangeObserver<Color>(cacheKey: widget.settingKey, defaultValue: widget.defaultValue, builder: (BuildContext context, Color value, OnChanged<Color> onChanged) {
      return Material(
        child: _SettingsTile(
          title: widget.titleBuilder!.call(currentDisplayedColor),
          enabled: widget.enabled,
          subtitle: widget.subtitleBuilder!.call(currentDisplayedColor),
          //onTap: () => _onColorChange(value, onChanged),
          titleTextStyle: widget.titleTextStyle,
          subtitleTextStyle: widget.subtitleTextStyle,
          child: ColorIndicator(
            width: 44,
            height: 44,
            borderRadius: 4,
            color: currentDisplayedColor,
            onSelectFocus: false,
            onSelect: () async {
              colorMenuHelper = OverlayHelper(LabeledGlobalKey("ColorMenu"), (UpdateParentState updateStateMethod) {
                return OverlayEntry(
                    builder: (context) {
                      return colorPickerDialog(context, updateStateMethod, value, onChanged);
                    }
                );
              });

              colorMenuHelper!.interactWithOverlay(context, setState);
            },
          ),
        )
      );

      // return Material(
      //   child: ListTile(
      //     title: const Text('Click this color to change it in a dialog'),
      //     subtitle: Text(
      //       '${ColorTools.materialNameAndCode(colorData.left)} aka ${ColorTools.nameThatColor(colorData.left)}',
      //     ),
      //     trailing: ColorIndicator(
      //       width: 44,
      //       height: 44,
      //       borderRadius: 4,
      //       color: colorData.left,
      //       onSelectFocus: false,
      //       onSelect: () async {
      //         colorMenuHelper = OverlayHelper(LabeledGlobalKey("ColorMenu"), (UpdateParentState updateStateMethod) {
      //           return OverlayEntry(
      //               builder: (context) {
      //                 return colorPickerDialog(context, updateStateMethod, value, onChanged);
      //               }
      //           );
      //         })..doWhenForcedClose = () => (colorData.right = null);
      //
      //         colorMenuHelper.interactWithOverlay(context, setState);
      //       },
      //     ),
      //   ),
      //   borderRadius: BorderRadius.circular(5.0),
      // );
    });
  }

  void _onColorChange(Color? value, OnChanged<Color> onChanged) {
    if (value == null) return;
    onChanged(value);
    widget.onChange?.call(value);
  }

  void closeOverlayOk(OnChanged<Color> onChanged) {
    if(colorMenuHelper!.removeOverlay()) {
      colorMenuHelper!.toggleOverlay();
    }

    debugPrint("Ok Button Color Saved: $currentDisplayedColor");

    _onColorChange(currentDisplayedColor, onChanged);

    // currentDisplayedColor = value.call();
    // colorData.left = colorData.right ?? colorData.left;
  }

  void closeOverlayCancel() {
    if(colorMenuHelper!.removeOverlay()) {
      colorMenuHelper!.toggleOverlay();
    }

    currentDisplayedColor = Settings.getValue<Color>(widget.settingKey) ?? widget.defaultValue;

    // colorData.right = null;
  }


  Widget colorPickerDialog(BuildContext context, UpdateParentState updateStateMethod, Color value, OnChanged<Color> onChanged) {
    ColorPickerActionButtonType dialogButtonType = ColorPickerActionButtonType.outlined;

    ColorPicker colorPickerWidget = ColorPicker(
      color: value,
      onColorChanged: (Color color) {
        updateStateMethod.call(() => currentDisplayedColor = color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 3,
      runSpacing: 5,
      wheelDiameter: 185,
      //155
      wheelSquarePadding: 10,
      heading: Text(
        'Select color',
        style: Theme
            .of(context)
            .textTheme
            .subtitle1,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme
            .of(context)
            .textTheme
            .subtitle1,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme
            .of(context)
            .textTheme
            .subtitle1,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: false,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        editFieldCopyButton: false,
        longPressMenu: true
      ),
      materialNameTextStyle: Theme
          .of(context)
          .textTheme
          .caption,
      colorNameTextStyle: Theme
          .of(context)
          .textTheme
          .bodyMedium,
      colorCodeTextStyle: Theme
          .of(context)
          .textTheme
          .caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    );

    MaterialLocalizations translate = MaterialLocalizations.of(context);

    //---------------------------

    Widget okButtonContent = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Icon(colorPickerWidget.actionButtons.okIcon),
        ),
        Text(colorPickerWidget.actionButtons.dialogOkButtonLabel ?? translate.okButtonLabel),
      ],
    );


    //---------------------------

    Widget cancelButtonContent = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Icon(colorPickerWidget.actionButtons.closeIcon),
        ),
        Text(colorPickerWidget.actionButtons.dialogCancelButtonLabel ?? translate.cancelButtonLabel
        ),
      ],
    );

    //---------------------------

    Widget okButton;
    Widget cancelButton;

    switch (dialogButtonType) {
      case ColorPickerActionButtonType.text:
        okButton = TextButton(
          child: okButtonContent,
          onPressed: () {
            closeOverlayOk(onChanged);
          },
        );

        cancelButton = TextButton(
          child: cancelButtonContent,
          onPressed: closeOverlayCancel,
        );

        break;
      case ColorPickerActionButtonType.outlined:
        okButton = OutlinedButton(
          child: okButtonContent,
          onPressed: () {
            closeOverlayOk(onChanged);
          },
        );

        cancelButton = OutlinedButton(
          child: cancelButtonContent,
          onPressed: closeOverlayCancel,
        );

        break;
      case ColorPickerActionButtonType.elevated:
        okButton = ElevatedButton(
          child: okButtonContent,
          onPressed: () {
            closeOverlayOk(onChanged);
          },
        );

        cancelButton = ElevatedButton(
          child: cancelButtonContent,
          onPressed: closeOverlayCancel,
        );

        break;
    }

    return AlertDialog(
      title: colorPickerWidget.title,
      content: ConstrainedBox(
        child: colorPickerWidget,
        constraints: BoxConstraints(
            minHeight: 100,
            minWidth: 300,
            maxWidth: 320
        ),
      ),
      actions: [cancelButton, okButton,],
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
      buttonPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      elevation: 2,
      scrollable: true,
    );
  }
}

/// This is a direct copy from [_SettingsTile] and is only used internally for a custom setting
class _SettingsTile extends StatefulWidget {
  /// title string for the tile
  final String title;

  /// widget to be placed at first in the tile
  final Widget? leading;

  /// subtitle string for the tile
  final String? subtitle;

  /// title text style
  final TextStyle? titleTextStyle;

  /// subtitle text style
  final TextStyle? subtitleTextStyle;

  /// flag to represent if the tile is accessible or not, if false user input is ignored
  final bool enabled;

  /// widget which is placed as the main element of the tile as settings UI
  final Widget child;

  /// call back for handling the tap event on tile
  final GestureTapCallback? onTap;

  /// flag to show the child below the main tile elements
  final bool showChildBelow;

  _SettingsTile({
    required this.title,
    required this.child,
    this.subtitle = '',
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.onTap,
    this.enabled = true,
    this.showChildBelow = false,
    this.leading,
  });

  @override
  __SettingsTileState createState() => __SettingsTileState();
}

class __SettingsTileState extends State<_SettingsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            leading: widget.leading,
            title: Text(
              widget.title,
              style: widget.titleTextStyle ?? headerTextStyle(context),
            ),
            subtitle: widget.subtitle?.isEmpty ?? true
                ? null
                : Text(
              widget.subtitle!,
              style:
              widget.subtitleTextStyle ?? subtitleTextStyle(context),
            ),
            enabled: widget.enabled,
            onTap: widget.onTap,
            trailing: Visibility(
              visible: !widget.showChildBelow,
              child: widget.child,
            ),
            dense: true,
            // wrap only if the subtitle is longer than 70 characters
            isThreeLine: (widget.subtitle?.isNotEmpty ?? false) &&
                widget.subtitle!.length > 70,
          ),
          Visibility(
            visible: widget.showChildBelow,
            child: widget.child,
          ),
          Divider(
            height: 0.0,
          ),
        ],
      ),
    );
  }
}