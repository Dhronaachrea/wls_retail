import 'dart:async';
import 'dart:convert';
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
import 'package:wls_pos/lottery/bloc/lottery_bloc.dart';
import 'package:wls_pos/lottery/models/request/saleRequestBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/pick_type_screen.dart';
import 'package:wls_pos/lottery/preview_game_screen.dart';
import 'package:wls_pos/lottery/widgets/added_bet_cart_msg.dart';
import 'package:wls_pos/lottery/widgets/grand_prize_widget.dart';
import 'package:wls_pos/lottery/widgets/other_available_bet_amounts.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import '../login/bloc/login_bloc.dart';
import '../utility/app_constant.dart';
import '../utility/utils.dart';
import '../utility/widgets/show_snackbar.dart';
import 'models/otherDataClasses/bankerBean.dart';
import 'models/otherDataClasses/betAmountBean.dart';
import 'models/otherDataClasses/quickPickBetAmountBean.dart';

/*
    created by Rajneesh Kr.Sharma on 7 May, 23
*/

class GameScreen extends StatefulWidget {
  final GameRespVOs? particularGameObjects;
  final List<PickType>? pickType;
  final BetRespVOs? betRespV0s;
  List<PanelBean>? mPanelBinList;
  List<List<PanelData>?>? mapThaiLotteryPanelBinList;

  GameScreen({Key? key, this.particularGameObjects, this.pickType, this.betRespV0s, this.mPanelBinList, this.mapThaiLotteryPanelBinList}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Ball? ball;
  Color? upperLineBallColor;
  late PickType selectedPickTypeObject;
  late BetRespVOs? selectedBetTypeData;
  late FlipCardController _controller;
  late FlipCardController _pickController;
  late final AnimationController _inOutAnimationController;
  late final Animation<double> _inOutAnimation;
  late final Animation<double> _inOutOffAnimation;

  List<Color?> lotteryGameColorList                                 = [];
  int maxSelectionLimit = 0, minSelectionLimit                      = 0;
  Map<String, Map<String, int>> ballPickingLimits                   = {};
  Map<String, List<String>> listOfSelectedNosMap                    = {};
  Map<String, List<BankerBean>>listOfSelectedUpperLowerLinesNosMap  = {};
  String selectedBetAmount                                          = "0";
  String betValue                                                   = "0";
  List<FiveByNinetyBetAmountBean> listBetAmount                     = [];
  int listBetAmountLength                                           = 0;
  List<QuickPickBetAmountBean> listQuickPick                        = [];
  bool mIsQpSelecting                                               = false;
  Map<String,bool> selectedPickType                                 = {};                          ////////////////////////////////////////
  Map<String,bool> selectedBetAmountValue                           = {};                          ////////////////////////////////////////
  String ballPickInstructions                                       = "Please select numbers";
  bool mIsToggleAllowed                                             = false;
  bool isOtherAmountAvailable                                       = false;
  bool isBankerPickType                                             = false;
  bool isUpperLine                                                  = true;
  int lowerLineBankerPickedNoIndex
  = 0;
  int upperLineBankerPickedNoIndex                                  = 0;
  int mRangeObjectIndex                                             = 0;
  int mMultiplePickTypeIndex                                        = 0;
  bool isMultiplePickType                                           = false;
  bool isPowerBallPlus                                              = false;
  List<Range>? ballObjectsRange                                     = [];
  Map<String, Range> ballObjectsMap                                 = {};
  var lotteryGameMainBetList                                        = [];
  var lotteryGameSideBetList                                        = [];
  List<PanelBean>? mPanelBinListTemp = [];
  bool isEdit = false;
  PanelBean? editPanelBeanData;


  ///////////////////  Thai Lottery  ////////////////////////
  TextEditingController permController          =  TextEditingController();
  Map<String, String> selectedNumberAndSlabList = {};
  List<SlabInfo>? slabList          = [];
  List<int> numberList              = <int>[]; // checking

  var colorList                     = [ WlsPosColor.game_color_red,
    WlsPosColor.game_color_blue,
    WlsPosColor.game_color_magenta,
    WlsPosColor.game_color_orange,
    WlsPosColor.game_color_green,
    WlsPosColor.game_color_cyan ];
  Iterable<BetWise>? pickedNoList;
  Iterable<MatchDetail>? slabDataList;
  Map<String,dynamic> slabColorMap          = <String,dynamic>{};
  List<List<String>> panelNumberList        = [];
  List<String> numList                      = [];
  List<String> shownPanelList               = [];
  List<Slabs> currentSlabList               = [];
  int activeRangeButtonIndex                = 0;
  List<PanelData>? mThaiLotteryPanelBinList = [];
  int alreadySelectedPanelsCount            = 0;
  int maxPanelAllowed                       = 0;
  bool isRangePanelShown                    = true;
  bool isLabelExistsInNumberConfig          = false;
  bool isDoubleJackpotEnabled               = false;
  bool isSecureJackpotEnabled               = false;
  double? doubleJackpotCost                  = 0;
  double? secureJackpotCost                  = 0;

  @override
  void initState() {
    super.initState();

    // ⚠️Please don't disturb the order. ️

    _controller               = FlipCardController();
    _pickController           = FlipCardController();
    getPickTypeWithQp();
    selectedPickTypeObject    = getPickTypeWithQp()[0];
    setNoPickLimits(selectedPickTypeObject);
    setInitialValues();
    checkIsPowerBallPlusEnabled();
    setBetAmount();
    setInitialBetAmount();

    pickedNoList = widget.particularGameObjects?.payoutWiseNumbersData?[0].betWise?.where((element) => element.betCode == widget.betRespV0s?.betCode);
    slabDataList = widget.particularGameObjects?.gameSchemas?.matchDetail?.where((element) => element.betType == widget.betRespV0s?.betCode);
    doubleJackpotCost =  widget.particularGameObjects?.doubleJackpot;
    secureJackpotCost =  widget.particularGameObjects?.secureJackpot;

    // var totalNumbers;
    setState((){
      for(List<PanelData>? models in widget.mapThaiLotteryPanelBinList ?? []) {
        alreadySelectedPanelsCount += models?.length ?? 0;
      }
      maxPanelAllowed = widget.particularGameObjects?.maxPanelAllowed ?? 0;

      pickedNoList?.forEach((element) {
        element.slabs?.forEach((slabList) {
          numList += slabList.numbers ?? [];
        });
        numList.sort();
        currentSlabList = element.slabs ?? [];
        numberList = (element.slabs?[0].numbers ?? []).map(int.parse).toList().sortedByNum((element) => element);
      });
      slabDataList?.forEach((element) {
        slabList = element.slabInfo;
      });
      // creating color map corresponding to slabs
      for(int i=0; i< (slabList?.length ?? 0); i++) {
        if(slabList?[i].slabPrizeValue != null) {
          slabColorMap[slabList![i].slabPrizeValue.toString()] = colorList[i];
        }
      }

      if (numList.length >=100) {
        for( int i=0; i<((numList.length ~/ 100) <= 1 ?  1 : (numList.length ~/ 100)); i++) {
          panelNumberList.add(numList.sublist((i*100),(i*100 + 100)));
        }
        if (panelNumberList.isNotEmpty) {
          shownPanelList = panelNumberList[0];
        }
      } else {
        shownPanelList = numberList.map((e) => e.toString()).toList();
      }

      permController.addListener(() {
        if (permController.text.isNotEmpty) {
          isRangePanelShown = false;
          String inputNo = permController.text.trim();
          if(inputNo.length == 3) {
            shownPanelList = [inputNo];
          } else {
            if (inputNo.length == 2){
              shownPanelList = ["0$inputNo"];
            } else {
              shownPanelList = ["00$inputNo"];
            }
          }
        } else {
          isRangePanelShown = true;
          if (numList.length >=100) {
            for( int i=0; i<((numList.length ~/ 100) <= 1 ?  1 : (numList.length ~/ 100)); i++) {
              panelNumberList.add(numList.sublist((i*100),(i*100 + 100)));
            }
            if (panelNumberList.isNotEmpty) {
              shownPanelList = panelNumberList[0];
            }
          } else {
            shownPanelList = numberList.map((e) => e.toString()).toList();
          }
        }
      });

      // print("panelNumberList====>>>>>>>>>>>>${panelNumberList}");
      print("panelNumberList.l====>>>>>>>>>>>>${panelNumberList.length}");
      isLabelExistsInNumberConfig = widget.particularGameObjects?.numberConfig?.range?[0].ball?.where((element) => element.label?.isNotEmpty == true).toList().isNotEmpty == true;
      print("isLabelExistsInNumberConfig: $isLabelExistsInNumberConfig");

    });

    _inOutAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _inOutAnimation           = Tween<double>(begin: 1, end: 0.85)
        .animate(_inOutAnimationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _inOutAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _inOutAnimationController.forward();
        }
      });

    _inOutOffAnimation = Tween<double>(begin: 1, end: 1)
        .animate(_inOutAnimationController);
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
        return widget.mPanelBinList == null || widget.mPanelBinList?.isEmpty == true;
      },
      child: WlsPosScaffold(
        showAppBar: true,
        onBackButton: (widget.mPanelBinList == null || widget.mPanelBinList?.isEmpty == true) ? null : () {
          AddedBetCartMsg().show(context: context, title: "Bet on cart !", subTitle: "You have some item in your cart. If you leave the game your cart will be cleared.", buttonText: "CLEAR", isCloseButton: true, buttonClick: () {
            Navigator.of(context).pop();
          });
        },
        drawer: WlsPosDrawer(drawerModuleList: const []),
        backgroundColor: WlsPosColor.white,
        appBarTitle: Text(getPicDisplayName(widget.betRespV0s?.betDispName ?? "NA"), style: const TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: mIsQpSelecting,
            child: Stack(
              children: [
                SingleChildScrollView(
                child: (widget.betRespV0s?.betCode?.toUpperCase().contains("3D") == true ||
                    widget.betRespV0s?.betCode?.toUpperCase().contains("2D") == true ||
                    widget.betRespV0s?.betCode?.toUpperCase().contains("1D") == true )
                    ? Column(
                  children: [
                    Column(
                      children: [
                        (widget.betRespV0s?.betCode?.toUpperCase().contains("3D") == true)
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: permController,
                                cursorColor: WlsPosColor.brownish_grey,
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                decoration: const InputDecoration(
                                    labelText: 'Find Number',
                                    labelStyle: TextStyle(
                                        color: WlsPosColor.brownish_grey
                                    ),
                                    counterText: "",
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: WlsPosColor.brownish_grey
                                        )
                                    )
                                ),
                              ),
                            ),
                            const WidthBox(10),
                            InkWell(
                              onTap: () {
                                // perm button
                                setState((){
                                  shownPanelList = getAllPossibleCombinations(permController.text.trim());
                                });

                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Ink(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.red,
                                ),
                                child: const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Perm",
                                    style: TextStyle(
                                        color: WlsPosColor.white
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).p(10)
                            : Container(),

                        ((numList.length ~/ 100) > 0)
                            ? ((numList.length ~/ 100) != 1)
                            ? isRangePanelShown
                                ? Column(
                                      children: [
                                        dottedLine(),
                                        const HeightBox(10),
                                        GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: isLandscape ? 3 : 2.5,
                                                crossAxisCount: isLandscape ? 7 : 4,
                                              ),
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: (numList.length ~/ 100) == 1 ? 0 : (numList.length ~/ 100),
                                              itemBuilder: (BuildContext context, int index) {
                                                return AnimationConfiguration.staggeredGrid(
                                                  position: index,
                                                  duration: const Duration(milliseconds: 250),
                                                  columnCount: 1,
                                                  child: SlideAnimation(
                                                    horizontalOffset: 50,
                                                    curve: Curves.easeIn,
                                                    child: Ink(
                                                      height: 30,
                                                      width: 30,
                                                      decoration: const BoxDecoration(
                                                          color: WlsPosColor.white,
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10),
                                                          )
                                                      ),
                                                      child: InkWell(
                                                        onTap: (){
                                                          setState((){
                                                            print("click index--------------->$index");
                                                            permController.clear();
                                                            activeRangeButtonIndex = index;
                                                            shownPanelList = panelNumberList[index];
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                              color: (activeRangeButtonIndex == index) ? WlsPosColor.game_color_red : WlsPosColor.white,
                                                              borderRadius: BorderRadius.circular(6),
                                                              border: Border.all( color: WlsPosColor.game_color_red, width: 1)
                                                          ),
                                                          child: Align(
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                  "${panelNumberList[index].isNotEmpty ? panelNumberList[index][0] : 0} - ${panelNumberList[index][panelNumberList[index].length - 1]}",
                                                                  style: TextStyle(
                                                                      fontSize: isLandscape ? 18 : 15,
                                                                      color: (activeRangeButtonIndex == index) ? WlsPosColor.white : WlsPosColor.game_color_red
                                                                  )
                                                              )
                                                          ),
                                                        ).p(1),
                                                      ),
                                                    ),
                                                  ),
                                                ).p(isLandscape ? 8 : 0);
                                              }
                                        ),
                                      ],
                                    )
                                : Container()
                            : Container()
                            : Container(),

                        dottedLine(),
                        const HeightBox(10),

                        GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 2.7,
                                crossAxisCount: isLandscape ? 7 : 3,
                                crossAxisSpacing: 10
                            ),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: slabList?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 250),
                                columnCount: 1,
                                child: SlideAnimation(
                                  horizontalOffset: 50,
                                  curve: Curves.easeIn,
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                        color: WlsPosColor.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        )
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                              color: colorList[index]
                                          ),
                                        ),
                                        const WidthBox(5),
                                        Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                "x${formatSlab((slabList?[index].slabPrizeValue ?? 0).toString())} pays",
                                                style:const TextStyle(color:Colors.black)
                                            )
                                        ),
                                      ],
                                    ),
                                  ).p(1),
                                ),
                              );
                            }
                        ),

                        dottedLine(),
                        const HeightBox(10),

                        AnimationLimiter(
                          child: Container(
                            width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                            child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: isLandscape ? 1 : 0.95,
                                  crossAxisCount: 10,
                                ),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:(shownPanelList.length <= 100) ? shownPanelList.length : 100,
                                itemBuilder: (BuildContext context, int index) {
                                  return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration: const Duration(milliseconds: 100),
                                      columnCount: 100,
                                      child: FlipAnimation(
                                        flipAxis: FlipAxis.y,
                                        curve: Curves.decelerate,
                                        child: FadeInAnimation(
                                          child: ScaleTransition(
                                            scale: mIsQpSelecting ? _inOutAnimation : _inOutOffAnimation,
                                            child: InkWell(
                                                onTap: () {
                                                  setState((){
                                                    if (selectedNumberAndSlabList.containsKey(shownPanelList[index])) {
                                                      selectedNumberAndSlabList.remove(shownPanelList[index]);

                                                    } else {
                                                      if ((alreadySelectedPanelsCount + selectedNumberAndSlabList.length) < maxPanelAllowed) {
                                                        print("current slab ==================>${shownPanelList[index]} ---> ${getCurrentSlab(shownPanelList[index]).toString()}");
                                                        selectedNumberAndSlabList[shownPanelList[index]] = getCurrentSlab(shownPanelList[index]).toString();

                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              duration: const Duration(seconds: 1),
                                                              content: Text("You can only select $maxPanelAllowed numbers."),
                                                            )
                                                        );

                                                      }
                                                    }


                                                    if (selectedNumberAndSlabList.isNotEmpty){
                                                      if (_controller.state?.isFront == true) {

                                                        _controller.toggleCard();
                                                      }
                                                    } else {
                                                      if (_controller.state?.isFront == false) {
                                                        _controller.toggleCard();
                                                      }
                                                    }

                                                    betValueCalculation(index);
                                                  });

                                                },
                                                customBorder: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                            border: Border.all(color: WlsPosColor.ball_border_bg, width: 1),
                                                            color: (selectedNumberAndSlabList.containsKey(shownPanelList[index]))
                                                                ? (slabColorMap.containsKey(getCurrentSlab(shownPanelList[index]).toString())
                                                                ? slabColorMap[getCurrentSlab(shownPanelList[index]).toString()]
                                                                : WlsPosColor.yellow_orange_three)
                                                                : WlsPosColor.transparent

                                                        ),
                                                        child: Center(child:
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                                shownPanelList[index],
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: (selectedNumberAndSlabList.containsKey(shownPanelList[index])) ? WlsPosColor.white : WlsPosColor.ball_border_bg,
                                                                    fontSize: isLandscape ? 18 : 12,
                                                                    fontWeight: FontWeight.w400
                                                                )
                                                            ),
                                                            (selectedNumberAndSlabList.containsKey(shownPanelList[index])) ? Text(
                                                                "x${formatSlab(getCurrentSlab(shownPanelList[index]).toString())} pays",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: WlsPosColor.app_bg,
                                                                    fontSize: isLandscape ? 11 : 5,
                                                                    fontWeight: FontWeight.w400
                                                                )
                                                            ) : Container(),
                                                          ],
                                                        )),
                                                      ),
                                                      Positioned(
                                                          top: -2, //change  according to your use case position
                                                          right: -3,// change  according to your use case position
                                                          child: RotationTransition(
                                                            turns: const AlwaysStoppedAnimation(45/360),
                                                            child: Container(
                                                              height: 10,
                                                              width: 13,
                                                              decoration: BoxDecoration(
                                                                color: (slabColorMap[(getCurrentSlab(shownPanelList[index])).toString()]),
                                                                borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                              ),
                                                            ),
                                                          )
                                                      ),
                                                    ]
                                                ).p(2)
                                            ),
                                          ),
                                        ),
                                      )
                                  );
                                }
                            ),
                          ),
                        ),
                      ],
                    ).pOnly(bottom: 2),

                    listBetAmount.isNotEmpty
                        ? Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Bet Amount (${getDefaultCurrency(getLanguage())})",
                                style: const TextStyle(
                                    color: WlsPosColor.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14
                                )
                            )
                        ).pOnly(top: 20, bottom: 2),
                        Row(
                          children: [
                            SizedBox(
                              height: isLandscape ? 55 : 40,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: listBetAmountLength,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        if (listBetAmount[index].amount != null) {
                                          setSelectedBetAmountForHighlighting(index);
                                          selectedBetAmountValue.clear();
                                          selectedBetAmountValue[listBetAmount[index].amount.toString()] = true;
                                          onBetAmountClick(listBetAmount[index].amount!);
                                        }
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Container(
                                        width: isLandscape ? 60 : 50,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: selectedBetAmountValue["${listBetAmount[index].amount}"] == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                                            border: Border.all(color: WlsPosColor.game_color_red)
                                        ),
                                        child: Align(alignment: Alignment.center, child: Text("${listBetAmount[index].amount}", style: TextStyle(color: selectedBetAmountValue["${listBetAmount[index].amount}"] == true ? WlsPosColor.white : WlsPosColor.game_color_red, fontSize: isLandscape ? 18 : 10))).p(4),
                                      ),
                                    ).p(2);

                                  }),
                            ),

                            isLandscape
                                ? Visibility(
                                  visible: isOtherAmountAvailable,
                                  child: InkWell(
                              onTap: () {
                                  if(isOtherAmountAvailable) {
                                    OtherAvailableBetAmountAlertDialog().show(context: context, title: "Select Amount (${getDefaultCurrency(getLanguage())})", buttonText: "Select", isCloseButton: true, listOfAmounts: listBetAmount, buttonClick: (selectedBetAmount) {
                                      setState(() {
                                        selectedBetAmountValue.clear();
                                        selectedBetAmountValue["$selectedBetAmount"] = true;
                                      });
                                      onBetAmountClick(selectedBetAmount);
                                    });
                                  }
                              },
                              customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                              ),
                              child: Ink(
                                  width: 110,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: WlsPosColor.white,
                                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                                      border: Border.all(color: WlsPosColor.game_color_red)
                                  ),
                                  child: Stack(
                                    children: [
                                      const Align(alignment: Alignment.center, child: Text("Other", style: TextStyle(color: WlsPosColor.red, fontSize: 15))),
                                      Align(
                                          alignment: Alignment.bottomRight,
                                          child:
                                          SizedBox(width: 30, height: 30, child: Lottie.asset('assets/lottie/tap.json'))
                                      ),
                                    ],
                                  ),
                              ),
                            ).p(2),
                                )
                                : Visibility(
                              visible: isOtherAmountAvailable,
                              child: Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    if(isOtherAmountAvailable) {
                                      OtherAvailableBetAmountAlertDialog().show(context: context, title: "Select Amount (${getDefaultCurrency(getLanguage())})", buttonText: "Select", isCloseButton: true, listOfAmounts: listBetAmount, buttonClick: (selectedBetAmount) {
                                        setState(() {
                                          selectedBetAmountValue.clear();
                                          selectedBetAmountValue["$selectedBetAmount"] = true;
                                        });
                                        onBetAmountClick(selectedBetAmount);
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
                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                                        border: Border.all(color: WlsPosColor.game_color_red)
                                    ),
                                    child: Stack(
                                      children: [
                                        const Align(alignment: Alignment.center, child: Text("Other", style: TextStyle(color: WlsPosColor.red, fontSize: 10))),
                                        Align(
                                            alignment: Alignment.bottomRight,
                                            child:
                                            SizedBox(width: 30, height: 30, child: Lottie.asset('assets/lottie/tap.json'))
                                        ),
                                      ],
                                    ),
                                  ),
                                ).p(2),
                              ),
                            ),


                            isLandscape
                                ? Ink(
                              width: 110,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: WlsPosColor.game_color_red,
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: WlsPosColor.game_color_red)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Align(alignment: Alignment.center, child: Text("Bet Amount", style: TextStyle(color: WlsPosColor.white, fontSize: 15))),
                                  Align(alignment: Alignment.center, child: Text(selectedBetAmount, style: const TextStyle(color: WlsPosColor.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ).p(2)
                                : Expanded(
                              flex: 1,
                              child: Ink(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: WlsPosColor.game_color_red,
                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                    border: Border.all(color: WlsPosColor.game_color_red)
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Align(alignment: Alignment.center, child: Text("Bet Amount", style: TextStyle(color: WlsPosColor.white, fontSize: 10))),
                                    Align(alignment: Alignment.center, child: Text(selectedBetAmount, style: const TextStyle(color: WlsPosColor.white, fontSize: 16, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ).p(2),
                            )
                          ],
                        ),
                        const HeightBox(50)
                      ],
                    )
                        : Container(),
                  ],

                ).p(8)

                    : Column(
                  children: [
                    isLabelExistsInNumberConfig
                      ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: isLandscape? 2 : 0.85,
                          crossAxisCount: isLandscape ? 4 : 3,
                        ),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.particularGameObjects?.numberConfig?.range?[0].ball?.length ?? 1,
                        itemBuilder: (context, index) {
                          return Ink(
                            decoration: BoxDecoration(
                              color: WlsPosColor.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(color: WlsPosColor.light_grey)
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: getNoOfParticularPanelCount(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "") == 0 ? WlsPosColor.white : WlsPosColor.neon_yellow,
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        labelledGameLabelList["${widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].label?.toLowerCase()}"]?.contains("asset") == true ? SvgPicture.asset("${labelledGameLabelList["${widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].label?.toLowerCase()}"]}", width: 50, height: 50, color: WlsPosColor.shamrock_green) : Center(child: Text("${labelledGameLabelList["${widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].label?.toLowerCase()}"]}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 30))),
                                        const HeightBox(8),
                                        labelledGameLabelList["${widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].label?.toLowerCase()}"]?.contains("asset") == true ? Center(child: Text("${widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].label}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12))).pOnly(bottom:4) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(height:.5, color: WlsPosColor.black),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: getNoOfParticularPanelCount(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "") == 0 ? WlsPosColor.white : WlsPosColor.game_color_green,
                                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8))
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number != null) {
                                                deleteBetLabelledGamePanel(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "");
                                              } else {
                                                log("-----------no numbers available-----------");
                                              }
                                            },
                                            child: Center(child: SvgPicture.asset('assets/icons/minus.svg', width: 18, height: 18, color: getNoOfParticularPanelCount(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "") == 0 ? WlsPosColor.black : WlsPosColor.white)),

                                          ),
                                        ),
                                      ),
                                      Container(width:0.5, color: WlsPosColor.black),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Center(child: Text("${getNoOfParticularPanelCount(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "")}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 16))),
                                          ],
                                        ),
                                      ),
                                      Container(width:0.5, color: WlsPosColor.black),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: getNoOfParticularPanelCount(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "") == 0 ? WlsPosColor.white : WlsPosColor.game_color_green,
                                              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8))
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number != null) {
                                                setState(() {
                                                  betValue = selectedBetAmount;
                                                });
                                                var maxPanel = widget.particularGameObjects?.maxPanelAllowed ?? 0;
                                                var panelDataListLength = widget.mPanelBinList?.length ?? 0;
                                                if (panelDataListLength < maxPanel) {
                                                  addBetLabelledGamePanel(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "");

                                                } else {
                                                  ShowToast.showToast(context, "Max panel limit reached !", type: ToastType.ERROR);
                                                }
                                              } else {
                                                  log("-----------no numbers available-----------");
                                                }
                                            },
                                            child: Center(child: SvgPicture.asset('assets/icons/plus.svg', width: 18, height: 18, color: getNoOfParticularPanelCount(widget.particularGameObjects?.numberConfig?.range?[0].ball?[index].number ?? "") == 0 ? WlsPosColor.black : WlsPosColor.white)),
                                          )
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ).p(3);
                        }
                    )
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ballObjectsMap.length,
                        itemBuilder: (BuildContext context, int rangeObjectIndex) {
                          return Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: Center(child: Text(ballPickInstructions, textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 14))),
                              ),
                              // Color tiles
                              Container(
                                width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                                child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 6,
                                      crossAxisCount: getColumnCount(rangeObjectIndex),
                                    ),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: getColorListLength(ballObjectsMap, rangeObjectIndex),
                                    itemBuilder: (BuildContext context, int index) {
                                      return AnimationConfiguration.staggeredGrid(
                                        position: index,
                                        duration: const Duration(milliseconds: 250),
                                        columnCount: 1,
                                        child: SlideAnimation(
                                          horizontalOffset: 50,
                                          curve: Curves.easeIn,
                                          child: Ink(
                                            decoration: const BoxDecoration(
                                                color: WlsPosColor.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                )
                                            ),
                                            child: Container(width: 20, height: 5, decoration: BoxDecoration(color: lotteryGameColorList[index], borderRadius: BorderRadius.circular(6))),
                                          ).p(1),
                                        ),
                                      );
                                    }
                                ),
                              ),
                              AnimationLimiter(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                                  child: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: lotteryGameColorList.isNotEmpty ? lotteryGameColorList.length < 5 ? 2 : 0.95 : 0.95,
                                        crossAxisCount: getColumnCount(rangeObjectIndex),
                                      ),
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?.length ?? 0,
                                      itemBuilder: (BuildContext context, int index) {
                                        return AnimationConfiguration.staggeredGrid(
                                            position: index,
                                            duration: const Duration(milliseconds: 400),
                                            columnCount: getColumnCount(rangeObjectIndex),
                                            child: FlipAnimation(
                                              flipAxis: FlipAxis.y,
                                              curve: Curves.decelerate,
                                              child: FadeInAnimation(
                                                child: ScaleTransition(
                                                  scale: mIsQpSelecting ? _inOutAnimation : _inOutOffAnimation,
                                                  child: InkWell(
                                                    onTap: () {
                                                      ball = widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index];
                                                      betValueCalculation(rangeObjectIndex);

                                                      if (ball != null) {
                                                        if(selectedPickType.keys.first.contains("QP")) {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            duration: Duration(seconds: 1),
                                                            content: Text("Numbers cannot be picked for manually this bet type."),
                                                          ));

                                                        } else {
                                                          setState(() {
                                                            mRangeObjectIndex = rangeObjectIndex;
                                                            if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
                                                              List<BankerBean> listOfSelectedNoUpperLower = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [];
                                                              var upperLineNosList                        = listOfSelectedNoUpperLower.where((element) => element.isSelectedInUpperLine == true).toList();
                                                              var lowerLineNosList                        = listOfSelectedNoUpperLower.where((element) => element.isSelectedInUpperLine == false).toList();
                                                              List<BankerBean> lowerLineDetails           = [];

                                                              if (lowerLineNosList.isNotEmpty) {
                                                                lowerLineDetails = lowerLineNosList.where((element) => element.number == ball?.number).toList();
                                                              }

                                                              if (upperLineNosList.isNotEmpty == true && upperLineNosList[0].number == ball?.number) {
                                                                if (isUpperLine == false) {
                                                                  setState(() {
                                                                    isUpperLine = true;
                                                                  });
                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                    duration: const Duration(seconds: 1),
                                                                    content: Text("${ball?.number} assigned to upper line. Please unselect from upper line to chose for lower line"),
                                                                  ));

                                                                } else {
                                                                  upperLineBankerPickedNoIndex = index;
                                                                  listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.remove(upperLineNosList[0]);
                                                                }
                                                              }

                                                              else if (lowerLineDetails.isNotEmpty == true) {
                                                                var lowerLineDetails = lowerLineNosList.where((element) => element.number == ball?.number).toList();
                                                                if(lowerLineDetails.isNotEmpty) {
                                                                  if (isUpperLine) {
                                                                    setState(() {
                                                                      isUpperLine = false;
                                                                    });
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      duration: const Duration(seconds: 1),
                                                                      content: Text("${ball?.number} assigned to lower line. Please unselect from lower line to chose for upper line"),
                                                                    ));

                                                                  } else {
                                                                    lowerLineBankerPickedNoIndex = index;
                                                                    listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.remove(lowerLineDetails[0]);
                                                                  }
                                                                }
                                                              }

                                                              else {
                                                                if(isUpperLine) {
                                                                  setNoPickLimitsForBanker(true, selectedPickTypeObject);
                                                                  var upperLineNosList = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [];
                                                                  var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                                  if (upperLineNosList.length < mMaxSelectionLimit) {
                                                                    if(ball?.number != null) {
                                                                      List<BankerBean> addTemp = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [];
                                                                      addTemp.add(BankerBean(number: ball?.number, color: ball?.color, index: index, isSelectedInUpperLine: true));
                                                                      listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] = addTemp;
                                                                      upperLineBankerPickedNoIndex = index;
                                                                    }

                                                                  } else {
                                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                      duration: Duration(seconds: 1),
                                                                      content: Text("You have reached the maximum selection limit for Upper Line!"),
                                                                    ));
                                                                  }

                                                                } else {
                                                                  setNoPickLimitsForBanker(false, selectedPickTypeObject);
                                                                  var lowerLineNosList    = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList() ?? [];
                                                                  var mMaxSelectionLimit  = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                                  if (lowerLineNosList.length < mMaxSelectionLimit) {
                                                                    if(ball?.number != null) {
                                                                      List<BankerBean> addTemp = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [];
                                                                      addTemp.add(BankerBean(number: ball?.number, color: ball?.color, index: index, isSelectedInUpperLine: false));
                                                                      listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] = addTemp;
                                                                      lowerLineBankerPickedNoIndex = index;
                                                                    }

                                                                  } else {
                                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                      duration: Duration(seconds: 1),
                                                                      content: Text("You have reached the maximum selection limit for Lower Line!"),
                                                                    ));
                                                                  }
                                                                }
                                                              }
                                                            }
                                                            else if (listOfSelectedNosMap["$rangeObjectIndex"]?.contains(ball?.number) == true) {
                                                              listOfSelectedNosMap["$rangeObjectIndex"]?.remove(ball?.number);
                                                              /*if (selectedBetTypeData?.betCode?.toUpperCase() == "DirectFirst".toUpperCase()) {
                                                                switchToPickType("Direct1");

                                                              } else if (selectedBetTypeData?.betCode?.toUpperCase() == "Direct2".toUpperCase()) {
                                                                if (selectedPickTypeObject.name?.toUpperCase() == "QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode?.toUpperCase() == "QP".toUpperCase()) {
                                                                  switchToPickType("Direct2");
                                                                }
                                                                if (selectedPickTypeObject.name?.toUpperCase() == "Perm QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode?.toUpperCase() == "QP".toUpperCase()) {
                                                                  switchToPickType("Perm2");
                                                                }
                                                                if (selectedPickTypeObject.name?.toUpperCase() == "Banker1AgainstAll QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode == "QP".toUpperCase()) {
                                                                  switchToPickType("Banker1AgainstAll");
                                                                }

                                                              } else if (selectedBetTypeData?.betCode?.toUpperCase() == "Direct3".toUpperCase()) {
                                                                if (selectedPickTypeObject.name?.toUpperCase() == "QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode == "QP".toUpperCase()) {
                                                                  switchToPickType("Direct3");
                                                                }
                                                                if (selectedPickTypeObject.name?.toUpperCase() == "Perm QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode == "QP".toUpperCase()) {
                                                                  switchToPickType("Perm3");
                                                                }

                                                              } else if (selectedBetTypeData?.betCode?.toUpperCase() == "Direct4".toUpperCase()) {
                                                                switchToPickType("Direct4");

                                                              } else if (selectedBetTypeData?.betCode?.toUpperCase() == "Direct5".toUpperCase()) {
                                                                switchToPickType("Direct5");
                                                              }*/

                                                            }
                                                            else {
                                                              var listOfSelectedNosLength = listOfSelectedNosMap["$rangeObjectIndex"]?.length ?? 0;
                                                              var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                              if (listOfSelectedNosLength < mMaxSelectionLimit) {
                                                                if (ball?.number != null) {
                                                                  List<String> addTemp = listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
                                                                  addTemp.add(ball?.number ?? "");
                                                                  listOfSelectedNosMap["$rangeObjectIndex"] = addTemp;
                                                                  if (selectedBetTypeData?.betCode?.toUpperCase() == "Direct2".toUpperCase() && selectedPickTypeObject.name?.toUpperCase() == "Perm QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode == "QP".toUpperCase()) {
                                                                    switchToPickType("Perm2");
                                                                  }
                                                                  if (selectedBetTypeData?.betCode?.toUpperCase() == "Direct3".toUpperCase() && selectedPickTypeObject.name?.toUpperCase() == "Perm QP".toUpperCase() && selectedPickTypeObject.range?[rangeObjectIndex].pickMode == "QP".toUpperCase()) {
                                                                    switchToPickType("Perm3");
                                                                  }
                                                                }

                                                              } else {

                                                                if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
                                                                  var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                    duration: const Duration(seconds: 1),
                                                                    content: Text("Sorry, you cannot select more than $mMaxSelectionLimit numbers"),
                                                                  ));

                                                                } else {
                                                                  var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
                                                                  String msg = mMaxSelectionLimit > 1 ? "Sorry, you cannot select more than $mMaxSelectionLimit numbers for ${selectedPickTypeObject.name!}!" : "Sorry, you cannot select more than $mMaxSelectionLimit number for ${selectedPickTypeObject.name!}!";
                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                    duration: const Duration(seconds: 1),
                                                                    content: Text(msg),
                                                                  ));
                                                                }
                                                              }
                                                            }
                                                          });

                                                          if(selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
                                                            var upperLineNosList = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [];
                                                            var lowerLineNosList = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList() ?? [];

                                                            if (upperLineNosList.isEmpty && lowerLineNosList.isEmpty) {
                                                              if (_controller.state?.isFront == false) {
                                                                _controller.toggleCard();
                                                              }

                                                            } else {
                                                              if (_controller.state?.isFront == true) {
                                                                _controller.toggleCard();
                                                              }
                                                            }
                                                          } else {
                                                            var listOfSelectedNosList = listOfSelectedNosMap["$rangeObjectIndex"] ?? [];

                                                            if (widget.mPanelBinList?.isEmpty == true) {
                                                              if (listOfSelectedNosList.isNotEmpty) {
                                                                if (_controller.state?.isFront == true) {
                                                                  _controller.toggleCard();
                                                                }
                                                              } else {
                                                                var nosCounts = 0;
                                                                for(int i=0;i<listOfSelectedNosMap.length; i++) {
                                                                  if(listOfSelectedNosMap["$i"]?.isNotEmpty == true) {
                                                                    nosCounts +=1;
                                                                  }
                                                                }
                                                                if (nosCounts < 1) {
                                                                  reset();
                                                                  _controller.toggleCard();
                                                                }
                                                              }
                                                            }
                                                          }
                                                          betValueCalculation(rangeObjectIndex);
                                                        }
                                                      }
                                                      else {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                        duration: Duration(seconds: 1),
                                                        content: Text("Balls do not present !"),
                                                      ));
                                                      }
                                                    },
                                                    customBorder: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()
                                                        ? Container (
                                                      decoration: BoxDecoration(
                                                          color: isBankerBallNoAvailable(listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? getBallBankersNoColor(listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) : Colors.transparent,
                                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                          border: isBankerBallNoAvailable(listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? Border.all(color: Colors.transparent, width: 2) : Border.all(color: WlsPosColor.ball_border_bg, width: 1)
                                                      ),
                                                      child: Center(child: Text("${index+1}".length == 1 ? "0${index+1}" : "${index+1}", style: TextStyle(color: isBankerBallNoAvailable(listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? WlsPosColor.white : WlsPosColor.ball_border_bg, fontSize: isLandscape ? 18 : 12, fontWeight: isBankerBallNoAvailable(listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? FontWeight.bold : FontWeight.w400))),
                                                    )
                                                        : Container(
                                                      decoration: BoxDecoration(
                                                          color:  getBallColor(listOfSelectedNosMap["$rangeObjectIndex"] ?? [] , index, rangeObjectIndex),
                                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                          border: isBallAvailable(listOfSelectedNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? Border.all(color: Colors.transparent, width: 2) : Border.all(color: WlsPosColor.ball_border_bg, width: 1)
                                                      ),
                                                      child: Center(child: Text("${index+1}".length == 1 ? "0${index+1}" : "${index+1}", style: TextStyle(color: isBallAvailable(listOfSelectedNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? WlsPosColor.white : WlsPosColor.ball_border_bg, fontSize: isLandscape ? 18 : 12, fontWeight: isBallAvailable(listOfSelectedNosMap["$rangeObjectIndex"] ?? [], index, rangeObjectIndex) ? FontWeight.bold : FontWeight.w400))),
                                                    )
                                                    ).p(2),
                                                  ),
                                                ),
                                              ),
                                            )
                                        );
                                      }
                                  ),
                                ),
                              ),
                              ballObjectsMap.isNotEmpty
                                  ? rangeObjectIndex != ballObjectsMap.length - 1
                                    ? const Text("+", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 20, fontWeight: FontWeight.bold)).pSymmetric(v:8)
                                    : Container()
                                  : Container(),
                            ],
                          );
                        }
                    ).pOnly(bottom: 2),
                    widget.particularGameObjects?.gameCode?.toUpperCase() == "powerball".toUpperCase()
                        ? Row(
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text("Select and increase your chance to win", style: TextStyle(color: WlsPosColor.app_blue, fontWeight: FontWeight.bold, fontSize: 14))).pSymmetric(v: 4, h: 4),
                        Ink(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: isPowerBallPlus ? WlsPosColor.shamrock_green : WlsPosColor.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: isPowerBallPlus ? Border.all(color: WlsPosColor.neon_green) : Border.all(color: WlsPosColor.game_color_grey),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isPowerBallPlus ? isPowerBallPlus = false : isPowerBallPlus = true;
                                List<PanelBean> mOldPanelBean = widget.mPanelBinList ?? [];
                                for (int i =0; i< mOldPanelBean.length ; i++) {
                                  if(isPowerBallPlus) {
                                    if (widget.mPanelBinList?[i].isPowerBallPlus == true) {
                                      if (widget.mPanelBinList?[i].amount != null) {
                                        widget.mPanelBinList?[i].amount = ((widget.mPanelBinList?[i].amount)! /  2) ;
                                        widget.mPanelBinList?[i].amount = ((widget.mPanelBinList?[i].amount)! *  2) ;
                                      }

                                    } else {
                                      if (widget.mPanelBinList?[i].amount != null) {
                                        widget.mPanelBinList?[i].amount = ((widget.mPanelBinList?[i].amount)! * 2);
                                      }
                                    }
                                    widget.mPanelBinList?[i].isPowerBallPlus = true;
                                  } else {
                                    if (widget.mPanelBinList?[i].amount != null) {
                                      widget.mPanelBinList?[i].amount = ((widget.mPanelBinList?[i].amount)! / 2);
                                      widget.mPanelBinList?[i].isPowerBallPlus = false;
                                    }
                                  }
                                }
                                betValueCalculation(0);
                              });
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SvgPicture.asset("assets/icons/check.svg", width: 10, height: 10, color: WlsPosColor.white).p(4),
                          ),
                        ).p(2)

                      ],
                    )
                        : Container(),
                    isLabelExistsInNumberConfig
                        ? getPickTypeWithQp().length == -1
                          ? const Align(alignment: Alignment.centerLeft, child: Text("Pick Type", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(top: 20, bottom: 2)
                          : Container()
                        : const Align(alignment: Alignment.centerLeft, child: Text("Pick Type", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(top: 20, bottom: 2),
                    isLabelExistsInNumberConfig
                        ? getPickTypeWithQp().length == -1
                          ? FlipCard(
                        controller: _pickController,
                        flipOnTouch: false,
                        fill: Fill.fillBack,
                        direction: FlipDirection.VERTICAL,
                        side: CardSide.FRONT,
                        front: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: getPickTypeWithQp().length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: selectedPickType[getPickTypeWithQp()[index].name] == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(6),
                                      ),
                                      border: Border.all(color: WlsPosColor.game_color_red)
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      selectedPickTypeData(getPickTypeWithQp()[index]);
                                    },
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(child: SizedBox(width:50, child: Text(getPickTypeWithQp()[index].name ?? "NA", textAlign: TextAlign.center, style: TextStyle(color: selectedPickType[getPickTypeWithQp()[index].name] == true ? WlsPosColor.white : WlsPosColor.game_color_red, fontSize: 10, fontWeight: selectedPickType[getPickTypeWithQp()[index].name] == true ? FontWeight.bold : FontWeight.w400)))),
                                  ),
                                ).p(2);
                              }
                          ).pOnly(bottom: 2),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            border: Border.all(color: isUpperLine ? WlsPosColor.game_color_green : WlsPosColor.white, width: 1.5)
                                        ),
                                        child: const Align(alignment: Alignment.centerLeft, child: Text("Upper Line:", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).p(8),
                                      ),
                                    ],
                                  ),
                                ).pOnly(right: 8),
                                Center(
                                    child: Container(
                                      width: 20,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList().isNotEmpty == true? getBallBankersNoColor(listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [], (upperLineBankerPickedNoIndex), mRangeObjectIndex) : Colors.transparent,
                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                                        //border: isBankerBallNoAvailable(listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [], upperLineBankerPickedNoIndex, mRangeObjectIndex) ? Border.all(color: Colors.transparent, width: 1) : Border.all(color: WlsPosColor.game_color_grey, width: 1)
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        isUpperLine = false;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                border: Border.all(color: isUpperLine ? WlsPosColor.white : WlsPosColor.game_color_green, width: 1.5)
                                            ),
                                            child: const Align(alignment: Alignment.centerLeft,
                                                child: Text("Lower Line:", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).p(10)
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                        child: listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().isEmpty == true
                                            ? Container(
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: WlsPosColor.white,
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                            //border: Border.all(color: WlsPosColor.game_color_grey, width: 1)
                                          ),
                                        )
                                            : Container(
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: WlsPosColor.white,
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                          ),
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().length,
                                              itemBuilder: (BuildContext context, int indx) {
                                                return Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: getBallBankersNoColor(listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().isNotEmpty == true
                                                        ? listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().where((element) => element.number == "${listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList()[indx].number}").toList() ?? [] : [], listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList()[indx].index ?? 0, mRangeObjectIndex),
                                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                  ),
                                                ).p(2);
                                              }
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              ).pOnly(left: 10),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBankerPickType = false;
                                  listOfSelectedUpperLowerLinesNosMap.clear();
                                });
                                if(_pickController.state?.isFront == false) {
                                  _pickController.toggleCard();
                                }
                                for(QuickPickBetAmountBean i in listQuickPick) {
                                  i.isSelected = false;
                                }
                                if (listOfSelectedUpperLowerLinesNosMap.isEmpty) {
                                  switchToPickType(selectedBetTypeData?.betCode ?? "");
                                }
                              },
                              child: Container(
                                  color: WlsPosColor.white,
                                  child: SvgPicture.asset("assets/icons/cross.svg", width: 18, height: 18, color: WlsPosColor.game_color_red)
                              ),
                            ).pOnly(left: 5),
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
                                      TextSpan(text: "Pick ball \nmatrix", style: TextStyle(color: WlsPosColor.black,fontWeight: FontWeight.w400, fontSize: 12)),
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
                                  itemCount: getPermRangeList(selectedPickTypeObject).length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: WlsPosColor.white,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(6),
                                          ),
                                          border: Border.all(color: WlsPosColor.game_color_grey)
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            mMultiplePickTypeIndex = index;
                                            isMultiplePickType = false;
                                            setPermQpList(rangeObjectIndex: index);
                                          });
                                        },
                                        customBorder: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(child: SizedBox(width: 30, child: Text("${index + 1}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12, fontWeight: FontWeight.bold)))),
                                      ),
                                    ).p(2);
                                  }
                              ).pOnly(right: 10),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBankerPickType = false;
                                  listOfSelectedNosMap.clear();
                                });
                                if(_pickController.state?.isFront == false) {
                                  _pickController.toggleCard();
                                }
                                for(QuickPickBetAmountBean i in listQuickPick) {
                                  i.isSelected = false;
                                }
                                if (listOfSelectedNosMap.isEmpty) {
                                  switchToPickType(selectedBetTypeData?.betCode ?? "");
                                }
                              },
                              child: Container(
                                  color: WlsPosColor.white,
                                  child: SvgPicture.asset("assets/icons/cross.svg", width: 18, height: 18, color: WlsPosColor.game_color_red)
                              ),
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
                                      const TextSpan(text: "Perm Qp:", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.w400, fontSize: 12)),
                                      TextSpan(text: "\n ( ${ballPickingLimits["$mMultiplePickTypeIndex"]?["minSelectionLimit"]} - ${ballPickingLimits["$mMultiplePickTypeIndex"]?["maxSelectionLimit"]} )", style: const TextStyle(color: WlsPosColor.game_color_grey, fontWeight: FontWeight.w400, fontSize: 10, fontStyle: FontStyle.italic)),
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
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: listQuickPick[index].isSelected == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(6),
                                          ),
                                          border: Border.all(color: listQuickPick[index].isSelected == true ? WlsPosColor.game_color_red : WlsPosColor.game_color_grey)
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            for(QuickPickBetAmountBean i in listQuickPick) {
                                              i.isSelected = false;
                                            }
                                            listQuickPick[index].isSelected = true;
                                          });
                                          qpGenerator(widget.particularGameObjects?.numberConfig?.range?[mMultiplePickTypeIndex].ball ?? [], listQuickPick[index].number ?? 0, rangeObjectIndex: mMultiplePickTypeIndex);
                                        },
                                        customBorder: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(child: SizedBox(width: 30, child: Text("${listQuickPick[index].number}", textAlign: TextAlign.center, style: TextStyle(color: listQuickPick[index].isSelected == true ? WlsPosColor.white : WlsPosColor.black, fontSize: 12, fontWeight: FontWeight.bold)))),
                                      ),
                                    ).p(2);
                                  }
                              ).pOnly(right: 10),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBankerPickType = false;
                                  var pickTypeObjectLength = selectedPickTypeObject.range?.length ?? 0;
                                  if(pickTypeObjectLength > 1) {
                                    isMultiplePickType = true;
                                  } else {
                                    listOfSelectedNosMap.clear();
                                    if(_pickController.state?.isFront == false) {
                                      _pickController.toggleCard();
                                    }
                                    for(QuickPickBetAmountBean i in listQuickPick) {
                                      i.isSelected = false;
                                    }
                                    if (listOfSelectedNosMap.isEmpty) {
                                      switchToPickType(selectedBetTypeData?.betCode ?? "");
                                    }
                                  }
                                });

                              },
                              child: Container(
                                  color: WlsPosColor.white,
                                  child: SvgPicture.asset("assets/icons/cross.svg", width: 18, height: 18, color: WlsPosColor.game_color_red)
                              ),
                            ),
                          ],
                        )
                    )
                          : Container()
                        : FlipCard(
                      controller: _pickController,
                      flipOnTouch: false,
                      fill: Fill.fillBack,
                      direction: FlipDirection.VERTICAL,
                      side: CardSide.FRONT,
                      front: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: isLandscape ? 55 : 45,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: getPickTypeWithQp().length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: selectedPickType[getPickTypeWithQp()[index].name] == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                    border: Border.all(color: WlsPosColor.game_color_red)
                                ),
                                child: InkWell(
                                  onTap: () {
                                    selectedPickTypeData(getPickTypeWithQp()[index]);
                                  },
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(child: SizedBox(width:isLandscape ? 100 : 50, child: Text(getPickTypeWithQp()[index].name ?? "NA", textAlign: TextAlign.center, style: TextStyle(color: selectedPickType[getPickTypeWithQp()[index].name] == true ? WlsPosColor.white : WlsPosColor.game_color_red, fontSize: isLandscape ? 18 : 10, fontWeight: selectedPickType[getPickTypeWithQp()[index].name] == true ? FontWeight.bold : FontWeight.w400)))),
                                ),
                              ).p(2);
                            }
                        ).pOnly(bottom: 2),
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                  border: Border.all(color: isUpperLine ? WlsPosColor.game_color_green : WlsPosColor.white, width: 1.5)
                                              ),
                                              child: const Align(alignment: Alignment.centerLeft, child: Text("Upper Line:", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).p(8),
                                          ),
                                        ],
                                      ),
                                    ).pOnly(right: 8),
                                    Center(
                                        child: Container(
                                          width: 20,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList().isNotEmpty == true? getBallBankersNoColor(listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [], (upperLineBankerPickedNoIndex), mRangeObjectIndex) : Colors.transparent,
                                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                                              //border: isBankerBallNoAvailable(listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [], upperLineBankerPickedNoIndex, mRangeObjectIndex) ? Border.all(color: Colors.transparent, width: 1) : Border.all(color: WlsPosColor.game_color_grey, width: 1)
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            isUpperLine = false;
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                  border: Border.all(color: isUpperLine ? WlsPosColor.white : WlsPosColor.game_color_green, width: 1.5)
                                                ),
                                                child: const Align(alignment: Alignment.centerLeft,
                                                child: Text("Lower Line:", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).p(10)
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                            child: listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().isEmpty == true
                                                ? Container(
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                  color: WlsPosColor.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                  //border: Border.all(color: WlsPosColor.game_color_grey, width: 1)
                                              ),
                                            )
                                                : Container(
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                  color: WlsPosColor.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                              ),
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().length,
                                                  itemBuilder: (BuildContext context, int indx) {
                                                    return Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: getBallBankersNoColor(listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().isNotEmpty == true
                                                            ? listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList().where((element) => element.number == "${listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList()[indx].number}").toList() ?? [] : [], listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList()[indx].index ?? 0, mRangeObjectIndex),
                                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                      ),
                                                    ).p(2);
                                                  }
                                              ),
                                            )
                                        ),
                                      ),
                                    ],
                                  ).pOnly(left: 10),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isBankerPickType = false;
                                      listOfSelectedUpperLowerLinesNosMap.clear();
                                    });
                                    if(_pickController.state?.isFront == false) {
                                      _pickController.toggleCard();
                                    }
                                    for(QuickPickBetAmountBean i in listQuickPick) {
                                      i.isSelected = false;
                                    }
                                    if (listOfSelectedUpperLowerLinesNosMap.isEmpty) {
                                      switchToPickType(selectedBetTypeData?.betCode ?? "");
                                    }
                                  },
                                  child: Container(
                                      color: WlsPosColor.white,
                                      child: SvgPicture.asset("assets/icons/cross.svg", width: 18, height: 18, color: WlsPosColor.game_color_red)
                                  ),
                                ).pOnly(left: 5),
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
                                    TextSpan(text: "Pick ball \nmatrix", style: TextStyle(color: WlsPosColor.black,fontWeight: FontWeight.w400, fontSize: 12)),
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
                                itemCount: getPermRangeList(selectedPickTypeObject).length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: WlsPosColor.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                        border: Border.all(color: WlsPosColor.game_color_grey)
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          mMultiplePickTypeIndex = index;
                                          isMultiplePickType = false;
                                          setPermQpList(rangeObjectIndex: index);
                                        });
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(child: SizedBox(width: 30, child: Text("${index + 1}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12, fontWeight: FontWeight.bold)))),
                                    ),
                                  ).p(2);
                                }
                            ).pOnly(right: 10),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isBankerPickType = false;
                                listOfSelectedNosMap.clear();
                              });
                              if(_pickController.state?.isFront == false) {
                                _pickController.toggleCard();
                              }
                              for(QuickPickBetAmountBean i in listQuickPick) {
                                i.isSelected = false;
                              }
                              if (listOfSelectedNosMap.isEmpty) {
                                switchToPickType(selectedBetTypeData?.betCode ?? "");
                              }
                            },
                            child: Container(
                                color: WlsPosColor.white,
                                child: SvgPicture.asset("assets/icons/cross.svg", width: 18, height: 18, color: WlsPosColor.game_color_red)
                            ),
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
                                    const TextSpan(text: "Perm Qp:", style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.w400, fontSize: 12)),
                                    TextSpan(text: "\n ( ${ballPickingLimits["$mMultiplePickTypeIndex"]?["minSelectionLimit"]} - ${ballPickingLimits["$mMultiplePickTypeIndex"]?["maxSelectionLimit"]} )", style: const TextStyle(color: WlsPosColor.game_color_grey, fontWeight: FontWeight.w400, fontSize: 10, fontStyle: FontStyle.italic)),
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
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: listQuickPick[index].isSelected == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                        border: Border.all(color: listQuickPick[index].isSelected == true ? WlsPosColor.game_color_red : WlsPosColor.game_color_grey)
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          for(QuickPickBetAmountBean i in listQuickPick) {
                                            i.isSelected = false;
                                          }
                                          listQuickPick[index].isSelected = true;
                                        });
                                        qpGenerator(widget.particularGameObjects?.numberConfig?.range?[mMultiplePickTypeIndex].ball ?? [], listQuickPick[index].number ?? 0, rangeObjectIndex: mMultiplePickTypeIndex);
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(child: SizedBox(width: 30, child: Text("${listQuickPick[index].number}", textAlign: TextAlign.center, style: TextStyle(color: listQuickPick[index].isSelected == true ? WlsPosColor.white : WlsPosColor.black, fontSize: 12, fontWeight: FontWeight.bold)))),
                                    ),
                                  ).p(2);
                                }
                            ).pOnly(right: 10),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isBankerPickType = false;
                                var pickTypeObjectLength = selectedPickTypeObject.range?.length ?? 0;
                                if(pickTypeObjectLength > 1) {
                                  isMultiplePickType = true;
                                } else {
                                  listOfSelectedNosMap.clear();
                                  if(_pickController.state?.isFront == false) {
                                    _pickController.toggleCard();
                                  }
                                  for(QuickPickBetAmountBean i in listQuickPick) {
                                    i.isSelected = false;
                                  }
                                  if (listOfSelectedNosMap.isEmpty) {
                                    switchToPickType(selectedBetTypeData?.betCode ?? "");
                                  }
                                }
                              });

                            },
                            child: Container(
                                color: WlsPosColor.white,
                                child: SvgPicture.asset("assets/icons/cross.svg", width: 18, height: 18, color: WlsPosColor.game_color_red)
                            ),
                          ),
                        ],
                      )
                    ),

                    Container(
                      decoration: DottedDecoration(
                        color: WlsPosColor.ball_border_bg,
                        strokeWidth: 0.5,
                        linePosition: LinePosition.bottom,
                      ),
                      height:12,
                      width: MediaQuery.of(context).size.width,
                    ),

                    listBetAmount.isNotEmpty ? Align(alignment: Alignment.centerLeft, child: Text("Bet Amount (${getDefaultCurrency(getLanguage())})", style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(top: 20, bottom: 2) : Container(),
                    listBetAmount.isNotEmpty
                        ? listBetAmount.length == 1
                          ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 50,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: WlsPosColor.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: WlsPosColor.ball_border_bg)
                              ),
                              child: Center(child: Text("${listBetAmount[0].amount}", style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 16, fontWeight: FontWeight.bold)).p(4)),
                            ),
                          )
                          : Row(
                      children: [
                        SizedBox(
                          height: isLandscape ? 55 : 40,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: listBetAmountLength,
                              itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  if (listBetAmount[index].amount != null) {
                                    setSelectedBetAmountForHighlighting(index);
                                    selectedBetAmountValue.clear();
                                    selectedBetAmountValue[listBetAmount[index].amount.toString()] = true;
                                    onBetAmountClick(listBetAmount[index].amount!);
                                  }
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Container(
                                  width: isLandscape ? 60 : 50,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: selectedBetAmountValue["${listBetAmount[index].amount}"] == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                                      border: Border.all(color: WlsPosColor.game_color_red)
                                  ),
                                  child: Align(alignment: Alignment.center, child: Text("${listBetAmount[index].amount}", style: TextStyle(color: selectedBetAmountValue["${listBetAmount[index].amount}"] == true ? WlsPosColor.white : WlsPosColor.game_color_red, fontSize: isLandscape ? 18 : 10))).p(4),
                                ),
                              ).p(2);

                          }),
                        ),

                        isLandscape
                         ? Visibility(
                          visible: isOtherAmountAvailable,
                           child: InkWell(
                            onTap: () {
                              if(isOtherAmountAvailable) {
                                OtherAvailableBetAmountAlertDialog().show(context: context, title: "Select Amount (${getDefaultCurrency(getLanguage())})", buttonText: "Select", isCloseButton: true, listOfAmounts: listBetAmount, buttonClick: (selectedBetAmount) {
                                  setState(() {
                                    selectedBetAmountValue.clear();
                                    selectedBetAmountValue["$selectedBetAmount"] = true;
                                  });
                                  onBetAmountClick(selectedBetAmount);
                                });
                              }
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Ink(
                              width: 110,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: WlsPosColor.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: WlsPosColor.game_color_red)
                              ),
                              child: Stack(
                                children: [
                                  const Align(alignment: Alignment.center, child: Text("Other", style: TextStyle(color: WlsPosColor.red, fontSize: 15))),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child:
                                      SizedBox(width: 30, height: 30, child: Lottie.asset('assets/lottie/tap.json'))
                                  ),
                                ],
                              ),
                            ),
                        ).p(2),
                         )
                         : Visibility(
                          visible: isOtherAmountAvailable,
                          child: Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                if(isOtherAmountAvailable) {
                                  OtherAvailableBetAmountAlertDialog().show(context: context, title: "Select Amount (${getDefaultCurrency(getLanguage())})", buttonText: "Select", isCloseButton: true, listOfAmounts: listBetAmount, buttonClick: (selectedBetAmount) {
                                    setState(() {
                                      selectedBetAmountValue.clear();
                                      selectedBetAmountValue["$selectedBetAmount"] = true;
                                    });
                                    onBetAmountClick(selectedBetAmount);
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
                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                    border: Border.all(color: WlsPosColor.game_color_red)
                                ),
                                child: Stack(
                                  children: [
                                    const Align(alignment: Alignment.center, child: Text("Other", style: TextStyle(color: WlsPosColor.red, fontSize: 10))),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child:
                                          SizedBox(width: 30, height: 30, child: Lottie.asset('assets/lottie/tap.json'))
                                    ),
                                  ],
                                ),
                              ),
                            ).p(2),
                          ),
                        ),


                        isLandscape
                         ? Ink(
                              width: 110,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: WlsPosColor.game_color_red,
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: WlsPosColor.game_color_red)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Align(alignment: Alignment.center, child: Text("Bet Amount", style: TextStyle(color: WlsPosColor.white, fontSize: 15))),
                                  Align(alignment: Alignment.center, child: Text(selectedBetAmount, style: const TextStyle(color: WlsPosColor.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ).p(2)
                         : Expanded(
                          flex: 1,
                          child: Ink(
                            height: 40,
                            decoration: BoxDecoration(
                                color: WlsPosColor.game_color_red,
                                borderRadius: const BorderRadius.all(Radius.circular(6)),
                                border: Border.all(color: WlsPosColor.game_color_red)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Align(alignment: Alignment.center, child: Text("Bet Amount", style: TextStyle(color: WlsPosColor.white, fontSize: 10))),
                                Align(alignment: Alignment.center, child: Text(selectedBetAmount, style: const TextStyle(color: WlsPosColor.white, fontSize: 16, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ).p(2),
                        )
                      ],
                    )
                        : Container(),
                    //grand prize
                    /*Container(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Expanded(child: doubleJackpotCost != null ?  InkWell(
                            onTap: () {
                              setState(() {
                                isDoubleJackpotEnabled = !isDoubleJackpotEnabled;
                              });
                              betValueCalculation(mRangeObjectIndex);
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Container(
                              width: isLandscape ? 180 : 150,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: isDoubleJackpotEnabled ? WlsPosColor.shamrock_green : WlsPosColor.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: WlsPosColor.shamrock_green)
                              ),
                              child: Align(alignment: Alignment.center, child: Text("Double the Grand Prize Add $doubleJackpotCost (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center,style: TextStyle(color: isDoubleJackpotEnabled ? WlsPosColor.white : WlsPosColor.game_color_black, fontSize: isLandscape ? 18 : 10))).p(4),
                            ),
                          ).p(2): const SizedBox(),),
                          Expanded(child: secureJackpotCost != null ? InkWell(
                            onTap: () {
                              setState(() {
                                isSecureJackpotEnabled = !isSecureJackpotEnabled;
                              });
                              betValueCalculation(mRangeObjectIndex);
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Container(
                              width:isLandscape ? 180 : 150,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: isSecureJackpotEnabled ? WlsPosColor.shamrock_green : WlsPosColor.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: WlsPosColor.shamrock_green)
                              ),
                              child: Align(alignment: Alignment.center, child: Text("Secure the Grand Prize Add $secureJackpotCost (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center, style: TextStyle(color: isSecureJackpotEnabled ? WlsPosColor.white : WlsPosColor.game_color_black, fontSize: isLandscape ? 18 : 10))).p(4),
                            ),
                          ).p(2) : const SizedBox(),)
                      ],).p(2),
                    ),*/
                    widget.particularGameObjects?.gameCode == "DailyLotto" ? GrandPrizeWidget(
                      doubleJackpotOnTap: () {
                        setState(() {
                          isDoubleJackpotEnabled = !isDoubleJackpotEnabled;
                        });
                        betValueCalculation(mRangeObjectIndex);
                      },
                      secureJackpotOnTap:() {
                        setState(() {
                          isSecureJackpotEnabled = !isSecureJackpotEnabled;
                        });
                        betValueCalculation(mRangeObjectIndex);
                      },
                      isLandscape: isLandscape,
                      doubleJackpotCost: doubleJackpotCost,
                      isDoubleJackpotEnabled: isDoubleJackpotEnabled,
                      secureJackpotCost: secureJackpotCost,
                      isSecureJackpotEnabled:isSecureJackpotEnabled,
                    ): const SizedBox(),
                    listBetAmount.isNotEmpty ? const HeightBox(50) : Container(),
                  ],
                ).p(8),
              ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    color: WlsPosColor.ball_border_light_bg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        isLabelExistsInNumberConfig
                          ? Container()
                          : lotteryGameMainBetList.length > 1
                              ? widget.particularGameObjects?.gameCode?.toUpperCase() == "powerball".toUpperCase()
                                  ? Material(
                              child: InkWell(
                                onTap: () {
                                  var mListOfSelectedNos = 0;
                                  var mMinSelectionLimit = 0;
                                  var isApplicable = true;

                                  for(var i=0; i< ballPickingLimits.length; i++) {
                                    mMinSelectionLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
                                    mListOfSelectedNos = listOfSelectedNosMap["$i"]?.length ?? 0;
                                    if (mListOfSelectedNos < mMinSelectionLimit) {
                                      String msg = "";
                                      if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
                                        msg = mMinSelectionLimit > 1 ? "Select at least ${ballPickingLimits["0"]?["minSelectionLimit"]} numbers and ${ballPickingLimits["1"]?["minSelectionLimit"]} bonus number from panel for ${selectedPickTypeObject.name}." : "Select at least ${ballPickingLimits["0"]?["minSelectionLimit"]} numbers and ${ballPickingLimits["1"]?["minSelectionLimit"]} bonus number from panel for ${selectedPickTypeObject.name}.";

                                      } else {
                                        msg = mMinSelectionLimit > 1 ? "${"Select at least $mMinSelectionLimit numbers for ${selectedPickTypeObject.name}"}." : "Select at least $mMinSelectionLimit number for ${selectedPickTypeObject.name}.";
                                      }

                                      ShowToast.showToast(context, msg, type: ToastType.INFO);
                                      setState(() {
                                        isApplicable = false;
                                      });
                                      break;

                                    }
                                  }
                                  if (isApplicable) {
                                    addBetIfOnly1BetType();
                                  }
                                },
                                child: Ink(
                                  width: 110,
                                  color: WlsPosColor.game_color_red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset('assets/icons/plus.svg', width: 15, height: 16, color: WlsPosColor.white).pOnly(left: 4),
                                      const Align(alignment: Alignment.center, child: Text("ADD BET", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 12))).pOnly(right: 4),
                                      Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(color: WlsPosColor.white, borderRadius: BorderRadius.circular(50)),
                                          child: Center(child: Text("${widget.mPanelBinList?.length}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.red, fontWeight: FontWeight.bold, fontSize: 12)))
                                      ),

                                    ],
                                  ).pOnly(right:2),
                                ),
                              ),
                            )
                                  : Container()
                            : lotteryGameMainBetList.length == 1 && lotteryGameSideBetList.isEmpty
                                ? Material(
                                    child: InkWell(
                                            onTap: () {
                                              var mListOfSelectedNos = 0;
                                              var mMinSelectionLimit = 0;
                                              var isApplicable = true;

                                              for(var i=0; i< ballPickingLimits.length; i++) {
                                                mMinSelectionLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
                                                mListOfSelectedNos = listOfSelectedNosMap["$i"]?.length ?? 0;
                                                if (mListOfSelectedNos < mMinSelectionLimit) {
                                                  String msg = "";
                                                  if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
                                                    msg = mMinSelectionLimit > 1 ? "Select at least ${ballPickingLimits["0"]?["minSelectionLimit"]} numbers and ${ballPickingLimits["1"]?["minSelectionLimit"]} bonus number from panel for ${selectedPickTypeObject.name}." : "Select at least ${ballPickingLimits["0"]?["minSelectionLimit"]} numbers and ${ballPickingLimits["1"]?["minSelectionLimit"]} bonus number from panel for ${selectedPickTypeObject.name}.";

                                                  } else {
                                                    msg = mMinSelectionLimit > 1 ? "${"Select at least $mMinSelectionLimit numbers for ${selectedPickTypeObject.name}"}." : "Select at least $mMinSelectionLimit number for ${selectedPickTypeObject.name}.";
                                                  }

                                                  ShowToast.showToast(context, msg, type: ToastType.INFO);
                                                  setState(() {
                                                    isApplicable = false;
                                                  });
                                                  break;

                                                }
                                              }
                                              if (isApplicable) {
                                                addBetIfOnly1BetType();
                                              }
                                            },
                                            child: Ink(
                                                width: 110,
                                                color: WlsPosColor.game_color_red,
                                                child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset('assets/icons/plus.svg', width: 15, height: 16, color: WlsPosColor.white).pOnly(left: 4),
                                          const Align(alignment: Alignment.center, child: Text("ADD BET", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 12))).pOnly(right: 4),
                                          Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(color: WlsPosColor.white, borderRadius: BorderRadius.circular(50)),
                                              child: Center(child: Text("${widget.mPanelBinList?.length}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.red, fontWeight: FontWeight.bold, fontSize: 12)))
                                          ),

                                        ],
                                      ).pOnly(right:2),
                                              ),
                                          ),
                                  )
                                : Container(),
                        Expanded(
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                reset();
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/icons/reset.svg', width: 18, height: 18, color: WlsPosColor.game_color_red).pOnly(bottom: 2),
                                  const Align(alignment: Alignment.center, child: Text("Reset", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 10))),
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
                              Text(betValue, textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16)).pOnly(bottom: 2),
                              Text("Bet Value (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 10)),
                            ],
                          ),
                        ),
                        isLabelExistsInNumberConfig
                            ? Expanded(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.mPanelBinList?.isEmpty == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text("No bet selected, please select any bet !"),
                                        ));

                                      } else {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (_) =>  MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider<LotteryBloc>(
                                                      create: (BuildContext context) => LotteryBloc(),
                                                    ),
                                                    BlocProvider<LoginBloc>(
                                                      create: (BuildContext context) => LoginBloc(),
                                                    )
                                                  ],
                                                  child: PreviewGameScreen(gameSelectedDetails: widget.mPanelBinList ?? [], gameObjectsList: widget.particularGameObjects, onComingToPreviousScreen: (String onComingToPreviousScreen) {
                                                    switch(onComingToPreviousScreen) {
                                                      case "isAllPreviewDataDeleted" : {
                                                        setState(() {
                                                          widget.mPanelBinList?.clear();
                                                          betValue = "0";
                                                        });
                                                        break;
                                                      }

                                                      case "isBuyPerformed" : {
                                                        setState(() {
                                                          widget.mPanelBinList?.clear();
                                                          betValue = "0";
                                                        });
                                                        break;
                                                      }
                                                    }
                                                  },
                                                      selectedGamesData: (List<PanelBean> selectedAllGameData, List<List<PanelData>?>? selectedAllThaiGameData) {
                                                        setState(() {
                                                          print("22222222222");
                                                          var pickTypeObject = getPickTypeWithQp().where((element) => element.name == selectedAllGameData[0].pickName).toList();
                                                          selectedPickTypeObject = pickTypeObject[0];
                                                          setNoPickLimits(selectedPickTypeObject);
                                                          listOfSelectedNosMap = selectedAllGameData[0].listSelectedNumber![0];
                                                          selectedPickType            = {selectedAllGameData[0].pickName ?? "Manual": true};
                                                          selectedBetTypeData         = widget.betRespV0s!;
                                                          ballPickInstructions        = widget.pickType?[0].description ?? "Please select numbers";

                                                          int selectedBetAmtTemp = selectedAllGameData[0].selectBetAmount ?? 1;
                                                          selectedBetAmountValue["$selectedBetAmtTemp"] = true;
                                                          selectedBetAmount = "$selectedBetAmtTemp";

                                                          log("listOfSelectedNosMap:$listOfSelectedNosMap");
                                                          log("selectedAllGameData::${jsonEncode(selectedAllGameData)}");
                                                          widget.mPanelBinList = selectedAllGameData;
                                                        });
                                                      }
                                                  )
                                              ),
                                              //child: LotteryScreen()),
                                            )
                                        );
                                      }

                                    },
                                    child: Ink(
                                      color: WlsPosColor.game_color_red,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Align(alignment: Alignment.center, child: Text("Proceed", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : lotteryGameMainBetList.length > 1
                                ? widget.particularGameObjects?.gameCode?.toUpperCase() == "powerball".toUpperCase()
                                  ? Expanded(
                                      child: Material(
                                        child: InkWell(
                                          onTap: () {
                                            print("listOfSelectedNosMap: $listOfSelectedNosMap");
                                            if (widget.mPanelBinList?.isEmpty == true) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                duration: Duration(seconds: 1),
                                                content: Text("No bet selected, please select any bet !"),
                                              ));
                                            } else {
                                              /*widget.mPanelBinList?[0].pickName = selectedPickTypeObject.name;
                                              widget.mPanelBinList?[0].amount = double.parse(betValue);
                                              widget.mPanelBinList?[0].listSelectedNumber = [listOfSelectedNosMap];
                                              if (selectedPickTypeObject.name?.contains("QP") == true) {
                                                widget.mPanelBinList?[0].isQpPreGenerated = true;
                                                widget.mPanelBinList?[0].isQuickPick = true;

                                              } else {
                                                widget.mPanelBinList?[0].isQpPreGenerated = false;
                                                widget.mPanelBinList?[0].isQuickPick = false;
                                              }
                                              print("after change : preview: ${jsonEncode(widget.mPanelBinList)}");*/

                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>  MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider<LotteryBloc>(
                                                            create: (BuildContext context) => LotteryBloc(),
                                                          ),
                                                          BlocProvider<LoginBloc>(
                                                            create: (BuildContext context) => LoginBloc(),
                                                          )
                                                        ],
                                                        child: PreviewGameScreen(gameSelectedDetails: widget.mPanelBinList ?? [], gameObjectsList: widget.particularGameObjects, onComingToPreviousScreen: (String onComingToPreviousScreen) {
                                                          switch(onComingToPreviousScreen) {
                                                            case "isAllPreviewDataDeleted" : {
                                                              setState(() {
                                                                widget.mPanelBinList?.clear();
                                                                betValue = "0";
                                                              });
                                                              break;
                                                            }

                                                            case "isBuyPerformed" : {
                                                              setState(() {
                                                                widget.mPanelBinList?.clear();
                                                                betValue = "0";
                                                              });
                                                              break;
                                                            }
                                                          }
                                                        },
                                                        selectedGamesData: (List<PanelBean> selectedAllGameData, List<List<PanelData>?>? selectedAllThaiGameData) {
                                                          setState(() {
                                                            print("22222222222");
                                                            var pickTypeObject = getPickTypeWithQp().where((element) => element.name == selectedAllGameData[0].pickName).toList();
                                                            selectedPickTypeObject = pickTypeObject[0];
                                                            setNoPickLimits(selectedPickTypeObject);
                                                            listOfSelectedNosMap = selectedAllGameData[0].listSelectedNumber![0];
                                                            selectedPickType            = {selectedAllGameData[0].pickName ?? "Manual": true};
                                                            selectedBetTypeData         = widget.betRespV0s!;
                                                            ballPickInstructions        = widget.pickType?[0].description ?? "Please select numbers";

                                                            int selectedBetAmtTemp = selectedAllGameData[0].selectBetAmount ?? 1;
                                                            selectedBetAmountValue["$selectedBetAmtTemp"] = true;
                                                            selectedBetAmount = "$selectedBetAmtTemp";

                                                            log("listOfSelectedNosMap:$listOfSelectedNosMap");
                                                            log("selectedAllGameData::${jsonEncode(selectedAllGameData)}");
                                                            widget.mPanelBinList = selectedAllGameData;
                                                          });
                                                        }
                                                      )
                                                    ),
                                                    //child: LotteryScreen()),
                                                  )
                                              );
                                            }

                                          },
                                          child: Ink(
                                            color: WlsPosColor.game_color_red,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Align(alignment: Alignment.center, child: Text("Proceed", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                              child: Material(
                                child: InkWell(
                                  onTap: () {
                                    if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
                                      if ( betValue == "0") {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text("Bet Value can't be 0."),
                                        ));
                                      } else {
                                        addBet();
                                      }

                                    } else {
                                      if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
                                        if (betValue == "0") {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: Text("Bet Value can't be 0."),
                                          ));
                                        } else {
                                          addBet();
                                        }

                                      } else {
                                        var mListOfSelectedNos = 0;
                                        var mMinSelectionLimit = 0;
                                        var isApplicable = true;

                                        for(var i=0; i< ballPickingLimits.length; i++) {
                                          mMinSelectionLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
                                          mListOfSelectedNos = listOfSelectedNosMap["$i"]?.length ?? 0;
                                          if (mListOfSelectedNos < mMinSelectionLimit) {
                                            String msg = "";
                                            if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
                                              msg = mMinSelectionLimit > 1 ? "${"You can only select only ${ballPickingLimits["0"]?["minSelectionLimit"]} numbers for first panel and ${ballPickingLimits["1"]?["minSelectionLimit"]} number from second panel."}." : "Select at least $mMinSelectionLimit number for ${selectedPickTypeObject.name}.";
                                            } else {
                                              msg = mMinSelectionLimit > 1 ? "${"Select at least $mMinSelectionLimit numbers for ${selectedPickTypeObject.name}"}." : "Select at least $mMinSelectionLimit number for ${selectedPickTypeObject.name}.";
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              duration: const Duration(seconds: 1),
                                              content: Text(msg),
                                            ));
                                            setState(() {
                                              isApplicable = false;
                                            });
                                            break;

                                          }
                                        }

                                        if (betValue == "0") {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: Text("Bet Value can't be 0."),
                                          ));
                                        } else {
                                          if (isApplicable) {
                                            addBet();
                                          }
                                        }
                                      }
                                    }

                                  },
                                  child: Ink(
                                    color: WlsPosColor.game_color_red,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset('assets/icons/plus.svg', width: 16, height: 16, color: WlsPosColor.white),
                                        const Align(alignment: Alignment.center, child: Text("ADD BET", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : lotteryGameMainBetList.length == 1 && lotteryGameSideBetList.isEmpty
                                  ? Expanded(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.mPanelBinList?.isEmpty == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text("No bet selected, please select any bet !"),
                                        ));
                                      } else {

                                        Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (_) =>  MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider<LotteryBloc>(
                                                      create: (BuildContext context) => LotteryBloc(),
                                                    ),
                                                    BlocProvider<LoginBloc>(
                                                      create: (BuildContext context) => LoginBloc(),
                                                    ),
                                                  ],
                                                  child: PreviewGameScreen(gameSelectedDetails: widget.mPanelBinList ?? [], gameObjectsList: widget.particularGameObjects, betRespV0s: widget.betRespV0s, pickType: widget.pickType, onComingToPreviousScreen: (String onComingToPreviousScreen) {
                                                    switch(onComingToPreviousScreen) {
                                                      case "isAllPreviewDataDeleted" : {
                                                        setState(() {
                                                          widget.mPanelBinList?.clear();
                                                          reset();
                                                        });
                                                        break;
                                                      }

                                                      case "isBuyPerformed" : {
                                                        setState(() {
                                                          widget.mPanelBinList?.clear();
                                                          reset();

                                                        });
                                                        break;
                                                      }
                                                    }
                                                  }, selectedGamesData: (List<PanelBean> selectedAllGameData, List<List<PanelData>?>? selectedAllThaiGameData) {
                                                    setState(() {
                                                      print("22222222222");
                                                      /*var pickTypeObject = getPickTypeWithQp().where((element) => element.name == selectedAllGameData[0].pickName).toList();
                                                      selectedPickTypeObject = pickTypeObject[0];
                                                      setNoPickLimits(selectedPickTypeObject);
                                                      listOfSelectedNosMap = selectedAllGameData[0].listSelectedNumber![0];
                                                      selectedPickType            = {selectedAllGameData[0].pickName ?? "Manual": true};
                                                      selectedBetTypeData         = widget.betRespV0s!;
                                                      ballPickInstructions        = widget.pickType?[0].description ?? "Please select numbers";

                                                      int selectedBetAmtTemp = selectedAllGameData[0].selectBetAmount ?? 1;
                                                      selectedBetAmountValue["$selectedBetAmtTemp"] = true;
                                                      selectedBetAmount = "$selectedBetAmtTemp";

                                                      log("listOfSelectedNosMap:$listOfSelectedNosMap");
                                                      log("selectedAllGameData::${jsonEncode(selectedAllGameData)}");*/
                                                      print("3333333333333");
                                                      widget.mPanelBinList = selectedAllGameData;
                                                    });
                                                  }
                                                 )),
                                              //child: LotteryScreen()),
                                            )
                                        );
                                      }

                                    },
                                    child: Ink(
                                      color: WlsPosColor.game_color_red,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Align(alignment: Alignment.center, child: Text("Proceed", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 13))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  : Expanded(
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
                                  if ( betValue == "0") {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Text("Bet Value can't be 0."),
                                    ));
                                  } else {
                                    addBet();
                                  }

                                } else {
                                  if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
                                    if (betValue == "0") {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("Bet Value can't be 0."),
                                      ));
                                    } else {
                                      addBet();
                                    }

                                  } else {
                                    var mListOfSelectedNos = 0;
                                    var mMinSelectionLimit = 0;
                                    var isApplicable = true;

                                    for(var i=0; i< ballPickingLimits.length; i++) {
                                      mMinSelectionLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
                                      mListOfSelectedNos = listOfSelectedNosMap["$i"]?.length ?? 0;
                                      if (mListOfSelectedNos < mMinSelectionLimit) {
                                        String msg = "";
                                        if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
                                          msg = mMinSelectionLimit > 1 ? "${"You can only select only ${ballPickingLimits["0"]?["minSelectionLimit"]} numbers for first panel and ${ballPickingLimits["1"]?["minSelectionLimit"]} number from second panel."}." : "Select at least $mMinSelectionLimit number for ${selectedPickTypeObject.name}.";
                                        } else {
                                          msg = mMinSelectionLimit > 1 ? "${"Select at least $mMinSelectionLimit numbers for ${selectedPickTypeObject.name}"}." : "Select at least $mMinSelectionLimit number for ${selectedPickTypeObject.name}.";
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          duration: const Duration(seconds: 1),
                                          content: Text(msg),
                                        ));
                                        setState(() {
                                          isApplicable = false;
                                        });
                                        break;

                                      }
                                    }

                                    if (betValue == "0") {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("Bet Value can't be 0."),
                                      ));
                                    } else {
                                      if (isApplicable) {
                                        addBet();
                                      }
                                    }
                                  }
                                }

                              },
                              child: Ink(
                                color: WlsPosColor.game_color_red,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset('assets/icons/plus.svg', width: 16, height: 16, color: WlsPosColor.white),
                                    const Align(alignment: Alignment.center, child: Text("ADD BET", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
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
          ),
        ),
      ),
    );
  }

  List<PickType> getPickTypeWithQp({BetRespVOs? betRespVOs}) {
    List<PickType>? originalPickType  = betRespVOs != null ? betRespVOs.pickTypeData?.pickType : widget.pickType;
    List<PickType> newPickType        = [];

    if (originalPickType != null) {
      for(PickType model in originalPickType) {
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

    print("newPickType: $newPickType");

    return newPickType;
  }

  setBetAmount() {
    if (selectedBetTypeData != null) {
      int unitPrice                  = selectedBetTypeData?.unitPrice?.toInt() ?? 1;
      int maxBetAmtMul                  = selectedBetTypeData?.maxBetAmtMul ?? 0;
      int count                         = maxBetAmtMul * unitPrice.toInt();
      //int count                         = maxBetAmtMul~/unitPrice;
      print("count: $count");
      if(count > 0) {
        var betArrayLength = maxBetAmtMul;
        if (unitPrice < 1) {
          for (int i = 1; i< betArrayLength + 1; i++) {
            if (unitPrice * i * maxBetAmtMul <= maxBetAmtMul * unitPrice) {
              FiveByNinetyBetAmountBean model = FiveByNinetyBetAmountBean();
              model.amount                    = unitPrice * i * maxBetAmtMul;
              model.isSelected                = false;
              listBetAmount.add(model);
            }
          }
        } else {
          for (int i = 1; i< betArrayLength + 1; i++) {
            if (unitPrice <= maxBetAmtMul * unitPrice) {
              FiveByNinetyBetAmountBean model = FiveByNinetyBetAmountBean();
              model.amount                    = unitPrice * i;
              model.isSelected                = false;
              listBetAmount.add(model);
            }
          }
        }

        if(listBetAmount.isNotEmpty) {
          setSelectedBetAmountForHighlighting(0);
          int amtListLength = listBetAmount.length;

          setState(() {
            listBetAmountLength = amtListLength > 5 ? 3 : amtListLength;
            print("listBetAmountLength: $listBetAmountLength");

            if(listBetAmount.length > 5) {
              isOtherAmountAvailable      = true;

            } else if (listBetAmount.length == 5) {
              isOtherAmountAvailable      = false;

            } else if (listBetAmount.length == 4) {
              isOtherAmountAvailable      = false;

            } else if (listBetAmount.length == 3) {
              isOtherAmountAvailable      = false;

            } else if (listBetAmount.length == 2) {
              isOtherAmountAvailable      = false;

            } else if (listBetAmount.length == 1) {
              isOtherAmountAvailable      = false;
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: WlsPosColor.game_color_red,
      duration: Duration(seconds: 1),
      content: Text("Bet amounts list is empty !"),
    )).closed.then((reason) {
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
     setState(() {
       selectedBetAmount = amount.toString();
     });
    betValueCalculation(mRangeObjectIndex);

    if(isLabelExistsInNumberConfig) {
      reConfigurePanelDataWithNewAmt();
    }
  }

  betValueCalculation(int rangeObjectIndex) {
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
      var minUpperLineSelectionLimit  = int.parse(selectedPickTypeObject.range?[rangeObjectIndex].pickCount?.split("-")[0].split(",")[0] ?? "0");
      var minLowerLineSelectionLimit  = int.parse(selectedPickTypeObject.range?[rangeObjectIndex].pickCount?.split("-")[1].split(",")[0] ?? "0");
      var upperLineNosList            = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [];
      var lowerLineNosList            = listOfSelectedUpperLowerLinesNosMap["$rangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList() ?? [];

      if (upperLineNosList.length >= minUpperLineSelectionLimit && lowerLineNosList.length >= minLowerLineSelectionLimit) {
        if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
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
          int amount = (int.parse(selectedBetAmount) * getNumberOfLines());
          setState(() {
            betValue = "$amount";
          });
        }

      } else {
        setState(() {
          betValue = "0";
        });
      }

  } else {

      if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
        int amount = (selectedNumberAndSlabList.length * (int.parse(selectedBetAmount))).toInt();
        setState(() {
          betValue = "$amount";
        });
      } else {
        var listOfSelectedNosMapLength = listOfSelectedNosMap["$rangeObjectIndex"]?.length ?? 0;
        var mMinSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["minSelectionLimit"] ?? 0;
        if (listOfSelectedNosMapLength >= mMinSelectionLimit) {
          if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
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
            int amount = (int.parse(selectedBetAmount) * getNumberOfLines());
            if(widget.particularGameObjects?.gameCode == "DailyLotto"){
              double totalDoubleJackpotCost = isDoubleJackpotEnabled ? amount * (doubleJackpotCost ?? 0) : 0;
              double totalSecureJackpotCost =  isSecureJackpotEnabled ? (amount * (secureJackpotCost ?? 0)) : 0;
              double betValueCost = amount + totalDoubleJackpotCost + totalSecureJackpotCost;
              setState(() {
                betValue = "$betValueCost";
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
  }

  int getNumberOfLines() {
    var listOfSelectedNosMapListLength = listOfSelectedNosMap["$mRangeObjectIndex"]?.length ?? 0;

    if (selectedPickTypeObject.code?.toUpperCase() == "Perm2".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 2);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm3".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 3);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm4".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 4);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm5".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 5);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm6".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 6);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm7".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 7);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm8".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 8);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Perm9".toUpperCase()) {
      return nCr(listOfSelectedNosMapListLength, 9);
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
      var upperLineNosList = listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [];
      var lowerLineNosList = listOfSelectedUpperLowerLinesNosMap["$mRangeObjectIndex"]?.where((element) => element.isSelectedInUpperLine == false).toList() ?? [];

      return upperLineNosList.length * lowerLineNosList.length;
    }
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker1AgainstAll".toUpperCase()) {
      return 89;
    }
    return 1;
  }

  selectedPickTypeData(PickType mPickType) {
    log("-------> PickType Name : ${mPickType.name}");
    setState(() {
      selectedPickTypeObject                  = mPickType;
      ballPickInstructions                    = mPickType.description ?? "Please select numbers";
      selectedPickType.clear();
      selectedPickType[mPickType.name ?? ""]  = true;
      reset();

      if (mPickType.name?.toUpperCase() == "QP".toUpperCase()) {
        setNoPickLimits(mPickType);

        List<Range1> pickTypeRangeList = mPickType.range ?? [];
        if(pickTypeRangeList.isNotEmpty) {
          for(int i = 0; i< pickTypeRangeList.length ;i++) {
            var minSLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
            var maxSLimit = ballPickingLimits["$i"]?["maxSelectionLimit"] ?? 0;
            log("rangeObjectIndex : $i | minLimit : ${ballPickingLimits["$i"]?["minSelectionLimit"]} | maxLimit : ${ballPickingLimits["$i"]?["maxSelectionLimit"]}");
            if (minSLimit == maxSLimit) {
              qpGenerator(widget.particularGameObjects?.numberConfig?.range?[i].ball ?? [], maxSLimit, rangeObjectIndex: i);
            }
          }
        }
      }
      else if(mPickType.name?.toUpperCase() == "Perm QP".toUpperCase()) {
        int pickTypeRangeCount = mPickType.range?.length ?? 0;
        setNoPickLimits(mPickType);
        setState(() {
          if(pickTypeRangeCount > 1) {
            isMultiplePickType = true;
            getPermRangeList(mPickType);

          } else {
            isMultiplePickType = false;
            mMultiplePickTypeIndex = 0;
            setPermQpList();
          }
        });

        if (_pickController.state?.isFront == true) {
          _pickController.toggleCard();
        }
      }
      else if (mPickType.name?.toUpperCase() == "Banker".toUpperCase()) {
        setNoPickLimitsForBanker(isUpperLine ? true : false, mPickType);
        setState(() {
          isBankerPickType = true;
        });
        if (_pickController.state?.isFront == true) {
          _pickController.toggleCard();
        }

      }
      else {
        setNoPickLimits(selectedPickTypeObject);
      }

      if (mPickType.range?[0].pickMode?.toUpperCase() == "FixedSet".toUpperCase()) {
        setNoPickLimits(mPickType);
        List<Range1> pickTypeRangeList = mPickType.range ?? [];

        if(pickTypeRangeList.isNotEmpty) {
          for(int i = 0; i< pickTypeRangeList.length ;i++) {
            var minSLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
            var maxSLimit = ballPickingLimits["$i"]?["maxSelectionLimit"] ?? 0;
            log("rangeObjectIndex : $i | minLimit : ${ballPickingLimits["$i"]?["minSelectionLimit"]} | maxLimit : ${ballPickingLimits["$i"]?["maxSelectionLimit"]}");
            if (minSLimit == maxSLimit) {
              List<String> pickedNosList = [];
              pickedNosList = selectedPickTypeObject.range?[i].pickValue?.split(",") ?? [];

              if (pickedNosList.isNotEmpty == true) {
                qpWithFixedNoGeneratorForLabeledGame(pickedNosList, maxSLimit, rangeObjectIndex: i);
                //qpWithFixedNoGenerator(pickedNosList, maxSLimit, rangeObjectIndex: i);
              }
            }
          }
        }
      }
      if (mPickType.code?.toUpperCase().contains("HOT") == true) {
        setNoPickLimits(mPickType);

        List<Range1> pickTypeRangeList = mPickType.range ?? [];
        if(pickTypeRangeList.isNotEmpty) {
          for(int i = 0; i< pickTypeRangeList.length ;i++) {
            var minSLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
            var maxSLimit = ballPickingLimits["$i"]?["maxSelectionLimit"] ?? 0;
            log("rangeObjectIndex : $i | minLimit : ${ballPickingLimits["$i"]?["minSelectionLimit"]} | maxLimit : ${ballPickingLimits["$i"]?["maxSelectionLimit"]}");
            if (minSLimit == maxSLimit) {
              var replacedStringList = widget.particularGameObjects?.hotNumbers?.replaceAll("[", "").replaceAll("]", "").replaceAll(" ", "").split(",") ?? [];
              if (replacedStringList.isNotEmpty == true) {
                qpWithFixedNoGenerator(replacedStringList, maxSLimit, rangeObjectIndex: i);
              }
            }
          }
        }
      }
      if (mPickType.code?.toUpperCase().contains("COLD") == true) {
        setNoPickLimits(mPickType);

        List<Range1> pickTypeRangeList = mPickType.range ?? [];
        if(pickTypeRangeList.isNotEmpty) {
          for(int i = 0; i< pickTypeRangeList.length ;i++) {
            var minSLimit = ballPickingLimits["$i"]?["minSelectionLimit"] ?? 0;
            var maxSLimit = ballPickingLimits["$i"]?["maxSelectionLimit"] ?? 0;
            log("rangeObjectIndex : $i | minLimit : ${ballPickingLimits["$i"]?["minSelectionLimit"]} | maxLimit : ${ballPickingLimits["$i"]?["maxSelectionLimit"]}");
            if (minSLimit == maxSLimit) {
              var replacedStringList = widget.particularGameObjects?.coldNumbers?.replaceAll("[", "").replaceAll("]", "").replaceAll(" ", "").split(",") ?? [];
              if (replacedStringList.isNotEmpty == true) {
                qpWithFixedNoGenerator(replacedStringList, maxSLimit, rangeObjectIndex: i);
              }
            }
          }
        }
      }
    });
  }

  List<QuickPickBetAmountBean> setPermQpList({int rangeObjectIndex=0}) {
    var mMinSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["minSelectionLimit"] ?? 0;
    var mMaxSelectionLimit = ballPickingLimits["$rangeObjectIndex"]?["maxSelectionLimit"] ?? 0;
    listQuickPick.clear();
    for (int count=mMinSelectionLimit; count <= mMaxSelectionLimit; count++) {
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
      for(int i=0; i< range1.length; i++) {
        setState(() {
          ballPickingLimits["$i"] = {
            "minSelectionLimit" : int.parse(range1[i].pickCount?.split(",")[0].toString() ?? "0"),
            "maxSelectionLimit" : int.parse(range1[i].pickCount?.split(",")[1].toString() ?? "0"),
          };

          minSelectionLimit = int.parse(selectedPickTypeObject.range?[0].pickCount?.split(",")[0] ?? "0");
          maxSelectionLimit = int.parse(selectedPickTypeObject.range?[0].pickCount?.split(",")[1] ?? "0");
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

  setNoPickLimitsForBanker(bool isUpperLine, PickType pickType) {
    List<Range1> range1 = pickType.range ?? [];
    if (range1.isNotEmpty) {
      for(int i=0; i< range1.length; i++) {
        setState(() {
          ballPickingLimits["$i"] = {
            "minSelectionLimit" : int.parse(range1[i].pickCount?.split("-")[isUpperLine ? 0 : 1].split(",")[0] ?? "0"),
            "maxSelectionLimit" : int.parse(range1[i].pickCount?.split("-")[isUpperLine ? 0 : 1].split(",")[1] ?? "0")
          };
        });
      }
      log("limits::$ballPickingLimits");

    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("No Pick Type Available."),
      ));
    }

  }

  switchToPickType(String pickCode) {
    print("switchToPickType: $switchToPickType");
    if (selectedBetTypeData != null) {
      List<PickType> pickTypeList = getPickTypeWithQp(betRespVOs: selectedBetTypeData);
      setState(() {
        for (int index = 0; index < pickTypeList.length; index++) {

          PickType pickedType     = pickTypeList[index];
          if (pickedType.code?.toUpperCase() == pickCode.toUpperCase()) {
            ballPickInstructions = pickedType.description ?? "Please select numbers";
            selectedPickTypeObject = pickedType;
            setNoPickLimits(pickTypeList[index]);
            selectedPickTypeData(getPickTypeWithQp()[index]);
            break;
          }
        }      });
    }
  }

  reset() {
    setState(() {
      listOfSelectedNosMap = {};
      for (int i=0; i< listOfSelectedUpperLowerLinesNosMap.length; i++) {
        var listOfSelectedUpperLowerLinesNosList = listOfSelectedUpperLowerLinesNosMap["$i"] ?? [];
        listOfSelectedUpperLowerLinesNosList.clear();
      }

      isUpperLine = true;
      betValue = "0";
      lowerLineBankerPickedNoIndex  = 0;
      upperLineBankerPickedNoIndex  = 0;
      selectedNumberAndSlabList     = {};
      if(_controller.state?.isFront == false) {
        _controller.state?.toggleCard();
      }
    });
  }

  bool isBallAvailable(List<String> ballList, int index, int rangeObjectIndex) {
    if (ballList.contains(widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index].number)) {
      return true;
    }
    return false;
  }

  Color getBallColor(List<String> ballList, int index, int rangeObjectIndex) {
    var colorName = "";
    if (ballList.contains(widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index].number)) {

      if (widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index].color.isNotEmptyAndNotNull == true) {
        colorName = widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index].color ?? "";

      } else {
        colorName = "NO_COLOR";
      }
    }
    return getColors(colorName) ?? Colors.transparent;
  }

  bool isBankerBallNoAvailable(List<BankerBean> ballList, int index, int rangeObjectIndex) {
    var ballDetails = ballList.where((element) => element.number == widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index].number).toList();

    if (ballDetails.isNotEmpty) {
      return true;
    }
    return false;
  }

  Color getBallBankersNoColor(List<BankerBean> ball, int index, int rangeObjectIndex) {
    var colorName = "";

    var ballDetails = ball.where((element) => element.number == widget.particularGameObjects?.numberConfig?.range?[rangeObjectIndex].ball?[index].number).toList();
    if(ballDetails.isNotEmpty) {
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
    selectedPickType            = {selectedPickTypeObject.name ?? "Manual": true};
    selectedBetTypeData         = widget.betRespV0s!;
    ballPickInstructions        = widget.pickType?[0].description ?? "Please select numbers";

    ballObjectsRange            = widget.particularGameObjects?.numberConfig?.range ?? [];
    var ballObjectsRangeLength  = ballObjectsRange?.isNotEmpty == true ? ballObjectsRange?.length ?? 0 : 0;
    for(int i = 0; i < ballObjectsRangeLength; i++) {
      if (ballObjectsRange?[i] != null) {
        ballObjectsMap["$i"] = ballObjectsRange![i];
      }
    }
    for (int i=0; i< ballObjectsMap.length ; i++) {
      getColorListLength(ballObjectsMap, i);
    }

    lotteryGameMainBetList = widget.particularGameObjects?.betRespVOs?.where((element) => element.winMode == "MAIN").toList()   ?? [];
    print("lotteryGameMainBetList --> $lotteryGameMainBetList");

    lotteryGameSideBetList = widget.particularGameObjects?.betRespVOs?.where((element) => element.winMode == "COLOR").toList()  ?? [];
  }

  checkIsPowerBallPlusEnabled() {
    List<PanelBean> powerPlusEnabledAvailable = widget.mPanelBinList?.where((element) => element.isPowerBallPlus == true).toList() ?? [];
    if (powerPlusEnabledAvailable.isNotEmpty) {
      isPowerBallPlus = true;
    }
  }

  setInitialBetAmount() {
    if (listBetAmount.isNotEmpty) {
      selectedBetAmount   = "${listBetAmount[0].amount ?? 0}";
      selectedBetAmountValue[listBetAmount[0].amount.toString()] = true;

    } else {
      selectedBetAmount   = "0";
    }
  }

  addBet() {
    PanelBean model = PanelBean();
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
      List<BankerBean> upperLineNosObjectList = [], lowerLineNosObjectList = [];

      for (int i=0; i< listOfSelectedUpperLowerLinesNosMap.length; i++) {
        List<BankerBean> listOfSelectedUpperLowerLinesNosList = listOfSelectedUpperLowerLinesNosMap["$i"] ?? [];
        upperLineNosObjectList            = listOfSelectedUpperLowerLinesNosList.where((element) => element.isSelectedInUpperLine == true).toList();
        lowerLineNosObjectList            = listOfSelectedUpperLowerLinesNosList.where((element) => element.isSelectedInUpperLine == false).toList();
      }

      List<String> listLowerLine = [];
      for (BankerBean i in  lowerLineNosObjectList) {
        if (i.number != null) {
          listLowerLine.add(i.number!);
        }
      }

      String? pickedValues                    = "${upperLineNosObjectList[0].number}-${listLowerLine.join(",")}";
      model.listSelectedNumberUpperLowerLine  = [listOfSelectedUpperLowerLinesNosMap];
      model.pickedValue                       = pickedValues;

    } else {
      String pickedValues = "";

      if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
        String pickedValue = "";
        for (var key in selectedNumberAndSlabList.keys) {
          if (key.length == 3) {
            pickedValue = key.characters.join("#");
          } else {
            pickedValue = "-1#" * (3 - key.length) + key.characters.join("#");
          }

          mThaiLotteryPanelBinList?.add(
              PanelData(
                  pickedValues: pickedValue,
                  currentPayout: double.parse((selectedNumberAndSlabList[key] ?? "0")),
                  totalNumbers: key.length,
                  betType: selectedBetTypeData?.betCode,
                  betAmountMultiple: double.parse(betValue) ~/ selectedNumberAndSlabList.length,
                  pickConfig: selectedPickTypeObject.range?[0].pickConfig,
                  pickType: widget.betRespV0s?.pickTypeData?.pickType?[0].code ?? "",
                  qpPreGenerated: false,
                  quickPick: false
              )
          );
        }

        widget.mapThaiLotteryPanelBinList?.add(mThaiLotteryPanelBinList);
        print("ans================>${widget.mapThaiLotteryPanelBinList}");
      }
      else {
        if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
          var listOfSelectedNosLength = listOfSelectedNosMap.length;
          List<String> pkV = [];
          for(int i=0; i<listOfSelectedNosLength; i++) {
            var afterJoinPickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
            if (afterJoinPickedValues.isNotEmpty) {
              pkV.add(afterJoinPickedValues);
            }
          }
          pickedValues = pkV.join("#");

        } else {
          var listOfSelectedNosLength = listOfSelectedNosMap.length;
          for(int i=0; i<listOfSelectedNosLength; i++) {
            pickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
          }
        }

        model.listSelectedNumber  = [listOfSelectedNosMap];
        model.pickedValue         = pickedValues;
        model.isPowerBallPlus     = isPowerBallPlus;
      }
    }

    model.gameName        = widget.particularGameObjects?.gameName;
    model.amount          = double.parse(betValue);
    model.winMode         = selectedBetTypeData?.winMode;
    model.betName         = selectedBetTypeData?.betDispName;
    model.pickName        = selectedPickTypeObject.name;
    model.betCode         = selectedBetTypeData?.betCode;
    model.pickCode        = selectedPickTypeObject.code;
    model.pickConfig      = selectedPickTypeObject.range?[0].pickConfig;
    model.isPowerBallPlus = isPowerBallPlus;
    if(widget.particularGameObjects?.gameCode == "DailyLotto"){
      model.isDoubleJackpotEnabled = isDoubleJackpotEnabled;
      model.isSecureJackpotEnabled = isSecureJackpotEnabled;
      model.secureJackpotCost = secureJackpotCost;
      model.doubleJackpotCost = doubleJackpotCost;
    }

    if (selectedBetAmount != "0") {
      if (selectedBetTypeData?.unitPrice != null) {
        double mUnitPrice = selectedBetTypeData?.unitPrice ?? 1;
        model.betAmountMultiple = int.parse(selectedBetAmount) ~/ mUnitPrice;
      }
    }
    model.selectBetAmount     = int.parse(selectedBetAmount);
    model.unitPrice           = selectedBetTypeData?.unitPrice ?? 1;
    model.numberOfDraws       = 1;
    model.numberOfLines       = getNumberOfLines();
    model.isMainBet           = true;

    if (selectedPickTypeObject.name?.contains("QP") == true) {
      model.isQuickPick       = true;
      model.isQpPreGenerated  = true;

    } else {
      model.isQuickPick       = false;
      model.isQpPreGenerated  = false;
    }
    if(widget.mPanelBinList != null) {
      widget.mPanelBinList?.add(model);
    }


    if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
      print("selectedValueList===========>${mThaiLotteryPanelBinList}");
      for (PanelData i in (mThaiLotteryPanelBinList ?? [])) {
        print("dataValue ------------${i.betType}-------------->>>>${i
            .pickedValues}");
      }

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<LoginBloc>(
                    create: (BuildContext context) => LoginBloc(),
                  )
                ],
                child: PickTypeScreen(
                    gameObjectsList: widget.particularGameObjects,
                    listPanelData: widget.mPanelBinList,
                    mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList,),
              )
          )
      );

    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<LoginBloc>(
                    create: (BuildContext context) => LoginBloc(),
                  )
                ],
                child: PickTypeScreen(gameObjectsList: widget.particularGameObjects, listPanelData: widget.mPanelBinList),
              )
          )
      );
    }

  }

  addBetIfOnly1BetType() {
    PanelBean model = PanelBean();
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
      List<BankerBean> upperLineNosObjectList = [], lowerLineNosObjectList = [];

      for (int i=0; i< listOfSelectedUpperLowerLinesNosMap.length; i++) {
        List<BankerBean> listOfSelectedUpperLowerLinesNosList = listOfSelectedUpperLowerLinesNosMap["$i"] ?? [];
        upperLineNosObjectList            = listOfSelectedUpperLowerLinesNosList.where((element) => element.isSelectedInUpperLine == true).toList();
        lowerLineNosObjectList            = listOfSelectedUpperLowerLinesNosList.where((element) => element.isSelectedInUpperLine == false).toList();
      }

      List<String> listLowerLine = [];
      for (BankerBean i in  lowerLineNosObjectList) {
        if (i.number != null) {
          listLowerLine.add(i.number!);
        }
      }

      String? pickedValues                    = "${upperLineNosObjectList[0].number}-${listLowerLine.join(",")}";
      model.listSelectedNumberUpperLowerLine  = [listOfSelectedUpperLowerLinesNosMap];
      model.pickedValue                       = pickedValues;

    } else {
      String pickedValues = "";

      if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
        String pickedValue = "";
        for (var key in selectedNumberAndSlabList.keys) {
          if (key.length == 3) {
            pickedValue = key.characters.join("#");
          } else {
            pickedValue = "-1#" * (3 - key.length) + key.characters.join("#");
          }

          mThaiLotteryPanelBinList?.add(
              PanelData(
                  pickedValues: pickedValue,
                  currentPayout: double.parse((selectedNumberAndSlabList[key] ?? "0")),
                  totalNumbers: key.length,
                  betType: selectedBetTypeData?.betCode,
                  betAmountMultiple: double.parse(betValue) ~/ selectedNumberAndSlabList.length,
                  pickConfig: selectedPickTypeObject.range?[0].pickConfig,
                  pickType: widget.betRespV0s?.pickTypeData?.pickType?[0].code ?? "",
                  qpPreGenerated: false,
                  quickPick: false
              )
          );
        }

        widget.mapThaiLotteryPanelBinList?.add(mThaiLotteryPanelBinList);
        print("ans================>${widget.mapThaiLotteryPanelBinList}");
      }
      else {
        if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
          var listOfSelectedNosLength = listOfSelectedNosMap.length;
          List<String> pkV = [];
          for(int i=0; i<listOfSelectedNosLength; i++) {
            var afterJoinPickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
            if (afterJoinPickedValues.isNotEmpty) {
              pkV.add(afterJoinPickedValues);
            }
          }
          pickedValues = pkV.join("#");

        } else {
          var listOfSelectedNosLength = listOfSelectedNosMap.length;
          for(int i=0; i<listOfSelectedNosLength; i++) {
            pickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
          }
        }

        model.listSelectedNumber  = [listOfSelectedNosMap];
        model.pickedValue         = pickedValues;
        model.isPowerBallPlus     = isPowerBallPlus;
      }
    }

    model.gameName        = widget.particularGameObjects?.gameName;
    model.amount          = double.parse(betValue);
    model.winMode         = selectedBetTypeData?.winMode;
    model.betName         = selectedBetTypeData?.betDispName;
    model.pickName        = selectedPickTypeObject.name;
    model.betCode         = selectedBetTypeData?.betCode;
    model.pickCode        = selectedPickTypeObject.code;
    model.pickConfig      = selectedPickTypeObject.range?[0].pickConfig;
    model.isPowerBallPlus = isPowerBallPlus;
    if(widget.particularGameObjects?.gameCode == "DailyLotto"){
      model.isDoubleJackpotEnabled = isDoubleJackpotEnabled;
      model.isSecureJackpotEnabled = isSecureJackpotEnabled;
      model.secureJackpotCost = secureJackpotCost;
      model.doubleJackpotCost = doubleJackpotCost;
    }

    if (selectedBetAmount != "0") {
      if (selectedBetTypeData?.unitPrice != null) {
        double mUnitPrice = selectedBetTypeData?.unitPrice ?? 1;
        model.betAmountMultiple = int.parse(selectedBetAmount) ~/ mUnitPrice;
      }
    }
    model.selectBetAmount     = int.parse(selectedBetAmount);
    model.unitPrice           = selectedBetTypeData?.unitPrice ?? 1;
    model.numberOfDraws       = 1;
    model.numberOfLines       = getNumberOfLines();
    model.isMainBet           = true;

    if (selectedPickTypeObject.name?.contains("QP") == true) {
      model.isQuickPick       = true;
      model.isQpPreGenerated  = true;

    } else {
      model.isQuickPick       = false;
      model.isQpPreGenerated  = false;
    }
    if(widget.mPanelBinList != null) {
      widget.mPanelBinList?.add(model);
    }


    if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
      print("selectedValueList===========>${mThaiLotteryPanelBinList}");
      for (PanelData i in (mThaiLotteryPanelBinList ?? [])) {
        print("dataValue ------------${i.betType}-------------->>>>${i
            .pickedValues}");
      }

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<LoginBloc>(
                    create: (BuildContext context) => LoginBloc(),
                  )
                ],
                child: PickTypeScreen(
                    gameObjectsList: widget.particularGameObjects,
                    listPanelData: widget.mPanelBinList,
                    mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList),
              )
          )
      );

    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>  MultiBlocProvider(
                providers: [
                  BlocProvider<LotteryBloc>(
                    create: (BuildContext context) => LotteryBloc(),
                  )
                ],
                child: GameScreen(particularGameObjects: widget.particularGameObjects, pickType: widget.betRespV0s?.pickTypeData?.pickType ?? [], betRespV0s: widget.betRespV0s, mPanelBinList: widget.mPanelBinList ?? [])),
          )
      );
    }
  }

  addBetIf1BetType() {
    PanelBean model = PanelBean();
    if (selectedPickTypeObject.code?.toUpperCase() == "Banker".toUpperCase()) {
      List<BankerBean> upperLineNosObjectList = [], lowerLineNosObjectList = [];

      for (int i=0; i< listOfSelectedUpperLowerLinesNosMap.length; i++) {
        List<BankerBean> listOfSelectedUpperLowerLinesNosList = listOfSelectedUpperLowerLinesNosMap["$i"] ?? [];
        upperLineNosObjectList            = listOfSelectedUpperLowerLinesNosList.where((element) => element.isSelectedInUpperLine == true).toList();
        lowerLineNosObjectList            = listOfSelectedUpperLowerLinesNosList.where((element) => element.isSelectedInUpperLine == false).toList();
      }

      List<String> listLowerLine = [];
      for (BankerBean i in  lowerLineNosObjectList) {
        if (i.number != null) {
          listLowerLine.add(i.number!);
        }
      }

      String? pickedValues                    = "${upperLineNosObjectList[0].number}-${listLowerLine.join(",")}";
      model.listSelectedNumberUpperLowerLine  = [listOfSelectedUpperLowerLinesNosMap];
      model.pickedValue                       = pickedValues;

    } else {
      String pickedValues = "";

      if (widget.particularGameObjects?.gameCode == "ThaiLottery") {
        String pickedValue = "";
        for (var key in selectedNumberAndSlabList.keys) {
          if (key.length == 3) {
            pickedValue = key.characters.join("#");
          } else {
            pickedValue = "-1#" * (3 - key.length) + key.characters.join("#");
          }

          mThaiLotteryPanelBinList?.add(
              PanelData(
                  pickedValues: pickedValue,
                  currentPayout: double.parse((selectedNumberAndSlabList[key] ?? "0")),
                  totalNumbers: key.length,
                  betType: selectedBetTypeData?.betCode,
                  betAmountMultiple: double.parse(betValue) ~/ selectedNumberAndSlabList.length,
                  pickConfig: selectedPickTypeObject.range?[0].pickConfig,
                  pickType: widget.betRespV0s?.pickTypeData?.pickType?[0].code ?? "",
                  qpPreGenerated: false,
                  quickPick: false
              )
          );
        }

        widget.mapThaiLotteryPanelBinList?.add(mThaiLotteryPanelBinList);
        print("ans================>${widget.mapThaiLotteryPanelBinList}");
      }
      else {
        if (widget.particularGameObjects?.familyCode?.toUpperCase() == "MultiSet".toUpperCase()) {
          var listOfSelectedNosLength = listOfSelectedNosMap.length;
          List<String> pkV = [];
          for(int i=0; i<listOfSelectedNosLength; i++) {
            var afterJoinPickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
            if (afterJoinPickedValues.isNotEmpty) {
              pkV.add(afterJoinPickedValues);
            }
          }
          pickedValues = pkV.join("#");

        } else {
          var listOfSelectedNosLength = listOfSelectedNosMap.length;
          for(int i=0; i<listOfSelectedNosLength; i++) {
            pickedValues = listOfSelectedNosMap["$i"]?.join(',') ?? "";
          }
        }

        model.listSelectedNumber  = [listOfSelectedNosMap];
        model.pickedValue         = pickedValues;
        model.isPowerBallPlus     = isPowerBallPlus;
      }
    }

    model.gameName        = widget.particularGameObjects?.gameName;
    model.amount          = double.parse(betValue);
    model.winMode         = selectedBetTypeData?.winMode;
    model.betName         = selectedBetTypeData?.betDispName;
    model.pickName        = selectedPickTypeObject.name;
    model.betCode         = selectedBetTypeData?.betCode;
    model.pickCode        = selectedPickTypeObject.code;
    model.pickConfig      = selectedPickTypeObject.range?[0].pickConfig;
    model.isPowerBallPlus = isPowerBallPlus;
    if(widget.particularGameObjects?.gameCode == "DailyLotto"){
      model.isDoubleJackpotEnabled = isDoubleJackpotEnabled;
      model.isSecureJackpotEnabled = isSecureJackpotEnabled;
      model.secureJackpotCost = secureJackpotCost;
      model.doubleJackpotCost = doubleJackpotCost;
    }

    if (selectedBetAmount != "0") {
      if (selectedBetTypeData?.unitPrice != null) {
        double mUnitPrice = selectedBetTypeData?.unitPrice ?? 1;
        model.betAmountMultiple = int.parse(selectedBetAmount) ~/ mUnitPrice;
      }
    }
    model.selectBetAmount     = int.parse(selectedBetAmount);
    model.unitPrice           = selectedBetTypeData?.unitPrice ?? 1;
    model.numberOfDraws       = 1;
    model.numberOfLines       = getNumberOfLines();
    model.isMainBet           = true;

    if (selectedPickTypeObject.name?.contains("QP") == true) {
      model.isQuickPick       = true;
      model.isQpPreGenerated  = true;

    } else {
      model.isQuickPick       = false;
      model.isQpPreGenerated  = false;
    }
    if(widget.mPanelBinList != null) {
      setState(() {
        widget.mPanelBinList?.add(model);
      });
    }

  }

  int getColorListLength(Map<String, dynamic> ballObjectsMap, int index) {
    Range? rangeBall      = ballObjectsMap["$index"];
    List<Ball>? ballList  =  rangeBall?.ball ?? [];
    lotteryGameColorList.clear();
    if (ballList.isNotEmpty) {
      for (Ball ballDetails in ballList) {
        if (ballDetails.color != null && ballDetails.color != "") {
          if(getColors(ballDetails.color!) != null) {
            if (!lotteryGameColorList.contains(getColors(ballDetails.color!)) ) {
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
    int totalBall   = getMaxBallLimit(ballObjectsMap , index);
    int columnCount = 9;

    if(lotteryGameColorList.isEmpty) {
      for(int j=7; j<=10; j++) {
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

    List<Ball>? ballList =  rangeBall?.ball ?? [];
    if (ballList.isNotEmpty) {
      return ballList.length;
    }
    return 0;
  }

  qpGenerator(List<Ball> numberConfig, int numbersToBeQp, {int rangeObjectIndex = 0}) {
    setState(() {
      mIsQpSelecting = true;
      _inOutAnimationController.forward();
    });

    for(int i=0;i<rangeObjectIndex +1;i++) {}
    math.Random random = math.Random();
    List<String> listOfQpNumber = [];
    while(listOfQpNumber.length < numbersToBeQp) {
      String randomNo = (random.nextInt(numberConfig.length) + 1).toString();
      if (!listOfQpNumber.contains(randomNo)) {
        listOfQpNumber.add(randomNo);
      }
    }

    //reset();
    setState(() {
      var listOfSelectedNosList = listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
      listOfSelectedNosList.clear();
    });

    setQpDelay(listOfQpNumber, rangeObjectIndex: rangeObjectIndex);
  }

  qpWithFixedNoGeneratorForLabeledGame(List<String> numbersPicked, int numbersToBeQp, {int rangeObjectIndex = 0}) {
    List<String> listOfQpNumber = [];
    listOfQpNumber = numbersPicked;

    reset();
    widget.mPanelBinList?.clear();

    for (String i in listOfQpNumber) {
      var listOfSelectedNosList = listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
      listOfSelectedNosList.add(i);
      listOfSelectedNosMap["$rangeObjectIndex"] = listOfSelectedNosList;
    }

    print("listOfSelectedNosMap: $listOfSelectedNosMap");
    var numbers = listOfSelectedNosMap["0"]?.join(",") ?? "";
    setState(() {
      betValue = selectedBetAmount;
    });
    addBetLabelledGamePanel(numbers);
  }

  qpWithFixedNoGenerator(List<String> numbersPicked, int numbersToBeQp, {int rangeObjectIndex = 0}) {
    setState(() {
      mIsQpSelecting = true;
      _inOutAnimationController.forward();
    });

    List<String> listOfQpNumber = [];
    listOfQpNumber = numbersPicked;

    setState(() {
      var listOfSelectedNosList = listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
      listOfSelectedNosList.clear();
    });

    setQpDelay(listOfQpNumber, rangeObjectIndex: rangeObjectIndex);
  }

  setQpDelay(List<String> listOfQpNumber, {rangeObjectIndex = 0}) {
    Timer(const Duration(seconds: 1), () {
      setState(() {
        mIsQpSelecting = false;
        for (String i in listOfQpNumber) {
          var listOfSelectedNosList = listOfSelectedNosMap["$rangeObjectIndex"] ?? [];
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
  double getCurrentSlab(String no){
    double currentSlabResult = 0;
    currentSlabList.forEach((element) {
      if (element.numbers != null) {
        if (element.numbers!.contains(no)){
          currentSlabResult = (element.slabPrizeValue ?? 0);
        }
      }
    });
    return currentSlabResult;
  }

  String formatSlab(String slab){
    List<String> num = slab.split(".");
    if ((num.length > 1) && (num[1] != "0")){
      return slab.toString();
    } else {
      return num[0];
    }
  }

  dottedLine() {
    return Container(
      decoration: DottedDecoration(
        color: WlsPosColor.ball_border_bg,
        strokeWidth: 0.5,
        linePosition: LinePosition.bottom,
      ),
      height:12,
      width: MediaQuery.of(context).size.width,
    );
  }

  void setEditData(PanelBean? mEditPanelData) {
    setState(() {
      editPanelBeanData = mEditPanelData;
      isEdit = true;
      var pickTypeObject = getPickTypeWithQp().where((element) => element.name == mEditPanelData?.pickName).toList();
      selectedPickTypeObject = pickTypeObject[0];
      setNoPickLimits(selectedPickTypeObject);
      listOfSelectedNosMap        = mEditPanelData?.listSelectedNumber?[0] ?? {};
      selectedPickType            = {mEditPanelData?.pickName ?? "Manual": true};
      selectedBetTypeData         = widget.betRespV0s!;
      ballPickInstructions        = pickTypeObject[0].description ?? "Please select numbers";

      selectedBetAmountValue.clear();
      int selectedBetAmtTemp = mEditPanelData?.selectBetAmount ?? 1;
      selectedBetAmountValue["$selectedBetAmtTemp"] = true;
      selectedBetAmount = "$selectedBetAmtTemp";
      betValue = "${mEditPanelData?.amount?.toInt()}";

      log("setEditData: listOfSelectedNosMap:$listOfSelectedNosMap");
      log("setEditData: listOfSelectedNosMap:$listOfSelectedNosMap");
    });
  }

  int getNoOfParticularPanelCount(String number) {
    return widget.mPanelBinList?.where((element) => element.pickedValue?.contains(number) == true).toList().length ?? 0;
    return widget.mPanelBinList?.where((element) => element.pickedValue == number).toList().length ?? 0;
  }

  deleteBetLabelledGamePanel(String number) {
    List<PanelBean>? panelDataObjectList = widget.mPanelBinList?.where((element) => element.pickedValue == number).toList();
    if (panelDataObjectList?.isNotEmpty == true) {
      setState(() {
        if (widget.mPanelBinList?.isNotEmpty == true) {
          widget.mPanelBinList?.remove(panelDataObjectList?[0]);
        }
      });
    }
    log("after delete :deleteBetLabelledGamePanel: ${jsonEncode(widget.mPanelBinList)}");
  }

  addBetLabelledGamePanel(String number) {
    PanelBean model = PanelBean();

    model.listSelectedNumber  = [listOfSelectedNosMap];
    model.pickedValue         = number;
    model.isPowerBallPlus     = isPowerBallPlus;

    model.gameName        = widget.particularGameObjects?.gameName;
    model.amount          = double.parse(betValue);
    model.winMode         = selectedBetTypeData?.winMode;
    model.betName         = selectedBetTypeData?.betDispName;
    model.pickName        = selectedPickTypeObject.name;
    model.betCode         = selectedBetTypeData?.betCode;
    model.pickCode        = selectedPickTypeObject.code;
    model.pickConfig      = selectedPickTypeObject.range?[0].pickConfig;
    model.isPowerBallPlus = isPowerBallPlus;

    if (selectedBetAmount != "0") {
      if (selectedBetTypeData?.unitPrice != null) {
        double mUnitPrice = selectedBetTypeData?.unitPrice ?? 1;
        model.betAmountMultiple = int.parse(selectedBetAmount) ~/ mUnitPrice;
      }
    }
    model.selectBetAmount     = int.parse(selectedBetAmount);
    model.unitPrice           = selectedBetTypeData?.unitPrice ?? 1;
    model.numberOfDraws       = 1;
    model.numberOfLines       = getNumberOfLines();
    setState(() {
      if(widget.mPanelBinList != null) {
        widget.mPanelBinList?.add(model);
      }
    });
    log("after ADD :addBetLabelledGamePanel: ${jsonEncode(widget.mPanelBinList)}");

  }

  void reConfigurePanelDataWithNewAmt() {
    List<PanelBean> panelDataList = widget.mPanelBinList ?? [];
    for(int i=0; i< panelDataList.length;i++) {
      widget.mPanelBinList?[i].selectBetAmount = int.parse(selectedBetAmount);
      widget.mPanelBinList?[i].amount          = double.parse(betValue);
      if (selectedBetAmount != "0") {
        if (selectedBetTypeData?.unitPrice != null) {
          double mUnitPrice = selectedBetTypeData?.unitPrice ?? 1;
          widget.mPanelBinList?[i].betAmountMultiple = int.parse(selectedBetAmount) ~/ mUnitPrice;
        }
      }
    }
    setState(() {
      betValue = selectedBetAmount;
    });
  }
}


