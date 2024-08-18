import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/lottery/bingo/model/data/bingo_purchase_detail_data.dart';
import 'package:wls_pos/lottery/bingo/model/data/card_model.dart';
import 'package:wls_pos/lottery/bingo/widget/bingo_widget.dart';
import 'package:wls_pos/lottery/bloc/lottery_state.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/advanceDrawBean.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart'
    as m_panel_bean;
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/widgets/advance_date_selection_dialog.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

import '../../purchase_details/bloc/game_sale_bloc.dart';
import '../../utility/UrlDrawGameBean.dart';
import '../../utility/auth_bloc/auth_bloc.dart';
import '../bloc/lottery_bloc.dart';
import '../bloc/lottery_event.dart';
import '../widgets/printing_dialog.dart';

class BingoPurchaseDetailScreen extends StatefulWidget {
  final BingoPurchaseDetailData bingoPurchaseDetailData;

  const BingoPurchaseDetailScreen(
      {Key? key, required this.bingoPurchaseDetailData})
      : super(key: key);

  @override
  State<BingoPurchaseDetailScreen> createState() =>
      _BingoPurchaseDetailScreenState();
}

class _BingoPurchaseDetailScreenState extends State<BingoPurchaseDetailScreen> {
  List<CardModel> selectedCardList = [];
  String betValue = '0';
  bool isBuyNowPressed = false;
  int priceSubtractor = 0;
  int mNumberOfDraws = 1;
  int mIndexConsecutiveDrawsList = 0;
  late int drawRespLength;
  List<Map<String, String>> listAdvanceDraws = [];
  List<String> listConsecutiveDraws = [];

  List<m_panel_bean.PanelBean> listPanel = [];
  String drawCountAdvance = "0";
  bool minusDraw = false;
  bool plusDraw = false;
  bool isAdvancePlay = false;
  String betAmount = "";
  String noOfBet = "";
  bool addDrawNotAllowed = false;
  bool minusDrawNotAllowed = false;
  bool isPurchasing = false;
  bool isAdvanceDateSelectionOptionChosen = false;
  List<AdvanceDrawBean> mAdvanceDrawBean = [];
  List<Map<String, String>> listAdvanceMap = [];
  int noOfDrawsFromDrawBtn = 0;
  int drawsCount = 1;
  Map<String, dynamic> printingDataArgs = {};
  double unitPrice = 1;
  String lastTicketNumber                            = "";
  String lastGameCode                                = "";

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(selectedCardList);
        return true;
      },
      child: AbsorbPointer(
        absorbing: isPurchasing,
        child: SafeArea(
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is GetLoginDataSuccess) {
                if (state.response != null) {
                  BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: state.response!));
                  PrintingDialog().show(
                      context: context,
                      title: "Printing started",
                      isCloseButton: true,
                      buttonText: 'Retry',
                      printingDataArgs: printingDataArgs,
                      onPrintingDone: () {
                        SharedPrefUtils.setDgeLastSaleTicketNo = lastTicketNumber;
                        SharedPrefUtils.setDgeLastSaleGameCode = lastGameCode;
                        SharedPrefUtils.setLastReprintTicketNo = lastTicketNumber;

                        widget.bingoPurchaseDetailData
                            .onComingToPreviousScreen("isBuyPerformed");
                        Navigator.of(context).pop(true);
                      }, isPrintingForSale: true);
                }
              }
            },
            child: WlsPosScaffold(
              onBackButton: () {
                Navigator.of(context).pop(selectedCardList);
              },
              showAppBar: true,
              centerTitle: false,
              drawer: WlsPosDrawer(drawerModuleList: const []),
              backgroundColor: WlsPosColor.white,
              appBarTitle: const Text(
                'Purchase Details',
                style: TextStyle(fontSize: 18, color: WlsPosColor.white),
              ),
              body: BlocListener<LotteryBloc, LotteryState>(
                listener: (context, state) {
                  if (state is GameSaleApiLoading) {
                    setState(() {
                      isPurchasing = true;
                    });
                  } else if (state is GameSaleApiSuccess) {
                    setState(() {
                      isPurchasing = false;
                    });
                    lastTicketNumber = state.response.responseData?.ticketNumber.toString() ?? "";
                    lastGameCode = state.response.responseData?.gameCode.toString() ?? "";

                   /* SharedPrefUtils.setLastSaleTicketNo =
                        jsonEncode(state.response.responseData?.ticketNumber ?? "");
                    print("UserInfo.getLastSaleTicketNo: ${jsonDecode(UserInfo.getDgeLastSaleTicketNo)}");*/

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text("Purchased Successfully"),
                    ));

                    printingDataArgs["saleResponse"] = jsonEncode(state.response);
                    printingDataArgs["username"] = UserInfo.userName;
                    printingDataArgs["currencyCode"] =
                        getDefaultCurrency(getLanguage());
                    // for (var elementElement in listPanel) {
                    //   elementElement.betAmountMultiple = unitPrice;
                    // }
                    print("listPanel: before -> ${jsonEncode(listPanel)}");
                    if (state.response.responseData?.gameCode == "BingoSeventyFive3") {
                      for(int i=0; i< listPanel.length; i++) {
                        listPanel[i].pickedValue = listPanel[i].pickedValue?.replaceAll("#", " ");
                      }
                    }
                    print("listPanel: after -> ${jsonEncode(listPanel)}");
                    printingDataArgs["panelData"] = jsonEncode(listPanel);

                    BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));

                  } else if (state is GameSaleApiError) {
                    setState(() {
                      isPurchasing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text("Purchased Error: \n ${state.errorMessage}"),
                    ));

                    if (state.errorCode != null) {
                      if (state.errorCode == 102) {
                        // Map<String, dynamic> panelDataToBeSave = {
                        //   "panelData": listPanel
                        // };
                        // SharedPrefUtils.setSelectedPanelData =
                        //     jsonEncode(panelDataToBeSave);
                        // SharedPrefUtils.setSelectedGameObject = jsonEncode(
                        //     widget.bingoPurchaseDetailData.particularGameObjects);
                        //
                        // print(
                        //     "UserInfo.getSelectedPanelData: ${jsonDecode(UserInfo.getSelectedPanelData)}");
                        // var jsonPanelData = jsonDecode(UserInfo.getSelectedPanelData)
                        //     as Map<String, dynamic>;
                        // print("jsonPanelData: $jsonPanelData");
                        // print(
                        //     "jsonPanelData[panelData]: ${jsonPanelData["panelData"]}");
                        // print(
                        //     "UserInfo.getSelectedGameObject: ${GameRespVOs.fromJson(jsonDecode(UserInfo.getSelectedGameObject))}");
                        Navigator.of(context).popUntil((route) => false);
                        Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
                      }
                    }
                  }
                },
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // IntrinsicHeight(
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: Column(
                        //           mainAxisSize: MainAxisSize.min,
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             Text(
                        //                 '${widget.bingoPurchaseDetailData.selectedCardList.length}',
                        //                 style: const TextStyle(
                        //                     color: WlsPosColor.cherry,
                        //                     fontWeight: FontWeight.w700,
                        //                     fontFamily: "Roboto",
                        //                     fontStyle: FontStyle.normal,
                        //                     fontSize: 16.0)),
                        //             const HeightBox(5),
                        //             const Text("Selected Cards",
                        //                 style: TextStyle(
                        //                     color: WlsPosColor.warm_grey_new,
                        //                     fontWeight: FontWeight.w500,
                        //                     fontFamily: "Roboto",
                        //                     fontStyle: FontStyle.normal,
                        //                     fontSize: 12.0)),
                        //           ],
                        //         ).p4(),
                        //       ),
                        //       // const VerticalDivider(color: WlsPosColor.brownish_grey_six,thickness: 2,),
                        //       Expanded(
                        //         child: Column(
                        //           mainAxisSize: MainAxisSize.min,
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             Text(betValue,
                        //                 style: const TextStyle(
                        //                     color: WlsPosColor.cherry,
                        //                     fontWeight: FontWeight.w700,
                        //                     fontFamily: "Roboto",
                        //                     fontStyle: FontStyle.normal,
                        //                     fontSize: 16.0),
                        //                 textAlign: TextAlign.center),
                        //             const HeightBox(5),
                        //             const Text("Bet Value",
                        //                 style: TextStyle(
                        //                     color: WlsPosColor.warm_grey_new,
                        //                     fontWeight: FontWeight.w500,
                        //                     fontFamily: "Roboto",
                        //                     fontStyle: FontStyle.normal,
                        //                     fontSize: 12.0),
                        //                 textAlign: TextAlign.center),
                        //           ],
                        //         ).p4(),
                        //       ),
                        //     ],
                        //   ),
                        // ).pOnly(bottom: 10),
                        Container(height: 10),
                        // selected cards
                        Expanded(
                          flex: 8,
                          child: GridView.builder(
                            itemCount: selectedCardList.isEmpty
                                ? 10
                                : selectedCardList.length,
                            //shrinkWrap: true,
                            //physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isLandscape ? 5 : 2,
                                    childAspectRatio: 5 / 6
                                ),
                            itemBuilder: (context, cardIndex) {
                              return selectedCardList.isEmpty
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
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[400]!,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  )),
                                            ).pOnly(bottom: 10),
                                            Container(
                                              width: 80,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[400]!,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ).p(6),
                                    )
                                  : BingoCard(
                                      isSelected:
                                          selectedCardList[cardIndex].isSelected,
                                      cardModel: selectedCardList[cardIndex],
                                      onCardTap: () {},
                                      onPurchase: true,
                                      onDelete: () {
                                        if (selectedCardList.isNotEmpty) {
                                          setState(() {
                                            betValue =
                                                '${int.parse(betValue) - (priceSubtractor * (noOfDrawsFromDrawBtn != 0 ? noOfDrawsFromDrawBtn : mNumberOfDraws != 0 ? mNumberOfDraws : 1)).round()}';
                                            selectedCardList.removeAt(cardIndex);
                                          });
                                          if (selectedCardList.isEmpty) {
                                            Navigator.pop(context, true);
                                          }
                                        }
                                      },
                                    );
                            },
                          ),
                        ),
                        // no of draws && draw list
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                      color: WlsPosColor.marigold,
                                      child: const Align(
                                          alignment: Alignment.center,
                                          child: Text("No. of Draw(s)",
                                              style: TextStyle(
                                                  color: WlsPosColor.white,
                                                  fontSize: 12)))),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Ink(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            color: WlsPosColor.white,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                            border: Border.all(
                                                color: WlsPosColor.game_color_grey,
                                                width: .5)),
                                        child: AbsorbPointer(
                                          absorbing: minusDrawNotAllowed,
                                          child: InkWell(
                                            onTap: () {
                                              resetAdvanceDraws();
                                              setState(() {
                                                noOfDrawsFromDrawBtn = 0;
                                                mAdvanceDrawBean.clear();
                                                listAdvanceMap.clear();
                                                isAdvancePlay = false;
                                                if (mIndexConsecutiveDrawsList > 0) {
                                                  mNumberOfDraws = int.parse(
                                                      listConsecutiveDraws[
                                                          --mIndexConsecutiveDrawsList]);
                                                }
                                              });
                                              enableDisableDrawsButton();
                                              recalculateAmount();
                                            },
                                            customBorder: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset(
                                                    'assets/icons/minus.svg',
                                                    width: 20,
                                                    height: 20,
                                                    color:
                                                        mIndexConsecutiveDrawsList ==
                                                                0
                                                            ? WlsPosColor
                                                                .game_color_grey
                                                            : WlsPosColor.black)),
                                          ),
                                        ),
                                      ).pOnly(right: 8),
                                      Align(
                                              alignment: Alignment.center,
                                              child: Text("$mNumberOfDraws",
                                                  style: const TextStyle(
                                                      color:
                                                          WlsPosColor.game_color_red,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16)))
                                          .pOnly(right: 8),
                                      Ink(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            color: WlsPosColor.white,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                            border: Border.all(
                                                color: WlsPosColor.game_color_grey,
                                                width: .5)),
                                        child: AbsorbPointer(
                                          absorbing: addDrawNotAllowed,
                                          child: InkWell(
                                            onTap: () {
                                              resetAdvanceDraws();
                                              setState(() {
                                                noOfDrawsFromDrawBtn = 0;
                                                mAdvanceDrawBean.clear();
                                                listAdvanceMap.clear();
                                                isAdvancePlay = false;
                                                drawRespLength = widget
                                                        .bingoPurchaseDetailData
                                                        .particularGameObjects
                                                        ?.drawRespVOs
                                                        ?.length ??
                                                    0;
                                                if (mIndexConsecutiveDrawsList <
                                                    drawRespLength) {
                                                  mNumberOfDraws = int.parse(
                                                      listConsecutiveDraws[
                                                          ++mIndexConsecutiveDrawsList]);
                                                }
                                              });
                                              enableDisableDrawsButton();
                                              recalculateAmount();
                                            },
                                            customBorder: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset(
                                                    'assets/icons/plus.svg',
                                                    width: 20,
                                                    height: 20,
                                                    color:
                                                        mIndexConsecutiveDrawsList ==
                                                                drawRespLength - 1
                                                            ? WlsPosColor
                                                                .game_color_grey
                                                            : WlsPosColor.black)),
                                          ),
                                        ),
                                      ).pOnly(right: 8),
                                    ],
                                  ),
                                ),
                                const VerticalDivider(width: 1, thickness: 1),
                                Expanded(
                                  child: Material(
                                    child: InkWell(
                                      onTap: () {
                                        if (mAdvanceDrawBean.isEmpty) {
                                          List<DrawRespVOs> drawDateObjectsList =
                                              widget
                                                      .bingoPurchaseDetailData
                                                      .particularGameObjects
                                                      ?.drawRespVOs ??
                                                  [];
                                          for (DrawRespVOs drawResp
                                              in drawDateObjectsList) {
                                            mAdvanceDrawBean.add(AdvanceDrawBean(
                                                drawRespVOs: drawResp,
                                                isSelected: false));
                                          }
                                        }
                                        if (mAdvanceDrawBean.isNotEmpty) {
                                          AdvanceDateSelectionDialog().show(
                                              context: context,
                                              title: "Select Draw",
                                              buttonText: "SELECT",
                                              isCloseButton: true,
                                              listOfDraws: mAdvanceDrawBean,
                                              buttonClick: (List<AdvanceDrawBean>
                                                  advanceDrawBean) {
                                                setState(() {
                                                  isAdvanceDateSelectionOptionChosen =
                                                      true;
                                                  if (advanceDrawBean.length > 1) {
                                                    mAdvanceDrawBean =
                                                        advanceDrawBean;
                                                    noOfDrawsFromDrawBtn =
                                                        mAdvanceDrawBean
                                                            .where((element) =>
                                                                element.isSelected ==
                                                                true)
                                                            .toList()
                                                            .length;
                                                    mNumberOfDraws = 0;
                                                    enableDisableDrawsButton();
                                                    recalculateAmount();
                                                  }
                                                });
                                              });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration: Duration(seconds: 1),
                                            content:
                                                Text("No advance draw available."),
                                          ));
                                        }
                                      },
                                      child: Ink(
                                        color: WlsPosColor.light_dark_white,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                        color: WlsPosColor.white,
                                                        borderRadius:
                                                            const BorderRadius.all(
                                                                Radius.circular(20)),
                                                        border: Border.all(
                                                            color: WlsPosColor
                                                                .game_color_grey,
                                                            width: .5)),
                                                    child: Center(
                                                        child: SvgPicture.asset(
                                                            'assets/icons/draw_list.svg',
                                                            width: 16,
                                                            height: 16,
                                                            color: WlsPosColor
                                                                .game_color_grey)))
                                                .pOnly(right: 8),
                                            const Align(
                                                    alignment: Alignment.center,
                                                    child: Text("Draw \n List",
                                                        style: TextStyle(
                                                            color: WlsPosColor
                                                                .game_color_grey,
                                                            fontSize: 10)))
                                                .pOnly(right: 8),
                                            Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        mAdvanceDrawBean
                                                                    .where((element) =>
                                                                        element
                                                                            .isSelected ==
                                                                        true)
                                                                    .toList()
                                                                    .isNotEmpty ==
                                                                true
                                                            ? mAdvanceDrawBean
                                                                .where((element) =>
                                                                    element
                                                                        .isSelected ==
                                                                    true)
                                                                .toList()
                                                                .length
                                                                .toString()
                                                            : "0",
                                                        style: const TextStyle(
                                                            color: WlsPosColor
                                                                .game_color_red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)))
                                                .pOnly(right: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // total selected card , betValue and buy
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            color: WlsPosColor.ball_border_light_bg,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              '${widget.bingoPurchaseDetailData.selectedCardList.length}',
                                              style: const TextStyle(
                                                  color: WlsPosColor.game_color_red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16))),
                                      const Align(
                                          alignment: Alignment.center,
                                          child: Text("Total Bets",
                                              style: TextStyle(
                                                  color: WlsPosColor.game_color_grey,
                                                  fontSize: 12))),
                                    ],
                                  ),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                          alignment: Alignment.center,
                                          child: Text(betValue,
                                              style: const TextStyle(
                                                  color: WlsPosColor.game_color_red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16))),
                                      Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              "Total Bet Value (${getDefaultCurrency(getLanguage())})",
                                              style: const TextStyle(
                                                  color: WlsPosColor.game_color_grey,
                                                  fontSize: 12))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Material(
                                    child: InkWell(
                                      onTap: () {
                                        proceedToBuy();
                                      },
                                      child: Ink(
                                        color: WlsPosColor.game_color_red,
                                        child: isPurchasing
                                            ? SizedBox(
                                                child: Lottie.asset(
                                                    'assets/lottie/buy_loader.json'))
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/icons/buy.svg',
                                                      width: 20,
                                                      height: 20,
                                                      color: WlsPosColor.white),
                                                  const Align(
                                                          alignment: Alignment.center,
                                                          child: Text("BUY NOW",
                                                              style: TextStyle(
                                                                  color: WlsPosColor
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  fontSize: 14)))
                                                      .pOnly(left: 4),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    // SafeArea(
                    //   bottom: true,
                    //   child: Align(
                    //     alignment: Alignment.bottomCenter,
                    //     child: Container(
                    //       height: context.screenHeight * 0.08,
                    //       decoration: const BoxDecoration(boxShadow: [
                    //         BoxShadow(
                    //             color: WlsPosColor.black_16,
                    //             offset: Offset(0, -3),
                    //             blurRadius: 6,
                    //             spreadRadius: 0)
                    //       ], color: WlsPosColor.white),
                    //       child: Row(
                    //         children: [
                    //           Expanded(
                    //             flex: 2,
                    //             child: BlocListener<GameSaleBloc, GameSaleState>(
                    //               listener: (context, state) {
                    //                 print("sate is $state");
                    //                 if (state is GameSaleSuccess) {
                    //                   print("game sale is success");
                    //                   Alert.show(
                    //                     isDarkThemeOn: false,
                    //                     buttonClick: () {
                    //                       resetLoader();
                    //                       Navigator.pushNamed(
                    //                           context, WlsPosScreen.homeScreen);
                    //                     },
                    //                     title: 'Success',
                    //                     subtitle:
                    //                         "Ticket Number: ${state.response.responseData?.ticketNumber}",
                    //                     buttonText: 'ok'.toUpperCase(),
                    //                     context: context,
                    //                     type: AlertType.success,
                    //                   );
                    //                 } else if (state is GameSaleError) {
                    //                   print("game sale is error");
                    //                   Alert.show(
                    //                     isDarkThemeOn: false,
                    //                     type: AlertType.error,
                    //                     buttonClick: () {
                    //                       resetLoader();
                    //                     },
                    //                     title: 'Error!',
                    //                     subtitle: state.errorMessage,
                    //                     buttonText: 'ok'.toUpperCase(),
                    //                     context: context,
                    //                   );
                    //                 }
                    //               },
                    //               child: InkWell(
                    //                 onTap: () {
                    //                   setState(() {
                    //                     isBuyNowPressed = true;
                    //                   });
                    //                   // ToDo add here to make sale
                    //                   // BlocProvider.of<GameSaleBloc>(context).add(
                    //                   //   GameSale(
                    //                   //     context: context,
                    //                   //     sportsPoolSaleModel: widget
                    //                   //         .purchaseDetailsModel.sportsPoolSaleModel,
                    //                   //   ),
                    //                   // );
                    //                 },
                    //                 child: Container(
                    //                   color: WlsPosColor.cherry,
                    //                   child: isBuyNowPressed
                    //                       ? Padding(
                    //                           padding: const EdgeInsets.all(8.0),
                    //                           child: SizedBox(
                    //                             height: context.screenHeight * 0.08 - 20,
                    //                             width: context.screenHeight * 0.08 - 20,
                    //                             child: const Center(
                    //                               child: CircularProgressIndicator(
                    //                                   color: WlsPosColor.white_two),
                    //                             ),
                    //                           ),
                    //                         )
                    //                       : Row(
                    //                           mainAxisAlignment: MainAxisAlignment.center,
                    //                           crossAxisAlignment:
                    //                               CrossAxisAlignment.center,
                    //                           children: [
                    //                             Align(
                    //                               alignment: Alignment.center,
                    //                               child: Image.asset(
                    //                                 "assets/icons/buy_icon.png",
                    //                                 width: 25,
                    //                                 height: 25,
                    //                               ),
                    //                             ),
                    //                             const WidthBox(5),
                    //                             const Align(
                    //                               alignment: Alignment.centerRight,
                    //                               child: Text("CONFIRM BUY",
                    //                                   style: TextStyle(
                    //                                       color: WlsPosColor.white,
                    //                                       fontWeight: FontWeight.w700,
                    //                                       fontFamily: "Roboto",
                    //                                       fontStyle: FontStyle.normal,
                    //                                       fontSize: 19.5),
                    //                                   textAlign: TextAlign.left),
                    //                             )
                    //                           ],
                    //                         ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void initData() {
    setState(() {
      //List<UnitCost?> unitCost = widget.bingoPurchaseDetailData.particularGameObjects?.unitCost?.where((element) => element.currency == getDefaultCurrency(getLanguage())).toList() ?? [];
      // if(unitCost.isNotEmpty){
      //   unitPrice = (unitCost[0]!.price ?? 1).round();
      // }
      unitPrice = (widget.bingoPurchaseDetailData.particularGameObjects
              ?.betRespVOs?[0].unitPrice ??
          1);
      selectedCardList = widget.bingoPurchaseDetailData.selectedCardList;
      betValue = widget.bingoPurchaseDetailData.betValue;
      priceSubtractor = int.parse(betValue) ~/ (selectedCardList.length);

      GameRespVOs? gameObjectsList =
          widget.bingoPurchaseDetailData.particularGameObjects;
      drawRespLength = gameObjectsList?.drawRespVOs?.length ?? 0;
      mNumberOfDraws = gameObjectsList?.drawRespVOs?.length ?? 0;
      drawRespLength = gameObjectsList?.drawRespVOs?.length ?? 0;
      //listPanel    = gameSelectedDetails;
      listConsecutiveDraws = gameObjectsList?.consecutiveDraw?.split(",") ?? [];
      if (listConsecutiveDraws.isNotEmpty) {
        mNumberOfDraws = int.parse(listConsecutiveDraws[0]);
        drawsCount = int.parse(listConsecutiveDraws[0]);
      }
    });
  }

  resetLoader() {
    setState(() {
      isBuyNowPressed = false;
    });
  }

  proceedToBuy() {
    for (int i = 0; i < mAdvanceDrawBean.length; i++) {
      if (mAdvanceDrawBean[i].isSelected == true) {
        listAdvanceMap.add({
          "drawId": mAdvanceDrawBean[i].drawRespVOs?.drawId.toString() ?? ""
        });
      }
    }
    for (int i = 0; i < selectedCardList.length; i++) {
      CardModel selectedCard = selectedCardList[i];
      for (int j = 0; j < selectedCard.cardNumberList.length; j++) {}
      GameRespVOs? gameObjectsList =
          widget.bingoPurchaseDetailData.particularGameObjects;
      //var numberOfCards = selectedCardList.length;
      m_panel_bean.PanelBean panelBean = m_panel_bean.PanelBean(
        betCode: gameObjectsList?.betRespVOs![0].betCode,
        pickCode:
            gameObjectsList?.betRespVOs![0].pickTypeData?.pickType![0].code,
        pickConfig: "Number",
        isQuickPick: false,
        numberOfLines: 1,
        //mNumberOfDraws,
        isQpPreGenerated: false,
        pickedValue: selectedCard.numberString,
        betAmountMultiple: 1,
        unitPrice: unitPrice,
      );
      listPanel.add(panelBean);
    }
    ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? rePrintApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_SALE").toList()[0];
    UrlDrawGameBean? buyApiUrlsDetails = getDrawGameUrlDetails(rePrintApiDetails!, context, "buy");
    BlocProvider.of<LotteryBloc>(context).add(LotterySaleApi(
        context: context,
        isAdvancePlay: listAdvanceMap.isNotEmpty ? true : false,
        noOfDraws: noOfDrawsFromDrawBtn != 0
            ? noOfDrawsFromDrawBtn
            : mNumberOfDraws != 0
                ? mNumberOfDraws
                : 1,
        // drawsCount,
        listAdvanceDraws: listAdvanceMap,
        listPanel: listPanel,
        gameObjectsList: widget.bingoPurchaseDetailData.particularGameObjects,
      apiUrlDetails: buyApiUrlsDetails
    ));
  }

  resetAdvanceDraws() {
    listAdvanceDraws.clear();
    drawCountAdvance = "0";
  }

  enableDisableDrawsButton() {
    setState(() {
      if (mIndexConsecutiveDrawsList != drawRespLength - 1) {
        addDrawNotAllowed = false;
      } else {
        addDrawNotAllowed = true;
      }

      if (mIndexConsecutiveDrawsList != 0) {
        minusDrawNotAllowed = false;
      } else {
        minusDrawNotAllowed = true;
      }
    });
  }

  void recalculateAmount() {
    var numberOfCards = selectedCardList.length;
    betValue = noOfDrawsFromDrawBtn != 0
        ? '${(numberOfCards * noOfDrawsFromDrawBtn * unitPrice).round()}'
        : '${(numberOfCards * mNumberOfDraws * unitPrice).round()}';
  }

// void recalculatePanelAmount() {
//   for (int index = 0; index < listPanel.length; index++) {
//     if(noOfDrawsFromDrawBtn != 0) {
//       listPanel[index].numberOfDraws = noOfDrawsFromDrawBtn;
//
//     } else {
//       listPanel[index].numberOfDraws = mNumberOfDraws;
//     }
//     int numberOfDraws = listPanel[index].numberOfDraws ?? 0;
//     int numberOfLines = listPanel[index].numberOfLines ?? 0;
//
//     var selectedAmt = listPanel[index].selectBetAmount ?? 0;
//
//     int amt = selectedAmt * numberOfDraws * numberOfLines;
//     setState(() {
//       listPanel[index].amount = amt.toDouble();
//     });
//   }
//   calculateTotalAmount();
// }
//
// calculateTotalAmount() {
//   int amount = 0;
//
//   for (m_panel_bean.PanelBean model in listPanel) {
//     amount = amount + (model.amount!= null ? model.amount!.toInt() : 0);
//   }
//   setState(() {
//     betAmount = "${getDefaultCurrency(getLanguage())} $amount";
//   });
//   calculateNumberOfBets();
// }
//
// calculateNumberOfBets() {
//   setState(() {
//     noOfBet = "${listPanel.length}";
//   });
// }
}
