import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/pick_type_screen.dart';
import 'package:wls_pos/lottery/widgets/added_bet_cart_msg.dart';
import 'package:wls_pos/lottery/widgets/other_available_bet_amounts.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import '../../utility/utils.dart';
import '../models/otherDataClasses/bankerBean.dart';
import '../models/otherDataClasses/betAmountBean.dart';
import '../models/otherDataClasses/quickPickBetAmountBean.dart';

class TwoDMyanmaar extends StatefulWidget {
  final GameRespVOs? particularGameObjects;
  final List<PickType>? pickType;
  final BetRespVOs? betRespV0s;
  final List<PanelBean>? mPanelBinList;
  final int? selectedSeriesNumber ;
  final String? betCode;

  const TwoDMyanmaar(
      {Key? key,
        this.particularGameObjects,
        this.pickType,
        this.betRespV0s,
        this.mPanelBinList,
        this.selectedSeriesNumber,
        this.betCode,
      })
      : super(key: key);

  @override
  State<TwoDMyanmaar> createState() => _GameScreenState();
}

class _GameScreenState extends State<TwoDMyanmaar>
    with TickerProviderStateMixin {
  late Ball? ball;
  Color? upperLineBallColor;
  late PickType selectedPickTypeObject;
  late BetRespVOs? selectedBetTypeData;
  late FlipCardController _controller;
  late FlipCardController _pickController;
  late final AnimationController _inOutAnimationController;
  late final Animation<double> _inOutAnimation;
  late final Animation<double> _inOutOffAnimation;

  List<Color?> lotteryGameColorList = [];
  int maxSelectionLimit = 0, minSelectionLimit = 0;

  // Map<String, Map<String, int>> ballPickingLimits = {};
  Map<String, Map<String, int>> ballPickingLimits                   = {};
  Map<String, List<String>> listOfSelectedNosMap = {};
  String selectedBetAmount = "0";
  String betValue = "0";
  List<FiveByNinetyBetAmountBean> listBetAmount = [];
  int listBetAmountLength = 0;
  List<QuickPickBetAmountBean> listQuickPick = [];
  bool mIsQpSelecting = false;
  Map<String, bool> selectedPickType =
  {}; ////////////////////////////////////////
  Map<String, bool> selectedBetAmountValue =
  {}; ////////////////////////////////////////
  String ballPickInstructions = "";
  bool mIsToggleAllowed = false;
  bool isOtherAmountAvailable = false;
  bool isBankerPickType = false;
  bool isUpperLine = true;
  int lowerLineBankerPickedNoIndex = 0;
  int upperLineBankerPickedNoIndex = 0;
  int mRangeObjectIndex = 0;
  int mMultiplePickTypeIndex = 0;
  bool isMultiplePickType = false;
  bool isPowerBallPlus = false;
  List<Range>? ballObjectsRange = [];
  List<String> listOfBalls = [];
  Map<String, Range> ballObjectsMap = {};

  @override
  void initState() {
    super.initState();

    // ⚠️Please don't disturb the order. ️

    _controller = FlipCardController();
    _pickController = FlipCardController();
    getPickTypeWithQp();
    selectedPickTypeObject = getPickTypeWithQp()[0];
    setNoPickLimits(selectedPickTypeObject);
    setInitialValues();
    checkIsPowerBallPlusEnabled();
    setBetAmount();
    setInitialBetAmount();

    _inOutAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _inOutAnimation =
    Tween<double>(begin: 1, end: 0.85).animate(_inOutAnimationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _inOutAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _inOutAnimationController.forward();
        }
      });

    _inOutOffAnimation =
        Tween<double>(begin: 1, end: 1).animate(_inOutAnimationController);
    //List<String> localListOfBalls =  List<String>.generate(100, (i) => i.length > 1 ? "$i" : "0$i");
    listOfBalls =
    List<String>.generate(100, (i) => i.length > 1 ? "$i" : "0$i");
    if (widget.betCode != null) {
      defaultSelectionFor2DMyanmarBalls(widget.betCode!);
    }
    print("-------> selectedBetAmount -- $selectedBetAmount");
  }

  @override
  void dispose() {
    _inOutAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WillPopScope(
      onWillPop: () async {
        return widget.mPanelBinList == null ||
            widget.mPanelBinList?.isEmpty == true;
      },
      child: WlsPosScaffold(
        showAppBar: true,
        onBackButton: (widget.mPanelBinList == null ||
            widget.mPanelBinList?.isEmpty == true)
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
                Navigator.of(context).pop();
              });
        },
        drawer: WlsPosDrawer(drawerModuleList: const []),
        backgroundColor: WlsPosColor.white,
        appBarTitle: Text(widget.betRespV0s?.betDispName ?? "NA",
            style: const TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: mIsQpSelecting,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder:
                              (BuildContext context, int rangeObjectIndex) {
                            return Column(
                              children: [
                                AnimationLimiter(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                                    child: GridView.builder(
                                        gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 0.9,
                                          crossAxisCount: 10,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        itemCount: listOfBalls.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return AnimationConfiguration
                                              .staggeredGrid(
                                            position: index,
                                            duration:
                                            const Duration(milliseconds: 400),
                                            columnCount:
                                            getColumnCount(rangeObjectIndex),
                                            child: FlipAnimation(
                                              flipAxis: FlipAxis.y,
                                              curve: Curves.decelerate,
                                              child: FadeInAnimation(
                                                child: ScaleTransition(
                                                  scale: mIsQpSelecting
                                                      ? _inOutAnimation
                                                      : _inOutOffAnimation,
                                                  child: InkWell(
                                                      onTap: () {
                                                        ball = Ball(
                                                            number: listOfBalls[
                                                            index]);
                                                        if (ball != null) {
                                                          if (selectedPickType
                                                              .keys.first
                                                              .contains("QP")) {
                                                            ScaffoldMessenger.of(
                                                                context)
                                                                .showSnackBar(
                                                                const SnackBar(
                                                                  duration: Duration(
                                                                      seconds: 1),
                                                                  content: Text(
                                                                      "Numbers cannot be picked for manually this bet type."),
                                                                ));
                                                          } else {
                                                            setState(() {
                                                              if (listOfSelectedNosMap[
                                                              "$rangeObjectIndex"]
                                                                  ?.contains(ball
                                                                  ?.number) ==
                                                                  true) {
                                                                listOfSelectedNosMap[
                                                                "$rangeObjectIndex"]
                                                                    ?.remove(ball
                                                                    ?.number);
                                                              } else {
                                                                var listOfSelectedNosLength =
                                                                    listOfSelectedNosMap[
                                                                    "$rangeObjectIndex"]
                                                                        ?.length ??
                                                                        0;
                                                                var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                                if (listOfSelectedNosLength <
                                                                    mMaxSelectionLimit) {
                                                                  if (ball?.number !=
                                                                      null) {
                                                                    List<String>
                                                                    addTemp =
                                                                        listOfSelectedNosMap[
                                                                        "$rangeObjectIndex"] ??
                                                                            [];
                                                                    addTemp.add(
                                                                        ball?.number ??
                                                                            "");
                                                                    listOfSelectedNosMap[
                                                                    "$rangeObjectIndex"] =
                                                                        addTemp;
                                                                  }
                                                                } else {
                                                                  ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                                  String msg =
                                                                  mMaxSelectionLimit >
                                                                      1
                                                                      ? "Sorry, you cannot select more than $mMaxSelectionLimit numbers for ${selectedPickTypeObject.name!}!"
                                                                      : "Sorry, you cannot select more than $mMaxSelectionLimit number for ${selectedPickTypeObject.name!}!";
                                                                  ScaffoldMessenger.of(
                                                                      context)
                                                                      .showSnackBar(
                                                                      SnackBar(
                                                                        duration:
                                                                        const Duration(
                                                                            seconds:
                                                                            1),
                                                                        content:
                                                                        Text(msg),
                                                                      ));
                                                                }
                                                              }
                                                            });
                                                          }

                                                          var listOfSelectedNosList =
                                                              listOfSelectedNosMap[
                                                              "$rangeObjectIndex"] ??
                                                                  [];

                                                          if (listOfSelectedNosList
                                                              .isNotEmpty) {
                                                            if (_controller.state
                                                                ?.isFront ==
                                                                true) {
                                                              _controller
                                                                  .toggleCard();
                                                            }
                                                          } else {
                                                            var nosCounts = 0;
                                                            for (int i = 0;
                                                            i <
                                                                listOfSelectedNosMap
                                                                    .length;
                                                            i++) {
                                                              if (listOfSelectedNosMap[
                                                              "$i"]
                                                                  ?.isNotEmpty ==
                                                                  true) {
                                                                nosCounts += 1;
                                                              }
                                                            }
                                                            if (nosCounts < 1) {
                                                              reset();
                                                              _controller
                                                                  .toggleCard();
                                                            }
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                              context)
                                                              .showSnackBar(
                                                              const SnackBar(
                                                                duration: Duration(
                                                                    seconds: 1),
                                                                content: Text(
                                                                    "Balls do not present !"),
                                                              ));
                                                        }
                                                        betValueCalculation(
                                                            rangeObjectIndex);
                                                      },
                                                      customBorder:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: getBallColor(
                                                                listOfSelectedNosMap[
                                                                "$rangeObjectIndex"] ??
                                                                    [],
                                                                index),
                                                            borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    6)),
                                                            border: Border.all(
                                                                color: WlsPosColor
                                                                    .ball_border_bg,
                                                                width: 1)),
                                                        child: Center(
                                                            child: Text(
                                                                listOfBalls[
                                                                index],
                                                                style: TextStyle(
                                                                    color: isBallAvailable(
                                                                        listOfSelectedNosMap["$rangeObjectIndex"] ??
                                                                            [],
                                                                        index,
                                                                        rangeObjectIndex)
                                                                        ? WlsPosColor
                                                                        .white
                                                                        : WlsPosColor
                                                                        .ball_border_bg,
                                                                    fontSize: 12,
                                                                    fontWeight: isBallAvailable(
                                                                        listOfSelectedNosMap["$rangeObjectIndex"] ??
                                                                            [],
                                                                        index,
                                                                        rangeObjectIndex)
                                                                        ? FontWeight
                                                                        .bold
                                                                        : FontWeight
                                                                        .w400))),
                                                      )).p(2),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            );
                          }).pOnly(bottom: 2),
                      widget.betCode == null
                       ? const Align(alignment: Alignment.centerLeft, child: Text("Pick Type", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(top: 20, bottom: 2)
                       : Container(),

                      widget.betCode == null
                        ? FlipCard(
                            controller: _pickController,
                            flipOnTouch: false,
                            fill: Fill.fillBack,
                            direction: FlipDirection.VERTICAL,
                            side: CardSide.FRONT,
                            front: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: isLandscape ? 85 : 65,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: getPickTypeWithQp().length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Ink(
                                      decoration: BoxDecoration(
                                          color: selectedPickType[getPickTypeWithQp()[index].name] == true
                                              ? WlsPosColor.game_color_red
                                              : WlsPosColor.white,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(6),
                                          ),
                                          border: Border.all(
                                              color:
                                              WlsPosColor.game_color_red)),
                                      child: InkWell(
                                        onTap: () {
                                          selectedPickTypeData(
                                              getPickTypeWithQp()[index]);
                                        },
                                        customBorder: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                            child: SizedBox(
                                                width: 80,
                                                child: Text(
                                                    index == 0 ? "Manual": getPickTypeWithQp()[index]
                                                        .name ==
                                                        "direct"
                                                        ? "Manual"
                                                        : getPickTypeWithQp()[index]
                                                        .name
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: selectedPickType[
                                                        getPickTypeWithQp()[index]
                                                            .name] ==
                                                            true
                                                            ? WlsPosColor.white
                                                            : WlsPosColor
                                                            .game_color_red,
                                                        fontSize: isLandscape ? 13 : 10,
                                                        fontWeight:
                                                        selectedPickType[getPickTypeWithQp()[index].name] ==
                                                            true
                                                            ? FontWeight.bold
                                                            : FontWeight.w400)).p4())),
                                      ),
                                    ).p(2);
                                  }).pOnly(bottom: 2).pOnly(top: 10, bottom: 10),
                            ),
                            back: isBankerPickType
                                ? Row(
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isUpperLine = true;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(
                                                        20)),
                                                border: Border.all(
                                                    color: isUpperLine
                                                        ? WlsPosColor
                                                        .game_color_green
                                                        : WlsPosColor.white,
                                                    width: 1.5)),
                                            child: const Align(
                                                alignment: Alignment
                                                    .centerLeft,
                                                child: Text(
                                                    "Upper Line:",
                                                    style: TextStyle(
                                                        color:
                                                        WlsPosColor
                                                            .black,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 14)))
                                                .p(8),
                                          ),
                                        ],
                                      ),
                                    ).pOnly(right: 8),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            isUpperLine = false;
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(
                                                            20)),
                                                    border: Border.all(
                                                        color: isUpperLine
                                                            ? WlsPosColor
                                                            .white
                                                            : WlsPosColor
                                                            .game_color_green,
                                                        width: 1.5)),
                                                child: const Align(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Text(
                                                        "Lower Line:",
                                                        style: TextStyle(
                                                            color: WlsPosColor
                                                                .black,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14)))
                                                    .p(10)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ).pOnly(left: 10),
                                ),
                              ],
                            )
                                : isMultiplePickType
                                ? Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 50,
                                  color: WlsPosColor.white,
                                  child: Center(
                                    child: RichText(
                                      text: const TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                              "Pick ball \nmatrix",
                                              style: TextStyle(
                                                  color:
                                                  WlsPosColor.black,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: getPermRangeList(
                                          selectedPickTypeObject)
                                          .length,
                                      itemBuilder:
                                          (BuildContext context,
                                          int index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              color: WlsPosColor.white,
                                              borderRadius:
                                              const BorderRadius
                                                  .all(
                                                Radius.circular(6),
                                              ),
                                              border: Border.all(
                                                  color: WlsPosColor
                                                      .game_color_grey)),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                mMultiplePickTypeIndex =
                                                    index;
                                                isMultiplePickType =
                                                false;
                                                setPermQpList(
                                                    rangeObjectIndex:
                                                    index);
                                              });
                                            },
                                            customBorder:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  6),
                                            ),
                                            child: Center(
                                                child: SizedBox(
                                                    width: 30,
                                                    child: Text(
                                                        "${index + 1}",
                                                        textAlign:
                                                        TextAlign
                                                            .center,
                                                        style: const TextStyle(
                                                            color: WlsPosColor
                                                                .black,
                                                            fontSize:
                                                            12,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold)))),
                                          ),
                                        ).p(2);
                                      }).pOnly(right: 10),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isBankerPickType = false;
                                      listOfSelectedNosMap.clear();
                                    });
                                    if (_pickController
                                        .state?.isFront ==
                                        false) {
                                      _pickController.toggleCard();
                                    }
                                    for (QuickPickBetAmountBean i
                                    in listQuickPick) {
                                      i.isSelected = false;
                                    }
                                    if (listOfSelectedNosMap.isEmpty) {
                                      switchToPickType(
                                          selectedBetTypeData
                                              ?.betCode ??
                                              "");
                                    }
                                  },
                                  child: Container(
                                      color: WlsPosColor.white,
                                      child: SvgPicture.asset(
                                          "assets/icons/cross.svg",
                                          width: 18,
                                          height: 18,
                                          color: WlsPosColor
                                              .game_color_red)),
                                ),
                              ],
                            )
                                : Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 50,
                                  color: WlsPosColor.white,
                                  child: Center(
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          const TextSpan(
                                              text: "Perm Qp:",
                                              style: TextStyle(
                                                  color:
                                                  WlsPosColor.black,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 12)),
                                          TextSpan(
                                              text:
                                              "\n ( $ballPickingLimits - $ballPickingLimits )",
                                              style: const TextStyle(
                                                  color: WlsPosColor
                                                      .game_color_grey,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 10,
                                                  fontStyle: FontStyle
                                                      .italic)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: listQuickPick.length,
                                      itemBuilder:
                                          (BuildContext context,
                                          int index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              color: listQuickPick[
                                              index]
                                                  .isSelected ==
                                                  true
                                                  ? WlsPosColor
                                                  .game_color_red
                                                  : WlsPosColor.white,
                                              borderRadius:
                                              const BorderRadius
                                                  .all(
                                                Radius.circular(6),
                                              ),
                                              border: Border.all(
                                                  color: listQuickPick[
                                                  index]
                                                      .isSelected ==
                                                      true
                                                      ? WlsPosColor
                                                      .game_color_red
                                                      : WlsPosColor
                                                      .game_color_grey)),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                for (QuickPickBetAmountBean i
                                                in listQuickPick) {
                                                  i.isSelected = false;
                                                }
                                                listQuickPick[index]
                                                    .isSelected = true;
                                              });
                                              qpGenerator(
                                                  widget
                                                      .particularGameObjects
                                                      ?.numberConfig
                                                      ?.range?[
                                                  mMultiplePickTypeIndex]
                                                      .ball ??
                                                      [],
                                                  listQuickPick[index]
                                                      .number ??
                                                      0,
                                                  rangeObjectIndex:
                                                  mMultiplePickTypeIndex);
                                            },
                                            customBorder:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  6),
                                            ),
                                            child: Center(
                                                child: SizedBox(
                                                    width: 30,
                                                    child: Text(
                                                        "${listQuickPick[index].number}",
                                                        textAlign:
                                                        TextAlign
                                                            .center,
                                                        style: TextStyle(
                                                            color: listQuickPick[index].isSelected ==
                                                                true
                                                                ? WlsPosColor
                                                                .white
                                                                : WlsPosColor
                                                                .black,
                                                            fontSize:
                                                            12,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold)))),
                                          ),
                                        ).p(2);
                                      }).pOnly(right: 10),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isBankerPickType = false;
                                      var pickTypeObjectLength =
                                          selectedPickTypeObject
                                              .range?.length ??
                                              0;
                                      if (pickTypeObjectLength > 1) {
                                        isMultiplePickType = true;
                                      } else {
                                        listOfSelectedNosMap.clear();
                                        if (_pickController
                                            .state?.isFront ==
                                            false) {
                                          _pickController.toggleCard();
                                        }
                                        for (QuickPickBetAmountBean i
                                        in listQuickPick) {
                                          i.isSelected = false;
                                        }
                                        if (listOfSelectedNosMap
                                            .isEmpty) {
                                          switchToPickType(
                                              selectedBetTypeData
                                                  ?.betCode ??
                                                  "");
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                      color: WlsPosColor.white,
                                      child: SvgPicture.asset(
                                          "assets/icons/cross.svg",
                                          width: 18,
                                          height: 18,
                                          color: WlsPosColor
                                              .game_color_red)),
                                ),
                              ],
                            )
                        )
                        : Container(),

                      Container(
                        decoration: DottedDecoration(
                          color: WlsPosColor.ball_border_bg,
                          strokeWidth: 0.5,
                          linePosition: LinePosition.bottom,
                        ),
                        height: 12,
                        width: MediaQuery.of(context).size.width,
                      ),
                      listBetAmount.isNotEmpty
                          ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "Bet Amount (${getDefaultCurrency(getLanguage())})",
                              style: const TextStyle(
                                  color: WlsPosColor.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)))
                          .pOnly(top: 20, bottom: 2)
                          : Container(),
                      listBetAmount.isNotEmpty
                          ? Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 40,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: listBetAmountLength,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        if (listBetAmount[index].amount !=
                                            null) {
                                          setSelectedBetAmountForHighlighting(
                                              index);
                                          selectedBetAmountValue.clear();
                                          selectedBetAmountValue[
                                          listBetAmount[index]
                                              .amount
                                              .toString()] = true;
                                          onBetAmountClick(
                                              listBetAmount[index]
                                                  .amount!);
                                        }
                                      },
                                      customBorder:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      child: Container(
                                        width: 50,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: selectedBetAmountValue[
                                            "${listBetAmount[index].amount}"] ==
                                                true
                                                ? WlsPosColor
                                                .game_color_red
                                                : WlsPosColor.white,
                                            borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(6)),
                                            border: Border.all(
                                                color: WlsPosColor
                                                    .game_color_red)),
                                        child: Align(
                                            alignment:
                                            Alignment.center,
                                            child: Text(
                                                "${listBetAmount[index].amount}",
                                                style: TextStyle(
                                                    color: selectedBetAmountValue[
                                                    "${listBetAmount[index].amount}"] ==
                                                        true
                                                        ? WlsPosColor
                                                        .white
                                                        : WlsPosColor
                                                        .game_color_red,
                                                    fontSize: 10)))
                                            .p(4),
                                      ),
                                    ).p(2);
                                  }),
                            ),
                          ),
                          Visibility(
                            visible: isOtherAmountAvailable,
                            child: Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  if (isOtherAmountAvailable) {
                                    OtherAvailableBetAmountAlertDialog()
                                        .show(
                                        context: context,
                                        title:
                                        "Select Amount (${getDefaultCurrency(getLanguage())})",
                                        buttonText: "Select",
                                        isCloseButton: true,
                                        listOfAmounts: listBetAmount,
                                        buttonClick:
                                            (selectedBetAmount) {
                                          setState(() {
                                            selectedBetAmountValue
                                                .clear();
                                            selectedBetAmountValue[
                                            "$selectedBetAmount"] =
                                            true;
                                          });
                                          onBetAmountClick(
                                              selectedBetAmount);
                                        });
                                  }
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Ink(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: WlsPosColor.white,
                                      borderRadius:
                                      const BorderRadius.all(
                                          Radius.circular(6)),
                                      border: Border.all(
                                          color: WlsPosColor
                                              .game_color_red)),
                                  child: Stack(
                                    children: [
                                      Align(
                                          alignment: Alignment.topCenter,
                                          child: const Text("Other",
                                              style: TextStyle(
                                                  color:
                                                  WlsPosColor.red,
                                                  fontSize: 10))
                                              .pOnly(top: 5)),
                                      Align(
                                          alignment:
                                          Alignment.bottomRight,
                                          child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Lottie.asset(
                                                  'assets/lottie/tap.json'))),
                                    ],
                                  ),
                                ),
                              ).p(2),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Ink(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: WlsPosColor.game_color_red,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6)),
                                  border: Border.all(
                                      color: WlsPosColor.game_color_red)),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Align(
                                      alignment: Alignment.center,
                                      child: Text("Bet Amount",
                                          style: TextStyle(
                                              color: WlsPosColor.white,
                                              fontSize: 10))),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(selectedBetAmount,
                                          style: const TextStyle(
                                              color: WlsPosColor.white,
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.bold))),
                                ],
                              ),
                            ).p(2),
                          )
                        ],
                      )
                          : Container(),
                      listBetAmount.isNotEmpty
                          ? const HeightBox(50)
                          : Container()
                    ],
                  ).p(8),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FlipCard(
                    controller: _controller,
                    flipOnTouch: false,
                    fill: Fill.fillBack,
                    // Fill the back side of the card to make in the same size as the front.
                    direction: FlipDirection.VERTICAL,
                    // default
                    side: CardSide.FRONT,
                    // The side to initially display.
                    front: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: WlsPosColor.ball_border_light_bg,
                      child: Center(
                          child: Text(ballPickInstructions,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: WlsPosColor.game_color_grey,
                                  fontSize: 14))),
                    ),
                    back: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: WlsPosColor.ball_border_light_bg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Material(
                              child: InkWell(
                                onTap: () {
                                  reset();
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset('assets/icons/reset.svg',
                                        width: 16,
                                        height: 16,
                                        color: WlsPosColor.game_color_red)
                                        .pOnly(bottom: 2),
                                    const Align(
                                        alignment: Alignment.center,
                                        child: Text("Reset",
                                            style: TextStyle(
                                                color:
                                                WlsPosColor.game_color_grey,
                                                fontSize: 12))),
                                  ],
                                ),
                              ),
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
                                        "Bet Value (${getDefaultCurrency(getLanguage())})",
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
                                  if (selectedPickTypeObject.code
                                      ?.toUpperCase() ==
                                      "Banker".toUpperCase()) {
                                    if (betValue == "0") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("Bet Value can't be 0."),
                                      ));
                                    } else {
                                      addBet();
                                    }
                                  } else {
                                    var isApplicable = true;

                                    if (betValue == "0") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("Bet Value can't be 0."),
                                      ));
                                    } else {
                                      if (isApplicable) {
                                        addBet();
                                      }
                                    }
                                  }
                                },
                                child: Ink(
                                  color: WlsPosColor.game_color_red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset('assets/icons/plus.svg',
                                          width: 16,
                                          height: 16,
                                          color: WlsPosColor.white),
                                      const Align(
                                          alignment: Alignment.center,
                                          child: Text("ADD BET",
                                              style: TextStyle(
                                                  color: WlsPosColor.white,
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
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PickType> getPickTypeWithQp({BetRespVOs? betRespVOs}) {
    List<PickType>? originalPickType = betRespVOs != null
        ? betRespVOs.pickTypeData?.pickType
        : widget.pickType;
    List<PickType> newPickType = [];

    if (originalPickType != null) {
      for (PickType model in originalPickType) {
        newPickType.add(model);
        // loop for rangeObjectIndex
        if(model.range?[0].qpAllowed?.toUpperCase() == "yes".toUpperCase()) {
          var qpData                    = PickType();
          qpData.code                   = model.code;
          qpData.description            = model.description;
          if (model.name?.toUpperCase() == "Manual".toUpperCase()) {
            qpData.name                 = "QP";

          } else {
            qpData.name                 = "${model.name} QP";
          }

          List<Range1> rangeList = model.range ?? [];
          List<Range1> totalRangeList   = [];

          for(int i=0; i < rangeList.length; i++) {
            var range = Range1();
            range.pickValue             = model.range?[i].pickValue;
            range.qpAllowed             = model.range?[i].qpAllowed;
            range.pickCount             = model.range?[i].pickCount;
            range.pickConfig            = model.range?[i].pickConfig;
            range.pickMode              = "QP";

            totalRangeList.add(range);
          }

          qpData.range                  = totalRangeList;
          newPickType.add(qpData);
        }
      }
    }

    return newPickType;
  }

  setBetAmount() {
    if (selectedBetTypeData != null) {
      double unitPrice = selectedBetTypeData?.unitPrice ?? 1.0;
      int maxBetAmtMul = selectedBetTypeData?.maxBetAmtMul ?? 0;
      int count = maxBetAmtMul ~/ unitPrice;
      if (count > 0) {
        for (int index = 1; index <= count; index++) {
          int amount = (index * unitPrice).toInt();
          FiveByNinetyBetAmountBean model = FiveByNinetyBetAmountBean();
          model.amount = amount;
          model.isSelected = false;
          listBetAmount.add(model);
        }

        if (listBetAmount.isNotEmpty) {
          setSelectedBetAmountForHighlighting(0);
          int amtListLength = listBetAmount.length;
          int amtListHalfLength = amtListLength ~/ 2;
          setState(() {
            listBetAmountLength =
            amtListLength > 5 ? amtListHalfLength : amtListLength;

            if (listBetAmount.length > 5) {
              isOtherAmountAvailable = true;
            } else if (listBetAmount.length == 5) {
              isOtherAmountAvailable = false;
            } else if (listBetAmount.length == 4) {
              isOtherAmountAvailable = false;
            } else if (listBetAmount.length == 3) {
              isOtherAmountAvailable = false;
            } else if (listBetAmount.length == 2) {
              isOtherAmountAvailable = false;
            } else if (listBetAmount.length == 1) {
              isOtherAmountAvailable = false;
            }
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBar(context);
        });
      }
    }
  }

  void showSnackBar(context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(
      backgroundColor: WlsPosColor.game_color_red,
      duration: Duration(seconds: 1),
      content: Text("Bet amounts list is empty !"),
    ))
        .closed
        .then((reason) {
      if (reason == SnackBarClosedReason.timeout) {
        showSnackBar(context);
      }
    });
  }

  setSelectedBetAmountForHighlighting(int position) {
    if (listBetAmount.isNotEmpty) {
      for (int index = 0; index < listBetAmount.length; index++) {
        listBetAmount[index].isSelected = position == index;
      }
    }
  }

  onBetAmountClick(int amount) {
    if(widget.betCode != null ){
      setState(() {
        selectedBetAmount = amount.toString();
      });
      betValue = "0";
      if(listOfSelectedNosMap.isNotEmpty == true) {
          List<String> listOfDefaultSelectedBalls = listOfSelectedNosMap["0"] ?? [];
          if(listOfDefaultSelectedBalls.isNotEmpty) {
            for (var _ in listOfDefaultSelectedBalls) { betValueCalculation(0); }
          }
      }
    } else {
      setState(() {
        selectedBetAmount = amount.toString();
      });
      betValueCalculation(mRangeObjectIndex);
    }
  }

  betValueCalculation(int rangeObjectIndex) {
    {
      var listOfSelectedNosMapLength =
          listOfSelectedNosMap["$rangeObjectIndex"]?.length ?? 0;
      if (listOfSelectedNosMapLength >= 1) {
        if (widget.particularGameObjects?.familyCode?.toUpperCase() ==
            "MultiSet".toUpperCase()) {
          if (isPowerBallPlus) {
            int amount = (int.parse(selectedBetAmount) * 1) * 2;
            setState(() {
              betValue = "$amount";
            });
          } else {
            int amount = (int.parse(selectedBetAmount) * 1);
            setState(() {
              betValue = "$amount";
            });
          }
        } else {
          int amount = int.parse(selectedBetAmount);
          if (widget.betCode != null) {
            setState(() {
              betValue = "${int.parse(betValue) + amount}";
            });

          } else {
            setState(() {
              betValue = "$amount";
            });
          }

        }
      } else {
        setState(() {
          betValue = "0";
        });
      }
    }
  }

  selectedPickTypeData(PickType mPickType) {
    log("-------> PickType Name : ${mPickType.name}");
    setState(() {
      selectedPickTypeObject = mPickType;
      ballPickInstructions = mPickType.description ?? "";
      selectedPickType.clear();
      selectedPickType[mPickType.name ?? ""] = true;
      reset();

      if (mPickType.name?.toUpperCase().contains("QP") ?? false) {
        setNoPickLimits(mPickType);

        List<Range1> pickTypeRangeList = mPickType.range ?? [];
        if (pickTypeRangeList.isNotEmpty) {
        //  for (int i = 0; i < pickTypeRangeList.length; i++) {
          int i = 0;
            var minSLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
            var maxSLimit = ballPickingLimits["$i"]?["maxSelectionLimit"] ?? 0;
            log("rangeObjectIndex : $i | minLimit : $ballPickingLimits | maxLimit : $ballPickingLimits");
            if (minSLimit == maxSLimit) {
              qpGenerator(
                  widget.particularGameObjects?.numberConfig?.range?[i].ball ??
                      [],
                  maxSLimit,
                  rangeObjectIndex: i);
            }
         // }
        }
      } else {
        setNoPickLimits(selectedPickTypeObject);
      }
    });
  }

  List<QuickPickBetAmountBean> setPermQpList({int rangeObjectIndex = 0}) {
    var mMinSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["minSelectionLimit"] ?? 0;
    var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
    listQuickPick.clear();
    for (int count = mMinSelectionLimit; count <= mMaxSelectionLimit; count++) {
      QuickPickBetAmountBean model = QuickPickBetAmountBean();
      model.number = count;
      model.isSelected = false;
      listQuickPick.add(model);
    }

    return listQuickPick;
  }

  List<Range1> getPermRangeList(PickType mPickType) {
    List<Range1> pickTypeRange = mPickType.range ?? [];
    return pickTypeRange;
  }

  setNoPickLimits(PickType pickType) {
    List<Range1> range1 = pickType.range ?? [];
    if (range1.isNotEmpty) {
      for (int i = 0; i < range1.length; i++) {
        setState(() {
          ballPickingLimits["$i"] = {
            "minSelectionLimit":
                int.parse(range1[i].pickCount?.split(",")[0].toString() ?? "0"),
            "maxSelectionLimit":
                int.parse(range1[i].pickCount?.split(",")[1].toString() ?? "0"),
          };
        });
      }
      log("ballPickingLimits:: $ballPickingLimits");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("No Pick Type Available."),
      ));
    }
  }

  switchToPickType(String pickCode) {
    if (selectedBetTypeData != null) {
      List<PickType> pickTypeList =
      getPickTypeWithQp(betRespVOs: selectedBetTypeData);
      setState(() {
        for (int index = 0; index < pickTypeList.length; index++) {
          PickType pickedType = pickTypeList[index];
          if (pickedType.code?.toUpperCase() == pickCode.toUpperCase()) {
            ballPickInstructions = pickedType.description ?? "";
            selectedPickTypeObject = pickedType;
            setNoPickLimits(pickTypeList[index]);
            selectedPickTypeData(getPickTypeWithQp()[index]);
            break;
          }
        }
      });
    }
  }

  reset() {
    setState(() {
      for (int i = 0; i < listOfSelectedNosMap.length; i++) {
        var listOfSelectedNosList = listOfSelectedNosMap["$i"] ?? [];
        listOfSelectedNosList.clear();
      }

      isUpperLine = true;
      betValue = "0";
      lowerLineBankerPickedNoIndex = 0;
      upperLineBankerPickedNoIndex = 0;
      if (_controller.state?.isFront == false) {
        _controller.state?.toggleCard();
      }
    });
  }

  bool isBallAvailable(List<String> ballList, int index, int rangeObjectIndex) {
    if (ballList.contains(listOfBalls[index])) {
      return true;
    }
    return false;
  }

  Color getBallColor(List<String> ballList, int index) {
    var colorName = "";
    if (ballList.contains(listOfBalls[index])) {
      colorName = "RED";
    } else {
      colorName = "";
    }
    return getColors(colorName) ?? Colors.transparent;
  }

  bool isBankerBallNoAvailable(
      List<BankerBean> ballList, int index, int rangeObjectIndex) {
    var ballDetails = ballList
        .where((element) =>
    element.number ==
        widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex]
            .ball?[index].number)
        .toList();

    if (ballDetails.isNotEmpty) {
      return true;
    }
    return false;
  }

  Color getBallBankersNoColor(
      List<BankerBean> ball, int index, int rangeObjectIndex) {
    var colorName = "";

    var ballDetails = ball
        .where((element) =>
    element.number ==
        widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex]
            .ball?[index].number)
        .toList();
    if (ballDetails.isNotEmpty) {
      if (ballDetails[0].color.isNotEmptyAndNotNull) {
        colorName = ballDetails[0].color ?? "";
      } else {
        colorName = "NO_COLOR";
      }
    }
    return getColors(colorName) ?? Colors.transparent;
  }

  Color? getColors(String colorName) {
    switch (colorName.toUpperCase()) {
      case "PINK":
        return WlsPosColor.game_color_pink;
      case "RED":
        return WlsPosColor.game_color_red;
      case "ORANGE":
        return WlsPosColor.game_color_orange;
      case "BROWN":
        return WlsPosColor.game_color_brown;
      case "GREEN":
        return WlsPosColor.game_color_green;
      case "CYAN":
        return WlsPosColor.game_color_cyan;
      case "BLUE":
        return WlsPosColor.game_color_blue;
      case "MAGENTA":
        return WlsPosColor.game_color_magenta;
      case "GREY":
        return WlsPosColor.game_color_grey;
      case "BLACK":
        return WlsPosColor.black;
      case "NO_COLOR":
        return WlsPosColor.tangerine;
      default:
        return Colors.transparent;
    }
  }

  setInitialValues() {
    selectedPickType = {widget.pickType![0].code ?? "Manual": true};
    selectedBetTypeData = widget.betRespV0s!;
    ballPickInstructions = widget.pickType?[0].description ?? "";

    ballObjectsRange = widget.particularGameObjects?.numberConfig?.range ?? [];
    var ballObjectsRangeLength = ballObjectsRange?.isNotEmpty == true
        ? ballObjectsRange?.length ?? 0
        : 0;
    for (int i = 0; i < ballObjectsRangeLength; i++) {
      if (ballObjectsRange?[i] != null) {
        ballObjectsMap["$i"] = ballObjectsRange![i];
      }
    }
    for (int i = 0; i < ballObjectsMap.length; i++) {
      getColorListLength(ballObjectsMap, i);
    }
  }

  checkIsPowerBallPlusEnabled() {
    List<PanelBean> powerPlusEnabledAvailable = widget.mPanelBinList
        ?.where((element) => element.isPowerBallPlus == true)
        .toList() ??
        [];
    if (powerPlusEnabledAvailable.isNotEmpty) {
      isPowerBallPlus = true;
    }
  }

  setInitialBetAmount() {
    if (listBetAmount.isNotEmpty) {
      selectedBetAmount = "${listBetAmount[0].amount ?? 0}";
      selectedBetAmountValue[listBetAmount[0].amount.toString()] = true;
    } else {
      selectedBetAmount = "0";
    }
  }

  addBet() {
    PanelBean model = PanelBean();
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
      List<BankerBean> upperLineNosObjectList = [], lowerLineNosObjectList = [];

      List<String> listLowerLine = [];
      for (BankerBean i in lowerLineNosObjectList) {
        if (i.number != null) {
          listLowerLine.add(i.number!);
        }
      }

      String? pickedValues =
          "${upperLineNosObjectList[0].number}-${listLowerLine.join(",")}";

      model.pickedValue = pickedValues;
    } else {
      String pickedValues = "";

      if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
        var listOfSelectedNosLength = listOfSelectedNosMap.length;
        List<String> pkV = [];
        for (int i = 0; i < listOfSelectedNosLength; i++) {
          var afterJoinPickedValues =
              listOfSelectedNosMap["$i"]?.join(',') ?? "";
          if (afterJoinPickedValues.isNotEmpty) {
            pkV.add(afterJoinPickedValues);
          }
        }
        pickedValues = pkV.join("#");
      } else {
        print("listOfSelectedNosMap : --------------------> $listOfSelectedNosMap");
        var listOfSelectedNosLength = listOfSelectedNosMap.length;
        for (int i = 0; i < listOfSelectedNosLength; i++) {
          pickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
        }
      }

      print("pickedValues --------------> $pickedValues");

      model.listSelectedNumber = [listOfSelectedNosMap];
      model.pickedValue = pickedValues;
      model.isPowerBallPlus = isPowerBallPlus;
    }

    model.gameName = widget.particularGameObjects?.gameName;
    model.amount = double.parse(betValue);
    model.winMode = selectedBetTypeData?.winMode;
    model.betName = selectedBetTypeData?.betDispName;
    model.pickName = selectedPickTypeObject.name;
    model.betCode = selectedBetTypeData?.betCode;
    model.pickCode = selectedPickTypeObject.code;
    model.pickConfig = selectedPickTypeObject.range?[0].pickConfig;
    model.isPowerBallPlus = isPowerBallPlus;

    if (selectedBetAmount != "0") {
      if (selectedBetTypeData?.unitPrice != null) {
        double mUnitPrice = selectedBetTypeData?.unitPrice ?? 1;
        model.betAmountMultiple = int.parse(selectedBetAmount) ~/ mUnitPrice;
      }
    }
    model.selectBetAmount = int.parse(selectedBetAmount);
    model.unitPrice = selectedBetTypeData?.unitPrice ?? 1;
    model.numberOfDraws = 1;
    model.numberOfLines = listOfSelectedNosMap["0"]?.length ?? 0;
    model.isMainBet = true;

    if (selectedPickTypeObject.name?.contains("QP") == true) {
      model.isQuickPick = true;
      model.isQpPreGenerated = true;
    } else {
      model.isQuickPick = false;
      model.isQpPreGenerated = false;
    }
    if (widget.mPanelBinList != null) {
      widget.mPanelBinList?.add(model);
    }

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(),
          )
        ],child: PickTypeScreen(
          gameObjectsList: widget.particularGameObjects,
          listPanelData: widget.mPanelBinList),)
    ));
  }

  int getColorListLength(Map<String, dynamic> ballObjectsMap, int index) {
    Range? rangeBall = ballObjectsMap["$index"];
    List<Ball>? ballList = rangeBall?.ball ?? [];
    lotteryGameColorList.clear();
    if (ballList.isNotEmpty) {
      for (Ball ballDetails in ballList) {
        if (ballDetails.color != null && ballDetails.color != "") {
          if (getColors(ballDetails.color!) != null) {
            if (!lotteryGameColorList.contains(getColors(ballDetails.color!))) {
              lotteryGameColorList.add(getColors(ballDetails.color!));
            }
          }
        }
      }
      return lotteryGameColorList.length;
    }
    return 0;
  }

  int getColumnCount(int index) {
    int totalBall = getMaxBallLimit(ballObjectsMap, index);
    int columnCount = 9;

    if (lotteryGameColorList.isEmpty) {
      for (int j = 7; j <= 10; j++) {
        if (totalBall % j == 0) {
          columnCount = j;
          break;
        }
      }
      return columnCount;
    } else {
      return lotteryGameColorList.length;
    }
  }

  int getMaxBallLimit(Map<String, dynamic> ballObjectsMap, int index) {
    Range? rangeBall = ballObjectsMap["$index"];

    List<Ball>? ballList = rangeBall?.ball ?? [];
    if (ballList.isNotEmpty) {
      return ballList.length;
    }
    return 0;
  }

  qpGenerator(List<Ball> numberConfig, int numbersToBeQp,
      {int rangeObjectIndex = 0}) {
    setState(() {
      mIsQpSelecting = true;
      _inOutAnimationController.forward();
    });

    for (int i = 0; i < rangeObjectIndex + 1; i++) {}
    math.Random random = math.Random();
    List<String> listOfQpNumber = [];
    while (listOfQpNumber.length < numbersToBeQp) {
      String randomNo = listOfBalls[random.nextInt(listOfBalls.length)];
      if (!listOfQpNumber.contains(randomNo)) {
        listOfQpNumber.add(randomNo);
      }
    }

    //reset();
    setState(() {
      var listOfSelectedNosList =
          listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
      listOfSelectedNosList.clear();
    });

    setQpDelay(listOfQpNumber, rangeObjectIndex: rangeObjectIndex);
  }

  setQpDelay(List<String> listOfQpNumber, {rangeObjectIndex = 0}) {
    Timer(const Duration(seconds: 1), () {
      setState(() {
        mIsQpSelecting = false;
        for (String i in listOfQpNumber) {
          var listOfSelectedNosList =
              listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
          listOfSelectedNosList.add(i.length == 1 ? "0$i" : i);
          listOfSelectedNosMap["$rangeObjectIndex"] = listOfSelectedNosList;
        }
        if (listOfSelectedNosMap["$rangeObjectIndex"]?.isNotEmpty == true) {
          if (_controller.state?.isFront == true) {
            _controller.toggleCard();
          }
        }
      });
      betValueCalculation(rangeObjectIndex);
    });
  }

  // String checkValidChar(String? input) {
  //   var validString = "";
  //   input?.split('#').forEach((ch) => {
  //     if (ch != "-1") {validString = validString + ch}
  //   });
  //   return validString;
  // }

  defaultSelectionFor2DMyanmarBalls(String betCode) {
    switch(betCode) {
      case "2D-Couple-Number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if (ballNumber[0] == ballNumber[1]) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
      case "2D-Brother-Number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if (int.parse(ballNumber[0]) == (int.parse(ballNumber[1]) - 1) || ((int.parse(ballNumber[0]) == 9) && (int.parse(ballNumber[1]) == 0)) ) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
      case "2D-Even-Even-Number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if ((int.parse(ballNumber[0]) % 2 == 0) && (int.parse(ballNumber[1]) % 2 == 0)) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
      case "2D-Even-Odd-Number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if ((int.parse(ballNumber[0]) % 2 == 0) && (int.parse(ballNumber[1]) % 2 != 0)) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
      case "2D-Odd-Odd-Number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if ((int.parse(ballNumber[0]) % 2 != 0) && (int.parse(ballNumber[1]) % 2 != 0)) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
      case "2D-Odd-Even-Number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if ((int.parse(ballNumber[0]) % 2 != 0) && (int.parse(ballNumber[1]) % 2 == 0)) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
      case "2D-series-number": {
        setState(() {
          listOfSelectedNosMap.clear();
          List<String> revisedListOfBalls = listOfSelectedNosMap["0"] ?? [];
          for(String ballNumber in listOfBalls) {
            if(ballNumber.length > 1) {
              if (int.parse(ballNumber[0]) == widget.selectedSeriesNumber) {
                revisedListOfBalls.add(ballNumber);
                listOfSelectedNosMap["0"] = revisedListOfBalls;
                betValueCalculation(0);
              }
            }
          }
        });
        break;
      }
    }

   WidgetsBinding.instance.addPostFrameCallback((_) {
     if (listOfSelectedNosMap["0"]?.isNotEmpty == true) {
       if (_controller.state?.isFront == true) {
         _controller.toggleCard();
       }
     }
    });
  }
}