import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import '../utility/app_constant.dart';
import '../utility/wls_pos_screens.dart';

class WlsPosDrawer extends StatefulWidget {
  final List<List<ModuleBeanLst>?> drawerModuleList;

  WlsPosDrawer({Key? key, required this.drawerModuleList}) : super(key: key);

  @override
  State<WlsPosDrawer> createState() => _WlsPosDrawerState();
}

class _WlsPosDrawerState extends State<WlsPosDrawer>
    with TickerProviderStateMixin {
  late final AnimationController _refreshBtnAnimationController;
  late final Animation<double> refreshBtnAnimation;

  @override
  void initState() {
    super.initState();
    print("drawerModuleList - > ${widget.drawerModuleList}");
    print("drawerModuleList length - > ${widget.drawerModuleList.length}");
    for (var i in widget.drawerModuleList) {
      print("drawerModuleList items---- > ${i?[0].moduleCode}");
      var data = i?[0].menuBeanList?[0].caption!;
    }
    setRefreshButtonAnimation();
  }

  @override
  void dispose() {
    _refreshBtnAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Drawer(
        width: context.screenWidth * (isLandscape ? 0.3 : 0.8),
        child: Container(
          width: context.screenWidth * (isLandscape ? 0.3 : 0.8),
          color: WlsPosColor.white,
          //header of drawer
          child: Column(
            children: [
              //Header
              Container(
                width: context.screenWidth * (isLandscape ? 0.3 : 0.8),
                color: WlsPosColor.navy_blue,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Image.asset("assets/icons/icon_drawer_user.png",
                          width: 70, height: 70),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          width: ((context.screenWidth * (isLandscape ? 0.3 : 0.8))-120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                UserInfo.userName.toString(),
                                style: const TextStyle(
                                  color: WlsPosColor.butterscotch,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              _spacer(),
                              Text(
                                "UserId : ${UserInfo.userId}",
                                style: const TextStyle(
                                  color: WlsPosColor.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                              _spacer(),
                              Text(
                                "Organisation : ${UserInfo.organisation}",
                                style: const TextStyle(
                                  color: WlsPosColor.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                              _spacer(),
                              BlocListener<LoginBloc, LoginState>(
                                listener: (context, state) {
                                  if (state is GetLoginDataSuccess) {
                                    if (state.response != null) {
                                      BlocProvider.of<AuthBloc>(context).add(
                                          UpdateUserInfo(
                                              loginDataResponse:
                                                  state.response!));
                                    }
                                  } else if (state is GetLoginDataError) {
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      _refreshBtnAnimationController.stop();
                                    });
                                  }
                                },
                                child: BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                  if (state is UserInfoUpdated) {
                                    _refreshBtnAnimationController.stop();
                                  }
                                  return Row(
                                    children: [
                                      Text(
                                        getUserBalance(),
                                        //UserInfo.totalBalance,
                                        style: const TextStyle(
                                          color: WlsPosColor.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(width: 5),
                                      InkWell(
                                        onTap: () {
                                          _refreshBtnAnimationController
                                              .forward();
                                          BlocProvider.of<LoginBloc>(context)
                                              .add(GetLoginDataApi(
                                                  context: context));
                                        },
                                        child: RotationTransition(
                                          turns: refreshBtnAnimation,
                                          child: Image.asset(
                                              "assets/icons/icon_refresh.png",
                                              width: 25,
                                              height: 25),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //ListView
              const HeightBox(5),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: WlsPosColor.white,
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, top: 0, bottom: 0),
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.drawerModuleList[index]?[0].displayName !=
                                            null
                                        ? widget
                                            .drawerModuleList[index]![0].displayName!
                                            .toString()
                                        : "",
                                    style: const TextStyle(
                                        color: WlsPosColor.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  ).pOnly(top: 4, bottom: 4),
                                  Container(
                                    color: Colors.white,
                                    width: context.screenWidth,
                                    height: ((widget.drawerModuleList[index]?[0]
                                            .menuBeanList?.length)! *
                                        42),
                                    child: ListView.separated(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index1) {
                                        return Material(
                                          color: WlsPosColor.white,
                                          child: InkWell(
                                            onTap: () {
                                              _onClick(widget
                                                  .drawerModuleList[index]![0]
                                                  .menuBeanList![index1]
                                                  .menuCode!);
                                            },
                                            child: Row(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  "assets/icons/${_getImage(widget.drawerModuleList[index]![0].menuBeanList![index1].menuCode!)}",
                                                  width: 25,
                                                  height: 25,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Text(
                                                widget
                                                            .drawerModuleList[
                                                                index]?[0]
                                                            .menuBeanList?[0]
                                                            .caption !=
                                                        null
                                                    ? widget
                                                        .drawerModuleList[
                                                            index]![0]
                                                        .menuBeanList![index1]
                                                        .caption!
                                                    : "",
                                                style: const TextStyle(
                                                    color: WlsPosColor.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            ]),
                                          ),
                                        );
                                      },
                                      itemCount: widget.drawerModuleList[index]?[0].menuBeanList?.length ?? 0,
                                      separatorBuilder: (context, index) {
                                        return Container(
                                          width: 100,
                                          height: 1,
                                          color: WlsPosColor.light_grey,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(
                                color: WlsPosColor.black,
                              );
                            },
                            itemCount: widget.drawerModuleList.length),
                      ),
                      SizedBox(
                        width: context.screenWidth * 0.8,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("assets/images/splash_logo.png",
                                  width: 70, height: 70),
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: const Text("Version 1.0.0"))
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _spacer() {
    return const SizedBox(height: 5);
  }

  _getImage(String code) {
    if (code == PAYMENT_REPORT) {
      return "icon_drawer_payment_report.png";
    }
    if (code == OLA_REPORT) {
      return "icon_drawer_deposit_withdraw_report.png";
    }
    if (code == CHANGE_PASSWORD) {
      return "icon_drawer_change_password.png";
    }
    if (code == DEVICE_REGISTRATION) {
      return "icon_drawer_device_register.png";
    }
    if (code == LOGOUT) {
      return "icon_drawer_logout.png";
    }
    if (code == BILL_REPORT) {
      return "icon_drawer_invoice.png";
    }
    if (code == M_LEDGER) {
      return "icon_drawer_ledger_report.png";
    }
    if (code == USER_REGISTRATION) {
      return "icon_drawer_user_registration.png";
    }
    if (code == USER_SEARCH) {
      return "icon_drawer_search_user.png";
    }
    if (code == ACCOUNT_SETTLEMENT) {
      return "icon_drawer_account_settlement.png";
    }
    if (code == SETTLEMENT_REPORT) {
      return "icon_drawer_settlement_report.png";
    }
    if (code == SALE_WINNING_REPORT) {
      return "icon_drawer_sale_winning_report.png";
    }
    if (code == INTRA_ORG_CASH_MGMT) {
      return "icon_drawer_cash_management.png";
    }
    if (code == M_SUMMARIZE_LEDGER) {
      return "ledger.png";
    }
    if (code == COLLECTION_REPORT) {
      return "icon_drawer_ledger_report.png";
    }
    if (code == ALL_RETAILERS) {
      return "icon_drawer_search_user.png";
    }
    if (code == QR_CODE_REGISTRATION) {
      return "icon_qr.png";
    }
    if (code == NATIVE_DISPLAY_QR) {
      return "icon_qr.png";
    }
    if (code == BALANCE_REPORT) {
      return "balance.png";
    }
    if (code == OPERATIONAL_REPORT) {
      return "statistics.png";
    }
  }

  _onClick(String code) {
    if (code == PAYMENT_REPORT) {
      return "icon_drawer_payment_report.png";
    }
    if (code == OLA_REPORT) {
      Navigator.pop(context);
      Navigator.pushNamed(context, WlsPosScreen.depositWithdrawalScreen);
      // return "icon_drawer_deposit_withdraw_report.png";
    }
    if (code == CHANGE_PASSWORD) {
      Navigator.pushNamed(
          context, WlsPosScreen.changePin);
    }
    if (code == DEVICE_REGISTRATION) {
      return "icon_drawer_device_register.png";
    }
    if (code == LOGOUT) {
      UserInfo.logout();
      Navigator.of(context).pushNamedAndRemoveUntil(
          WlsPosScreen.loginScreen, (Route<dynamic> route) => false);
    }
    if (code == BILL_REPORT) {
      return "icon_drawer_invoice.png";
    }
    if (code == M_LEDGER) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, WlsPosScreen.ledgerReportScreen);
    }
    if (code == USER_REGISTRATION) {
      return "icon_drawer_user_registration.png";
    }
    if (code == USER_SEARCH) {
      return "icon_drawer_search_user.png";
    }
    if (code == ACCOUNT_SETTLEMENT) {
      return "icon_drawer_account_settlement.png";
    }
    if (code == SETTLEMENT_REPORT) {
      return "icon_drawer_settlement_report.png";
    }
    if (code == SALE_WINNING_REPORT) {
      Navigator.pushNamed(
          context, WlsPosScreen.saleWinTxn);
    }
    if (code == INTRA_ORG_CASH_MGMT) {
      return "icon_drawer_cash_management.png";
    }
    if (code == M_SUMMARIZE_LEDGER) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, WlsPosScreen.summarizeLedgerReport);
    }
    if (code == COLLECTION_REPORT) {
      return "icon_drawer_ledger_report.png";
    }
    if (code == ALL_RETAILERS) {
      return "icon_drawer_search_user.png";
    }
    if (code == QR_CODE_REGISTRATION) {
      return "icon_qr.png";
    }
    if (code == NATIVE_DISPLAY_QR) {
      return "icon_qr.png";
    }
    if (code == BALANCE_REPORT) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, WlsPosScreen.balanceInvoiceReportScreen);
    }
    if (code == OPERATIONAL_REPORT) {
      Navigator.of(context).pop();
      Navigator.pushNamed(context, WlsPosScreen.operationalReportScreen);
    }
  }

  String getUserBalance() {
    String balance = UserInfo.totalBalance.replaceAll(',', '.');
    return '$balance ${getDefaultCurrency(getLanguage())}';
  }

  void setRefreshButtonAnimation() {
    _refreshBtnAnimationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    refreshBtnAnimation =
        Tween<double>(begin: 1, end: 2).animate(_refreshBtnAnimationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _refreshBtnAnimationController.reset();
            } else if (status == AnimationStatus.dismissed) {
              _refreshBtnAnimationController.forward();
            }
          });
  }
}
