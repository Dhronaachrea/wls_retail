import 'dart:developer';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/lottery/bingo/bloc/bingo_bloc.dart';
import 'package:wls_pos/lottery/bingo/model/data/bingo_purchase_detail_data.dart';
import 'package:wls_pos/lottery/bingo/model/data/card_model.dart';
import 'package:wls_pos/lottery/bingo/widget/bingo_widget.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

import '../../utility/widgets/primary_button.dart';
import '../../utility/utils.dart';
import '../models/response/fetch_game_data_response.dart';
import 'model/response/pick_number_response_model.dart';

/*
    created by Chandra Bhushan Tiwari on 19 May, 23
*/

class BingoGameScreen extends StatefulWidget {
  final GameRespVOs? particularGameObjects;

  const BingoGameScreen({Key? key, this.particularGameObjects})
      : super(key: key);

  @override
  State<BingoGameScreen> createState() => _BingoGameScreenState();
}

class _BingoGameScreenState extends State<BingoGameScreen> {
  double bottomHeight = 60;
  List<CardModel> cardList = [];
  List<CardModel> selectedCardList = [];
  bool mIsShimmerLoading = false;
  late FlipCardController _bottomCardController;
  String betValue = "0";
  double unitPrice = 1;

  @override
  void initState() {
    pickNumber();
    init();
    _bottomCardController = FlipCardController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("bingo game screen is called");
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return SafeArea(
      child: WlsPosScaffold(
          showAppBar: true,
          centerTitle: false,
          drawer: WlsPosDrawer(drawerModuleList: const []),
          backgroundColor: mIsShimmerLoading
              ? WlsPosColor.light_dark_white
              : WlsPosColor.white,
          appBarTitle: Text(
              widget.particularGameObjects?.gameName ?? 'Lotto Amigo',
              style: const TextStyle(fontSize: 18, color: WlsPosColor.white)),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    BlocListener<BingoBloc, BingoState>(
                      listener: (context, state) {
                        log("state : $state");
                        if (state is PickingNumber) {
                          setState(() {
                            mIsShimmerLoading = true;
                          });
                        } else if (state is PickedNumber) {
                          PickNumberResponse pickedNumberResponse =
                              state.response;
                          cardList = [];
                          setState(() {
                            if (selectedCardList.isNotEmpty) {
                              cardList.addAll(selectedCardList);
                            }
                            splitResponse(pickedNumberResponse);
                            mIsShimmerLoading = false;
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (_bottomCardController.state?.isFront == true &&
                                  selectedCardList.isNotEmpty) {
                                _bottomCardController.toggleCard();
                              }
                            });
                          });
                        } else if (state is PickNumberError) {
                          setState(() {
                            mIsShimmerLoading = false;
                          });
                        }
                      },
                      child: GridView.builder(
                        itemCount: mIsShimmerLoading ? 10 : cardList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLandscape ? 5 : 2,
                                childAspectRatio: 5 / 6
                            ),
                        itemBuilder: (context, cardIndex) {
                          return mIsShimmerLoading
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
                                  isSelected: cardList[cardIndex].isSelected,
                                  cardModel: cardList[cardIndex],
                                  onCardTap: () {
                                    if (selectedCardList
                                        .contains(cardList[cardIndex])) {
                                      selectedCardList
                                          .remove(cardList[cardIndex]);
                                      cardList[cardIndex].isSelected = false;
                                    } else {
                                      if (selectedCardList.length ==
                                          widget.particularGameObjects
                                              ?.maxPanelAllowed) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: const Duration(seconds: 1),
                                          content: Text(
                                              "Only maximum of ${widget.particularGameObjects?.maxPanelAllowed} panels are allowed for purchasing"),
                                        ));
                                        return; // if card is not selected no further calculation
                                      }
                                      selectedCardList.add(cardList[cardIndex]);
                                      cardList[cardIndex].isSelected = true;
                                    }
                                    //flip card
                                    if (selectedCardList.isEmpty ||
                                        _bottomCardController.state?.isFront ==
                                            true) {
                                      _bottomCardController.toggleCard();
                                    }
                                    calculateBetValue();
                                    setState(() {});
                                  });
                        },
                      ).p(isLandscape ? 50 : 10),
                    ),
                    SecondaryButton(
                      onPressed: () {
                        pickNumber();
                      },
                      text: "Get New Cards",
                      borderColor: WlsPosColor.cherry,
                      textColor: WlsPosColor.cherry,
                    ).pSymmetric(h: 50),
                    HeightBox(bottomHeight),
                  ],
                ),
              ),
              SafeArea(
                bottom: true,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: WlsPosColor.white,
                    height: bottomHeight,
                    child: mIsShimmerLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[300]!,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
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
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )),
                                      ).p(6),
                                      Container(
                                        width: 75,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )),
                                      ).pOnly(left: 6, right: 6),
                                    ],
                                  ),
                                ),
                                Container(
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
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )),
                                      ).p(6),
                                      Container(
                                        width: 75,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )),
                                      ).pOnly(left: 6, right: 6),
                                    ],
                                  ),
                                ),
                                Container(
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
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )),
                                      ).p(6),
                                      Container(
                                        width: 75,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )),
                                      ).pOnly(left: 6, right: 6),
                                    ],
                                  ),
                                ),
                                Container(
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
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(3),
                                            )),
                                      ).p(6),
                                      Container(
                                        width: 75,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400]!,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )),
                                      ).pOnly(left: 6, right: 6),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FlipCard(
                            controller: _bottomCardController,
                            flipOnTouch: false,
                            fill: Fill.fillBack,
                            // Fill the back side of the card to make in the same size as the front.
                            direction: FlipDirection.VERTICAL,
                            // default
                            side: CardSide.FRONT,
                            // The side to initially display.
                            front: Container(
                              width: MediaQuery.of(context).size.width,
                              color: WlsPosColor.ball_border_light_bg,
                              child: const Center(
                                  child: Text("Please select some cards to play",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: WlsPosColor.game_color_grey,
                                          fontSize: 14))),
                            ),
                            back: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        onReset();
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset("assets/icons/reset_icon.png",
                                            width: 20, height: 20),
                                        const HeightBox(5),
                                        const Text("Reset",
                                            style: TextStyle(
                                                color: WlsPosColor.warm_grey_new,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Roboto",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 12.0),
                                            textAlign: TextAlign.center),
                                      ],
                                    ).p(2),
                                  ),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${selectedCardList.length ?? 0}",
                                          style: const TextStyle(
                                              color: WlsPosColor.cherry,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "Roboto",
                                              fontStyle: FontStyle.normal,
                                              fontSize: 16.0),
                                          textAlign: TextAlign.center),
                                      const HeightBox(5),
                                      const FittedBox(
                                        child: Text("Selected Cards",
                                            style: TextStyle(
                                                color: WlsPosColor.warm_grey_new,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Roboto",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 12.0),
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ).p(2),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        child: Text(betValue,
                                            style: const TextStyle(
                                                color: WlsPosColor.cherry,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "Roboto",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 16.0),
                                            textAlign: TextAlign.center),
                                      ),
                                      const HeightBox(5),
                                      FittedBox(
                                        child: Text(
                                            "Bet Value (${getDefaultCurrency(getLanguage())})",
                                            style: const TextStyle(
                                                color: WlsPosColor.warm_grey_new,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Roboto",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 12.0),
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ).p(2),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          WlsPosScreen.bingoPurchaseDetail,
                                          arguments: BingoPurchaseDetailData(
                                              selectedCardList: selectedCardList,
                                              betValue: betValue,
                                              particularGameObjects:
                                                  widget.particularGameObjects,
                                              onComingToPreviousScreen: (String
                                                  onComingToPreviousScreen) {
                                                if (onComingToPreviousScreen ==
                                                    'isBuyPerformed') {
                                                  onReset();
                                                  Navigator.pop(context);
                                                }
                                              })).then((emptyResponse) {
                                        if (emptyResponse != null &&
                                            emptyResponse == true) {
                                          setState(() {
                                            onReset();
                                          });
                                        } else if (emptyResponse
                                        is List<CardModel>) {
                                          selectedCardList = emptyResponse;
                                          List<CardModel> unselectedCardList = [];
                                          for (var cardListElement
                                          in cardList) {
                                            if (selectedCardList
                                                .contains(cardListElement)) {
                                              //do nothing
                                            } else {
                                              cardListElement.isSelected = false;
                                              unselectedCardList.add(cardListElement);
                                            }
                                          }
                                          cardList = [];
                                          cardList.addAll(selectedCardList);
                                          cardList.addAll(unselectedCardList);
                                          calculateBetValue();
                                          setState(() {});
                                        }
                                      });
                                    },
                                    child: Container(
                                      color: WlsPosColor.cherry,
                                      child: Row(
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
                                            child: Text("PROCEED",
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
                              ],
                            ),
                          ),

                    // selectedCardList.isEmpty
                    //         ? Container(
                    //             width: MediaQuery.of(context).size.width,
                    //             color: WlsPosColor.ball_border_light_bg,
                    //             child: const Center(
                    //                 child: Text("Please select some cards to play",
                    //                     textAlign: TextAlign.center,
                    //                     style: TextStyle(
                    //                         color: WlsPosColor.game_color_grey,
                    //                         fontSize: 14))),
                    //           )
                    //         : Row(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             children: [
                    //               Expanded(
                    //                 child: InkWell(
                    //                   onTap: () {
                    //                     setState(() {
                    //                       onReset();
                    //                     });
                    //                   },
                    //                   child: Column(
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.center,
                    //                     mainAxisAlignment: MainAxisAlignment.center,
                    //                     children: [
                    //                       Image.asset("assets/icons/reset_icon.png",
                    //                           width: 20, height: 20),
                    //                       const HeightBox(5),
                    //                       const Text("Reset",
                    //                           style: TextStyle(
                    //                               color: WlsPosColor.warm_grey_new,
                    //                               fontWeight: FontWeight.w500,
                    //                               fontFamily: "Roboto",
                    //                               fontStyle: FontStyle.normal,
                    //                               fontSize: 12.0),
                    //                           textAlign: TextAlign.center),
                    //                     ],
                    //                   ).p(2),
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 child: Column(
                    //                   crossAxisAlignment: CrossAxisAlignment.center,
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Text("${selectedCardList.length ?? 0}",
                    //                         style: const TextStyle(
                    //                             color: WlsPosColor.cherry,
                    //                             fontWeight: FontWeight.w700,
                    //                             fontFamily: "Roboto",
                    //                             fontStyle: FontStyle.normal,
                    //                             fontSize: 16.0),
                    //                         textAlign: TextAlign.center),
                    //                     const HeightBox(5),
                    //                     const Text("No. Of Lines",
                    //                         style: TextStyle(
                    //                             color: WlsPosColor.warm_grey_new,
                    //                             fontWeight: FontWeight.w500,
                    //                             fontFamily: "Roboto",
                    //                             fontStyle: FontStyle.normal,
                    //                             fontSize: 12.0),
                    //                         textAlign: TextAlign.center),
                    //                   ],
                    //                 ).p(2),
                    //               ),
                    //               Expanded(
                    //                 child: Column(
                    //                   crossAxisAlignment: CrossAxisAlignment.center,
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: const [
                    //                     FittedBox(
                    //                       child: Text("3",
                    //                           style: TextStyle(
                    //                               color: WlsPosColor.cherry,
                    //                               fontWeight: FontWeight.w700,
                    //                               fontFamily: "Roboto",
                    //                               fontStyle: FontStyle.normal,
                    //                               fontSize: 16.0),
                    //                           textAlign: TextAlign.center),
                    //                     ),
                    //                     HeightBox(5),
                    //                     Text("Bet Value",
                    //                         style: TextStyle(
                    //                             color: WlsPosColor.warm_grey_new,
                    //                             fontWeight: FontWeight.w500,
                    //                             fontFamily: "Roboto",
                    //                             fontStyle: FontStyle.normal,
                    //                             fontSize: 12.0),
                    //                         textAlign: TextAlign.center),
                    //                   ],
                    //                 ).p(2),
                    //               ),
                    //               Expanded(
                    //                 flex: 2,
                    //                 child: InkWell(
                    //                   onTap: () {},
                    //                   child: Container(
                    //                     color: WlsPosColor.cherry,
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.center,
                    //                       children: [
                    //                         Align(
                    //                           alignment: Alignment.center,
                    //                           child: Image.asset(
                    //                             "assets/icons/buy_icon.png",
                    //                             width: 25,
                    //                             height: 25,
                    //                           ),
                    //                         ),
                    //                         const WidthBox(5),
                    //                         const Align(
                    //                           alignment: Alignment.centerRight,
                    //                           child: Text("BUY NOW",
                    //                               style: TextStyle(
                    //                                   color: WlsPosColor.white,
                    //                                   fontWeight: FontWeight.w700,
                    //                                   fontFamily: "Roboto",
                    //                                   fontStyle: FontStyle.normal,
                    //                                   fontSize: 19.5),
                    //                               textAlign: TextAlign.left),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void pickNumber() {
    BlocProvider.of<BingoBloc>(context).add(PickNumber(
      context: context,
    ));
  }

  void splitResponse(PickNumberResponse pickedNumberResponse) {
    List<String>? numbersList = pickedNumberResponse.responseData;
    numbersList?.forEach((element) {
      String cardNumberString = element;
      List<String> cardNumberList = cardNumberString.split(RegExp(r'[,#]'));
      CardModel? cardModel = CardModel(
          cardNumberList: cardNumberList,
          numberString: cardNumberString,
          isSelected: false);
      if (cardList.length < numOfBingoCards) {
        cardList.add(cardModel);
      } else {
        return;
      }
    });
  }

  void onReset() {
    selectedCardList = [];
    for (var element in cardList) {
      element.isSelected = false;
    }
    _bottomCardController.toggleCard();
  }

  void init() {
    unitPrice = widget.particularGameObjects?.betRespVOs?[0].unitPrice ?? 1;
  }

  void calculateBetValue() {
    betValue = "${selectedCardList.length * (unitPrice.round())}";
  }

}
