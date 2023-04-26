
import 'package:flutter/cupertino.dart';

import '../../../common/util/string_utils.dart';
import '../../fl_main.dart';

typedef UpdateParentState = void Function(void Function());

///
/// Class Used to better manage Overlay Entry's
///
class OverlayHelper {

  static final Key _emptyHelperKey = ValueKey("EMPTY_HELPER");

  static int _numberOfLinkedHelpers = 0;

  static Map<String, List<Key>> linkedOverlays = {};

  //-----------------------

  Key overlayKey;

  String linkedId = "none";

  OverlayEntry? overlayEntry;

  bool isOverlayVisible = false;

  bool removeOnClose = false;

  //-----------------------

  OverlayEntry? Function(UpdateParentState updateStateMethod, {Map<String, dynamic>? inputs}) overlayBuilder;

  void Function()? interactMethodFunction;

  //-----------------------

  OverlayHelper(this.overlayKey, this.overlayBuilder, {Key? linkedOverlay, this.removeOnClose = false}){
    if(linkedOverlay != null){
      linkedId = dataManager.getOverlayHelperSafe(linkedOverlay).linkedId;
    }
  }

  static void linkHelpers(List<OverlayHelper> helpers, { List<Key> overlayKeys = const[] }){
    for(OverlayHelper helper in helpers){
      helper.linkedId = "LinkedHelpersGroup$_numberOfLinkedHelpers";
    }

    linkedOverlays["LinkedHelpersGroup$_numberOfLinkedHelpers"] = overlayKeys..addAll(helpers.map((e) => e.overlayKey));

    _numberOfLinkedHelpers++;
  }

  static OverlayHelper emptyOverlayHelper(void Function() outputFunction){
    return OverlayHelper(_emptyHelperKey, (updateStateMethod, {Map<String, dynamic>? inputs}) {
      outputFunction.call();

      return null;
    });
  }

  //-----------------------

  bool openOverlay(BuildContext context, UpdateParentState updateStateMethod, {Map<String, dynamic> inputs = const {}}){
    if(!closeOverlay()){
      for(Key key in linkedOverlays[linkedId] ?? []){
        if(key == overlayKey) continue;

        dataManager.getOverlayHelper(key)?.closeOverlay();
      }

      overlayEntry = overlayBuilder.call(updateStateMethod, inputs: inputs);

      if(overlayEntry != null) Overlay.of(context)!.insert(overlayEntry!);

      toggleOverlayVisablity();

      return true;
    }

    return false;
  }

  bool closeOverlay(){
    if(isOverlayVisible) {
      if(overlayEntry != null) {
        overlayEntry!.remove();
      }

      if(removeOnClose){
        dataManager.removeOverlayHelper(overlayKey);
      }

      toggleOverlayVisablity();

      return true;
    }

    return false;
  }

  void closeAllLinkedOverlays(){
    if(linkedId != "none"){
      for(Key key in linkedOverlays[linkedId] ?? []){
        dataManager.getOverlayHelper(key)?.closeOverlay();
      }
    }
  }

  bool toggleOverlayVisablity(){
    isOverlayVisible = !isOverlayVisible;

    TextLogger.consoleOutput("{} was just Toggled to: {}", args: [overlayKey, isOverlayVisible]);

    return isOverlayVisible;
  }

  bool isAnEmptyOverlay(){
    return overlayKey == _emptyHelperKey;
  }


}