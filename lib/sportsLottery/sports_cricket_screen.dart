import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import '../utility/widgets/show_snackbar.dart';
import '../utility/widgets/wls_pos_text_field_underline.dart';

/*
    created by Mr. Chandra Bhushan Tiwari on 5th May, 23
*/

class SportsCricketScreen extends StatefulWidget {
  List<dynamic>? args;

  SportsCricketScreen({Key? key, required this.args}) : super(key: key);

  @override
  State<SportsCricketScreen> createState() => _SportsCricketScreenState();
}

class _SportsCricketScreenState extends State<SportsCricketScreen> {
  ResponseData? responseData;
  DrawData? drawData;
  double bottomNavigationHeight = 110;
  List<DrawData>? drawData1 = [];
  ScrollController drawController = ScrollController();
  int drawGameSelectedIndex = 0;
  int numOfLines = 0;
  double betValue = 0;
  double selectedPrice = 0;
  double unitTicketPrice = 0;
  double addOnUnitTicketPrice = 0;
  String? currency;
  Map<String, dynamic>? unitTicketPriceJson;
  double currencyMultiplier = 0;
  int? selectedPriceContainerIndex = 0;
  bool onOtherTap = false;
  double maxTicketPrice = 0;
  double betAmountMultiple = 0;
  GameType gameType = GameType.game;

  int numOfAddOnLine = 0;
  double gameBetValue = 0;
  double addOnBetValue = 0;
  bool tossSelectionStarted = false;
  TextEditingController textEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  List<String>? selectedOptionNameList;

  bool get checkIfAddOnAvailableAndSelected =>
      (drawData!.addOnDrawData != null && numOfAddOnLine > 0);

  @override
  void initState() {
    responseData = widget.args![0];
    drawData = widget.args![1];
    initializeData();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // drawData = widget.responseData?.drawData;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WlsPosScaffold(
      showAppBar: true,
      centerTitle: false,
      appBarTitle: Text(responseData?.gameName ?? "Soccer 4"),
      body: Column(
        children: [
          // Option to select draw
          DrawSelector(
            drawData: drawData,
            drawController: drawController,
            responseData: responseData,
            onTap: (index) {
              initializeData();
              setState(() {
                drawGameSelectedIndex = index;
              });
            },
            drawGameSelectedIndex: drawGameSelectedIndex,
          ),
          drawData!.addOnDrawData != null
              ? GameTypeSelector(
                  gameType: gameType,
                  onGameTap: () {
                    setState(() {
                      gameType = GameType.game;
                    });
                  },
                  onTossTap: () {
                    setState(() {
                      gameType = GameType.toss;
                    });
                  },
                )
              : Container(),
          Expanded(
            child: Stack(
              children: [
                gameType == GameType.game
                    ? Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * (isLandscape ? 0.6 : 1),
                        child: Column(
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
                                    itemCount: drawData!.markets?.length,
                                    itemBuilder:
                                        (BuildContext context, int marketIndex) {
                                      return AnimationLimiter(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: drawData!.markets?[marketIndex]
                                              .eventDetail?.length,
                                          itemBuilder: (context, index) =>
                                              AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration:
                                                const Duration(milliseconds: 700),
                                            child: SlideAnimation(
                                              verticalOffset: 50,
                                              child: FadeInAnimation(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.stretch,
                                                  children: [
                                                    index == 0
                                                        ? GameTimeSection(
                                                            marketName: drawData!
                                                                .markets?[
                                                                    marketIndex]
                                                                .marketName,
                                                            gameName: responseData!
                                                                .gameName)
                                                        : Container(),
                                                    LineNumRow(
                                                      index: index,
                                                      venueName: drawData?.markets?[marketIndex]
                                                          .eventDetail?[index]
                                                          .venueName,
                                                      startTime: drawData!
                                                          .markets?[marketIndex]
                                                          .eventDetail?[index]
                                                          .startTime,
                                                      gameName:
                                                          responseData!.gameName,
                                                      eventGameName: drawData!
                                                          .markets?[marketIndex]
                                                          .eventDetail![index]
                                                          .eventName,
                                                    ),
                                                    const HeightBox(5),
                                                    //selection tab row
                                                    Row(
                                                      children: getOptionList(
                                                          eventIndex: index,
                                                          drawDataIndex:
                                                              drawGameSelectedIndex,
                                                          marketIndex: marketIndex,
                                                          gameName:
                                                              drawData!.gameName),
                                                    ),
                                                    const HeightBox(5),
                                                    responseData!.gameName ==
                                                            "PICK4"
                                                        ? Container()
                                                        : TeamRow(
                                                            index: index,
                                                            homeTeam: drawData!
                                                                .markets?[
                                                                    marketIndex]
                                                                .eventDetail?[index]
                                                                .homeTeamName,
                                                            awayTeam: drawData!
                                                                .markets?[
                                                                    marketIndex]
                                                                .eventDetail?[index]
                                                                .awayTeamName,
                                                          ),
                                                    const HeightBox(10),
                                                    responseData!.gameName ==
                                                            "PICK4"
                                                        ? const Divider(
                                                            thickness: 1,
                                                            color: WlsPosColor
                                                                .light_grey,
                                                          )
                                                        : const MySeparator(
                                                            width: 5,
                                                            color: WlsPosColor
                                                                .pinkish_grey_two),
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
                      ),
                    )
                    : Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * (isLandscape ? 0.6 : 1),
                        child: Column(
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
                                        drawData!.addOnDrawData?.markets?.length,
                                    itemBuilder:
                                        (BuildContext context, int marketIndex) {
                                      return AnimationLimiter(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: drawData!
                                              .addOnDrawData
                                              ?.markets?[marketIndex]
                                              .eventDetail
                                              ?.length,
                                          itemBuilder: (context, index) =>
                                              AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration:
                                                const Duration(milliseconds: 700),
                                            child: SlideAnimation(
                                              verticalOffset: 50,
                                              child: FadeInAnimation(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.stretch,
                                                  children: [
                                                    index == 0
                                                        ? GameTimeSection(
                                                            marketName: drawData!
                                                                .addOnDrawData!
                                                                .markets?[
                                                                    marketIndex]
                                                                .marketName,
                                                          )
                                                        : Container(),
                                                    LineNumRow(
                                                      index: index,
                                                      venueName: drawData!
                                                          .addOnDrawData
                                                          ?.markets?[marketIndex]
                                                          .eventDetail?[index]
                                                          .venueName,
                                                      startTime: drawData!
                                                          .addOnDrawData
                                                          ?.markets?[marketIndex]
                                                          .eventDetail?[index]
                                                          .startTime,
                                                    ),
                                                    const HeightBox(5),
                                                    //selection tab row
                                                    Row(
                                                      children: getAddOnOptionList(
                                                        eventIndex: index,
                                                        drawDataIndex:
                                                            drawGameSelectedIndex,
                                                        marketIndex: marketIndex,
                                                      ),
                                                    ),
                                                    const HeightBox(5),
                                                    TeamRow(
                                                      index: index,
                                                      homeTeam: drawData!
                                                          .addOnDrawData
                                                          ?.markets?[marketIndex]
                                                          .eventDetail?[index]
                                                          .homeTeamName,
                                                      awayTeam: drawData!
                                                          .addOnDrawData
                                                          ?.markets?[marketIndex]
                                                          .eventDetail?[index]
                                                          .awayTeamName,
                                                    ),
                                                    const HeightBox(10),
                                                    const MySeparator(
                                                        width: 5,
                                                        color: WlsPosColor
                                                            .pinkish_grey_two),
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
                      ),
                    ),
                BottomView(
                  bottomNavigationHeight: bottomNavigationHeight,
                  numOfLines: numOfLines,
                  betValue: betValue,
                  drawData: drawData,
                  drawGameSelectedIndex: drawGameSelectedIndex,
                  onReset: () {
                    setState(() {
                      initializeData();
                    });
                  },
                  onValueTap: (selectedTicketPrice, index) {
                    if(index == (totalPriceOption - 1) && maxTicketPrice <= 0){
                      ShowToast.showToast(context, "Max ticket price is unavailable", type: ToastType.ERROR);
                    }
                    else{
                      setState(() {
                        if (index == (totalPriceOption - 1)) {
                          onOtherTap = true;
                          selectedPrice = 0;
                          selectedPriceContainerIndex = index;
                          onOtherTap = true;
                        } else {
                          selectedPrice = selectedTicketPrice;
                          selectedPriceContainerIndex = index;
                          onOtherTap = false;
                        }
                      });
                      if (index == (totalPriceOption - 1)) {
                        Alert.customShow(
                          isBackPressedAllowed: false,
                          buttonClick: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              var trimmedValue =
                              (textEditingController.text).trim();
                              double doubleValue = double.parse(
                                  trimmedValue == '' ? '0' : trimmedValue);
                              Navigator.pop(context);
                              //textEditingController.clear();
                              setState(() {
                                if (doubleValue > maxTicketPrice) {
                                  selectedPrice = 0;
                                } else {
                                  selectedPrice = doubleValue;
                                }
                              });
                              setLineNumberAndBetValue();
                            }
                          },
                          context: context,
                          buttonText: "OK",
                          child: Form(
                            key: _formKey,
                            child: WlsPosTextFieldUnderline(
                              controller: textEditingController,
                              maxLength: maxTicketPrice.toString().length,
                              autoFocus: true,
                              inputType: TextInputType.number,
                              //keyboardType
                              hintText: "Enter a value",
                              inputFormatters: <TextInputFormatter>[
                                // for below version 2 use this
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                // for version 2 and greater you can also use this
                                FilteringTextInputFormatter.digitsOnly,
                                //deny first input as zero
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'^0+'),
                                ),
                              ],
                              maxLine: 1,
                              onChanged: (value) {
                                log("onChanged : $value");
                              },
                              errorMaxLines: 2,
                              validator: (value) {
                                var trimmedValue = (value ?? '0').trim();
                                double doubleValue = double.parse(
                                    trimmedValue == '' ? '0' : trimmedValue);
                                if (doubleValue == 0) {
                                  return 'Please enter a value first';
                                }
                                if (doubleValue % betAmountMultiple != 0 ||
                                    doubleValue > maxTicketPrice) {
                                  return "Price must be less than or equal to $maxTicketPrice and multiple of $betAmountMultiple";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        );
                      }
                      setLineNumberAndBetValue();
                    }
                  },
                  unitTicketPrice: unitTicketPrice,
                  currency: currency,
                  unitTicketPriceJson: unitTicketPriceJson,
                  currencyMultiplier: currencyMultiplier,
                  selectedPriceContainerIndex: selectedPriceContainerIndex,
                  onOtherTap: onOtherTap,
                  onBuy: () {
                    if (isRedundentClick()) return;
                    if (numOfLines < 1 ||
                        (tossSelectionStarted && numOfAddOnLine < 1)) {
                      Alert.show(
                        isDarkThemeOn: false,
                        buttonClick: () {},
                        title: 'Error!',
                        subtitle:
                            "To play, Select at least 1 option of every match",
                        buttonText: 'ok'.toUpperCase(),
                        context: context,
                      );
                    }
                    // if toss is mandatory
                    // else if (numOfAddOnLine < 1) {
                    //   Alert.show(
                    //     isDarkThemeOn: false,
                    //     buttonClick: () {},
                    //     title: 'Error!',
                    //     subtitle:
                    //         "To play, Select at least 1 option of every match in ${drawData![drawGameSelectedIndex].addOnDrawData?.gameName}",
                    //     buttonText: 'ok'.toUpperCase(),
                    //     context: context,
                    //   );
                    // }
                    else if (selectedPrice < 1) {
                      Alert.show(
                        isDarkThemeOn: false,
                        buttonClick: () {},
                        title: 'Error!',
                        subtitle: "Please select amount first",
                        buttonText: 'ok'.toUpperCase(),
                        context: context,
                      );
                    } else if (selectedPrice % betAmountMultiple != 0) {
                      Alert.show(
                        isDarkThemeOn: false,
                        buttonClick: () {},
                        title: 'Error!',
                        subtitle:
                            "Price must be less than or equal to $maxTicketPrice and multiple of $betAmountMultiple",
                        buttonText: 'ok'.toUpperCase(),
                        context: context,
                      );
                    } else {
                      List<PurchaseListItemModel> purchaseListItemModelList =
                          [];
                      for (int selectedMarketIndex = 0;
                          selectedMarketIndex < drawData!.markets!.length;
                          selectedMarketIndex++) {
                        for (int selectedEventIndex = 0;
                            selectedEventIndex <
                                drawData!.markets![selectedMarketIndex]
                                    .eventDetail!.length;
                            selectedEventIndex++) {
                          List<String>? selectedOptionList =
                              getSelectedOptionList(drawGameSelectedIndex,
                                  selectedMarketIndex, selectedEventIndex);

                          purchaseListItemModelList.add(
                            PurchaseListItemModel(
                              venueName: drawData!.markets?[selectedMarketIndex]
                                  .eventDetail?[selectedEventIndex].venueName,
                              startTime: drawData!.markets?[selectedMarketIndex]
                                  .eventDetail?[selectedEventIndex].startTime,
                              homeTeam: drawData!
                                  .markets?[selectedMarketIndex]
                                  .eventDetail?[selectedEventIndex]
                                  .homeTeamName,
                              awayTeam: drawData!
                                  .markets?[selectedMarketIndex]
                                  .eventDetail?[selectedEventIndex]
                                  .awayTeamName,
                              marketName: drawData!
                                  .markets?[selectedMarketIndex].marketName,
                              selectedOptionList: selectedOptionList!,
                              selectedOptionNameList: selectedOptionNameList!,
                              eventGameName: drawData!
                                  .markets?[selectedMarketIndex]
                                  .eventDetail?[selectedEventIndex]
                                  .eventName,
                            ),
                          );
                        }
                      }
                      //code for game sale api
                      List<spSaleModel.Markets> saleMarketsList = [];
                      List<spSaleModel.Options> saleOptionsList = [];
                      List<spSaleModel.Events> saleEventsList = [];
                      for (int selectedMarketIndex = 0;
                          selectedMarketIndex < drawData!.markets!.length;
                          selectedMarketIndex++) {
                        for (int selectedEventIndex = 0;
                            selectedEventIndex <
                                drawData!.markets![selectedMarketIndex]
                                    .eventDetail!.length;
                            selectedEventIndex++) {
                          for (int selectedOptionIndex = 0;
                              selectedOptionIndex <
                                  drawData!
                                      .markets![selectedMarketIndex]
                                      .eventDetail![selectedEventIndex]
                                      .optionInfo!
                                      .length;
                              selectedOptionIndex++) {
                            if (drawData!
                                    .markets![selectedMarketIndex]
                                    .eventDetail![selectedEventIndex]
                                    .optionInfo![selectedOptionIndex]
                                    .isSelected ==
                                true) {
                              OptionInfo selectedOption = drawData!
                                  .markets![selectedMarketIndex]
                                  .eventDetail![selectedEventIndex]
                                  .optionInfo![selectedOptionIndex];
                              int selectedId = selectedOption.id;
                              String selectedCode =
                                  selectedOption.tpOptionCode ?? '';
                              String selectedName =
                                  selectedOption.tpOptionName ?? '';
                              saleOptionsList.add(
                                spSaleModel.Options(
                                  id: selectedId,
                                  code: selectedCode,
                                  name: selectedName,
                                ),
                              );
                            }
                          }
                          saleEventsList.add(
                            spSaleModel.Events(
                              eventId: drawData!.markets![selectedMarketIndex]
                                  .eventDetail![selectedEventIndex].id,
                              options: saleOptionsList,
                            ),
                          );
                          saleOptionsList = [];
                        }
                        saleMarketsList.add(spSaleModel.Markets(
                            marketCode: drawData!
                                .markets![selectedMarketIndex].marketCode,
                            events: saleEventsList));
                        saleEventsList = [];
                      }
                      //code for add on
                      List<spSaleModel.Markets> addOnSaleMarketsList = [];
                      List<spSaleModel.Options> addOnSaleOptionsList = [];
                      List<spSaleModel.Events> addOnSaleEventsList = [];
                      if (checkIfAddOnAvailableAndSelected) {
                        for (int addOnSelectedMarketIndex = 0;
                            addOnSelectedMarketIndex <
                                drawData!.addOnDrawData!.markets!.length;
                            addOnSelectedMarketIndex++) {
                          for (int addOnSelectedEventIndex = 0;
                              addOnSelectedEventIndex <
                                  drawData!
                                      .addOnDrawData!
                                      .markets![addOnSelectedMarketIndex]
                                      .eventDetail!
                                      .length;
                              addOnSelectedEventIndex++) {
                            for (int addOnSelectedOptionIndex = 0;
                                addOnSelectedOptionIndex <
                                    drawData!
                                        .addOnDrawData!
                                        .markets![addOnSelectedMarketIndex]
                                        .eventDetail![addOnSelectedEventIndex]
                                        .optionInfo!
                                        .length;
                                addOnSelectedOptionIndex++) {
                              if (drawData!
                                      .addOnDrawData!
                                      .markets![addOnSelectedMarketIndex]
                                      .eventDetail![addOnSelectedEventIndex]
                                      .optionInfo![addOnSelectedOptionIndex]
                                      .isSelected ==
                                  true) {
                                OptionInfo selectedOption = drawData!
                                    .addOnDrawData!
                                    .markets![addOnSelectedMarketIndex]
                                    .eventDetail![addOnSelectedEventIndex]
                                    .optionInfo![addOnSelectedOptionIndex];
                                int selectedId = selectedOption.id;
                                String selectedCode =
                                    selectedOption.tpOptionCode ?? '';
                                String selectedName =
                                    selectedOption.tpOptionName ?? '';
                                addOnSaleOptionsList.add(
                                  spSaleModel.Options(
                                    id: selectedId,
                                    code: selectedCode,
                                    name: selectedName,
                                  ),
                                );
                              }
                            }
                            addOnSaleEventsList.add(
                              spSaleModel.Events(
                                eventId: drawData!
                                    .markets![addOnSelectedMarketIndex]
                                    .eventDetail![addOnSelectedEventIndex]
                                    .id,
                                options: addOnSaleOptionsList,
                              ),
                            );
                            addOnSaleOptionsList = [];
                          }
                          addOnSaleMarketsList.add(spSaleModel.Markets(
                              marketCode: drawData!
                                  .addOnDrawData!
                                  .markets![addOnSelectedMarketIndex]
                                  .marketCode,
                              events: addOnSaleEventsList));
                          addOnSaleEventsList = [];
                        }
                      }
                      // common code for addon and game
                      spSaleModel.SportsPoolSaleModel sportsPoolSaleModel =
                          spSaleModel.SportsPoolSaleModel();
                      sportsPoolSaleModel.orderId =
                          DateTime.now().microsecondsSinceEpoch;
                      sportsPoolSaleModel.locale = 'en';
                      sportsPoolSaleModel.domainName = sportsPoolDomainName;
                      sportsPoolSaleModel.merchantId = rmsMerchantId;
                      sportsPoolSaleModel.gameCode = drawData!.gameCode;
                      sportsPoolSaleModel.currencyCode = drawData!
                          .currency; //ToDo need to be replace with retailer currency
                      sportsPoolSaleModel.drawId = drawData!.id;
                      sportsPoolSaleModel.userType = 'RETAILER';
                      sportsPoolSaleModel.drawStatus = drawData!.drawStatus;
                      sportsPoolSaleModel.drawName = drawData!.drawName;
                      sportsPoolSaleModel.saleStartTime =
                          drawData!.saleStartTime;
                      sportsPoolSaleModel.drawFreezeTime =
                          drawData!.drawFreezeTime;
                      sportsPoolSaleModel.drawDateTime = drawData!.drawDateTime;
                      sportsPoolSaleModel.noOfTicketPerLine = (betValue /
                          (numOfLines + numOfAddOnLine)) /
                          unitTicketPrice; // selectedPrice; // need to check for this
                      sportsPoolSaleModel.totalSaleAmount = betValue;
                      sportsPoolSaleModel.isMobile = true;
                      sportsPoolSaleModel.deviceId = 'MOBILE';
                      sportsPoolSaleModel.betType =
                          drawData!.isMultiPlayAllowed! ? "MULTIPLE" : "SINGLE";
                      sportsPoolSaleModel.itemId =
                          DateTime.now().microsecondsSinceEpoch;
                      sportsPoolSaleModel.mainDrawData =
                          spSaleModel.MainDrawData(
                              noOfLines: numOfLines,
                              unitTicketPrice: unitTicketPrice,
                              totalAmount: numOfLines * unitTicketPrice,
                              markets: saleMarketsList);
                      if (checkIfAddOnAvailableAndSelected) {
                        sportsPoolSaleModel.addOnDrawData =
                            spSaleModel.AddOnDrawData(
                                noOfLines: numOfAddOnLine,
                                unitTicketPrice: unitTicketPrice,
                                totalAmount: numOfAddOnLine * unitTicketPrice,
                                markets: addOnSaleMarketsList);
                      }
                      //code for game sale api end
                      Future.delayed(const Duration(milliseconds: 500),
                          () async {
                        var returnValue = await Navigator.pushNamed(
                          context,
                          WlsPosScreen.purchaseDetailsScreen,
                          arguments: PurchaseDetailsModel(
                            responseData: responseData,
                            drawGameSelectedIndex: drawGameSelectedIndex,
                            numOfLines: numOfLines,
                            betValue: betValue,
                            currency: currency,
                            purchaseListItemModelList:
                                purchaseListItemModelList,
                            sportsPoolSaleModel: sportsPoolSaleModel,
                          ),
                        );
                        if (returnValue != null && returnValue as bool) {
                          setState(() {
                            initializeData();
                          });
                        }
                      });
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      if (value > maxTicketPrice) {
                        selectedPrice = 0;
                        Alert.show(
                          isDarkThemeOn: false,
                          buttonClick: () {},
                          title: 'Error!',
                          subtitle:
                              "Price must be less than or equal to $maxTicketPrice and multiple of $betAmountMultiple",
                          buttonText: 'ok'.toUpperCase(),
                          context: context,
                        );
                      } else {
                        selectedPrice = value;
                      }
                    });
                    setLineNumberAndBetValue();
                  },
                  maxTicketPrice: maxTicketPrice,
                  selectedPrice: selectedPrice,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  setLineNumberAndBetValue() {
    List<int> numberOfSelectedEventList = [];
    List<int> numberOfAddOnSelectedEventList = [];
    drawData!.markets?.forEach((element) {
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
    drawData!.addOnDrawData?.markets?.forEach((element) {
      element.eventDetail?.forEach((element) {
        int addOnSelectionCounter = 0;
        element.optionInfo?.forEach((element) {
          if (element.isSelected == true) {
            addOnSelectionCounter++;
          }
        });
        numberOfAddOnSelectedEventList.add(addOnSelectionCounter);
      });
    });
    int lineMultiplication = 1;
    int addOnlineMultiplication = 0;
    for (var element in numberOfSelectedEventList) {
      lineMultiplication = element * lineMultiplication;
    }
    if (drawData!.addOnDrawData != null) {
      addOnlineMultiplication = 1;
      for (var element in numberOfAddOnSelectedEventList) {
        addOnlineMultiplication = element * addOnlineMultiplication;
      }
    }
    setState(() {
      numOfLines = lineMultiplication;
      numOfAddOnLine = addOnlineMultiplication;
      gameBetValue = numOfLines * selectedPrice;
      addOnBetValue = numOfAddOnLine * selectedPrice;
      betValue = gameBetValue + addOnBetValue;
    });
  }

  // setGameLineNumberAndBetValue() {
  //   List<int> numberOfSelectedEventList = [];
  //   drawData![drawGameSelectedIndex].markets?.forEach((element) {
  //     element.eventDetail?.forEach((element) {
  //       int selectionCounter = 0;
  //       element.optionInfo?.forEach((element) {
  //         if (element.isSelected == true) {
  //           selectionCounter++;
  //         }
  //       });
  //       numberOfSelectedEventList.add(selectionCounter);
  //     });
  //   });
  //   int lineMultiplication = 1;
  //   for (var element in numberOfSelectedEventList) {
  //     lineMultiplication = element * lineMultiplication;
  //   }
  //   setState(() {
  //     numOfLines = lineMultiplication;
  //     gameBetValue = numOfLines * selectedPrice;
  //     betValue = gameBetValue + addOnBetValue;
  //   });
  // }
  //
  // setAddOnLineNumberAndBetValue() {
  //   List<int> numberOfAddOnSelectedEventList = [];
  //   drawData![drawGameSelectedIndex].addOnDrawData?.markets?.forEach((element) {
  //     element.eventDetail?.forEach((element) {
  //       int addOnSelectionCounter = 0;
  //       element.optionInfo?.forEach((element) {
  //         if (element.isSelected == true) {
  //           addOnSelectionCounter++;
  //         }
  //       });
  //       numberOfAddOnSelectedEventList.add(addOnSelectionCounter);
  //     });
  //   });
  //   int addOnlineMultiplication = 1;
  //   for (var element in numberOfAddOnSelectedEventList) {
  //     addOnlineMultiplication = element * addOnlineMultiplication;
  //   }
  //   setState(() {
  //     numOfAddOnLine = addOnlineMultiplication;
  //     addOnBetValue = numOfAddOnLine * selectedPrice;
  //     betValue = gameBetValue + addOnBetValue;
  //   });
  // }

  List<Widget> getAddOnOptionList({eventIndex, drawDataIndex, marketIndex}) {
    var optionInfo = drawData!.addOnDrawData?.markets![marketIndex]
        .eventDetail![eventIndex].optionInfo!;
    return optionInfo!
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
                    tossSelectionStarted = true;
                    if ((drawData!.addOnDrawData?.isMultiPlayAllowed ?? true)) {
                      optionInfo[optionIndex].isSelected = true;
                    } else {
                      optionInfo.asMap().forEach(
                        (index, value) {
                          if (optionIndex == index) {
                            optionInfo[index].isSelected = true;
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

  List<Widget> getOptionList(
      {eventIndex, drawDataIndex, marketIndex, gameName}) {
    var optionInfo =
        drawData!.markets![marketIndex].eventDetail![eventIndex].optionInfo!;
    return optionInfo
        .asMap()
        .map(
          (optionIndex, element) => MapEntry(
            optionIndex,
            Expanded(
              child: SelectOption(
                probability: element.probability,
                title: gameName.toString().toUpperCase() == "PICK4"
                    ? element.tpOptionCode ?? ""
                    : element.tpOptionName ?? "",
                selected: optionInfo[optionIndex].isSelected,
                onTap: () {
                  setState(() {
                    if ((drawData!.isMultiPlayAllowed ?? true)) {
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
    drawData!.markets?.forEach((market) {
      market.eventDetail?.forEach((event) {
        event.optionInfo?.forEach((option) {
          option.isSelected = false;
        });
      });
    });
    if (drawData!.addOnDrawData != null) {
      drawData!.addOnDrawData!.markets?.forEach((market) {
        market.eventDetail?.forEach((event) {
          event.optionInfo?.forEach((option) {
            option.isSelected = false;
          });
        });
      });
      gameType = GameType.game;
      addOnUnitTicketPrice = drawData!.addOnDrawData!.unitTicketPrice ?? 0;
      tossSelectionStarted = false;
    }

    unitTicketPrice = drawData!.unitTicketPrice;
    currency = drawData!.currency;
    unitTicketPriceJson = drawData!.unitTicketPriceJson?.toJson();
    currencyMultiplier = unitTicketPriceJson![currency].toDouble();
    selectedPrice = currencyMultiplier;
    selectedPriceContainerIndex = 0;
    numOfLines = 0;
    betValue = 0;
    maxTicketPrice = responseData?.maxTicketMultiple; //drawData!.maxTicketPrice;
    betAmountMultiple = drawData!.betAmountMultiple;
  }

  List<String>? getSelectedOptionList(int drawGameSelectedIndex,
      int selectedMarketIndex, int selectedEventIndex) {
    List<String>? selectedOptionList = [];
    selectedOptionNameList = [];
    for (int selectedOptionIndex = 0;
        selectedOptionIndex <
            drawData!.markets![selectedMarketIndex]
                .eventDetail![selectedEventIndex].optionInfo!.length;
        selectedOptionIndex++) {
      if (drawData!
              .markets![selectedMarketIndex]
              .eventDetail![selectedEventIndex]
              .optionInfo![selectedOptionIndex]
              .isSelected ==
          true) {
        selectedOptionList.add(drawData!
            .markets![selectedMarketIndex]
            .eventDetail![selectedEventIndex]
            .optionInfo![selectedOptionIndex]
            .tpOptionCode!);

        selectedOptionNameList!.add(drawData!
            .markets![selectedMarketIndex]
            .eventDetail![selectedEventIndex]
            .optionInfo![selectedOptionIndex]
            .tpOptionName!);
      }
    }
    if (checkIfAddOnAvailableAndSelected) {
      for (int selectedAddOnOptionIndex = 0;
          selectedAddOnOptionIndex <
              drawData!.addOnDrawData!.markets![selectedMarketIndex]
                  .eventDetail![selectedEventIndex].optionInfo!.length;
          selectedAddOnOptionIndex++) {
        if (drawData!
                .addOnDrawData
                ?.markets![selectedMarketIndex]
                .eventDetail![selectedEventIndex]
                .optionInfo![selectedAddOnOptionIndex]
                .isSelected ==
            true) {
          selectedOptionList.add(
              "TOSS - ${drawData!.addOnDrawData!.markets![selectedMarketIndex].eventDetail![selectedEventIndex].optionInfo![selectedAddOnOptionIndex].tpOptionCode!}");
        }
      }
    }
    return selectedOptionList;
  }
}
