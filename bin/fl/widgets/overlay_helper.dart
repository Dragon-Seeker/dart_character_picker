
import 'package:flutter/cupertino.dart';

typedef UpdateParentState = void Function(void Function());

class OverlayHelper {

  static int numberOfLinkedHelpers = 0;

  static Map<String, List<OverlayHelper>> linkedOverlays = {};

  //-----------------------

  GlobalKey overlayKey;

  bool isOverlayVisible = false;

  OverlayEntry Function(UpdateParentState updateStateMethod) overlayBuilder;

  //-----------------------

  OverlayEntry? overlayEntry;

  String linkedId = "none";

  void Function()? doWhenForcedClose;

  //-----------------------

  OverlayHelper(this.overlayKey, this.overlayBuilder);

  static void linkHelpers(List<OverlayHelper> helpers){
    for(OverlayHelper helper in helpers){
      helper.linkedId = "LinkedHelpersGroup$numberOfLinkedHelpers";
    }

    linkedOverlays["LinkedHelpersGroup$numberOfLinkedHelpers"] = helpers;

    numberOfLinkedHelpers++;
  }

  //-----------------------
  void interactWithOverlay(BuildContext context, void Function(void Function()) updateStateMethod){
    if(!removeOverlay(forcedClosed: true)){
      List<OverlayHelper> helpers = linkedOverlays[linkedId] ?? [];

      for(OverlayHelper helper in helpers){
        if(helper.removeOverlay()){
          helper.toggleOverlay();
        }
      }

      overlayEntry = overlayBuilder.call(updateStateMethod);

      Overlay.of(context)!.insert(overlayEntry!);
    }

    toggleOverlay();
  }

  void toggleOverlay(){
    isOverlayVisible = !isOverlayVisible;
  }

  bool removeOverlay({bool forcedClosed = false}){
    if(isOverlayVisible) {
      if(overlayEntry != null) {
        if(forcedClosed){
          doWhenForcedClose?.call();
        }

        overlayEntry!.remove();
      }

      return true;
    }

    return false;
  }

}