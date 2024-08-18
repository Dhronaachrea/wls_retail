import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/purchase_details/model/request/purchase_details_model.dart';
import 'package:wls_pos/purchase_details/model/request/purchase_list_model.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart' as m_panel_bean;

import '../login/bloc/login_state.dart';
import '../utility/secured_shared_pref.dart';
import '../utility/widgets/alert_dialog.dart';
import 'bloc/game_sale_bloc.dart';

class PurchaseDetails extends StatefulWidget {
  final PurchaseDetailsModel purchaseDetailsModel;

  const PurchaseDetails({Key? key, required this.purchaseDetailsModel})
      : super(key: key);

  @override
  State<PurchaseDetails> createState() => _PurchaseDetailsState();
}

class _PurchaseDetailsState extends State<PurchaseDetails> {
  final bool _mIsShimmerLoading = false;
  bool isBuyNowPressed = false;
  int? count;
  Map<String, dynamic> printingDataArgs               = {};
  List<m_panel_bean.PanelBean> listPanel              = [];

  @override
  Widget build(BuildContext context) {
    count = widget.purchaseDetailsModel.purchaseListItemModelList!.length;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is GetLoginDataSuccess) {
          if (state.response != null) {
            BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: state.response!));
            setState(() {
              isBuyNowPressed = false;
            });
            PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isSportsPoolSale: true,onPrintingDone:(){
             // widget.onComingToPreviousScreen("isBuyPerformed");
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            }, isPrintingForSale: true);

          }
        } else if (state is GetLoginDataError) {

          PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isSportsPoolSale: true, onPrintingDone:(){
            //widget.onComingToPreviousScreen("isBuyPerformed");
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
          }, isPrintingForSale: true);
        }
      },
      child: AbsorbPointer(
        absorbing: isBuyNowPressed,
        child: SafeArea(
          child: WlsPosScaffold(
            showAppBar: true,
            centerTitle: false,
            backgroundColor: _mIsShimmerLoading
                ? WlsPosColor.light_dark_white
                : WlsPosColor.white,
            appBarTitle: const Text("Purchase Details",
                style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      color: WlsPosColor.white_two,
                      padding: const EdgeInsets.all(10),
                      child: widget.purchaseDetailsModel.responseData!.gameCode ==
                          "PICK_4"
                          ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('No. of Races: $count',
                              style: const TextStyle(
                                // color: WlsPosColor.navy_blue,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Roboto",
                                fontStyle: FontStyle.normal,
                                fontSize: 14.0,
                              )),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                            child: Row(
                              children: [
                                Text(
                                    'Bet ${widget.purchaseDetailsModel.currency} ${widget.purchaseDetailsModel.betValue}',
                                    style: const TextStyle(
                                      // color: WlsPosColor.navy_blue,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Roboto",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14.0,
                                    )),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: WlsPosColor.white,
                                    ),
                                    child: Image.asset(
                                      width: 20,
                                      height: 20,
                                      "assets/icons/delete.png",
                                      color: WlsPosColor.cherry,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  '${widget.purchaseDetailsModel.responseData?.drawData![widget.purchaseDetailsModel.drawGameSelectedIndex].drawName}',
                                  style: const TextStyle(fontSize: 14)),
                              Text(
                                ' - ${formatDate(
                                  date: widget
                                      .purchaseDetailsModel
                                      .responseData!
                                      .drawData![widget.purchaseDetailsModel
                                      .drawGameSelectedIndex]
                                      .drawDateTime!,
                                  inputFormat: Format.apiDateFormat2,
                                  outputFormat: Format.dateFormat12,
                                )}',
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: WlsPosColor.white,
                              ),
                              child: Image.asset(
                                width: 20,
                                height: 20,
                                "assets/icons/delete.png",
                                color: WlsPosColor.cherry,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    widget.purchaseDetailsModel.responseData!.gameCode == "PICK_4"
                        ? Container()
                        : IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    '${widget.purchaseDetailsModel.numOfLines}',
                                    style: const TextStyle(
                                        color: WlsPosColor.cherry,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Roboto",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16.0)),
                                const HeightBox(5),
                                const Text("No. Of Lines",
                                    style: TextStyle(
                                        color: WlsPosColor.warm_grey_new,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Roboto",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12.0)),
                              ],
                            ).p4(),
                          ),
                          // const VerticalDivider(color: WlsPosColor.brownish_grey_six,thickness: 2,),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    "${widget.purchaseDetailsModel.currency} ${widget.purchaseDetailsModel.betValue}",
                                    style: const TextStyle(
                                        color: WlsPosColor.cherry,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Roboto",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16.0),
                                    textAlign: TextAlign.center),
                                const HeightBox(5),
                                const Text("Bet Value",
                                    style: TextStyle(
                                        color: WlsPosColor.warm_grey_new,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Roboto",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12.0),
                                    textAlign: TextAlign.center),
                              ],
                            ).p4(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: EdgeInsets.only(
                              top: 8, bottom: context.screenHeight * 0.16),
                          decoration: BoxDecoration(
                              border: Border.all(color: WlsPosColor.white_two),
                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                          child: Column(
                            children: [
                              widget.purchaseDetailsModel.responseData!.gameCode ==
                                  "PICK_4"
                                  ? Container(
                                color: WlsPosColor.white_two,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: context.screenWidth * 0.12,
                                          child: const Text('Race',
                                              style: TextStyle(
                                                // color: WlsPosColor.navy_blue,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: "Roboto",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14.0,
                                              )),
                                        ),
                                        const Text('Horse Name',
                                            style: TextStyle(
                                              // color: WlsPosColor.navy_blue,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Roboto",
                                              fontStyle: FontStyle.normal,
                                              fontSize: 14.0,
                                            )).pOnly(left: 35),
                                      ],
                                    ),
                                    const Text('Horse No.',
                                        style: TextStyle(
                                          // color: WlsPosColor.navy_blue,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Roboto",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0,
                                        )),
                                  ],
                                ),
                              )
                                  : const SizedBox(),
                              Expanded(
                                child: AnimationLimiter(
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: widget.purchaseDetailsModel
                                          .purchaseListItemModelList?.length,
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration.staggeredList(
                                          duration: const Duration(milliseconds: 700),
                                          position: index,
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  widget
                                                      .purchaseDetailsModel
                                                      .responseData!
                                                      .gameCode ==
                                                      "PICK_4"
                                                      ? const SizedBox()
                                                      : Row(
                                                    children: [
                                                      Container(
                                                        width: 30,
                                                        height: 30,
                                                        color: WlsPosColor
                                                            .navy_blue,
                                                        alignment:
                                                        Alignment.center,
                                                        child: Text(
                                                          '${index + 1}',
                                                          style: const TextStyle(
                                                              color: WlsPosColor
                                                                  .white),
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            widget
                                                                .purchaseDetailsModel
                                                                .purchaseListItemModelList![
                                                            index]
                                                                .venueName!,
                                                            style: const TextStyle(
                                                                color:
                                                                WlsPosColor
                                                                    .black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                                fontFamily:
                                                                "Roboto",
                                                                fontStyle:
                                                                FontStyle
                                                                    .normal,
                                                                fontSize: 12.0),
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                          Text(
                                                              widget
                                                                  .purchaseDetailsModel
                                                                  .purchaseListItemModelList![
                                                              index]
                                                                  .startTime!,
                                                              style: const TextStyle(
                                                                  color:
                                                                  WlsPosColor
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                                  fontFamily:
                                                                  "Roboto",
                                                                  fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                                  fontSize:
                                                                  12.0),
                                                              textAlign:
                                                              TextAlign
                                                                  .right)
                                                        ],
                                                      ).pOnly(left: 5),
                                                    ],
                                                  ),
                                                  widget
                                                      .purchaseDetailsModel
                                                      .responseData!
                                                      .gameCode ==
                                                      "PICK_4"
                                                      ? Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: context
                                                                .screenWidth *
                                                                0.21,
                                                            child: Text(
                                                              widget
                                                                  .purchaseDetailsModel
                                                                  .purchaseListItemModelList![
                                                              index]
                                                                  .eventGameName,
                                                              style:
                                                              const TextStyle(
                                                                color:
                                                                WlsPosColor
                                                                    .marine,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                                fontFamily:
                                                                "Roboto",
                                                                fontStyle:
                                                                FontStyle
                                                                    .normal,
                                                                fontSize: 12.0,
                                                              ),
                                                              textAlign:
                                                              TextAlign
                                                                  .left,
                                                            ),
                                                          ),
                                                          Container(
                                                            width: context
                                                                .screenWidth *
                                                                0.4,
                                                            child: Text(
                                                              getRaceName(widget
                                                                  .purchaseDetailsModel
                                                                  .purchaseListItemModelList![index]),
                                                              style:
                                                              const TextStyle(
                                                                color:
                                                                WlsPosColor
                                                                    .marine,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                                fontFamily:
                                                                "Roboto",
                                                                fontStyle:
                                                                FontStyle
                                                                    .normal,
                                                                fontSize: 12.0,
                                                              ),
                                                              textAlign:
                                                              TextAlign
                                                                  .left,
                                                            ).pOnly(left: 10),
                                                          )
                                                        ],
                                                      ),
                                                      Container(
                                                        width: context
                                                            .screenWidth *
                                                            0.2,
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            getRaceNumber(widget
                                                                .purchaseDetailsModel
                                                                .purchaseListItemModelList![index]),
                                                            style: const TextStyle(
                                                              // color: WlsPosColor.navy_blue,
                                                              fontWeight:
                                                              FontWeight
                                                                  .normal,
                                                              fontFamily:
                                                              "Roboto",
                                                              fontStyle:
                                                              FontStyle
                                                                  .normal,
                                                              fontSize: 14.0,
                                                            )),
                                                      ),
                                                    ],
                                                  ).pSymmetric(v: 10)
                                                      : Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 8,
                                                        child: Wrap(
                                                          crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                          children: [
                                                            Text(
                                                              widget
                                                                  .purchaseDetailsModel
                                                                  .purchaseListItemModelList![
                                                              index]
                                                                  .homeTeam!,
                                                              style:
                                                              const TextStyle(
                                                                color:
                                                                WlsPosColor
                                                                    .marine,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                                fontFamily:
                                                                "Roboto",
                                                                fontStyle:
                                                                FontStyle
                                                                    .normal,
                                                                fontSize: 12.0,
                                                              ),
                                                              textAlign:
                                                              TextAlign
                                                                  .left,
                                                            ),
                                                            Container(
                                                              width: 20,
                                                              height: 20,
                                                              decoration:
                                                              const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: WlsPosColor
                                                                    .yellow_orange_three,
                                                              ),
                                                              alignment:
                                                              Alignment
                                                                  .center,
                                                              child:
                                                              const Center(
                                                                child: Text(
                                                                  'vs',
                                                                ),
                                                              ),
                                                            ).pOnly(
                                                                left: 5,
                                                                right: 5),
                                                            Text(
                                                              widget
                                                                  .purchaseDetailsModel
                                                                  .purchaseListItemModelList![
                                                              index]
                                                                  .awayTeam!,
                                                              style: const TextStyle(
                                                                  color:
                                                                  WlsPosColor
                                                                      .marine,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                                  fontFamily:
                                                                  "Roboto",
                                                                  fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                                  fontSize:
                                                                  12.0),
                                                              textAlign:
                                                              TextAlign
                                                                  .left,
                                                            ),
                                                            Text(
                                                              " > ${widget.purchaseDetailsModel.purchaseListItemModelList![index].marketName!}",
                                                              style: const TextStyle(
                                                                  color:
                                                                  WlsPosColor
                                                                      .black,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                                  fontFamily:
                                                                  "Roboto",
                                                                  fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                                  fontSize:
                                                                  12.0),
                                                              textAlign:
                                                              TextAlign
                                                                  .left,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Wrap(
                                                        direction:
                                                        Axis.horizontal,
                                                        children: widget
                                                            .purchaseDetailsModel
                                                            .purchaseListItemModelList![
                                                        index]
                                                            .selectedOptionList
                                                            .asMap()
                                                            .map((optionIndex,
                                                            element) =>
                                                            MapEntry(
                                                                optionIndex,
                                                                AnimationConfiguration
                                                                    .staggeredList(
                                                                  position:
                                                                  optionIndex,
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                      700),
                                                                  child:
                                                                  SlideAnimation(
                                                                    horizontalOffset:
                                                                    50,
                                                                    child:
                                                                    FadeInAnimation(
                                                                      child:
                                                                      Container(
                                                                        margin:
                                                                        const EdgeInsets.symmetric(horizontal: 2),
                                                                        padding:
                                                                        const EdgeInsets.all(4),
                                                                        decoration:
                                                                        const BoxDecoration(
                                                                          borderRadius: BorderRadius.all(
                                                                            Radius.circular(3),
                                                                          ),
                                                                          color: WlsPosColor.cherry,
                                                                        ),
                                                                        child:
                                                                        Center(
                                                                          child: Text(
                                                                            widget.purchaseDetailsModel.purchaseListItemModelList![index].selectedOptionList[optionIndex],
                                                                            style: const TextStyle(
                                                                              color: WlsPosColor.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )))
                                                            .values
                                                            .toList(),
                                                      ),
                                                    ],
                                                  ).pSymmetric(v: 10),
                                                  const MySeparator(
                                                    width: 5,
                                                    color:
                                                    WlsPosColor.pinkish_grey_two,
                                                  )
                                                ],
                                              ).pOnly(bottom: 15),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              )
                            ],
                          ),
                        ))
                  ],
                ),
                SafeArea(
                  bottom: true,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: context.screenHeight * 0.08,
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: WlsPosColor.black_16,
                            offset: Offset(0, -3),
                            blurRadius: 6,
                            spreadRadius: 0)
                      ], color: WlsPosColor.white),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: BlocListener<GameSaleBloc, GameSaleState>(
                              listener: (context, state) {
                                print("sate is $state");
                                if (state is GameSaleSuccess) {
                                  print("game sale is success");
                                  // SharedPrefUtils.setSportsPoolLastOrderId = jsonEncode(state.response.responseData?.orderId.toString() ?? "");
                                  // SharedPrefUtils.setSportsPoolLastItemId = jsonEncode(state.response.responseData?.itemId.toString() ?? "");
                                  // print("UserInfo.getSportsPoolLastOrderId: ${jsonDecode(UserInfo.getSportsPoolLastOrderId)}");
                                  // print("UserInfo.getSportsPoolLastItemId: ${jsonDecode(UserInfo.getSportsPoolLastItemId)}");
                                  printingDataArgs["saleResponse"]  = jsonEncode(state.response);
                                  printingDataArgs["username"]      = UserInfo.userName;
                                  printingDataArgs["currencyCode"]  = getDefaultCurrency(getLanguage());
                                  printingDataArgs["panelData"]     = jsonEncode(listPanel);
                                  BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
                                  // Alert.show(
                                  //   isDarkThemeOn: false,
                                  //   buttonClick: () {
                                  //     resetLoader();
                                  //     Navigator.pushNamed(
                                  //         context, WlsPosScreen.homeScreen);
                                  //   },
                                  //   title: 'Success',
                                  //   subtitle:
                                  //   "Ticket Number: ${state.response.responseData?.ticketNumber}",
                                  //   buttonText: 'ok'.toUpperCase(),
                                  //   context: context,
                                  //   type: AlertType.success,
                                  // );
                                } else if (state is GameSaleError) {
                                  print("game sale is error");
                                  Alert.show(
                                    isDarkThemeOn: false,
                                    type: AlertType.error,
                                    buttonClick: () {
                                      resetLoader();
                                    },
                                    title: 'Error!',
                                    subtitle: state.errorMessage,
                                    buttonText: 'ok'.toUpperCase(),
                                    context: context,
                                  );
                                }
                              },
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isBuyNowPressed = true;
                                  });
                                  SecuredSharedPrefUtils.setSportsPoolLastOrderId = widget
                                      .purchaseDetailsModel.sportsPoolSaleModel?.orderId.toString() ?? '';
                                  SecuredSharedPrefUtils.setSportsPoolLastItemId = widget
                                      .purchaseDetailsModel.sportsPoolSaleModel?.itemId.toString() ?? '';
                                  BlocProvider.of<GameSaleBloc>(context).add(
                                    GameSale(
                                      context: context,
                                      sportsPoolSaleModel: widget
                                          .purchaseDetailsModel.sportsPoolSaleModel,
                                    ),
                                  );
                                },
                                child: Container(
                                  color: WlsPosColor.cherry,
                                  child: isBuyNowPressed
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height:
                                      context.screenHeight * 0.08 - 20,
                                      width: context.screenHeight * 0.08 - 20,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            color: WlsPosColor.white_two),
                                      ),
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          "assets/icons/buy_icon.png",
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),
                                      const WidthBox(5),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Text("CONFIRM BUY",
                                            style: TextStyle(
                                                color: WlsPosColor.white,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "Roboto",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 19.5),
                                            textAlign: TextAlign.left),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  resetLoader() {
    setState(() {
      isBuyNowPressed = false;
    });
  }

  String getRaceName(PurchaseListItemModel purchaseListItemModelList) {
    String raceName = '';
    purchaseListItemModelList.selectedOptionNameList
        .asMap()
        .forEach((index, element) {
      if (index == 0)
        raceName = element;
      else
        raceName = raceName + ',' + element;
    });
    return raceName;
  }

  String getRaceNumber(PurchaseListItemModel purchaseListItemModelList) {
    String raceNumber = '';
    purchaseListItemModelList.selectedOptionList
        .asMap()
        .forEach((index, element) {
      if (index == 0)
        raceNumber = element;
      else
        raceNumber = raceNumber + ',' + element;
    });
    return raceNumber;
  }
}
