import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/login/models/response/GetLoginDataResponse.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class WlsPosAppBar extends StatefulWidget implements PreferredSizeWidget {
  const WlsPosAppBar({
    this.myKey,
    Key? key,
    this.title = const Text(''),
    this.showBalance,
    this.showBell,
    this.showDrawer,
    this.backgroundColor,
    this.showBottomAppBar = false,
    this.centeredTitle = false,
    this.bottomTapvalue,
    this.bottomTapLoginValue,
    this.onBackButton,
    this.isHomeScreen,
    this.mAppBarBalanceChipVisible
  }) : super(key: key);

  final GlobalKey<ScaffoldState>? myKey;
  final Widget? title;
  final bool? bottomTapvalue;
  final bool? bottomTapLoginValue;
  final bool? showDrawer;
  final bool? showBalance;
  final bool? showBell;
  final Color? backgroundColor;
  final bool? showBottomAppBar;
  final bool? centeredTitle;
  final bool? isHomeScreen;
  final VoidCallback? onBackButton;
  final bool? mAppBarBalanceChipVisible;

  @override
  State<WlsPosAppBar> createState() => _WlsPosAppBarState();

  @override
  Size get preferredSize => showBottomAppBar == false
      ? const Size(double.infinity, kToolbarHeight + 10)
      : const Size(double.infinity, kToolbarHeight * 2);
}

class _WlsPosAppBarState extends State<WlsPosAppBar> {
  bool? isUserLoggedIn;
  late Map<String, dynamic> prefs;

  Data? userInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("updating app bar");
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AppBar(
            centerTitle: widget.centeredTitle,
            backgroundColor: WlsPosColor.marine_two,
            elevation: 0,
            titleSpacing: 0,
            title: widget.isHomeScreen == true
                ? Image.asset(
                "assets/images/splash_logo.png", width: 70, height: 70)
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /* const CircleAvatar(
                    backgroundImage: AssetImage('assets/icons/SCRATCH.png'),
                  ),
                  const SizedBox(width: 5),*/
                widget.title ?? const Text(''),
              ],
            ),
            leading: Visibility(
              visible: widget.showDrawer ?? true,
              child: widget.isHomeScreen ?? true
                  ? MaterialButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                child: SvgPicture.asset("assets/icons/drawer.svg",
                    color: WlsPosColor.white),
              )
                  : MaterialButton(
                  onPressed: () {
                    widget.onBackButton != null
                        ? widget.onBackButton!()
                        : Navigator.of(context).pop();
                  },
                  child: SvgPicture.asset("assets/icons/back_icon.svg",
                      color: WlsPosColor.white,
                      width: 5,
                      height: 25,
                      fit: BoxFit.contain)),
            ),
            actions: [
              widget.mAppBarBalanceChipVisible != null
                  ? Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4, right: 8),
                padding: const EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                    color: WlsPosColor.app_blue.withOpacity(0.2),
                    border: Border.all(color: WlsPosColor.white),
                    borderRadius: const BorderRadius.all(Radius.circular(50))
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: DefaultTextStyle
                          .of(context)
                          .style,
                      children: <TextSpan>[
                        const TextSpan(
                            text: 'Balance\n',
                            style: TextStyle(
                                fontSize: 12,
                                color: WlsPosColor.white)),
                        TextSpan(
                            text: getUserBalance(),//'${UserInfo.totalBalance} ${getDefaultCurrency(getLanguage())}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: WlsPosColor.neon_green
                            )),
                      ],
                    ),
                  ),
                ),
              )
                  : Container()
            ],
          );
        });
  }

  String getUserBalance() {
    String balance = UserInfo.totalBalance.replaceAll(',', '.');
    return '$balance ${getDefaultCurrency(getLanguage())}';
  }
}
