import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/lottery/bloc/lottery_bloc.dart';
import 'package:wls_pos/lottery/bloc/lottery_event.dart';
import 'package:wls_pos/lottery/bloc/lottery_state.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/advanceDrawBean.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/widgets/advance_date_selection_dialog.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

import '../../../utility/UrlDrawGameBean.dart';

class ZooPurchaseDetails extends StatefulWidget {
  final GameRespVOs? gameObjectsList;
  final List<PanelBean>? mPanelBinList;
  final Function(String) onComingToPreviousScreen;

  const ZooPurchaseDetails(
      {Key? key,
        this.gameObjectsList,
        this.mPanelBinList,
        required this.onComingToPreviousScreen})
      : super(key: key);

  @override
  _ZooPurchaseDetailsState createState() => _ZooPurchaseDetailsState();
}

class _ZooPurchaseDetailsState extends State<ZooPurchaseDetails> {
  bool isPurchasing = false;
  Map<String, dynamic> printingDataArgs = {};
  int noOfDraws = 1;
  bool minusDrawNotAllowed = false;
  List<Map<String, String>> listAdvanceDraws = [];
  String drawCountAdvance = "0";
  int noOfDrawsFromDrawBtn = 0;
  List<AdvanceDrawBean> mAdvanceDrawBean = [];
  List<Map<String, String>> listAdvanceMap = [];
  bool isAdvancePlay = false;
  int mIndexConsecutiveDrawsList = 0;
  int mNumberOfDraws = 1;
  List<String> listConsecutiveDraws = [];
  bool addDrawNotAllowed = false;
  late int drawRespLength;
  String betAmount = "";
  String noOfBet = "";
  List<PanelBean> listPanel = [];
  int drawsCount = 1;

  @override
  void initState() {
    initializeInitialValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isPurchasing,
      child:
      SafeArea(
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
                          widget.onComingToPreviousScreen("isBuyPerformed");
                          Navigator.of(context).pop(true);
                        }, isPrintingForSale: true);
                  }
                }
              },
              child: WlsPosScaffold(
                showAppBar: true,
                backgroundColor: WlsPosColor.light_dark_white,
                onBackButton: (widget.mPanelBinList == null ||
                    widget.mPanelBinList?.isEmpty == true)
                    ? null
                    : () {
                  Navigator.of(context).pop(widget.mPanelBinList);
                },
                appBarTitle: Text("Purchase Details",
                    style: const TextStyle(fontSize: 18, color: WlsPosColor.white)),
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
                      SharedPrefUtils.setDgeLastSaleTicketNo = jsonEncode(state.response.responseData?.ticketNumber.toString() ?? "");
                      SharedPrefUtils.setDgeLastSaleGameCode = jsonEncode(state.response.responseData?.gameCode.toString() ?? "");


                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text("Purchased Successfully"),
                      ));

                      printingDataArgs["saleResponse"] = jsonEncode(state.response);
                      printingDataArgs["username"] = UserInfo.userName;
                      printingDataArgs["currencyCode"] =
                          getDefaultCurrency(getLanguage());
                      log("--------------------------------------------------------------------------------------------------------");
                      if (state.response.responseData?.gameCode == "BichoRapido") {
                        log("state.response.responseData?.gameCode: ${state.response.responseData?.gameCode}");
                        var panelListLength = widget.mPanelBinList?.length ?? 0;
                        for(int i=0; i< panelListLength; i++) {
                          print("widget.mPanelBinList?[i].pickedValue: ${widget.mPanelBinList?[i].pickedValue}");
                          widget.mPanelBinList?[i].pickedValue = widget.mPanelBinList?[i].pickedValue?.replaceAll("-1", "X");
                        }
                      }

                      for(var i=0 ; i< (state.response.responseData?.panelData ?? []).length ; i++) {
                        widget.mPanelBinList?[i].numberOfLines = state.response.responseData?.panelData?[i].numberOfLines;
                        widget.mPanelBinList?[i].unitPrice = state.response.responseData?.panelData?[i].unitCost;
                      }
                      log("panelData: ${jsonEncode(widget.mPanelBinList)}");
                      printingDataArgs["panelData"] = jsonEncode(widget.mPanelBinList);

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
                          Map<String, dynamic> panelDataToBeSave = {
                            "panelData": widget.mPanelBinList
                          };
                          SharedPrefUtils.setSelectedPanelData =
                              jsonEncode(panelDataToBeSave);
                          SharedPrefUtils.setSelectedGameObject =
                              jsonEncode(widget.gameObjectsList);

                          print(
                              "UserInfo.getSelectedPanelData: ${jsonDecode(UserInfo.getSelectedPanelData)}");
                          var jsonPanelData = jsonDecode(UserInfo.getSelectedPanelData)
                          as Map<String, dynamic>;
                          print("jsonPanelData: $jsonPanelData");
                          print(
                              "jsonPanelData[panelData]: ${jsonPanelData["panelData"]}");
                          print(
                              "UserInfo.getSelectedGameObject: ${GameRespVOs.fromJson(jsonDecode(UserInfo.getSelectedGameObject))}");
                          Navigator.of(context).popUntil((route) => false);
                          Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
                        }
                      }
                    }
                  },
                  child: WillPopScope(
                    onWillPop: () async {
                      Navigator.of(context).pop(widget.mPanelBinList);
                      // widget.selectedGamesData(listPanel);
                      return true;
                    },
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(
                                      width: 1, color: WlsPosColor.light_grey),
                                ),
                                child: Column(
                                  children: [
                                    ListView.builder(
                                        itemCount: widget.mPanelBinList!.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              widget.mPanelBinList![index].selectedPickDataList!.isEmpty
                                                  ? Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Container(
                                                    color: WlsPosColor
                                                        .warm_grey_light,
                                                    padding: EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        top: 5,
                                                        bottom: 5),
                                                    child: Text(
                                                        pickedValues(widget
                                                            .mPanelBinList![index]
                                                            .pickedValue),
                                                        style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w400,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                          FontStyle.normal,
                                                          fontSize: 13.0,
                                                        )),
                                                  ),
                                                  Text(
                                                      '${getDefaultCurrency(getLanguage()) + " " + widget.mPanelBinList![index].betAmountMultiple.toString()}',
                                                      style: TextStyle(
                                                        color: WlsPosColor.marine,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily: "Roboto",
                                                        // fontStyle: FontStyle.normal,
                                                        fontSize: 15.0,
                                                      ))
                                                ],
                                              ).pOnly(
                                                  left: 10, right: 10, top: 10)
                                                  : const SizedBox(),
                                              widget.mPanelBinList![index].selectedPickDataList!.isEmpty
                                                  ? Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                      widget.mPanelBinList![index]
                                                          .pickCode!,
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        fontFamily: "Roboto",
                                                        fontStyle:
                                                        FontStyle.normal,
                                                        fontSize: 13.0,
                                                      )),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        widget.mPanelBinList!
                                                            .removeAt(index);
                                                      });
                                                      if (widget.mPanelBinList!
                                                          .isEmpty) {
                                                        Navigator.of(context).pop(
                                                            widget.mPanelBinList);
                                                      }
                                                    },
                                                    child: Image.asset(
                                                        width: 20,
                                                        height: 20,
                                                        "assets/icons/delete.png"),
                                                  )
                                                ],
                                              ).pOnly(left: 10, right: 10, top: 10)
                                                  : const SizedBox(),
                                              widget.mPanelBinList![index].selectedPickDataList!.isNotEmpty
                                                  ? ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: widget.mPanelBinList![index].selectedPickDataList!.length,
                                                  itemBuilder: (context, i) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                          MainAxisSize.max,
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  color: WlsPosColor
                                                                      .warm_grey_light,
                                                                  alignment:
                                                                  Alignment
                                                                      .center,
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(2),
                                                                  child: Text(
                                                                      getNameAndNumber(
                                                                          widget
                                                                              .mPanelBinList![
                                                                          index]
                                                                              .selectedPickDataList![
                                                                          i]
                                                                              .gameNameList![0],
                                                                          'number'),
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                        fontFamily:
                                                                        "Roboto",
                                                                        fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                        // fontSize: 13.0,
                                                                      )),
                                                                ),
                                                                Text(
                                                                    getNameAndNumber(
                                                                        widget
                                                                            .mPanelBinList![index]
                                                                            .selectedPickDataList![i]
                                                                            .gameNameList![0],
                                                                        'name')
                                                                        .toUpperCase(),
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                      fontFamily:
                                                                      "Roboto",
                                                                      fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                      fontSize:
                                                                      13.0,
                                                                    )).pOnly(left: 5)
                                                              ],
                                                            ),
                                                            i == 0 ? Text(
                                                                '${getDefaultCurrency(getLanguage()) + " " + widget.mPanelBinList![index].betAmountMultiple.toString()}',
                                                                style: TextStyle(
                                                                  color: WlsPosColor
                                                                      .marine,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontFamily:
                                                                  "Roboto",
                                                                  // fontStyle: FontStyle.normal,
                                                                  fontSize: 15.0,
                                                                )) : Container()
                                                          ],
                                                        ).pOnly(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                                width: 30,
                                                                height: 30,
                                                                "assets/images/animals/${getImageName(widget.mPanelBinList![index].selectedPickDataList![i].gameNameList![0])}.jpg"),
                                                            Container(
                                                              width: 50,
                                                              margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                              child: Table(
                                                                  border: TableBorder.symmetric(
                                                                      inside: BorderSide(
                                                                          width: 1,
                                                                          color: Colors
                                                                              .grey),
                                                                      outside:
                                                                      BorderSide
                                                                          .none),
                                                                  children: [
                                                                    TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                            child: Text(
                                                                                widget.mPanelBinList![index].selectedPickDataList![i].gameNumberList![0][
                                                                                0],
                                                                                textAlign:
                                                                                TextAlign.center)),
                                                                        TableCell(
                                                                            child: Text(
                                                                                widget.mPanelBinList![index].selectedPickDataList![i].gameNumberList![0][
                                                                                1],
                                                                                textAlign:
                                                                                TextAlign.center)),
                                                                      ],
                                                                    ),
                                                                    TableRow(
                                                                      children: [
                                                                        TableCell(
                                                                            child: Text(
                                                                                widget.mPanelBinList![index].selectedPickDataList![i].gameNumberList![0][
                                                                                2],
                                                                                textAlign:
                                                                                TextAlign.center)),
                                                                        TableCell(
                                                                            child: Text(
                                                                                widget.mPanelBinList![index].selectedPickDataList![i].gameNumberList![0][
                                                                                3],
                                                                                textAlign:
                                                                                TextAlign.center)),
                                                                      ],
                                                                    ),
                                                                  ]),
                                                            )
                                                          ],
                                                        ).pOnly(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10),
                                                        index == 2
                                                            ? SizedBox()
                                                            : Container(
                                                          margin:
                                                          EdgeInsets.only(
                                                              top: 10,
                                                              left: 10),
                                                          width: 150,
                                                          height: 1,
                                                          color: WlsPosColor
                                                              .warm_grey_light,
                                                        )
                                                        // MySeparator(width: 5,).pOnly(top: 15, bottom: 5)
                                                      ],
                                                    );
                                                  })
                                                  : const SizedBox(),
                                              widget.mPanelBinList![index].selectedPickDataList!.isNotEmpty
                                                  ? Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(  widget
                                                      .mPanelBinList![index].gameName.toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        fontFamily: "Roboto",
                                                        fontStyle:
                                                        FontStyle.normal,
                                                        fontSize: 13.0,
                                                      )),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        widget.mPanelBinList!
                                                            .removeAt(index);
                                                      });
                                                      if (widget.mPanelBinList!
                                                          .isEmpty) {
                                                        Navigator.of(context).pop(
                                                            widget.mPanelBinList);
                                                      }
                                                    },
                                                    child: Image.asset(
                                                        width: 20,
                                                        height: 20,
                                                        "assets/icons/delete.png"),
                                                  )
                                                ],
                                              ).pOnly(
                                                  left: 10, right: 10, top: 20)
                                                  : const SizedBox(),
                                              MySeparator(
                                                width: 3,
                                              ).pOnly(top: 15, bottom: 5),
                                            ],
                                          );
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ).pOnly(left: 10, right: 10, top: 10, bottom: 130),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SafeArea(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              color: WlsPosColor.ball_border_light_bg,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                                        recalculatePanelAmount();
                                                      },
                                                      customBorder: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Center(
                                                          child: SvgPicture.asset(
                                                              'assets/icons/minus.svg',
                                                              width: 20,
                                                              height: 20,
                                                              color: mIndexConsecutiveDrawsList ==
                                                                  -1 ||
                                                                  mIndexConsecutiveDrawsList ==
                                                                      0
                                                                  ? WlsPosColor.game_color_grey
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
                                                            fontSize: 16))).pOnly(right: 8),
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
                                                              .gameObjectsList
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
                                                        recalculatePanelAmount();
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
                                                        widget.gameObjectsList?.drawRespVOs ??
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
                                                            if (advanceDrawBean.length > 1) {
                                                              if (advanceDrawBean
                                                                  .where((element) =>
                                                              element.isSelected ==
                                                                  true)
                                                                  .toList()
                                                                  .isNotEmpty) {
                                                                mAdvanceDrawBean =
                                                                    advanceDrawBean;
                                                                noOfDrawsFromDrawBtn =
                                                                    mAdvanceDrawBean
                                                                        .where((element) =>
                                                                    element
                                                                        .isSelected ==
                                                                        true)
                                                                        .toList()
                                                                        .length;
                                                                mNumberOfDraws = 0;
                                                                mIndexConsecutiveDrawsList = -1;
                                                                enableDisableDrawsButton();
                                                                recalculatePanelAmount();
                                                              } else {
                                                                resetAdvanceDraws();
                                                                setState(() {
                                                                  noOfDrawsFromDrawBtn = 0;
                                                                  mAdvanceDrawBean.clear();
                                                                  listAdvanceMap.clear();
                                                                  isAdvancePlay = false;
                                                                  drawRespLength = widget
                                                                      .gameObjectsList
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
                                                                recalculatePanelAmount();
                                                              }
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
                                  SizedBox(
                                    height: 50,
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
                                                      noOfBet
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color: WlsPosColor
                                                              .game_color_red,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16))),
                                              const Align(
                                                  alignment: Alignment.center,
                                                  child: Text("Total Bets",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .game_color_grey,
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
                                                  child: Text(
                                                    // betAmount,
                                                      getTotalBetAmount(
                                                          widget.mPanelBinList),
                                                      style: const TextStyle(
                                                          color: WlsPosColor
                                                              .game_color_red,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16))),
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      "Total Bet Value (${getDefaultCurrency(getLanguage())})",
                                                      style: const TextStyle(
                                                          color: WlsPosColor
                                                              .game_color_grey,
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
                                                child: Row(
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
                                                        child: Text("CONFIRM BUY",
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
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ) )),
    );
  }

  String pickedValues(String? pickedValues) {
    if(pickedValues!.contains("-1"))
      pickedValues = pickedValues!.replaceFirst(RegExp('-1'), 'X');
    return pickedValues!.replaceAll(RegExp('#'), '');
  }

  String getNameAndNumber(String gameNameList, String type) {
    return type == 'name'
        ? gameNameList.split(',')[0]
        : gameNameList.split(',')[1];
  }

  String getImageName(String gameNameList) {
    return gameNameList.split(',')[1] + gameNameList.split(',')[0];
  }

  String getTotalBetAmount(List<PanelBean>? mPanelBinList) {
    int? totalBetAmount = 0;
    for (var data in mPanelBinList!) {
      // totalBetAmount = (totalBetAmount! + data.betAmountMultiple!);
      totalBetAmount = (totalBetAmount! + data.betAmountMultiple!).toInt();
    }
    return (totalBetAmount! * noOfDraws).toString();
  }

  void proceedToBuy() {
    ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? rePrintApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_SALE").toList()[0];
    UrlDrawGameBean? buyApiUrlsDetails = getDrawGameUrlDetails(rePrintApiDetails!, context, "buy");

    BlocProvider.of<LotteryBloc>(context).add(LotterySaleApi(
        context: context,
        isAdvancePlay: false,
        // noOfDraws: widget.mPanelBinList!.length,
        noOfDraws: noOfDraws,
        // listAdvanceDraws: listAdvanceMap,
        listPanel: widget.mPanelBinList,
        gameObjectsList: widget.gameObjectsList,
      apiUrlDetails: buyApiUrlsDetails,
    ));
  }

  resetAdvanceDraws() {
    setState(() {
      listAdvanceDraws.clear();
      drawCountAdvance = "0";
    });
  }

  enableDisableDrawsButton() {
    setState(() {
      if (mIndexConsecutiveDrawsList == -1) {
        print("mIndexConsecutiveDrawsList: $mIndexConsecutiveDrawsList");
        addDrawNotAllowed = false;
        minusDrawNotAllowed = true;
      } else {
        if (mIndexConsecutiveDrawsList != drawRespLength - 1) {
          addDrawNotAllowed = false;
        } else {
          addDrawNotAllowed = true;
        }
        if (!addDrawNotAllowed) {
          if (mIndexConsecutiveDrawsList != 0) {
            minusDrawNotAllowed = false;
          } else {
            minusDrawNotAllowed = true;
          }
        }
      }
    });
  }

  void recalculatePanelAmount() {
    for (int index = 0; index < widget.mPanelBinList!.length; index++) {
      if (noOfDrawsFromDrawBtn != 0) {
        widget.mPanelBinList![index].numberOfDraws = noOfDrawsFromDrawBtn;
      } else {
        widget.mPanelBinList![index].numberOfDraws = mNumberOfDraws;
      }
      int numberOfDraws = widget.mPanelBinList![index].numberOfDraws ?? 0;
      noOfDraws = widget.mPanelBinList![index].numberOfDraws ?? 0;

      // var selectedAmt = widget.mPanelBinList![index].betAmountMultiple ?? 0;
      var selectedAmt = widget.mPanelBinList![index].betAmountMultipleNumber ?? 0;

      // int amt = selectedAmt * numberOfDraws;
      int amt = selectedAmt * 1;
      setState(() {
        widget.mPanelBinList![index].betAmountMultiple = amt;
        // widget.mPanelBinList![index].amount = amt.toDouble();
      });
    }
    calculateTotalAmount();
  }

  calculateTotalAmount() {
    int amount = 0;

    for (PanelBean model in listPanel) {
      amount = amount + (model.amount != null ? model.amount!.toInt() : 0);
    }
    setState(() {
      betAmount = "${getDefaultCurrency(getLanguage())} $amount";
    });
    calculateNumberOfBets();
  }

  calculateNumberOfBets() {
    setState(() {
      noOfBet = "${listPanel.length}";
    });
  }

  void initializeInitialValues() {
    print(
        "previewScreen: panel Data:  ${jsonEncode(widget.mPanelBinList!)}");
    drawRespLength = widget.gameObjectsList?.drawRespVOs?.length ?? 0;
    listPanel = widget.mPanelBinList!;
    listConsecutiveDraws =
        widget.gameObjectsList?.consecutiveDraw?.split(",") ?? [];
    if (listConsecutiveDraws.isNotEmpty) {
      mNumberOfDraws = int.parse(listConsecutiveDraws[0]);
      drawsCount = int.parse(listConsecutiveDraws[0]);
    }

    enableDisableDrawsButton();
    calculateTotalAmount();
  }
}
