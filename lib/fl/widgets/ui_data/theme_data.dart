
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class ThemeHandler {

  static bool fullBlackTextIcons = Settings.getValue("full_black_text_icons", defaultValue: false)!;

  static ThemeData themeData(){
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: getPrimaryColor(),
      //colorScheme: ColorScheme.light().copyWith(primary: getPrimaryColor()),
    );
  }

  static ThemeData darkThemeData(){
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: getPrimaryColor(),
      //colorScheme: ColorScheme.dark().copyWith(primary: getPrimaryColor()),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
            onSurface: Colors.white,
          )
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onSurface: Colors.white,
          )
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            primary: Colors.white,
            onSurface: Colors.white,
          )
      ),
    );
  }

  static ButtonStyle whiteTextButtonStyle() {
    return TextButton.styleFrom(
      primary: Colors.white,
      onSurface: Colors.white,
    );
  }

  static ButtonStyle? whiteElevatedButtonThemeData() {
    return ElevatedButton.styleFrom(
      primary: Colors.white,
      onSurface: Colors.white,
    );
  }

  static ButtonStyle whiteOutlinedButtonThemeData() {
    return OutlinedButton.styleFrom(
      primary: Colors.white,
      onSurface: Colors.white,
    );
  }

  static T checkThemeMode<T>(BuildContext context, T lightModeEntry, T darkModeEntry){
    return Theme.of(context).brightness == Brightness.light ? lightModeEntry : darkModeEntry;
  }

  static BoxDecoration basicDecoration(BuildContext context){
    return BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: basicRadius());
  }

  static BorderRadius basicRadius(){
    return BorderRadius.all(Radius.circular(5));
  }

  //--------------------------------------------------------------------------------------------------

  static ThemeMode getThemeMode(){
    return ThemeMode.values[Settings.getValue<int>("brightness_mode", defaultValue: 0)!];
  }

  static Color? getPrimaryColor(){
    return Settings.getValue<Color>("main_theme_color");
  }

  static Color? getContrastedColor(BuildContext context){
    return fullBlackTextIcons ? Colors.black : null;
  }

}