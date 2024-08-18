import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/widgets/added_bet_cart_msg.dart';
import 'package:wls_pos/lottery/zoo_lotto/widgets/mihar_cantena_widget.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/draw_timer_widget.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

/*
    created by Rahul Poswal on 20 May, 23
*/

class DrawZooLottoScreen extends StatefulWidget {
  final GameRespVOs? gameObjectsList;
  List<PanelBean>? listPanelData;

  DrawZooLottoScreen({Key? key, this.gameObjectsList, this.listPanelData})
      : super(key: key);

  @override
  State<DrawZooLottoScreen> createState() => _PickTypeScreenState();
}

class _PickTypeScreenState extends State<DrawZooLottoScreen> {
  List<BetRespVOs>? lotteryGameMainBetList = [];
  List<BetRespVOs>? lotteryGameSideBetList = [];
  final bool _mIsShimmerLoading = false;
  String totalAmount = "0";
  var maxPanelAllowed = 0;
  var listOfPanelDataLength = 0;

  List<LastDrawWinningResultVOs>? lastDrawWinningResultVOs = [];
  List<String> winningCommaNumberList = [];

  // List<String> winningNumberHasListString = [];
  List<String> winningNumberList = [];
  List<Ball>? numberRange = [];
  List<String>? winningNumberHasListString = [];
  List<String>? numberConfigList = [];

  @override
  void initState() {
    super.initState();
    numberRange = widget.gameObjectsList!.numberConfig!.range![2].ball;
    lastDrawWinningResultVOs = widget.gameObjectsList!.lastDrawWinningResultVOs!
        .where((element) => element.winningNumber != '')
        .toList();
    winningCommaNumberList =
        ((widget.gameObjectsList!.lastDrawWinningResultVOs![0].winningNumber!)
            .split(","));
    for (var listValue in winningCommaNumberList) {
      String? winningNumber = '';
      for (var data in listValue.split('#')) {
        winningNumber = winningNumber! + data;
      }
      winningNumberHasListString!.add(winningNumber!);
    }
    for (var data in winningNumberHasListString!) {
      numberRange!.asMap().forEach((index, value) {
        if (int.parse(data.substring(2)) == index) {
          numberConfigList!.add(value.label!);
        }
      });
    }

    lotteryGameMainBetList = widget.gameObjectsList?.betRespVOs
            ?.where((element) => element.winMode == "MAIN")
            .toList() ??
        [];
    if (widget.gameObjectsList?.gameCode?.toUpperCase() ==
        "powerball".toUpperCase()) {
      List<BetRespVOs>? betRespV0sList = widget.gameObjectsList?.betRespVOs
          ?.where((element) =>
              element.betCode?.toUpperCase().contains("plus".toUpperCase()) !=
              true)
          .toList();
      if (betRespV0sList?.isNotEmpty == true) {
        lotteryGameMainBetList = betRespV0sList;
      }
    }
    lotteryGameMainBetList = lotteryGameMainBetList?.isNotEmpty == true
        ? lotteryGameMainBetList
        : [];
    lotteryGameSideBetList = widget.gameObjectsList?.betRespVOs
            ?.where((element) => element.winMode == "COLOR")
            .toList() ??
        [];
    lotteryGameSideBetList = widget.gameObjectsList?.betRespVOs
            ?.where((element) => element.winMode != "MAIN")
            .toList() ??
        [];
    maxPanelAllowed = widget.gameObjectsList?.maxPanelAllowed ?? 0;
    listOfPanelDataLength = widget.listPanelData?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WlsPosScaffold(
      showAppBar: true,
      onBackButton: (widget.listPanelData == null || widget.listPanelData?.isEmpty == true)
          ? null
          : () {
              AddedBetCartMsg().show(
                  context: context,
                  title: "Bet on cart !",
                  subTitle:
                      "You have some item in your cart. If you leave the game your cart will be cleared.",
                  buttonText: "CLEAR",
                  isCloseButton: true,
                  buttonClick: () {
                    widget.listPanelData!.clear();
                    Navigator.of(context).pop();
                  });
            },
      drawer: WlsPosDrawer(drawerModuleList: const []),
      backgroundColor: _mIsShimmerLoading
          ? WlsPosColor.light_dark_white
          : WlsPosColor.white,
      appBarTitle: Text(widget.gameObjectsList?.gameName ?? "NA",
          style: const TextStyle(fontSize: 18, color: WlsPosColor.white)),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // const DrawTimerWidget(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                        decoration: const BoxDecoration(
                            color: WlsPosColor.border_inside,
                            // borderRadius: BorderRadius.only(
                            //   topRight: Radius.circular(10.0),
                            //   topLeft: Radius.circular(10)
                            // ),
                            border: Border(
                              top: BorderSide(
                                color: WlsPosColor.light_grey,
                                width: 1.0,
                              ),
                              right: BorderSide(
                                color: WlsPosColor.light_grey,
                                width: 2.0,
                              ),
                            )
                            // border: Border.all(width: 2, color: WlsPosColor.light_grey)
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Last Result',
                                style: TextStyle(
                                  color: WlsPosColor.brownish_grey,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto",
                                  fontStyle: FontStyle.normal,
                                  fontSize: isLandscape ? 18 : 13.0,
                                )),
                            Text(
                                formatDate(
                                    date: widget
                                        .gameObjectsList!
                                        .lastDrawWinningResultVOs![0]
                                        .lastDrawDateTime!,
                                    inputFormat: Format.apiDateFormat2,
                                    outputFormat: Format.calendarFormat),
                                style: TextStyle(
                                  color: WlsPosColor.brownish_grey,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Roboto",
                                  fontStyle: FontStyle.normal,
                                  fontSize: isLandscape ? 20 : 14.0,
                                )),
                          ],
                        ).p(10),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                        child: Table(
                          border: TableBorder.all(
                              width: 1, color: WlsPosColor.light_grey),
                          children: [
                            TableRow(
                                children: lastDrawWinningResultVOs!
                                    .asMap()
                                    .map((index, value) => MapEntry(
                                        index,
                                        Center(
                                          child: Column(
                                            children: [
                                              Text('Reel ${++index}',
                                                  style: TextStyle(
                                                    color:
                                                        WlsPosColor.brownish_grey,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Roboto",
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: isLandscape ? 20 : 13.0,
                                                  )),
                                              Text(numberConfigList![--index],
                                                  style: TextStyle(
                                                    color:
                                                        WlsPosColor.brownish_grey,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Roboto",
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: isLandscape ? 20 : 8.0,
                                                  )).p(5),
                                            ],
                                          ).p(isLandscape ? 15 : 10),
                                        )))
                                    .values
                                    .toList()),
                            TableRow(
                                children: winningNumberHasListString!
                                    .map((value) => Center(
                                          child: Column(
                                            children: [
                                              Text(value,
                                                  style: TextStyle(
                                                    color:
                                                        WlsPosColor.brownish_grey,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Roboto",
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: isLandscape ? 20 : 13.0,
                                                  )),
                                            ],
                                          ).p(isLandscape ? 10 : 5),
                                        ))
                                    .toList()),
                          ],
                        ),
                      ),
                    )
                  ],
                ).p(isLandscape ? 20 : 10),
                Container(
                  height: context.screenHeight - 250,
                  // width: context.screenWidth,
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 5.0,
                      childAspectRatio: 3.0,
                    ),
                    children: List.generate(
                        widget.gameObjectsList!.betRespVOs!.length, (index) {
                      return MiharCantenaWidget(
                          onTapData: () {
                            Navigator.pushReplacementNamed(
                                context, WlsPosScreen.miharGameScreen,
                                arguments: {
                                  'betData': widget.gameObjectsList!.betRespVOs![index],
                                  'gameObjectsList': widget.gameObjectsList!,
                                  'panelBinList': widget.listPanelData,
                                });
                          },
                          tickValue: true,
                          drawData:
                              widget.gameObjectsList!.betRespVOs![index]);
                    }),
                  ).pOnly(top: 20, left: 10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
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
                                  widget.listPanelData != null
                                      ? "${widget.listPanelData?.length}"
                                      : "0",
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
                              child: Text(
                                  calculateTotalAmount(),
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
                            if (widget.listPanelData?.isEmpty == true) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text(
                                    "No bet selected, please select any bet !"),
                              ));
                            } else {
                              Navigator.pushNamed(context,
                                  WlsPosScreen.zooPurchaseDetailsScreen,
                                  arguments: {
                                    "gameObjectsList": widget.gameObjectsList,
                                    "listPanelData": widget.listPanelData,
                                    "onComingToPreviousScreen": (String
                                    onComingToPreviousScreen) {
                                      if (onComingToPreviousScreen == 'isBuyPerformed') {
                                        // reset();
                                        setState(() {
                                          widget.listPanelData = [];
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                  }).then((list) {
                                    if(list != null)
                                    setState(() {
                                      widget.listPanelData = list as List<PanelBean>?;
                                    });
                              });
                            }
                          },
                          child: Ink(
                            color: WlsPosColor.game_color_red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/icons/buy.svg',
                                    width: 20,
                                    height: 20,
                                    color: WlsPosColor.white),
                                const Align(
                                        alignment: Alignment.center,
                                        child: Text("BUY",
                                            style: TextStyle(
                                                color: WlsPosColor.white,
                                                fontWeight: FontWeight.bold,
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
            ),
          )
        ],
      ),
    );
  }
  String calculateTotalAmount() {
    int amount = 0;
    if (widget.listPanelData != null) {
      for (PanelBean model in widget.listPanelData!) {
        if (model.betAmountMultiple != null) {
          // amount = (amount + model.betAmountMultiple!).toInt();
          amount = (amount + model.amount!).toInt();
        }
      }
      String strAmount = "${getDefaultCurrency(getLanguage())} $amount";
      totalAmount = strAmount;
    }
    return totalAmount;
  }

  void getWinnerNumber(List<String> value) {
    String numberValue = '';
    for (var num in value) {
      numberValue = numberValue + num;
    }
    setState(() {
      winningNumberList.add(numberValue);
    });
    print('winningList $winningNumberList');
  }
}
