import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wls_pos/utility/widgets/wls_pos_app_bar.dart';

class WlsPosScaffold extends StatefulWidget {
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool showAppBar;
  final bool showDrawerIcon;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;

  final DragStartBehavior drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final Widget? appBarTitle;
  final bool showLoginBtnOnAppBar;
  final bool centerTitle;
  final bool isHomeScreen;
  final VoidCallback? onBackButton;
  final bool? mAppBarBalanceChipVisible;

  const WlsPosScaffold(
      {Key? key,
      this.showAppBar = false,
      this.showDrawerIcon = true,
      this.body,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.floatingActionButtonAnimator,
      this.persistentFooterButtons,
      this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
      this.drawer,
      this.onDrawerChanged,
      this.endDrawer,
      this.onEndDrawerChanged,
      this.bottomNavigationBar,
      this.bottomSheet,
      this.backgroundColor,
      this.resizeToAvoidBottomInset,
      this.primary = true,
      this.drawerDragStartBehavior = DragStartBehavior.start,
      this.extendBody = false,
      this.extendBodyBehindAppBar = false,
      this.drawerScrimColor,
      this.drawerEdgeDragWidth,
      this.drawerEnableOpenDragGesture = false,
      this.endDrawerEnableOpenDragGesture = true,
      this.restorationId,
      this.appBarTitle,
      this.showLoginBtnOnAppBar = true,
      this.centerTitle = true,
      this.isHomeScreen = false,
      this.onBackButton,
      this.mAppBarBalanceChipVisible = true})
      : super(key: key);

  @override
  State<WlsPosScaffold> createState() => _WlsPosScaffoldState();
}

class _WlsPosScaffoldState extends State<WlsPosScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? WlsPosAppBar(
          title: widget.appBarTitle,
          mAppBarBalanceChipVisible: widget.mAppBarBalanceChipVisible,
          centeredTitle: widget.centerTitle,
          showDrawer: widget.showDrawerIcon,
          isHomeScreen: widget.isHomeScreen,
          onBackButton: widget.onBackButton,
      )
          : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      persistentFooterButtons: widget.persistentFooterButtons,
      persistentFooterAlignment: widget.persistentFooterAlignment,
      drawer: widget.drawer,
      onDrawerChanged: widget.onDrawerChanged,
      endDrawer: widget.endDrawer,

      onEndDrawerChanged: widget.onEndDrawerChanged,
      bottomNavigationBar: widget.bottomNavigationBar,
      bottomSheet: widget.bottomSheet,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      primary: widget.primary,
      drawerDragStartBehavior: widget.drawerDragStartBehavior,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawerScrimColor: widget.drawerScrimColor,
      drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      restorationId: widget.restorationId,
    );
  }
}
