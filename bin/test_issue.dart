import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Page1(),
    );
  }
}

class Page1 extends StatelessWidget {

  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Page 1"),
        ),
        body: Container(
          child: Container(
            child: TextButton(
              child: Text("Go to next page"),
              onPressed: () async {
                await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                      return const Page2();
                    }
                  )
                );
              },
              style: TextButton.styleFrom(primary: Colors.white, padding: EdgeInsets.all(32.0)),
            ),
            padding: EdgeInsets.all(4.0),
            color: Colors.blue,
          ),
          alignment: Alignment.topLeft,
        ),
      ),
    );
  }
}

//TODO: Issue the fucks up mouse clicking completely!

//======== Exception caught by scheduler library =====================================================
// The following assertion was thrown during a scheduler callback:
// Scaffold.geometryOf() must only be accessed during the paint phase.
//
// The ScaffoldGeometry is only available during the paint phase, because its value is computed during the animation and layout phases prior to painting.
// When the exception was thrown, this was the stack:
// #0      _ScaffoldGeometryNotifier.value.<anonymous closure> (package:flutter/src/material/scaffold.dart:765:9)
// #1      _ScaffoldGeometryNotifier.value (package:flutter/src/material/scaffold.dart:771:6)
// #2      _BottomAppBarClipper.getClip (package:flutter/src/material/bottom_app_bar.dart:194:35)
// #3      _RenderCustomClip._updateClip (package:flutter/src/rendering/proxy_box.dart:1382:25)
// #4      RenderPhysicalShape.hitTest (package:flutter/src/rendering/proxy_box.dart:2013:7)
// #5      RenderBoxContainerDefaultsMixin.defaultHitTestChildren.<anonymous closure> (package:flutter/src/rendering/box.dart:2824:25)
// #6      BoxHitTestResult.addWithPaintOffset (package:flutter/src/rendering/box.dart:785:31)
// #7      RenderBoxContainerDefaultsMixin.defaultHitTestChildren (package:flutter/src/rendering/box.dart:2819:33)
// #8      RenderCustomMultiChildLayoutBox.hitTestChildren (package:flutter/src/rendering/custom_layout.dart:413:12)
// #9      RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #10     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #11     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #12     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #13     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #14     RenderPhysicalModel.hitTest (package:flutter/src/rendering/proxy_box.dart:1918:18)
// #15     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #16     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #17     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #18     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #19     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #20     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #21     RenderIgnorePointer.hitTest (package:flutter/src/rendering/proxy_box.dart:3349:31)
// #22     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #23     RenderTransform.hitTestChildren.<anonymous closure> (package:flutter/src/rendering/proxy_box.dart:2399:22)
// #24     BoxHitTestResult.addWithRawTransform (package:flutter/src/rendering/box.dart:824:31)
// #25     BoxHitTestResult.addWithPaintTransform (package:flutter/src/rendering/box.dart:749:12)
// #26     RenderTransform.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:2395:19)
// #27     RenderTransform.hitTest (package:flutter/src/rendering/proxy_box.dart:2389:12)
// #28     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #29     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #30     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #31     RenderTransform.hitTestChildren.<anonymous closure> (package:flutter/src/rendering/proxy_box.dart:2399:22)
// #32     BoxHitTestResult.addWithRawTransform (package:flutter/src/rendering/box.dart:824:31)
// #33     BoxHitTestResult.addWithPaintTransform (package:flutter/src/rendering/box.dart:749:12)
// #34     RenderTransform.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:2395:19)
// #35     RenderTransform.hitTest (package:flutter/src/rendering/proxy_box.dart:2389:12)
// #36     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #37     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #38     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #39     RenderProxyBoxWithHitTestBehavior.hitTest (package:flutter/src/rendering/proxy_box.dart:178:19)
// #40     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #41     RenderTransform.hitTestChildren.<anonymous closure> (package:flutter/src/rendering/proxy_box.dart:2399:22)
// #42     BoxHitTestResult.addWithRawTransform (package:flutter/src/rendering/box.dart:824:31)
// #43     BoxHitTestResult.addWithPaintTransform (package:flutter/src/rendering/box.dart:749:12)
// #44     RenderTransform.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:2395:19)
// #45     RenderTransform.hitTest (package:flutter/src/rendering/proxy_box.dart:2389:12)
// #46     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #47     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #48     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #49     RenderTransform.hitTestChildren.<anonymous closure> (package:flutter/src/rendering/proxy_box.dart:2399:22)
// #50     BoxHitTestResult.addWithRawTransform (package:flutter/src/rendering/box.dart:824:31)
// #51     BoxHitTestResult.addWithPaintTransform (package:flutter/src/rendering/box.dart:749:12)
// #52     RenderTransform.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:2395:19)
// #53     RenderTransform.hitTest (package:flutter/src/rendering/proxy_box.dart:2389:12)
// #54     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #55     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #56     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #57     RenderProxyBoxWithHitTestBehavior.hitTest (package:flutter/src/rendering/proxy_box.dart:178:19)
// #58     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #59     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #60     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #61     _RenderFocusTrap.hitTest (package:flutter/src/widgets/routes.dart:2172:19)
// #62     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #63     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #64     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #65     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #66     RenderOffstage.hitTest (package:flutter/src/rendering/proxy_box.dart:3468:31)
// #67     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #68     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #69     _RenderTheatre.hitTestChildren.<anonymous closure> (package:flutter/src/widgets/overlay.dart:771:25)
// #70     BoxHitTestResult.addWithPaintOffset (package:flutter/src/rendering/box.dart:785:31)
// #71     _RenderTheatre.hitTestChildren (package:flutter/src/widgets/overlay.dart:766:33)
// #72     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #73     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #74     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #75     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #76     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #77     RenderAbsorbPointer.hitTest (package:flutter/src/rendering/proxy_box.dart:3566:17)
// #78     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #79     RenderProxyBoxWithHitTestBehavior.hitTest (package:flutter/src/rendering/proxy_box.dart:178:19)
// #80     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #81     RenderCustomPaint.hitTestChildren (package:flutter/src/rendering/custom_paint.dart:535:18)
// #82     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #83     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #84     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #85     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #86     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #87     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #88     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #89     RenderProxyBoxMixin.hitTestChildren (package:flutter/src/rendering/proxy_box.dart:131:19)
// #90     RenderBox.hitTest (package:flutter/src/rendering/box.dart:2463:11)
// #91     RenderView.hitTest (package:flutter/src/rendering/view.dart:185:14)
// #92     RenderView.hitTestMouseTrackers (package:flutter/src/rendering/view.dart:199:5)
// #93     MouseTracker._findAnnotations (package:flutter/src/rendering/mouse_tracker.dart:262:47)
// #94     MouseTracker.updateAllDevices.<anonymous closure> (package:flutter/src/rendering/mouse_tracker.dart:361:80)
// #95     MouseTracker._deviceUpdatePhase (package:flutter/src/rendering/mouse_tracker.dart:211:9)
// #96     MouseTracker.updateAllDevices (package:flutter/src/rendering/mouse_tracker.dart:358:5)
// #97     RendererBinding._scheduleMouseTrackerUpdate.<anonymous closure> (package:flutter/src/rendering/binding.dart:387:22)
// #98     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1146:15)
// #99     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1091:9)
// #100    SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:997:5)
// #104    _invoke (dart:ui/hooks.dart:151:10)
// #105    PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:308:5)
// #106    _drawFrame (dart:ui/hooks.dart:115:31)
// (elided 3 frames from dart:async)
// ====================================================================================================

class Page2 extends StatelessWidget {

  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Page 2"),
        ),
        body: Container(),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.api,
            color: Colors.white,
          ),
          onPressed: () {},
          backgroundColor: Colors.red,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          // Fix for issue with notch in debug env
          shape: !kDebugMode ? CircularNotchedRectangle() : null,
          notchMargin: 4.0,
          child: Row(
            children:[
              Container (
                child: TextButton (
                  child: Text (
                    "Test 3",
                  ),
                  onPressed: () {},
                ),
              ),
              Container (
                child: TextButton (
                  child: Text (
                    "Test 4",
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
        ),
      )
    );
  }

}

// class Page2 extends StatelessWidget {
//
// }

