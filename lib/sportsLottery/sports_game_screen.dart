import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/purchase_details/model/request/purchase_details_model.dart';
import 'package:wls_pos/purchase_details/model/request/purchase_list_model.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/purchase_details/model/request/sports_pool_sale_model.dart'
    as spSaleModel;
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';

import 'package:wls_pos/utility/wls_pos_screens.dart';

class SportsGameScreen extends StatefulWidget {
  final ResponseData? responseData;

  const SportsGameScreen({Key? key, required this.responseData})
      : super(key: key);

  @override
  State<SportsGameScreen> createState() => _SportsGameScreenState();
}

class _SportsGameScreenState extends State<SportsGameScreen> {
  double bottomNavigationHeight = 110;
  List<DrawData>? drawData = [];
  ScrollController drawController = ScrollController();
  int drawGameSelectedIndex = 0;
  int numOfLines = 0;
  double betValue = 0;
  double selectedPrice = 0;
  double unitTicketPrice = 0;
  String? currency;
  Map<String, dynamic>? unitTicketPriceJson;
  double currencyMultiplier = 0;
  int? selectedPriceContainerIndex = 0;
  bool onOtherTap = false;
  double maxTicketPrice = 0;
  double betAmountMultiple = 0;

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    drawData = widget.responseData?.drawData;
    return WlsPosScaffold(
      showAppBar: true,
      centerTitle: false,
      appBarTitle: Text(widget.responseData?.gameName ?? "Soccer 4"),
      body: Column(
        children: [
          // Option to select draw
          // drawData != null && drawData!.isNotEmpty
          //     ? DrawSelector(
          //         drawData: drawData,
          //         drawController: drawController,
          //         responseData: widget.responseData,
          //         onTap: (index) {
          //           initializeData();
          //           setState(() {
          //             drawGameSelectedIndex = index;
          //           });
          //         },
          //         drawGameSelectedIndex: drawGameSelectedIndex,
          //       )
          //     : const SizedBox(),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: bottomNavigationHeight,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                              color: WlsPosColor.white_six, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: WlsPosColor.black_16,
                              offset: Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            )
                          ],
                          color: WlsPosColor.white,
                        ),
                        child: ListView.builder(
                          itemCount:
                              drawData?[drawGameSelectedIndex].markets?.length,
                          itemBuilder: (BuildContext context, int marketIndex) {
                            return AnimationLimiter(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: drawData?[drawGameSelectedIndex]
                                    .markets?[marketIndex]
                                    .eventDetail
                                    ?.length,
                                itemBuilder: (context, index) =>
                                    AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 700),
                                  child: SlideAnimation(
                                    verticalOffset: 50,
                                    child: FadeInAnimation(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          index == 0
                                              ? GameTimeSection(
                                                  marketName: drawData?[
                                                          drawGameSelectedIndex]
                                                      .markets?[marketIndex]
                                                      .marketName,
                                                )
                                              : Container(),
                                          LineNumRow(
                                            index: index,
                                            venueName:
                                                drawData?[drawGameSelectedIndex]
                                                    .markets?[marketIndex]
                                                    .eventDetail?[index]
                                                    .venueName,
                                            startTime:
                                                drawData?[drawGameSelectedIndex]
                                                    .markets?[marketIndex]
                                                    .eventDetail?[index]
                                                    .startTime,
                                          ),
                                          const HeightBox(5),
                                          //selection tab row
                                          Row(
                                            children: getOptionList(
                                              eventIndex: index,
                                              drawDataIndex:
                                                  drawGameSelectedIndex,
                                              marketIndex: marketIndex,
                                            ),
                                          ),
                                          const HeightBox(5),
                                          TeamRow(
                                            index: index,
                                            homeTeam:
                                                drawData?[drawGameSelectedIndex]
                                                    .markets?[marketIndex]
                                                    .eventDetail?[index]
                                                    .homeTeamName,
                                            awayTeam:
                                                drawData?[drawGameSelectedIndex]
                                                    .markets?[marketIndex]
                                                    .eventDetail?[index]
                                                    .awayTeamName,
                                          ),
                                          const HeightBox(10),
                                          const MySeparator(
                                              width: 5,
                                              color:
                                                  WlsPosColor.pinkish_grey_two),
                                        ],
                                      ).p8(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // BottomView(
                //   selectedPrice: selectedPrice,
                //   bottomNavigationHeight: bottomNavigationHeight,
                //   numOfLines: numOfLines,
                //   betValue: betValue,
                //   drawData: drawData,
                //   drawGameSelectedIndex: drawGameSelectedIndex,
                //   onReset: () {
                //     setState(() {
                //       initializeData();
                //     });
                //   },
                //   onValueTap: (selectedTicketPrice, index) {
                //     setState(() {
                //       if (index == 4) {
                //         onOtherTap = true;
                //         selectedPrice = 0;
                //         selectedPriceContainerIndex = index;
                //         onOtherTap = true;
                //       } else {
                //         selectedPrice = selectedTicketPrice;
                //         selectedPriceContainerIndex = index;
                //         onOtherTap = false;
                //       }
                //     });
                //     setLineNumberAndBetValue();
                //   },
                //   unitTicketPrice: unitTicketPrice,
                //   currency: currency,
                //   unitTicketPriceJson: unitTicketPriceJson,
                //   currencyMultiplier: currencyMultiplier,
                //   selectedPriceContainerIndex: selectedPriceContainerIndex,
                //   onOtherTap: onOtherTap,
                //   onBuy: () {
                //     if (isRedundentClick()) return;
                //     if (numOfLines < 1) {
                //       Alert.show(
                //         isDarkThemeOn: false,
                //         buttonClick: () {},
                //         title: 'Error!',
                //         subtitle:
                //             "To play, Select at least 1 option of every match",
                //         buttonText: 'ok'.toUpperCase(),
                //         context: context,
                //       );
                //     } else if (selectedPrice < 1) {
                //       Alert.show(
                //         isDarkThemeOn: false,
                //         buttonClick: () {},
                //         title: 'Error!',
                //         subtitle: "Please select amount first",
                //         buttonText: 'ok'.toUpperCase(),
                //         context: context,
                //       );
                //     } else if (selectedPrice % betAmountMultiple != 0) {
                //       Alert.show(
                //         isDarkThemeOn: false,
                //         buttonClick: () {},
                //         title: 'Error!',
                //         subtitle:
                //             "Price must be less than or equal to $maxTicketPrice and multiple of $betAmountMultiple",
                //         buttonText: 'ok'.toUpperCase(),
                //         context: context,
                //       );
                //     } else {
                //       List<PurchaseListItemModel> purchaseListItemModelList =
                //           [];
                //       for (int selectedMarketIndex = 0;
                //           selectedMarketIndex <
                //               drawData![drawGameSelectedIndex].markets!.length;
                //           selectedMarketIndex++) {
                //         for (int selectedEventIndex = 0;
                //             selectedEventIndex <
                //                 drawData![drawGameSelectedIndex]
                //                     .markets![selectedMarketIndex]
                //                     .eventDetail!
                //                     .length;
                //             selectedEventIndex++) {
                //           List<String>? selectedOptionList =
                //               getSelectedOptionList(drawGameSelectedIndex,
                //                   selectedMarketIndex, selectedEventIndex);
                //           purchaseListItemModelList.add(
                //             PurchaseListItemModel(
                //               venueName: drawData?[drawGameSelectedIndex]
                //                   .markets?[selectedMarketIndex]
                //                   .eventDetail?[selectedEventIndex]
                //                   .venueName,
                //               startTime: drawData?[drawGameSelectedIndex]
                //                   .markets?[selectedMarketIndex]
                //                   .eventDetail?[selectedEventIndex]
                //                   .startTime,
                //               homeTeam: drawData?[drawGameSelectedIndex]
                //                   .markets?[selectedMarketIndex]
                //                   .eventDetail?[selectedEventIndex]
                //                   .homeTeamName,
                //               awayTeam: drawData?[drawGameSelectedIndex]
                //                   .markets?[selectedMarketIndex]
                //                   .eventDetail?[selectedEventIndex]
                //                   .awayTeamName,
                //               marketName: drawData?[drawGameSelectedIndex]
                //                   .markets?[selectedMarketIndex]
                //                   .marketName,
                //               selectedOptionList: selectedOptionList!,
                //             ),
                //           );
                //         }
                //       }
                //       //code for game sale api
                //       List<spSaleModel.Markets> saleMarketsList = [];
                //       List<spSaleModel.Options> saleOptionsList = [];
                //       List<spSaleModel.Events> saleEventsList = [];
                //       for (int selectedMarketIndex = 0;
                //           selectedMarketIndex <
                //               drawData![drawGameSelectedIndex].markets!.length;
                //           selectedMarketIndex++) {
                //         for (int selectedEventIndex = 0;
                //             selectedEventIndex <
                //                 drawData![drawGameSelectedIndex]
                //                     .markets![selectedMarketIndex]
                //                     .eventDetail!
                //                     .length;
                //             selectedEventIndex++) {
                //           for (int selectedOptionIndex = 0;
                //               selectedOptionIndex <
                //                   drawData![drawGameSelectedIndex]
                //                       .markets![selectedMarketIndex]
                //                       .eventDetail![selectedEventIndex]
                //                       .optionInfo!
                //                       .length;
                //               selectedOptionIndex++) {
                //             if (drawData![drawGameSelectedIndex]
                //                     .markets![selectedMarketIndex]
                //                     .eventDetail![selectedEventIndex]
                //                     .optionInfo![selectedOptionIndex]
                //                     .isSelected ==
                //                 true) {
                //               OptionInfo selectedOption =
                //                   drawData![drawGameSelectedIndex]
                //                       .markets![selectedMarketIndex]
                //                       .eventDetail![selectedEventIndex]
                //                       .optionInfo![selectedOptionIndex];
                //               int selectedId = selectedOption.id;
                //               String selectedCode =
                //                   selectedOption.tpOptionCode ?? '';
                //               String selectedName =
                //                   selectedOption.tpOptionName ?? '';
                //               saleOptionsList.add(
                //                 spSaleModel.Options(
                //                   id: selectedId,
                //                   code: selectedCode,
                //                   name: selectedName,
                //                 ),
                //               );
                //             }
                //           }
                //           saleEventsList.add(
                //             spSaleModel.Events(
                //               eventId: drawData![drawGameSelectedIndex]
                //                   .markets![selectedMarketIndex]
                //                   .eventDetail![selectedEventIndex]
                //                   .id,
                //               options: saleOptionsList,
                //             ),
                //           );
                //           saleOptionsList = [];
                //         }
                //         saleMarketsList.add(spSaleModel.Markets(
                //             marketCode: drawData![drawGameSelectedIndex]
                //                 .markets![selectedMarketIndex]
                //                 .marketCode,
                //             events: saleEventsList));
                //         saleEventsList = [];
                //       }
                //       spSaleModel.SportsPoolSaleModel sportsPoolSaleModel =
                //           spSaleModel.SportsPoolSaleModel();
                //       sportsPoolSaleModel.orderId =
                //           DateTime.now().microsecondsSinceEpoch;
                //       sportsPoolSaleModel.locale = 'en';
                //       sportsPoolSaleModel.domainName = 'www.retail.co.in';
                //       sportsPoolSaleModel.merchantId = rmsMerchantId;
                //       sportsPoolSaleModel.gameCode =
                //           drawData![drawGameSelectedIndex].gameCode;
                //       sportsPoolSaleModel.currencyCode = drawData![
                //               drawGameSelectedIndex]
                //           .currency; //ToDo need to be replace with retailer currency
                //       sportsPoolSaleModel.drawId =
                //           drawData![drawGameSelectedIndex].id;
                //       sportsPoolSaleModel.userType = 'RETAILER';
                //       sportsPoolSaleModel.drawStatus =
                //           drawData![drawGameSelectedIndex].drawStatus;
                //       sportsPoolSaleModel.drawName =
                //           drawData![drawGameSelectedIndex].drawName;
                //       sportsPoolSaleModel.saleStartTime =
                //           drawData![drawGameSelectedIndex].saleStartTime;
                //       sportsPoolSaleModel.drawFreezeTime =
                //           drawData![drawGameSelectedIndex].drawFreezeTime;
                //       sportsPoolSaleModel.drawDateTime =
                //           drawData![drawGameSelectedIndex].drawDateTime;
                //       sportsPoolSaleModel.noOfTicketPerLine = (betValue /
                //               numOfLines) /
                //           unitTicketPrice; // selectedPrice; // need to check for this
                //       sportsPoolSaleModel.totalSaleAmount = betValue;
                //       sportsPoolSaleModel.isMobile = true;
                //       sportsPoolSaleModel.deviceId = 'MOBILE';
                //       sportsPoolSaleModel.betType =
                //           drawData![drawGameSelectedIndex].isMultiPlayAllowed!
                //               ? "MULTIPLE"
                //               : "SINGLE";
                //       sportsPoolSaleModel.itemId =
                //           DateTime.now().microsecondsSinceEpoch;
                //       sportsPoolSaleModel.mainDrawData =
                //           spSaleModel.MainDrawData(
                //               noOfLines: numOfLines,
                //               unitTicketPrice: unitTicketPrice,
                //               totalAmount: numOfLines * unitTicketPrice,
                //               markets: saleMarketsList);
                //       //code for game sale api end
                //       Future.delayed(const Duration(milliseconds: 500),
                //           () async {
                //         var returnValue = await Navigator.pushNamed(
                //           context,
                //           WlsPosScreen.purchaseDetailsScreen,
                //           arguments: PurchaseDetailsModel(
                //             responseData: widget.responseData,
                //             drawGameSelectedIndex: drawGameSelectedIndex,
                //             numOfLines: numOfLines,
                //             betValue: betValue,
                //             currency: currency,
                //             purchaseListItemModelList:
                //                 purchaseListItemModelList,
                //             sportsPoolSaleModel: sportsPoolSaleModel,
                //           ),
                //         );
                //         if (returnValue != null && returnValue as bool) {
                //           setState(() {
                //             initializeData();
                //           });
                //         }
                //       });
                //     }
                //   },
                //   onChanged: (value) {
                //     setState(() {
                //       if (value > maxTicketPrice) {
                //         selectedPrice = 0;
                //         Alert.show(
                //           isDarkThemeOn: false,
                //           buttonClick: () {},
                //           title: 'Error!',
                //           subtitle:
                //               "Price must be less than or equal to $maxTicketPrice and multiple of $betAmountMultiple",
                //           buttonText: 'ok'.toUpperCase(),
                //           context: context,
                //         );
                //       } else {
                //         selectedPrice = value;
                //       }
                //     });
                //     setLineNumberAndBetValue();
                //   },
                //   maxTicketPrice: maxTicketPrice,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  setLineNumberAndBetValue() {
    List<int> numberOfSelectedEventList = [];
    drawData![drawGameSelectedIndex].markets?.forEach((element) {
      element.eventDetail?.forEach((element) {
        int selectionCounter = 0;
        element.optionInfo?.forEach((element) {
          if (element.isSelected == true) {
            selectionCounter++;
          }
        });
        numberOfSelectedEventList.add(selectionCounter);
      });
    });
    int lineMultiplication = 1;
    for (var element in numberOfSelectedEventList) {
      lineMultiplication = element * lineMultiplication;
    }
    setState(() {
      numOfLines = lineMultiplication;
      betValue = numOfLines * selectedPrice;
    });
  }

  List<Widget> getOptionList({eventIndex, drawDataIndex, marketIndex}) {
    var optionInfo = drawData![drawDataIndex]
        .markets![marketIndex]
        .eventDetail![eventIndex]
        .optionInfo!;
    return optionInfo
        .asMap()
        .map(
          (optionIndex, element) => MapEntry(
            optionIndex,
            Expanded(
              child: SelectOption(
                probability: element.probability,
                title: element.tpOptionName ?? "",
                selected: optionInfo[optionIndex].isSelected,
                onTap: () {
                  setState(() {
                    if ((drawData![drawDataIndex].isMultiPlayAllowed ?? true)) {
                      optionInfo[optionIndex].isSelected =
                          !optionInfo[optionIndex].isSelected;
                    } else {
                      optionInfo.asMap().forEach(
                        (index, value) {
                          if (optionIndex == index) {
                            optionInfo[index].isSelected =
                                !optionInfo[index].isSelected;
                          } else {
                            optionInfo[index].isSelected = false;
                          }
                        },
                      );
                    }
                  });
                  setLineNumberAndBetValue();
                },
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  void initializeData() {
    drawData = widget.responseData?.drawData;

    drawData?[drawGameSelectedIndex].markets?.forEach((market) {
      market.eventDetail?.forEach((event) {
        event.optionInfo?.forEach((option) {
          option.isSelected = false;
        });
      });
    });
    unitTicketPrice = drawData?[drawGameSelectedIndex].unitTicketPrice;
    currency = drawData?[drawGameSelectedIndex].currency;
    unitTicketPriceJson =
        drawData?[drawGameSelectedIndex].unitTicketPriceJson?.toJson();
    currencyMultiplier = unitTicketPriceJson![currency].toDouble();
    selectedPrice = currencyMultiplier;
    selectedPriceContainerIndex = 0;
    numOfLines = 0;
    betValue = 0;
    maxTicketPrice = drawData?[drawGameSelectedIndex].maxTicketPrice;
    betAmountMultiple = drawData?[drawGameSelectedIndex].betAmountMultiple;
  }

  List<String>? getSelectedOptionList(int drawGameSelectedIndex,
      int selectedMarketIndex, int selectedEventIndex) {
    List<String>? selectedOptionList = [];
    for (int selectedOptionIndex = 0;
        selectedOptionIndex <
            drawData![drawGameSelectedIndex]
                .markets![selectedMarketIndex]
                .eventDetail![selectedEventIndex]
                .optionInfo!
                .length;
        selectedOptionIndex++) {
      if (drawData![drawGameSelectedIndex]
              .markets![selectedMarketIndex]
              .eventDetail![selectedEventIndex]
              .optionInfo![selectedOptionIndex]
              .isSelected ==
          true) {
        selectedOptionList.add(drawData![drawGameSelectedIndex]
            .markets![selectedMarketIndex]
            .eventDetail![selectedEventIndex]
            .optionInfo![selectedOptionIndex]
            .tpOptionCode!);
      }
    }
    return selectedOptionList;
  }
}
