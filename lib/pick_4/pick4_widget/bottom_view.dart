import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class BottomView extends StatelessWidget {
  final double bottomNavigationHeight;
  final int numOfLines;
  final double betValue;
  // final List<DrawData>? drawData;
  final int drawGameSelectedIndex;
  final VoidCallback onReset;
  final Function(double selectedTicketPrice, int index) onValueTap;
  final double unitTicketPrice;
  final String? currency;
  // final Map<String, dynamic>? unitTicketPriceJson;
  final double currencyMultiplier;
  final int? selectedPriceContainerIndex;
  final VoidCallback onBuy;
  final bool onOtherTap;

  final Function(double) onChanged;
  final double maxTicketPrice;
  final double selectedPrice;

   BottomView({
    Key? key,
    required this.bottomNavigationHeight,
    required this.numOfLines,
    required this.betValue,
    // required this.drawData,
    required this.drawGameSelectedIndex,
    required this.onReset,
    required this.onValueTap,
    required this.unitTicketPrice,
    required this.currency,
    // required this.unitTicketPriceJson,
    required this.currencyMultiplier,
    required this.selectedPriceContainerIndex,
    required this.onBuy,
    required this.onOtherTap,
    required this.onChanged,
    required this.maxTicketPrice,
    required this.selectedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*double unitTicketPrice = drawData?[drawGameSelectedIndex].unitTicketPrice;
    String? currency = drawData?[drawGameSelectedIndex].currency;
    Map<String, dynamic>? unitTicketPriceJson =
        drawData?[drawGameSelectedIndex].unitTicketPriceJson?.toJson();
    double currencyMultiplier = unitTicketPriceJson![currency].toDouble(); */

    return SafeArea(
      bottom: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: bottomNavigationHeight,
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
                color: WlsPosColor.black_16,
                offset: Offset(0, -3),
                blurRadius: 6,
                spreadRadius: 0)
          ], color: WlsPosColor.white),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                alignment: Alignment.centerLeft,
                child: Text('Bet Amount'.toUpperCase(),
                  style: TextStyle(
                      // color: WlsPosColor.warm_grey_new,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Roboto",
                      fontStyle: FontStyle.normal,
                      fontSize: 12.0),
                )
              ),
              SizedBox(
                height: 40,
                child: AnimationLimiter(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 700),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: InkWell(
                              onTap: () {
                                onValueTap(
                                    currencyMultiplier * (index + 1), index
                                );
                              },
                              child: PriceSelectContainer(
                                index: index,
                                selectedPriceContainerIndex:
                                selectedPriceContainerIndex,
                                unitTicketPrice: unitTicketPrice,
                                currency: currency!,
                                onOtherTap: onOtherTap,
                                currencyMultiplier: currencyMultiplier,
                                onChanged: (value) {
                                  onChanged(value);
                                },
                                maxTicketPrice: maxTicketPrice,
                                selectedPrice: selectedPrice,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ).pSymmetric(h: 8),
              const HeightBox(5),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onReset();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("$numOfLines",
                              style: const TextStyle(
                                  color: WlsPosColor.cherry,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Roboto",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16.0),
                              textAlign: TextAlign.center),
                          const HeightBox(5),
                          const Text("No. Of Lines",
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FittedBox(
                            // child: Text("$currency $betValue",
                            child: Text("\$ $betValue",
                                style: const TextStyle(
                                    color: WlsPosColor.cherry,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Roboto",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.0),
                                textAlign: TextAlign.center),
                          ),
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
                      ).p(2),
                    ),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () {
                          onBuy();
                        },
                        child: Container(
                          color: WlsPosColor.cherry,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                child: Text("BUY NOW",
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
            ],
          ),
        ),
      ),
    );
  }
}
