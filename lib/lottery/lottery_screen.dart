import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/lottery/bloc/lottery_bloc.dart';
import 'package:wls_pos/lottery/bloc/lottery_event.dart';
import 'package:wls_pos/lottery/bloc/lottery_state.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/lottery/pick_type_screen.dart';
import 'package:wls_pos/lottery/widgets/cancel_ticket_confirmation_dialog.dart';
import 'package:wls_pos/lottery/widgets/draw_not_available_msg.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/lottery_bottom_nav/last_result_dialog/last_result_dialog.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/bloc/winning_claim_bloc.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/bloc/winning_claim_event.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/bloc/winning_claim_state.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/response/TicketVerifyResponse.dart' as winning_claim;
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/my_timer_lottery.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart' as re_print_resp;
import '../login/bloc/login_bloc.dart';
import 'lottery_game_screen.dart';
import 'dart:math' as math;

import 'models/response/RePrintResponse.dart';

class LotteryScreen extends StatefulWidget {
  const LotteryScreen({Key? key}) : super(key: key);

  @override
  State<LotteryScreen> createState() => _LotteryScreenState();
}

class _LotteryScreenState extends State<LotteryScreen> {
  List<GameRespVOs> lotteryGameObjectList   = [];
  List<String> lotteryGameCodeList    = [];
  bool _mIsShimmerLoading = false;
  bool timeUpdating = false;
  String? currentDateTime;
  bool isLastResultOrRePrintingOrCancelling = false;
  List<String> mComingSoonGameCodeList = ["BingoSeventyFive3","ThaiLottery","BichoRapido","TwoDMYANMAAR"];
  List<PanelBean> listPanelData   = [];
  bool isNoInternet   = false;
  BuildContext? lotteryBlocContext;
  UrlDrawGameBean?  verifyTicketUrls;
  winning_claim.ResponseData? verifyResponse;
  winning_claim.TicketVerifyResponse? ticketVerifyResponse;
  Map<String, dynamic> printingDataArgs               = {};
  List<String> listOfBalls = [];//only for twoDMyanMaar

  @override
  void initState() {
    super.initState();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
      ModuleBeanLst? drawerModuleBeanList     = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
      MenuBeanList? winningClaimMenuBeanList  = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_WIN_CLAIM").toList()[0];
      verifyTicketUrls  = getDrawGameUrlDetails(winningClaimMenuBeanList!, context, "verifyTicket");
      BlocProvider.of<LotteryBloc>(context).add(FetchGameDataApi(context: context));
    listOfBalls =
    List<String>.generate(100, (i) => i.length > 1 ? "$i" : "0$i");
    }

    void viewWillAppear() {
      setState(() {});
    }

    @override
    Widget build(BuildContext context) {
      final Orientation orientation = MediaQuery.of(context).orientation;
      final bool isLandscape = (orientation == Orientation.landscape);

      return FocusDetector(
        onFocusGained: viewWillAppear,
        child: SafeArea(
          child: AbsorbPointer(
            absorbing: isLastResultOrRePrintingOrCancelling,
          child: WillPopScope(
            onWillPop: () async{
              return !isLastResultOrRePrintingOrCancelling;
            },
            child: WlsPosScaffold(
                showAppBar: true,
                drawer: WlsPosDrawer(drawerModuleList: const []),
                backgroundColor: _mIsShimmerLoading ? WlsPosColor.light_dark_white : WlsPosColor.white,
                appBarTitle: const Text("Lottery", style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
                bottomNavigationBar: AbsorbPointer(
                  absorbing: isLastResultOrRePrintingOrCancelling,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: WlsPosColor.warm_grey_six, width: 1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _mIsShimmerLoading
                            ? Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[300]!,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: WlsPosColor.warm_grey,
                                        blurRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width : 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )
                                        ),
                                      ).p(6),
                                      Container(
                                        width : 70,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )
                                        ),
                                      ).pOnly(left: 6, right: 6, bottom: 6),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: WlsPosColor.warm_grey,
                                        blurRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width : 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )
                                        ),
                                      ).p(6),
                                      Container(
                                        width : 70,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )
                                        ),
                                      ).pOnly(left: 6, right: 6, bottom: 6),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: WlsPosColor.warm_grey,
                                        blurRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width : 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )
                                        ),
                                      ).p(6),
                                      Container(
                                        width : 70,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )
                                        ),
                                      ).pOnly(left: 6, right: 6, bottom: 6),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: WlsPosColor.warm_grey,
                                        blurRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width : 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )
                                        ),
                                      ).p(6),
                                      Container(
                                        width : 70,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )
                                        ),
                                      ).pOnly(left: 6, right: 6, bottom: 6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextButton(
                                  clipBehavior: Clip.hardEdge,
                                  onPressed: () {
                                    Navigator.pushNamed(context, WlsPosScreen.winningClaimScreen);
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset("assets/images/win.png", width: 25, height: 25,),
                                      const SizedBox(height: 2,),
                                      const Text("Winning Claim", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: WlsPosColor.warm_grey_three))
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  clipBehavior: Clip.hardEdge,
                                  onPressed: () {
                                    showGeneralDialog(
                                        context: context,
                                        pageBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double> secondaryAnimation) {
                                          return Container();
                                        },
                                        transitionBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double> secondaryAnimation,
                                            child) {
                                          var curve = Curves.easeInOut.transform(animation.value);
                                          return Transform.scale(
                                            scale: curve,
                                            child: LastResultDialog(
                                                lotteryGameObjectList: lotteryGameObjectList,
                                                mCallBack: (
                                                    UrlDrawGameBean? apiUrlDetails ,
                                                    String fromDateTime,
                                                    String toDateTime,
                                                    String gameCode
                                                    ) {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    isLastResultOrRePrintingOrCancelling = true;
                                                  });
                                                  BlocProvider.of<LotteryBloc>(this.context).add(ResultApi(
                                                      context: context,
                                                      apiUrlDetails: apiUrlDetails,
                                                      fromDateTime: fromDateTime,
                                                      toDateTime: toDateTime,
                                                      gameCode: gameCode
                                                  ));
                                                }
                                            ),
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 400));

                                  },
                                  child: Column(
                                    children: [
                                      Image.asset("assets/images/result.png", width: 25, height: 25,),
                                      const SizedBox(height: 2,),
                                      const Text("Last Result", style: TextStyle(fontSize: 10, color: WlsPosColor.warm_grey_three),)
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: .5, height: 50, color: WlsPosColor.game_color_grey),
                              Expanded(
                                child: Container(
                                  color: (UserInfo.getDgeLastSaleTicketNo.isNotEmpty && UserInfo.getDgeLastSaleTicketNo != "0" && UserInfo.getDgeLastSaleTicketNo != "-1")
                                      ? WlsPosColor.white
                                      : WlsPosColor.light_grey.withOpacity(0.4),
                                  child: TextButton(
                                    clipBehavior: Clip.hardEdge,
                                    onPressed: () {
                                      if (UserInfo.getDgeLastSaleTicketNo.isNotEmpty && UserInfo.getDgeLastSaleTicketNo != "0" && UserInfo.getDgeLastSaleTicketNo != "-1") {
                                        CancelTicketConfirmationDialog().show(context: context, title: "Cancel Ticket", subTitle: "Are you sure you want to cancel ticket ${SharedPrefUtils.getLastReprintTicketNo} ?", buttonText: "Yes", isCloseButton: true, buttonClick: () {
                                          ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
                                          MenuBeanList? cancelTicketApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_CANCEL_TICKET").toList()[0];
                                          UrlDrawGameBean? cancelTicketApiUrlsDetails = getDrawGameUrlDetails(cancelTicketApiDetails!, context, "cancelTicket");
                                          BlocProvider.of<LotteryBloc>(context).add(
                                              CancelTicketApi(
                                                  context:context,
                                                  apiUrlDetails: cancelTicketApiUrlsDetails
                                              )
                                          );
                                        });

                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Image.asset("assets/images/cancel_ticket.png", width: 25, height: 25,),
                                        const SizedBox(height: 2),
                                        const Text("Cancel", style: TextStyle(fontSize: 10, color: WlsPosColor.warm_grey_three),)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: .5, height: 50, color: WlsPosColor.game_color_grey),
                              Expanded(
                                child: Container(
                                  color: WlsPosColor.white,
                                  child: TextButton(
                                    clipBehavior: Clip.hardEdge,
                                    onPressed: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext ctx) {
                                          return StatefulBuilder(
                                            builder: (context, StateSetter setInnerState) {
                                              return Dialog(
                                                  insetPadding: const EdgeInsets.symmetric(
                                                      horizontal: 14.0, vertical: 8.0),
                                                  backgroundColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        decoration: BoxDecoration(
                                                            color: WlsPosColor.white,
                                                            borderRadius: BorderRadius.circular(12)
                                                        ),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Material(
                                                                color: WlsPosColor.game_color_red.withOpacity(0.2),
                                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                                child: InkWell(
                                                                  onTap:() {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  customBorder: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Container(
                                                                    width: 30,
                                                                    height:30,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(width: 1, color: WlsPosColor.game_color_red),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(8)),

                                                                    ),
                                                                    child: const Center(child: Icon(Icons.close, size: 16, color: WlsPosColor.game_color_red)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ).pOnly(top:16),
                                                            const HeightBox(10),
                                                            Container(
                                                              color: WlsPosColor.black,
                                                              child: Image.asset("assets/images/splash_logo.png", width: 200, height: 50).p(10),
                                                            ),
                                                            const HeightBox(4),
                                                            const Text(
                                                              "Select an option for reprint",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color: WlsPosColor.black,
                                                              ),
                                                            ),
                                                            const HeightBox(20),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                Material(
                                                                  color: (UserInfo.getDgeLastSaleTicketNo.isNotEmpty && UserInfo.getDgeLastSaleTicketNo != "0" && UserInfo.getDgeLastSaleTicketNo != "-1" && SharedPrefUtils.getLastReprintTicketNo.isNotEmpty) ? WlsPosColor.game_color_blue : WlsPosColor.game_color_grey.withOpacity(0.5),
                                                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      if (UserInfo.getDgeLastSaleTicketNo.isNotEmpty && UserInfo.getDgeLastSaleTicketNo != "0" && UserInfo.getDgeLastSaleTicketNo != "-1" && SharedPrefUtils.getLastReprintTicketNo.isNotEmpty) {
                                                                        Navigator.of(ctx).pop();
                                                                        ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
                                                                        MenuBeanList? rePrintApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_REPRINT").toList()[0];
                                                                        UrlDrawGameBean? rePrintApiUrlsDetails = getDrawGameUrlDetails(rePrintApiDetails!, context, "reprintTicket");
                                                                        if (lotteryBlocContext != null) {
                                                                          BlocProvider.of<LotteryBloc>(lotteryBlocContext!).add(
                                                                              RePrintApi(
                                                                                  context:lotteryBlocContext!,
                                                                                  apiUrlDetails: rePrintApiUrlsDetails
                                                                              )
                                                                          );
                                                                        } else {
                                                                          ShowToast.showToast(context, "unable to get context", type: ToastType.ERROR);
                                                                        }
                                                                      }

                                                                    },
                                                                    customBorder: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(6),
                                                                    ),
                                                                    child: const SizedBox(
                                                                      height: 50,
                                                                      child: Center(child: Text("Sale Reprint", style: TextStyle(color: WlsPosColor.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const HeightBox(10),
                                                                Material(
                                                                  color: SharedPrefUtils.getLastWinningTicketNo.isNotEmpty ? WlsPosColor.game_color_green : WlsPosColor.game_color_grey.withOpacity(0.5),
                                                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      if (SharedPrefUtils.getLastWinningTicketNo.isNotEmpty) {
                                                                        Navigator.of(ctx).pop();
                                                                        if (lotteryBlocContext != null) {
                                                                          BlocProvider.of<WinningClaimBloc>(lotteryBlocContext!).add(
                                                                              TicketVerifyApi(
                                                                                  context: context,
                                                                                  ticketNumber: SharedPrefUtils.getLastWinningTicketNo,
                                                                                  apiDetails: verifyTicketUrls
                                                                              )
                                                                          );

                                                                        } else {
                                                                          ShowToast.showToast(context, "unable to get context", type: ToastType.ERROR);
                                                                        }
                                                                      }

                                                                    },
                                                                    customBorder: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(6),
                                                                    ),
                                                                    child: SizedBox(
                                                                      height: 50,
                                                                      child: Center(child: Text("Winning Reprint", style: const TextStyle(color: WlsPosColor.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ) ,
                                                            const HeightBox(20),
                                                          ],
                                                        ).pSymmetric(v: 10, h: 30),
                                                      )
                                                  )
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Image.asset("assets/images/reprint.png", width: 25, height: 25,),
                                        const SizedBox(height: 2,),
                                        const Text("Reprint", style: TextStyle(fontSize: 10, color: WlsPosColor.warm_grey_three))
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: Stack(
                  children: [
                    RefreshIndicator(
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      color: WlsPosColor.app_blue,
                      displacement: 60,
                      edgeOffset: 1,
                      strokeWidth: 2,
                      onRefresh: () {
                        setState(() {
                          isNoInternet       = false;
                          _mIsShimmerLoading = false;
                          lotteryGameObjectList.clear();
                        });
                        return Future.delayed(const Duration(milliseconds: 300), () { BlocProvider.of<LotteryBloc>(context).add(FetchGameDataApi(context: context)); },);
                      },
                      child: BlocListener<WinningClaimBloc, WinningClaimState>(
                        listener: (context, state) {
                          if(state is TicketVerifyApiLoading) {
                            setState(() {
                              isLastResultOrRePrintingOrCancelling = true;
                            });
                          }
                          else if (state is TicketVerifySuccess) {
                            log(" --------------------------->>>>>>>>>|| ${jsonEncode(state.response)}");
                            var responseTicketNumber = "";
                            setState(() {
                              isLastResultOrRePrintingOrCancelling = false;
                              winning_claim.TicketVerifyResponse? response = state.response;
                              ticketVerifyResponse = state.response;
                              winning_claim.ResponseData? data = state.response?.responseData;
                              verifyResponse = data;

                              String showErrorMsg = "";
                              if (response == null) {
                                ShowToast.showToast(context, "response is null", type: ToastType.ERROR);

                              } else if (response.responseCode == 0) {
                                responseTicketNumber = response.responseData?.ticketNumber ?? "";
                                var responseDrawData = response.responseData?.drawData ?? [];
                                for (int i = 0; i < responseDrawData.length; i++) {
                                  var panelWinList = responseDrawData[i].panelWinList ?? [];
                                  for (int j = 0; j < panelWinList.length; j++) {
                                    List<String> time = responseDrawData[i].drawTime?.split(":") ?? [];
                                    String boldStatus = responseDrawData[i].winStatus ?? "";
                                    showErrorMsg = "${"$showErrorMsg ${responseDrawData[i].drawDate} ${time[0]}:${time[1]}"}\n$boldStatus\n\n";
                                  }
                                }
                                showSuccessDialog(context, responseTicketNumber, data?.winClaimAmount ?? 0.0);
                              }
                            });
                          }
                          else if (state is TicketVerifyError) {
                            setState(() {
                              isLastResultOrRePrintingOrCancelling = false;
                              if(state.errorMessage == "No connection") {
                                isNoInternet = true;
                              }
                            });
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                  onWillPop: () async {
                                    return false;
                                  },
                                  child: StatefulBuilder(
                                    builder: (context, StateSetter setInnerState) {
                                      return Dialog(
                                          insetPadding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 18.0),
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                                color: WlsPosColor.white,
                                                borderRadius: BorderRadius.circular(12)
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const HeightBox(10),
                                                Image.asset("assets/images/logo.webp", width: 150, height: 100),
                                                const HeightBox(4),
                                                Text(
                                                  state.errorMessage,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: WlsPosColor.black,
                                                  ),
                                                ),
                                                const HeightBox(30),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: WlsPosColor.game_color_red,
                                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                                    ),
                                                    height: 45,
                                                    child: Center(child: Text("Close", style: const TextStyle(color: WlsPosColor.white, fontSize: 14))),
                                                  ),
                                                ),
                                                const HeightBox(20),

                                              ],
                                            ).pSymmetric(v: 10, h: 30),
                                          ).p(4)
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: BlocListener<LotteryBloc, LotteryState>(
                          listener: (context, state) {
                            setState(() {
                              lotteryBlocContext = context;
                            });

                            if (state is FetchGameLoading) {
                              setState(() {
                                if (!timeUpdating) {
                                  _mIsShimmerLoading = true;
                                }
                              });
                            }
                            else if (state is FetchGameSuccess) {
                              setState(() {
                                isNoInternet = false;
                                timeUpdating = false;
                                _mIsShimmerLoading = false;
                                lotteryGameObjectList = state.response.responseData?.gameRespVOs ?? [];
                                for (GameRespVOs gameResp in lotteryGameObjectList) {
                                  if (gameResp.gameCode?.isNotEmpty == true ) {
                                    lotteryGameCodeList.add(gameResp.gameCode ?? "");
                                  }
                                }
                                currentDateTime = state.response.responseData?.currentDate;
                                /*for (var moduleCodeVar in homeModuleCodesList) {
                          if (state.response.responseData?.moduleBeanLst?.where((element) => (element.moduleCode == moduleCodeVar)) != null) {
                            homeModuleList.add(state.response.responseData?.moduleBeanLst?.where((element) => (element.moduleCode == moduleCodeVar)).toList());
                          }
                        }
                        for (var moduleCodeVar in drawerModuleCodesList) {
                          if (state.response.responseData?.moduleBeanLst?.where((element) => (element.moduleCode == moduleCodeVar)) != null) {
                            drawerModuleList.add(state.response.responseData?.moduleBeanLst?.where((element) => (element.moduleCode == moduleCodeVar)).toList());
                          }
                        }
                        if (drawerModuleList.isNotEmpty) {
                          _mIsDrawerVisible = true;
                        } else {
                          _mIsDrawerVisible = false;
                        }*/
                              });
                            }
                            else if (state is FetchGameError) {
                              if(state.errorMessage == "No connection") {
                                setState(() {
                                  isNoInternet = true;
                                });
                              }
                              setState(() {
                                timeUpdating=false;
                                _mIsShimmerLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: const Duration(seconds: 2),
                                content: Text(state.errorMessage),
                              ));
                            }

                            setState(() {
                              if (state is RePrintLoading) {
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = true;
                                });
                              }
                              else if(state is RePrintSuccess) {
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = false;
                                });
                                re_print_resp.ResponseData? response = state.response.responseData;
                                UserInfo.setLastSaleGameCode(response?.gameCode ?? "");
                                SharedPrefUtils.setLastReprintTicketNo = response?.ticketNumber ?? "0";

                                if(state.response.responseData?.gameCode == "ThaiLottery") {
                                  for(int i=0; i< (state.response.responseData?.panelData ?? []).length ; i++) {
                                    state.response.responseData?.panelData?[i].pickedValues  = (state.response.responseData?.panelData?[i].pickedValues ?? "").replaceAll("#", "").replaceAll("-1", "");
                                    state.response.responseData?.panelData?[i].pickDisplayName = getThaiLotteryCategory(state.response.responseData?.panelData?[i].betType ?? "");
                                    state.response.responseData?.panelData?[i].betDisplayName  = getPicDisplayName(state.response.responseData?.panelData?[i].betType ?? "");
                                  }
                                } else if(state.response.responseData?.gameCode == "TwoDMYANMAAR") {
                                  // ToDo need to change here for TwoDMyanmaar reprint
                                  List<PanelData>? twoDPanelData = [];
                                  Map<String, List<PanelData>> panelDataMap = {};
                                  List<PanelData>? responsePanelData = state.response.responseData?.panelData ?? [];
                                  for(int i=0; i< responsePanelData.length ; i++){
                                    responsePanelData[i].pickedValues  = (responsePanelData[i].pickedValues ?? "").replaceAll("#", "").replaceAll("-1", "");
                                    String? mBetType = responsePanelData[i].betType == "2D-direct" ? "${responsePanelData[i].betType}_${responsePanelData[i].quickPick}" :responsePanelData[i].betType;
                                    if(panelDataMap.containsKey(mBetType)){
                                      panelDataMap[mBetType]?.add(responsePanelData[i]);
                                    } else {
                                      panelDataMap[mBetType ?? ''] = [responsePanelData[i]];
                                    }
                                  }
                                  log("panelDataMap------>: $panelDataMap");
                                  int twoDPanelDataIndex = 0;
                                  panelDataMap.forEach((key, value) {
                                    List<PanelData> mapValuePanelData = value;
                                    for (int mapValuePanelDataIndex = 0; mapValuePanelDataIndex < mapValuePanelData.length; mapValuePanelDataIndex++) {
                                      if(mapValuePanelDataIndex == 0){
                                        twoDPanelData.add(mapValuePanelData[mapValuePanelDataIndex]);
                                      } else {
                                        twoDPanelData[twoDPanelDataIndex].betAmountMultiple = (twoDPanelData[twoDPanelDataIndex].betAmountMultiple ?? 0.0) + (mapValuePanelData[mapValuePanelDataIndex].betAmountMultiple ?? 0.0);
                                        twoDPanelData[twoDPanelDataIndex].pickedValues = getPickValues(twoDPanelData[twoDPanelDataIndex].betType, twoDPanelData[twoDPanelDataIndex].pickedValues, mapValuePanelData[mapValuePanelDataIndex].pickedValues);
                                        twoDPanelData[twoDPanelDataIndex].numberOfLines = (twoDPanelData[twoDPanelDataIndex].numberOfLines??0) + (mapValuePanelData[mapValuePanelDataIndex].numberOfLines??0);
                                      }
                                    }
                                    twoDPanelData[twoDPanelDataIndex].betAmountMultiple = (twoDPanelData[twoDPanelDataIndex].betAmountMultiple??0.0) / mapValuePanelData.length;
                                    twoDPanelDataIndex++;
                                  });
                                  state.response.responseData?.panelData = twoDPanelData;
                                  for(int i=0; i< (state.response.responseData?.panelData ?? []).length ; i++){
                                    state.response.responseData?.panelData?[i].panelPrice  = (state.response.responseData?.panelData?[i].unitCost?? 1) * (state.response.responseData?.panelData?[i].betAmountMultiple ?? 1) * (state.response.responseData?.panelData?[i].numberOfLines ?? 1);
                                    state.response.responseData?.panelData?[i].betAmountMultiple = state.response.responseData?.panelData?[i].betAmountMultiple.toInt();
                                    //if(state.response.responseData?.panelData?[i].betType == "2D-series-number" ){
                                      List<String>? stringPickValuesList = state.response.responseData?.panelData?[i].pickedValues?.split(',');
                                      if(stringPickValuesList != null){
                                        Set<String> stringPickValuesSet = {...stringPickValuesList};
                                        List<String> newStringPickValuesList = stringPickValuesSet.toList();
                                        state.response.responseData?.panelData?[i].pickedValues = newStringPickValuesList.join(',');
                                      }
                                   // }
                                  }
                                  log("twoDPanelData------>: $twoDPanelData");
                                  log("twoDstate.response.responseData?.panelData------>: ${jsonEncode(state.response.responseData?.panelData ?? [])}");
                                  log("twoDstate.response------>: ${jsonEncode(state.response)}");
                                  // ToDo need to change here for TwoDMyanmaar end
                                  }
                                Map<String,dynamic> printingDataArgs = {};
                                printingDataArgs["saleResponse"]          = jsonEncode(state.response);
                                printingDataArgs["username"]              = UserInfo.userName;
                                printingDataArgs["currencyCode"]          = getDefaultCurrency(getLanguage());
                                printingDataArgs["panelData"]             = jsonEncode(state.response.responseData?.panelData ?? []);

                                PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isRePrint: true, onPrintingDone:() {
                                }, isPrintingForSale: false);

                              }
                              else if (state is RePrintError) {
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = false;
                                });
                                ShowToast.showToast(context, state.errorMessage, type: ToastType.ERROR);
                              }
                              if(state is CancelTicketSuccess){
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = false;
                                });
                                Map<String,dynamic> printingDataArgs = {};
                                printingDataArgs["cancelTicketResponse"]  = jsonEncode(state.response);
                                printingDataArgs["username"]              = UserInfo.userName;
                                printingDataArgs["currencyCode"]          = getDefaultCurrency(getLanguage());

                                PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isCancelTicket: true, onPrintingDone:(){
                                }, isPrintingForSale: false);

                                UserInfo.setLastSaleTicketNo("");
                                UserInfo.setLastSaleGameCode("");
                                SharedPrefUtils.setLastReprintTicketNo = "";
                                ShowToast.showToast(context, "Ticket SuccessFully Cancelled", type: ToastType.SUCCESS);
                              }
                              else if (state is CancelTicketError) {
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = false;
                                });
                                ShowToast.showToast(context, state.errorMessage, type: ToastType.ERROR);
                              }
                              else if (state is ResultError) {
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = false;
                                });
                                ShowToast.showToast(context, state.errorMessage.replaceAll("date", "time"), type: ToastType.ERROR);
                              }
                              else if(state is ResultSuccess){
                                setState(() {
                                  isLastResultOrRePrintingOrCancelling = false;
                                });
                                Navigator.pop(context);
                                Navigator.pushNamed(context, WlsPosScreen.resultPreviewScreen, arguments: state.response.responseData);
                              }
                            });
                          },
                          child: isNoInternet
                              ? Stack( // Stack is used to bring No Internet column widget at center
                              children: [
                                Align(
                                  child: ListView.builder( // ListView widget is used so that Refresh indicator can work properly at case of single child(non-scrollable-widgets).
                                    itemCount: 1,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (BuildContext context, int index) {
                                      return SizedBox(
                                        height: MediaQuery.of(context).size.height - 200,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              const Expanded(flex: 1, child: SizedBox()),
                                              SizedBox(width: 300, height: 300, child: Lottie.asset('assets/lottie/no_internet.json')),
                                              const HeightBox(10),
                                              const Text("No Internet",
                                                  style: TextStyle(color: WlsPosColor.game_color_red, letterSpacing: 2, fontSize: 18))
                                                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                                  .flipH(duration: const Duration(milliseconds: 300))
                                                  .move(delay: 150.ms, duration: 1100.ms),
                                              const Expanded(flex: 1, child: SizedBox()),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                      children: [
                                        SizedBox(width: 100, height: 100, child: Transform.rotate(angle: -math.pi / 2.5, child: Lottie.asset('assets/lottie/pull_to_refresh.json'))),
                                        const Text("Swipe to refresh", style: TextStyle(color: WlsPosColor.app_blue, letterSpacing: 2, fontSize: 14))
                                      ],
                                    )
                                ),
                              ]
                          )
                              : GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: isLandscape ? 1.5 : 0.8, // landscape ---> 2 // potrate ---> 0.8
                                crossAxisCount: isLandscape ? 4 : 2,
                              ),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _mIsShimmerLoading ? 10 : lotteryGameObjectList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _mIsShimmerLoading
                                    ? Shimmer.fromColors(
                                  baseColor: Colors.grey[400]!,
                                  highlightColor: Colors.grey[300]!,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: WlsPosColor.warm_grey,
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width : 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[400]!,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10),
                                              )
                                          ),
                                        ).pOnly(bottom: 10),
                                        Container(
                                          width : 70,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[400]!,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10),
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).p(6),
                                )
                                    : Ink(
                                    decoration: const BoxDecoration(
                                      color: WlsPosColor.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: WlsPosColor.warm_grey_six,
                                          blurRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        mComingSoonGameCodeList.contains(lotteryGameObjectList[index].gameCode)
                                            ? Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            width: 100,
                                            height: 25,
                                            decoration: const BoxDecoration(
                                                color: Colors.purpleAccent,
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                                            ),
                                            child: const Text("Coming soon", style: TextStyle(color: WlsPosColor.white)).pOnly(left: 6, top: 6),
                                          ),
                                        )
                                            : Container(),
                                        InkWell(
                                            onTap: () {
                                              if (lotteryGameObjectList[index].drawRespVOs?.isEmpty == true) {
                                                DrawNotAvailableMsgDialog().show(context: context, title: "Draw is not available !", isCloseButton: true, buttonText: 'Check after sometime . . .');

                                              } else if (lotteryGameObjectList[index].gameCode?.toUpperCase() == "BingoSeventyFive3".toUpperCase()){
                                                Navigator.pushNamed(context, WlsPosScreen.bingoGameScreen, arguments: lotteryGameObjectList[index]);
                                              } else {
                                                var lotteryGameMainBetList = lotteryGameObjectList[index].betRespVOs?.where((element) => element.winMode == "MAIN").toList()   ?? [];
                                                var lotteryGameSideBetList = lotteryGameObjectList[index].betRespVOs?.where((element) => element.winMode == "COLOR").toList()  ?? [];
                                                if (lotteryGameSideBetList.isEmpty && lotteryGameMainBetList.isEmpty) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                    duration: Duration(seconds: 1),
                                                    content: Text("No Bets available, Please after some time !"),
                                                  ));
                                                } else {
                                                  if (lotteryGameMainBetList.isNotEmpty) {
                                                    if (lotteryGameMainBetList.length > 1) {
                                                      if (lotteryGameObjectList[index].gameCode?.toUpperCase() == "powerball".toUpperCase()) {
                                                        List<BetRespVOs>? betRespV0sPowerBallList = lotteryGameObjectList[index].betRespVOs?.where((element) => element.betCode?.toUpperCase().contains("plus".toUpperCase()) != true).toList() ?? [];
                                                        if (betRespV0sPowerBallList.length > 1) {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (_) => MultiBlocProvider(
                                                                      providers: [
                                                                        BlocProvider<LoginBloc>(
                                                                          create: (BuildContext context) => LoginBloc(),
                                                                        )
                                                                      ],
                                                                      child: PickTypeScreen(gameObjectsList: lotteryGameObjectList[index], listPanelData: []))
                                                              )
                                                          );

                                                        } else {
                                                          List<BetRespVOs>? betRespV0s = lotteryGameObjectList[index].betRespVOs ?? [];
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                builder: (_) =>  MultiBlocProvider(
                                                                    providers: [
                                                                      BlocProvider<LotteryBloc>(
                                                                        create: (BuildContext context) => LotteryBloc(),
                                                                      )
                                                                    ],
                                                                    child: GameScreen(particularGameObjects: lotteryGameObjectList[index], pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: betRespV0s[0], mPanelBinList: [])),
                                                              )
                                                          );
                                                        }

                                                      }
                                                      else if(lotteryGameObjectList[index].gameCode?.toUpperCase() == "BICHORAPIDO".toUpperCase())
                                                      {
                                                        Navigator.pushNamed(context, WlsPosScreen.zooLottoGameScreen, arguments: {"gameObjectsList": lotteryGameObjectList[index], "listPanelData": listPanelData});
                                                      }

                                                      else {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) => MultiBlocProvider(
                                                                    providers: [
                                                                      BlocProvider<LoginBloc>(
                                                                        create: (BuildContext context) => LoginBloc(),
                                                                      ),
                                                                    ],
                                                                    child: PickTypeScreen(gameObjectsList: lotteryGameObjectList[index], listPanelData: []))
                                                            )
                                                        );
                                                      }

                                                    } else {
                                                      if (lotteryGameSideBetList.isNotEmpty) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) => MultiBlocProvider(
                                                                    providers: [
                                                                      BlocProvider<LoginBloc>(
                                                                        create: (BuildContext context) => LoginBloc(),
                                                                      )
                                                                    ],
                                                                    child: PickTypeScreen(gameObjectsList: lotteryGameObjectList[index], listPanelData: []))
                                                            )
                                                        );

                                                      } else {
                                                        List<BetRespVOs>? betRespV0s = lotteryGameObjectList[index].betRespVOs ?? [];
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (_) =>  MultiBlocProvider(
                                                                  providers: [
                                                                    BlocProvider<LotteryBloc>(
                                                                      create: (BuildContext context) => LotteryBloc(),
                                                                    )
                                                                  ],
                                                                  child: GameScreen(particularGameObjects: lotteryGameObjectList[index], pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: betRespV0s[0], mPanelBinList: [])),
                                                            )
                                                        );
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            },
                                            customBorder: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Ink(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Image.asset(
                                                          width : 100,
                                                          height: 100,
                                                          lotteryGameCodeList.contains(lotteryGameObjectList[index].gameCode)
                                                              ?
                                                          "assets/icons/${lotteryGameObjectList[index].gameCode}.png"
                                                              : "assets/images/splash_logo.png"
                                                      ),
                                                      Text(lotteryGameObjectList[index].gameName!.toString(), style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)),
                                                      const Divider( thickness: 2,).pOnly(top: 9),
                                                    ],
                                                  ),
                                                  (lotteryGameObjectList[index].drawRespVOs?.isEmpty == true)
                                                      ? const SizedBox(
                                                      width: double.infinity,
                                                      height: 50,
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text("Draw not available!",
                                                          style: TextStyle(color: Colors.red),),

                                                      )
                                                  )
                                                      : SizedBox(
                                                    width: double.infinity,
                                                    height: isLandscape ? 70 : 50,
                                                    child: Align(
                                                      alignment: Alignment.center,
                                                      child: MyTimerLottery(
                                                        drawDateTime: DateTime.parse(lotteryGameObjectList[index].drawRespVOs?[0].drawSaleStopTime ?? "2023-10-30 13:44:45"),
                                                        currentDateTime: DateTime.parse(currentDateTime ?? "2023-10-30 13:44:45"),
                                                        gameType: null,
                                                        gameName: lotteryGameObjectList[index].gameName,
                                                        callback: (newGameData) {
                                                          setState(() {
                                                            timeUpdating = true;
                                                            BlocProvider.of<LotteryBloc>(context).add(FetchGameDataApi(context: context));
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                        ),
                                      ],
                                    )
                                ).p(6);
                              }
                          ).p(10),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isLastResultOrRePrintingOrCancelling,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: WlsPosColor.black.withOpacity(0.7),
                        child: Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                                width: 70,
                                height: 70,
                                child: Lottie.asset('assets/lottie/gradient_loading.json'))),
                      ),
                    )
                  ],
                )
            ),
          ),
        ),
    ),
      );
  }

  showSuccessDialog(BuildContext context, String? ticketNumber, double? winClaimAmount) {
    return showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (BuildContext _,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return Transform.scale(
            scale: curve,
            child: Dialog(
                elevation: 30.0,
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HeightBox(40),
                          const Text(
                            "Success",
                            style: TextStyle(
                                color: WlsPosColor.shamrock_green,
                                fontSize: 20,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const HeightBox(20),
                          const Text("Ticket:", style: TextStyle(color: WlsPosColor.warm_grey_three, fontSize: 12)),
                          Text("$ticketNumber\n", style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                          winClaimAmount != 0.0
                              ? Column(
                            children: [
                              const Text("Winning Amount:", style: TextStyle(color: WlsPosColor.warm_grey_three, fontSize: 12)),
                              Text("$winClaimAmount\n", style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),

                            ],
                          )
                              : Container(),
                          const HeightBox(10),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 1,color: Colors.red),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white
                                    ),
                                    child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Close",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.red, fontSize: 14),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    printingDataArgs["winClaimedResponse"]  = jsonEncode(ticketVerifyResponse);
                                    printingDataArgs["lastWinningSaleTicketNo"]  = SharedPrefUtils.getLastWinningSaleTicketNo;
                                    printingDataArgs["username"]            = UserInfo.userName;
                                    printingDataArgs["currencyCode"]        = getDefaultCurrency(getLanguage());
                                    printingDataArgs["languageCode"]        = "en";

                                    PrintingDialog().show(context: context, title: "Printed Started", isCloseButton: false, buttonText: 'Retry', printingDataArgs: printingDataArgs, isWinClaim: true, onPrintingDone:(){
                                      Navigator.of(context).pop(true);
                                    }, isPrintingForSale: false);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red
                                    ),
                                    child: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Close & Print",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        )
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ).pOnly(top: 40),
                    Positioned.fill(
                      top: 10,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.white,
                          ),
                          child: SizedBox(width: 70, height: 70, child: Lottie.asset('assets/lottie/printing_success.json')),
                        ),
                      ),
                    )
                  ],
                )
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400));
  }

  showErrorDialog(BuildContext context, String showErrorMsg) {
    return showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return Transform.scale(
            scale: curve,
            child: Dialog(
              elevation: 3.0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
              backgroundColor: WlsPosColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HeightBox(40),
                  const Text(
                    "Ticket Status",
                    style: TextStyle(
                        color: WlsPosColor.game_color_red,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  const HeightBox(20),
                  Center(child: Text(showErrorMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black)).pOnly(bottom: 10)),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: WlsPosColor.red
                      ),
                      child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "OK",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: WlsPosColor.white, fontSize: 18, fontWeight: FontWeight.bold),
                          )
                      ),
                    ),
                  ),
                  const HeightBox(20)
                ],
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400));
  }

  String? getPickValues(String? betType, String? twoDPanelDataPickedValues, String? mapPanelDataPickedValues) {
    // String? mPickValues;
    // switch(betType) {
    //   case "2D-Couple-Number": {
    //     for(String ballNumber in listOfBalls) {
    //       if(ballNumber.length > 1) {
    //         if (ballNumber[0] == ballNumber[1]) {
    //           mPickValues == null ? mPickValues = ballNumber : mPickValues = '$mPickValues,$ballNumber';
    //         }
    //       }
    //     }
    //     return mPickValues;
    //   }
    //   case "2D-Brother-Number": {
    //     for(String ballNumber in listOfBalls) {
    //       if(ballNumber.length > 1) {
    //         if (int.parse(ballNumber[0]) == (int.parse(ballNumber[1]) - 1) || ((int.parse(ballNumber[0]) == 9) && (int.parse(ballNumber[1]) == 0)) ) {
    //           mPickValues == null ? mPickValues = ballNumber : mPickValues = '$mPickValues,$ballNumber';
    //         }
    //       }
    //     }
    //     return mPickValues;
    //     // return "01 , 12 , 23 , 34 , 45 , 56 , 67 , 78 , 89 , 90";
    //   }
    //   case "2D-Even-Even-Number": {
    //     for(String ballNumber in listOfBalls) {
    //       if(ballNumber.length > 1) {
    //         if ((int.parse(ballNumber[0]) % 2 == 0) && (int.parse(ballNumber[1]) % 2 == 0)) {
    //           mPickValues == null ? mPickValues = ballNumber : mPickValues = '$mPickValues,$ballNumber';
    //         }
    //       }
    //     }
    //     return mPickValues;
    //   }
    //   case "2D-Even-Odd-Number": {
    //     for(String ballNumber in listOfBalls) {
    //       if(ballNumber.length > 1) {
    //         if ((int.parse(ballNumber[0]) % 2 == 0) && (int.parse(ballNumber[1]) % 2 != 0)) {
    //           mPickValues == null ? mPickValues = ballNumber : mPickValues = '$mPickValues,$ballNumber';
    //         }
    //       }
    //     }
    //     return mPickValues;
    //   }
    //   case "2D-Odd-Odd-Number": {
    //     for(String ballNumber in listOfBalls) {
    //       if(ballNumber.length > 1) {
    //         if ((int.parse(ballNumber[0]) % 2 != 0) && (int.parse(ballNumber[1]) % 2 != 0)) {
    //           mPickValues == null ? mPickValues = ballNumber : mPickValues = '$mPickValues,$ballNumber';
    //         }
    //       }
    //     }
    //     return mPickValues;
    //   }
    //   case "2D-Odd-Even-Number": {
    //     for(String ballNumber in listOfBalls) {
    //       if(ballNumber.length > 1) {
    //         if ((int.parse(ballNumber[0]) % 2 != 0) && (int.parse(ballNumber[1]) % 2 == 0)) {
    //           mPickValues == null ? mPickValues = ballNumber : mPickValues = '$mPickValues,$ballNumber';
    //         }
    //       }
    //     }
    //     return mPickValues;
    //   }
    //   case "2D-series-number": {
    //     return "$twoDPanelDataPickedValues,$mapPanelDataPickedValues";
    //   }
    //   default: {
    //     return "$twoDPanelDataPickedValues,$mapPanelDataPickedValues";
    //   }
    //   }
    return "$twoDPanelDataPickedValues,$mapPanelDataPickedValues";
  }
}
