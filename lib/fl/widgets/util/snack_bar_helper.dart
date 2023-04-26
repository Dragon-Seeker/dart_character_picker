
import 'package:flutter/material.dart';

import '../../../common/util/string_utils.dart';
import '../../fl_main.dart';
import '../ui_data/theme_data.dart';

enum SnackBarColors{
  dark(Colors.black54, [Colors.white]),
  light(Colors.black54, [Colors.black]);

  final Color? backgroundColor;
  final List<Color> outputTextColor;

  const SnackBarColors(this.backgroundColor, this.outputTextColor);

  ///
  /// 0 - Normal
  /// 1 - Warning
  /// 2 - Error
  ///

  Color getTextColor(int warningType){
    if(outputTextColor.length == 3){
      return outputTextColor[warningType];
    } else {
      return outputTextColor[0];
    }
  }

  Color? getBackgroundColor(){
    if(this == light){
      return Color.lerp(backgroundColor, ThemeHandler.getPrimaryColor(), 0.8);
    }

    return backgroundColor;
  }
}

class SnackBarMaker {

  static SnackBar errorSnack(String warningText){
    return normalSnack("[Warning]:" + warningText, Colors.red, warningType: 2);
  }

  static SnackBar warningSnack(String warningText){
    return normalSnack(warningText, Colors.yellow, warningType: 1, icon: Icons.error_outline_rounded);
  }

  static SnackBar normalSnack(String text, Color? color, { int warningType = 0, IconData icon = Icons.arrow_forward_ios}){
    SnackBarColors colorData = ThemeHandler.getThemeMode() == ThemeMode.dark ? SnackBarColors.dark : SnackBarColors.light;

    return SnackBar(
      content: Container(
        child: Container(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: Icon(icon,
                    color: color),
              ),
              Text(text,
                style: TextStyle(
                    inherit: true,
                    color: colorData.getTextColor(warningType),
                ),
              ),
            ],
          ),
          constraints: BoxConstraints.tight(Size(100, 20)),
        ),
      ),
      width: 400,
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorData.getBackgroundColor(),//colorData.backgroundColor,
      elevation: 200,
    );
  }

  static sendSnackBar(SnackBar snackBar, {BuildContext? context}){
    ScaffoldMessengerState? state;

    if(context != null){
      state = ScaffoldMessenger.of(context);
    } else {
      state = MyApp.snackBarKey.currentState;
    }

    if(state != null){
      state.showSnackBar(snackBar);
    } else {
      TextLogger.errorOutput("Seems that a snackBar was not sent due to the ScaffoldMessengerState not existing at this time");
    }
  }

}