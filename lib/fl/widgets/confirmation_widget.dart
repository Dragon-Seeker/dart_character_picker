
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'util/overlay_helper.dart';
import 'ui_data/theme_data.dart';

class ConfirmationWidget extends StatelessWidget{

  final Text title;
  final Widget bodyWidget;

  final void Function(UpdateParentState) confirmFunc;
  final void Function() cancelFunc;

  final UpdateParentState updateParentWidget;

  ConfirmationWidget(Key key, this.updateParentWidget, {required this.title, required this.bodyWidget, required this.confirmFunc, required this.cancelFunc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations translate = MaterialLocalizations.of(context);

    //---------------------------

    Widget okButtonContent = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Padding(
        //   padding: const EdgeInsetsDirectional.only(end: 4),
        //   child: Icon(Icons.check),
        // ),
        Text("Delete"),
      ],
    );

    //---------------------------

    Widget cancelButtonContent = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        // Padding(
        //   padding: const EdgeInsetsDirectional.only(end: 4),
        //   child: Icon(Icons.close),
        // ),
        Text("Cancel")
      ],
    );

    //---------------------------

    Widget okButton;
    Widget cancelButton;

    ColorPickerActionButtonType dialogButtonType = ColorPickerActionButtonType.outlined;

    switch (dialogButtonType) {
      case ColorPickerActionButtonType.text:
        okButton = TextButton(
          child: okButtonContent,
          onPressed: () {
            confirmFunc.call(updateParentWidget);
          },
        );

        cancelButton = TextButton(
          child: cancelButtonContent,
          onPressed: cancelFunc,
        );

        break;
      case ColorPickerActionButtonType.outlined:
        okButton = OutlinedButton(
          child: okButtonContent,
          onPressed: () {
            confirmFunc.call(updateParentWidget);
          },
        );

        cancelButton = OutlinedButton(
          child: cancelButtonContent,
          onPressed: cancelFunc,
        );

        break;
      case ColorPickerActionButtonType.elevated:
        okButton = ElevatedButton(
          child: okButtonContent,
          onPressed: () {
            confirmFunc.call(updateParentWidget);
          },
        );

        cancelButton = ElevatedButton(
          child: cancelButtonContent,
          onPressed: cancelFunc,
        );

        break;
    }

    return AlertDialog(
      title: Material(
        child: Container(
          child: title,
          padding: EdgeInsets.all(10),
        ),
        borderRadius: ThemeHandler.basicRadius(),
      ),
      titlePadding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 6),
      content: Material(
        child: Container(
          child: Column(children: [
              bodyWidget,
              Divider(height: 30,),
              Row(children: [cancelButton, VerticalDivider(), okButton], mainAxisAlignment: MainAxisAlignment.center,),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        borderRadius: ThemeHandler.basicRadius(),
      ),
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 12),
      buttonPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      elevation: 2,
      scrollable: true,
    );
  }

}