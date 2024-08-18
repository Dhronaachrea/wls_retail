import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/lottery/bloc/lottery_bloc.dart';
import 'package:wls_pos/lottery/models/request/saleRequestBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/preview_game_screen.dart';
import 'package:wls_pos/lottery/side_game_screen.dart';
import 'package:wls_pos/lottery/two_d_myanmaar/two_d_myanmaar.dart';
import 'package:wls_pos/lottery/two_d_myanmaar/widget/select_series_number.dart';
import 'package:wls_pos/lottery/widgets/added_bet_cart_msg.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import '../login/bloc/login_bloc.dart';
import '../login/bloc/login_event.dart';
import '../utility/auth_bloc/auth_bloc.dart';
import 'lottery_game_screen.dart';
import 'models/otherDataClasses/betAmountBean.dart';

/*
    created by Rajneesh Kr.Sharma on 7 May, 23
*/

class PickTypeScreen extends StatefulWidget {
  late GameRespVOs? gameObjectsList;
  List<PanelBean>? listPanelData;
  List<List<PanelData>?>? mapThaiLotteryPanelBinList;
  PickTypeScreen({Key? key, this.gameObjectsList, this.listPanelData, this.mapThaiLotteryPanelBinList}) : super(key: key);

  @override
  State<PickTypeScreen> createState() => _PickTypeScreenState();
}

class _PickTypeScreenState extends State<PickTypeScreen> {
  List<BetRespVOs>? lotteryGameMainBetList    = [];
  List<BetRespVOs>? lotteryGameSideBetList    = [];
  final bool _mIsShimmerLoading               = false;
  String totalAmount                          = "0";
  var maxPanelAllowed                         = 0;
  var listOfPanelDataLength                   = 0;
  List<BetRespVOs> lotteryGame3DList    = [];
  List<BetRespVOs> lotteryGame2DList    = [];
  List<BetRespVOs> lotteryGame1DList    = [];
  List<String> lastResultDetail         = [];
  List<List<PanelData>?>? lastPanelSoldData = [];
  bool mFetchGameDataLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
    if (widget.gameObjectsList?.gameCode == "ThaiLottery" && widget.mapThaiLotteryPanelBinList == null ) {
      BlocProvider.of<LoginBloc>(context).add(FetchGameDataApi(context: context, gameCodeList: ["ThaiLottery"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WillPopScope(
      onWillPop: () async {
        return widget.listPanelData == null || widget.listPanelData?.isEmpty == true;
      },
      child: Stack(
        children: [
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is GetLoginDataSuccess) {
                print("updated---------------------------------------------------------");
                if (state.response != null) {
                  BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: state.response!));
                }

              }
              if (state is FetchGameLoading) {
                setState(() {
                  mFetchGameDataLoading = true;
                });
              }
              else if (state is FetchGameSuccess) {
                setState(() {
                  mFetchGameDataLoading = false;
                  List<GameRespVOs?> lotteryGameObjectList = state.response.responseData?.gameRespVOs ?? [];
                  if(lotteryGameObjectList.isNotEmpty) {
                    widget.gameObjectsList = lotteryGameObjectList[0];
                    initializeData();
                  }
                });
              }
              else if (state is FetchGameError) {
                setState(() {
                  mFetchGameDataLoading = false;
                });
                if(state.errorMessage == "No connection") {

                }

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(state.errorMessage),
                ));
              }
            },
            child: WlsPosScaffold(
              showAppBar: true,
              onBackButton: (widget.listPanelData == null || widget.listPanelData?.isEmpty == true) ? null : () {
                AddedBetCartMsg().show(context: context, title: "Bet on cart !", subTitle: "You have some item in your cart. If you leave the game your cart will be cleared.", buttonText: "CLEAR", isCloseButton: true, buttonClick: () {
                  Navigator.of(context).pop();
                });
              },
              drawer: WlsPosDrawer(drawerModuleList: const []),
              backgroundColor: _mIsShimmerLoading ? WlsPosColor.light_dark_white : WlsPosColor.white,
              centerTitle: false,
              appBarTitle: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.20,
                  height: 50,
                  child: Text(widget.gameObjectsList?.gameName ?? "", style: const TextStyle(fontSize: 18, color: WlsPosColor.white), overflow: TextOverflow.visible)
              ),
              body: SafeArea(
                child: (lotteryGame3DList.isNotEmpty || lotteryGame2DList.isNotEmpty || lotteryGame3DList.isNotEmpty)
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lastResultDetailsCard(isLandscape),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          lotteryGame3DList.isNotEmpty
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "3D",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ).pOnly(left: isLandscape ? 50 : 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 2,
                                          crossAxisCount: isLandscape ? 13 : 3,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: lotteryGame3DList?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          return _mIsShimmerLoading
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
                                                    width : 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400]!,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        )
                                                    ),
                                                  ).pOnly(bottom: 10),
                                                  Container(
                                                    width : 80,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400]!,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ).pOnly(left: 18, bottom: 12),
                                          )
                                              : Ink(
                                            decoration: const BoxDecoration(
                                              color: WlsPosColor.white,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: WlsPosColor.warm_grey_six,
                                                  blurRadius: 2.0,
                                                ),
                                              ],
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                List<BetRespVOs>? betRespV0s = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode == lotteryGameMainBetList?[index].betCode).toList();

                                                print("-----------------> $betRespV0s");
                                                print("------------betRespV0s 0-----> ${betRespV0s?[0]}");
                                                if (betRespV0s != null) {
                                                  if (listOfPanelDataLength < maxPanelAllowed) {
                                                    Navigator.of(context).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (_) =>  MultiBlocProvider(
                                                              providers: [
                                                                BlocProvider<LotteryBloc>(
                                                                  create: (BuildContext context) => LotteryBloc(),
                                                                )
                                                              ],
                                                              child: GameScreen(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame3DList[index], mPanelBinList: widget.listPanelData ?? [], mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList ?? [])),
                                                        )
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                      duration: Duration(seconds: 1),
                                                      content: Text("Max panel limit reached !"),
                                                    ));
                                                  }

                                                }
                                              },
                                              customBorder: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Ink(
                                                child: Container(
                                                  width: 10,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(width: 1.8, color: Colors.red)
                                                  ),
                                                  child: Align(alignment: Alignment.center,child: Text( getPicDisplayName(lotteryGame3DList[index].betDispName ?? ""), textAlign: TextAlign.center,style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),)),
                                                ),
                                              ),
                                            ),
                                          ).pOnly(left: 10, bottom: 10);

                                        }
                                    ),
                                  ).pOnly(top: 10,right: 10),
                                ],
                              ),
                            ],
                          )
                              : Container(),

                          lotteryGame2DList.isNotEmpty
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "2D",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ).pOnly(left: isLandscape ? 50 : 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 2,
                                          crossAxisCount: isLandscape ? 13 : 3,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: lotteryGame2DList?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          return _mIsShimmerLoading
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
                                                    width : 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400]!,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        )
                                                    ),
                                                  ).pOnly(bottom: 10),
                                                  Container(
                                                    width : 80,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400]!,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ).pOnly(left: 18, bottom: 12),
                                          )
                                              : Ink(
                                            decoration: const BoxDecoration(
                                              color: WlsPosColor.white,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: WlsPosColor.warm_grey_six,
                                                  blurRadius: 2.0,
                                                ),
                                              ],
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                List<BetRespVOs>? betRespV0s = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode == lotteryGameMainBetList?[index].betCode).toList();
                                                print("-----------------> $betRespV0s");
                                                print("------------betRespV0s 0-----> ${betRespV0s?[0]}");
                                                if (betRespV0s != null) {
                                                  if (listOfPanelDataLength < maxPanelAllowed) {
                                                    if(widget.gameObjectsList?.gameCode == "TwoDMYANMAAR" && betRespV0s[0].pickTypeData?.pickType![0].code == "series"){
                                                        SelectSeriesNumber()
                                                            .show(
                                                            context: context,
                                                            title:
                                                            "Select Series Type",
                                                            buttonText: "Select",
                                                            isCloseButton: false,
                                                            listOfAmounts: [
                                                              FiveByNinetyBetAmountBean(amount: 0, isSelected: true),
                                                              FiveByNinetyBetAmountBean(amount: 1, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 2, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 3, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 4, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 5, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 6, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 7, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 8, isSelected: false),
                                                              FiveByNinetyBetAmountBean(amount: 9, isSelected: false),
                                                            ],
                                                            buttonClick: (selectedSeriesNumber) {
                                                              log("selectedSeriesNumber: $selectedSeriesNumber");
                                                              Navigator.of(context).pushReplacement(
                                                                  MaterialPageRoute(
                                                                    builder: (_) =>  MultiBlocProvider(
                                                                        providers: [
                                                                          BlocProvider<LotteryBloc>(
                                                                            create: (BuildContext context) => LotteryBloc(),
                                                                          )
                                                                        ],
                                                                        child: widget.gameObjectsList?.gameCode == "TwoDMYANMAAR" ?
                                                                        TwoDMyanmaar(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame2DList[index], mPanelBinList: widget.listPanelData ?? [],selectedSeriesNumber: selectedSeriesNumber, betCode: lotteryGame2DList[index].betCode)
                                                                            :GameScreen(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame2DList[index], mPanelBinList: widget.listPanelData ?? [], mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList ?? [],)),
                                                                  )
                                                              );
                                                              log("selectedSeriesNumber1: $selectedSeriesNumber");
                                                            });
                                                    } else {
                                                      Navigator.of(context).pushReplacement(
                                                          MaterialPageRoute(
                                                            builder: (_) =>  MultiBlocProvider(
                                                                providers: [
                                                                  BlocProvider<LotteryBloc>(
                                                                    create: (BuildContext context) => LotteryBloc(),
                                                                  )
                                                                ],
                                                                child: widget.gameObjectsList?.gameCode == "TwoDMYANMAAR" ?
                                                                lotteryGame2DList[index].betCode != "2D-direct"
                                                                    ?TwoDMyanmaar(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame2DList[index], mPanelBinList: widget.listPanelData ?? [], betCode: lotteryGame2DList[index].betCode,)
                                                                    :TwoDMyanmaar(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame2DList[index], mPanelBinList: widget.listPanelData ?? [],)
                                                                    :GameScreen(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame2DList[index], mPanelBinList: widget.listPanelData ?? [], mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList ?? [],)),
                                                          )
                                                      );
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                      duration: Duration(seconds: 1),
                                                      content: Text("Max panel limit reached !"),
                                                    ));
                                                  }

                                                }
                                              },
                                              customBorder: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Ink(
                                                child: Container(
                                                  width: 10,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(width: 1.8, color: Colors.red)
                                                  ),
                                                  child: Align(alignment: Alignment.center,child: Text( getPicDisplayName(lotteryGame2DList[index].betDispName ?? ""), textAlign: TextAlign.center,style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),)),
                                                ),
                                              ),
                                            ),
                                          ).pOnly(left: 10, bottom: 10);

                                        }
                                    ),
                                  ).pOnly(top: 10,right: 10),
                                ],
                              ),

                            ],
                          )
                              : Container(),

                          lotteryGame1DList.isNotEmpty
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "1D",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ).pOnly(left: isLandscape ? 50 : 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 2,
                                          crossAxisCount: isLandscape ? 13 : 3,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: lotteryGame1DList?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          return _mIsShimmerLoading
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
                                                    width : 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400]!,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        )
                                                    ),
                                                  ).pOnly(bottom: 10),
                                                  Container(
                                                    width : 80,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400]!,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(10),
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ).pOnly(left: 18, bottom: 12),
                                          )
                                              : Ink(
                                            decoration: const BoxDecoration(
                                              color: WlsPosColor.white,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: WlsPosColor.warm_grey_six,
                                                  blurRadius: 2.0,
                                                ),
                                              ],
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                print("2222222222222222222");
                                                List<BetRespVOs>? betRespV0s = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode == lotteryGameMainBetList?[index].betCode).toList();
                                                print("---thai lottery--------------> $betRespV0s");
                                                print("------------ thai lottery betRespV0s 0-----> ${betRespV0s?[0]}");
                                                if (betRespV0s != null) {
                                                  if (listOfPanelDataLength < maxPanelAllowed) {
                                                    Navigator.of(context).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (_) =>  MultiBlocProvider(
                                                              providers: [
                                                                BlocProvider<LotteryBloc>(
                                                                  create: (BuildContext context) => LotteryBloc(),
                                                                )
                                                              ],
                                                              child: GameScreen(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: lotteryGame1DList[index], mPanelBinList: widget.listPanelData ?? [], mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList ?? [])),
                                                        )
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                      duration: Duration(seconds: 1),
                                                      content: Text("Max panel limit reached !"),
                                                    ));
                                                  }

                                                }
                                              },
                                              customBorder: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Ink(
                                                child: Container(
                                                  width: 10,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(width: 1.8, color: Colors.red)
                                                  ),
                                                  child: Align(alignment: Alignment.center,child: Text( getPicDisplayName(lotteryGame1DList[index].betDispName ?? ""), textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),)),
                                                ),
                                              ),
                                            ),
                                          ).pOnly(left: 10, bottom: 10);

                                        }
                                    ),
                                  ).pOnly(top: 10,right: 10),
                                ],
                              ),
                            ],
                          )
                              : Container(),

                        ],
                      ).pOnly(top: 20),
                    ),
                    Expanded(child: Container()),
                    Container(
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
                                Align(alignment: Alignment.center, child: Text("$listOfPanelDataLength", style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                const Align(alignment: Alignment.center, child: Text("Total Bets", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                              ],
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(alignment: Alignment.center, child: Text(totalAmount, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                Align(alignment: Alignment.center, child: Text("Total Bet Value (${getDefaultCurrency(getLanguage())})", style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Material(
                              child: InkWell(
                                onTap: () {
                                  print("44444444444444444444");
                                  if(widget.gameObjectsList?.gameCode == "ThaiLottery"){

                                    if (widget.mapThaiLotteryPanelBinList?.isEmpty == true || widget.mapThaiLotteryPanelBinList == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("No bet selected, please select any bet !"),
                                      ));
                                    }
                                    else {
                                      Navigator.push(context,
                                          MaterialPageRoute(
                                            builder: (_) =>  MultiBlocProvider(
                                                providers: [
                                                  BlocProvider<LotteryBloc>(
                                                    create: (BuildContext context) => LotteryBloc(),
                                                  )
                                                ],
                                                child: PreviewGameScreen(gameSelectedDetails: widget.listPanelData ?? [], gameObjectsList: widget.gameObjectsList, mapThaiLotteryPanelBinList: widget.mapThaiLotteryPanelBinList ,onComingToPreviousScreen: (String onComingToPreviousScreen) {
                                                  switch(onComingToPreviousScreen) {
                                                    case "isAllPreviewDataDeleted" : {
                                                      setState(() {
                                                        widget.listPanelData?.clear();
                                                        widget.mapThaiLotteryPanelBinList?.clear();
                                                        calculateTotalAmount();
                                                      });
                                                      break;
                                                    }

                                                    case "isBuyPerformed" : {
                                                      setState(() {
                                                        lastPanelSoldData = widget.mapThaiLotteryPanelBinList ?? [];
                                                        widget.listPanelData?.clear();
                                                        widget.mapThaiLotteryPanelBinList?.clear();
                                                        calculateTotalAmount();
                                                        log("lastPanelSoldData: ${jsonEncode(lastPanelSoldData)}");
                                                        BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
                                                        BlocProvider.of<LoginBloc>(context).add(FetchGameDataApi(context: context, gameCodeList: ["ThaiLottery"]));
                                                      });
                                                      break;
                                                    }
                                                  }
                                                }, selectedGamesData: (List<PanelBean> selectedAllGameData, List<List<PanelData>?>? selectedAllThaiGameData) {
                                                  setState(() {
                                                    widget.listPanelData = selectedAllGameData;
                                                    widget.mapThaiLotteryPanelBinList = selectedAllThaiGameData; // check later
                                                  });
                                                  calculateTotalAmount();
                                                })),
                                            //child: LotteryScreen()),
                                          )
                                      );
                                    }

                                  }
                                  if(widget.gameObjectsList?.gameCode == 'TwoDMYANMAAR'){
                                    if (widget.listPanelData?.isEmpty == true) {
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
                                                child: PreviewGameScreen(gameSelectedDetails: widget.listPanelData ?? [], gameObjectsList: widget.gameObjectsList, onComingToPreviousScreen: (String onComingToPreviousScreen) {
                                                  switch(onComingToPreviousScreen) {
                                                    case "isAllPreviewDataDeleted" : {
                                                      setState(() {
                                                        widget.listPanelData?.clear();
                                                        calculateTotalAmount();
                                                      });
                                                      break;
                                                    }

                                                    case "isBuyPerformed" : {
                                                      setState(() {
                                                        widget.listPanelData?.clear();
                                                        calculateTotalAmount();
                                                        BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
                                                      });
                                                      break;
                                                    }
                                                  }
                                                }, selectedGamesData: (List<PanelBean> selectedAllGameData, List<List<PanelData>?>? selectedAllThaiGameData) {
                                                  setState(() {
                                                    widget.listPanelData = selectedAllGameData;
                                                  });
                                                  calculateTotalAmount();
                                                })),
                                            //child: LotteryScreen()),
                                          )
                                      );
                                    }
                                  }

                                },
                                child: Ink(
                                  color: WlsPosColor.game_color_red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset('assets/icons/buy.svg', width: 20, height: 20, color: WlsPosColor.white),
                                      const Align(alignment: Alignment.center, child: Text("PROCEED", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
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
                )

                    : Column(
                    children: [
                      const Align(alignment: Alignment.centerLeft, child: Text("Main Bet", style: TextStyle(color: WlsPosColor.black, fontSize: 14, fontWeight: FontWeight.bold))).p(10),
                      GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: isLandscape ? 2 : 1.8, // 1.8
                            crossAxisCount: isLandscape ? 12 : 3,// 3
                          ),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _mIsShimmerLoading ? 10 : lotteryGameMainBetList?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return _mIsShimmerLoading
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
                                      width : 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[400]!,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          )
                                      ),
                                    ).pOnly(bottom: 10),
                                    Container(
                                      width : 80,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[400]!,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ).pOnly(left: 18, bottom: 12),
                            )
                                : Ink(
                              decoration: const BoxDecoration(
                                color: WlsPosColor.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: WlsPosColor.warm_grey_six,
                                    blurRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  List<BetRespVOs>? betRespV0s = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode == lotteryGameMainBetList?[index].betCode).toList();
                                  print("-----------------> $betRespV0s");
                                  print("------------betRespV0s 0-----> ${betRespV0s?[0]}");
                                  if (betRespV0s != null) {
                                    var listPanelDataLength = widget.listPanelData?.length ?? 0;
                                    if (listPanelDataLength < maxPanelAllowed) {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>  MultiBlocProvider(
                                                providers: [
                                                  BlocProvider<LotteryBloc>(
                                                    create: (BuildContext context) => LotteryBloc(),
                                                  )
                                                ],
                                                child: GameScreen(particularGameObjects: widget.gameObjectsList, pickType: betRespV0s[0].pickTypeData?.pickType ?? [], betRespV0s: betRespV0s[0], mPanelBinList: widget.listPanelData ?? [])),
                                          )
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("Max panel limit reached !"),
                                      ));
                                    }

                                  }
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Ink(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(lotteryGameMainBetList?[index].betDispName ?? "NA", style: const TextStyle(color: WlsPosColor.black, fontSize: 14))
                                    ],
                                  ),
                                ),
                              ),
                            ).pOnly(left: 10, bottom: 10);
                          }
                      ).pOnly(right: 10),
                      const HeightBox(40),
                      lotteryGameSideBetList?.isNotEmpty == true
                          ? const Align(alignment: Alignment.centerLeft, child: Text("Side Bet", style: TextStyle(color: WlsPosColor.black, fontSize: 14, fontWeight: FontWeight.bold))).pOnly(left: 10, bottom: 10)
                          : Container(),
                      lotteryGameSideBetList?.isNotEmpty == true
                          ? Row(
                        children: [
                          Ink(
                            decoration: const BoxDecoration(
                              color: WlsPosColor.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: WlsPosColor.warm_grey_six,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                var listPanelDataLength = widget.listPanelData?.length ?? 0;
                                if (listPanelDataLength < maxPanelAllowed) {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) =>  MultiBlocProvider(
                                            providers: [
                                              BlocProvider<LotteryBloc>(
                                                create: (BuildContext context) => LotteryBloc(),
                                              )
                                            ],
                                            child: SideGameScreen(gameObjectsList: widget.gameObjectsList, listPanelData: widget.listPanelData, betCategory: "FirstBall"),
                                          )
                                      )
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text("Max panel limit reached !"),
                                  ));
                                }
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Ink(
                                child: const Text("First Ball", style: TextStyle(color: WlsPosColor.black, fontSize: 14)).p(18),
                              ),
                            ),
                          ).pOnly(left: 12, bottom: 12),
                          Ink(
                            decoration: const BoxDecoration(
                              color: WlsPosColor.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: WlsPosColor.warm_grey_six,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                var listPanelDataLength = widget.listPanelData?.length ?? 0;
                                if (listPanelDataLength < maxPanelAllowed) {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) =>  MultiBlocProvider(
                                            providers: [
                                              BlocProvider<LotteryBloc>(
                                                create: (BuildContext context) => LotteryBloc(),
                                              )
                                            ],
                                            child: SideGameScreen(gameObjectsList: widget.gameObjectsList, listPanelData: widget.listPanelData, betCategory: "LastBall"),
                                          )
                                      )
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text("Max panel limit reached !"),
                                  ));
                                }
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text("Last Ball", style: TextStyle(color: WlsPosColor.black, fontSize: 14)).p(18),
                            ),
                          ).pOnly(left: 18, bottom: 12),
                          Ink(
                            decoration: const BoxDecoration(
                              color: WlsPosColor.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: WlsPosColor.warm_grey_six,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                var listPanelDataLength = widget.listPanelData?.length ?? 0;
                                if (listPanelDataLength < maxPanelAllowed) {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) =>  MultiBlocProvider(
                                            providers: [
                                              BlocProvider<LotteryBloc>(
                                                create: (BuildContext context) => LotteryBloc(),
                                              )
                                            ],
                                            child: SideGameScreen(gameObjectsList: widget.gameObjectsList, listPanelData: widget.listPanelData, betCategory: "All"),
                                          )
                                      )
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text("Max panel limit reached !"),
                                  ));
                                }
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Ink(
                                  child: const Text("First 5 balls", style: TextStyle(color: WlsPosColor.black, fontSize: 14)).p(18)
                              ),
                            ),
                          ).pOnly(left: 18, bottom: 12)
                        ],
                      )
                          : Container(),
                      Expanded(child: Container()),
                      Container(
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
                                  Align(alignment: Alignment.center, child: Text(widget.listPanelData != null ? "${widget.listPanelData?.length}" : "0", style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                  const Align(alignment: Alignment.center, child: Text("Total Bets", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                                ],
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(alignment: Alignment.center, child: Text(totalAmount, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                  Align(alignment: Alignment.center, child: Text("Total Bet Value (${getDefaultCurrency(getLanguage())})", style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Material(
                                child: InkWell(
                                  onTap: () {
                                    if (widget.listPanelData?.isEmpty == true) {
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
                                                child: PreviewGameScreen(gameSelectedDetails: widget.listPanelData ?? [], gameObjectsList: widget.gameObjectsList, onComingToPreviousScreen: (String onComingToPreviousScreen) {
                                                  switch(onComingToPreviousScreen) {
                                                    case "isAllPreviewDataDeleted" : {
                                                      setState(() {
                                                        widget.listPanelData?.clear();
                                                        calculateTotalAmount();
                                                      });
                                                      break;
                                                    }

                                                    case "isBuyPerformed" : {
                                                      setState(() {
                                                        widget.listPanelData?.clear();
                                                        calculateTotalAmount();
                                                        BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
                                                      });
                                                      break;
                                                    }
                                                  }
                                                }, selectedGamesData: (List<PanelBean> selectedAllGameData, List<List<PanelData>?>? selectedAllThaiGameData) {
                                                  setState(() {
                                                    widget.listPanelData = selectedAllGameData;
                                                  });
                                                  calculateTotalAmount();
                                                })),
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
                                        SvgPicture.asset('assets/icons/buy.svg', width: 20, height: 20, color: WlsPosColor.white),
                                        const Align(alignment: Alignment.center, child: Text("PROCEED", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ]
                ),
              ),
            ),
          ),
          Visibility(
            visible: mFetchGameDataLoading,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: WlsPosColor.black.withOpacity(0.7),
              child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Lottie.asset('assets/lottie/gradient_loading.json')
                  )
              ),
            ),
          )
        ]
      ),
    );
  }

  calculateTotalAmount() {
    int amount = 0;
    if (widget.gameObjectsList?.gameCode == "ThaiLottery") {
      if (widget.mapThaiLotteryPanelBinList != null) {
        for (List<PanelData>? models in widget.mapThaiLotteryPanelBinList ?? []) {
          for(PanelData model in models ?? []) {
            if (model.betAmountMultiple != null) {
              amount = (amount + model.betAmountMultiple!).toInt();
            }
          }
        }

        String strAmount = "${getDefaultCurrency(getLanguage())} $amount";
        totalAmount = strAmount;

      }

      if (widget.mapThaiLotteryPanelBinList != null) {
        listOfPanelDataLength = 0;
        for(List<PanelData>? models in widget.mapThaiLotteryPanelBinList ?? []) {
          listOfPanelDataLength += models?.length ?? 0;
        }
      } else {
        listOfPanelDataLength = 0;
      }

      print("listOfPanelDataLength---------------------> ${listOfPanelDataLength}");

    } else {
      listOfPanelDataLength = widget.listPanelData?.length ?? 0;
      if (widget.listPanelData != null) {
        for (PanelBean model in widget.listPanelData!) {
          if (model.amount != null) {
            amount = (amount + model.amount!).toInt();
          }
        }

        String strAmount = "${getDefaultCurrency(getLanguage())} $amount";
        totalAmount = strAmount;

      }
    }

  }

  _lastResultDetailsCard(bool isLandscape) {

    if(widget.gameObjectsList?.gameCode == "TwoDMYANMAAR"){
      Map<String, Map<String, String>> mRecentResultsData = {};

      String afterNoonLastResult = "";
      String eveningLastResult = "";

      String checkValidChar(String? input) {
        var validString = "";
        input?.split('#').forEach((ch) => {
          if (ch != "-1") {validString = validString + ch}
        });
        return validString;
      }
      for (var element
      in widget.gameObjectsList!.lastDrawWinningResultVOs!) {
        List<String>? dateTime = element.lastDrawDateTime?.split(" ");

        if (!mRecentResultsData.containsKey(dateTime![0]) &&
            mRecentResultsData.length < 2) {
          Map<String, String> time = {};
          if (int.parse(dateTime[1].split(":")[0]) >= 16) {
            //pm
            time["pm"] = checkValidChar(element.winningNumber?.split(",")[0]);
          } else {
            //am
            time["am"] = checkValidChar(element.winningNumber?.split(",")[0]);
          }

          mRecentResultsData[dateTime[0]] = time;
        }
      }
      afterNoonLastResult = checkValidChar(
          widget.gameObjectsList!.lastDrawResult?.split(",")[0]);

      eveningLastResult = checkValidChar(
          widget.gameObjectsList!.lastDrawResult?.split(",")[1]);
      return Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
              decoration: const BoxDecoration(
                  color: WlsPosColor.warm_grey,
                  //WlsPosColor.game_color_gray_bg,
                  border: Border(
                    left: BorderSide(
                      color: WlsPosColor.black,
                      width: 1.0,
                    ),
                    right: BorderSide(
                      color: WlsPosColor.black,
                      width: 1.0,
                    ),
                    top: BorderSide(
                      color: WlsPosColor.black,
                      width: 1.0,
                    ),
                  )),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Last Result",
                        style: TextStyle(
                            fontSize: isLandscape ? 24 : 20.0,
                            fontWeight: FontWeight.w500)),
                    Text(
                        formatDate(
                          date: mRecentResultsData.entries.first.key
                              .toString(),
                          inputFormat: Format.apiDateFormat3,
                          outputFormat: Format.calendarFormat,
                        ),
                        style: TextStyle(
                            fontSize: isLandscape ? 24 : 20.0,
                            fontWeight: FontWeight.w500)),
                  ]),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
              color: WlsPosColor.white,
              child: Table(
                border: TableBorder.all(
                    color: WlsPosColor.black,
                    style: BorderStyle.solid,
                    width: 1),
                children: [
                  TableRow(children: [
                    Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Afternoon',
                            style: TextStyle(
                                fontSize: isLandscape ? 24 :20.0,
                                color:
                                WlsPosColor.yellow_orange_three,
                                fontWeight: FontWeight.w400)),
                      )
                    ]),
                    Column(children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Evening',
                            style: TextStyle(
                                fontSize: isLandscape ? 24 :20.0,
                                color:
                                WlsPosColor.yellow_orange_three,
                                fontWeight: FontWeight.w400)),
                      )
                    ]),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(children: [
                        Text(afterNoonLastResult,
                            style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Text(eveningLastResult,
                            style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500))
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
              decoration: const BoxDecoration(
                  color: WlsPosColor.warm_grey,
                  //WlsPosColor.game_color_gray_bg,
                  border: Border(
                    left: BorderSide(
                      color: WlsPosColor.black,
                      width: 1.0,
                    ),
                    right: BorderSide(
                      color: WlsPosColor.black,
                      width: 1.0,
                    ),
                    top: BorderSide(
                      color: WlsPosColor.black,
                      width: 1.0,
                    ),
                  )),
              child: Column(children: [
                Text("Recent Result",
                    style: TextStyle(
                        fontSize: isLandscape ? 24 : 20.0, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
              color: WlsPosColor.white,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(5),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                },
                border: TableBorder.all(
                    color: WlsPosColor.black,
                    style: BorderStyle.solid,
                    width: 1),
                children: [
                  for (var item in mRecentResultsData.entries)
                    TableRow(children: [
                      TableCell(
                        verticalAlignment:
                        TableCellVerticalAlignment.middle,
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item.key,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                )),
                          )
                        ]),
                      ),
                      TableCell(
                        verticalAlignment:
                        TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: RichText(
                            text: TextSpan(
                              text: item.value['am'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: WlsPosColor.black,
                                  fontSize: 16),
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' Afternoon',
                                    style: TextStyle(
                                      fontSize: isLandscape ? 18 : 13,
                                      fontWeight: FontWeight.w400,
                                      color: WlsPosColor
                                          .yellow_orange_three,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment:
                        TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: RichText(
                            text: TextSpan(
                              text: item.value['pm'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: WlsPosColor.black,
                                  fontSize: 16),
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' Evening',
                                    style: TextStyle(
                                      fontSize: isLandscape ? 18 : 13,
                                      fontWeight: FontWeight.w400,
                                      color: WlsPosColor
                                          .yellow_orange_three,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ).pSymmetric(h: 8, v: 4);
    } else {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (isLandscape ? 0.8 : 1),
          child: Column(
            children: [
              Container(
                height: isLandscape ? 60 : 30,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                  color: WlsPosColor.ball_border_bg,
                ),
                child: Row(
                  children: [
                    Text("Last Result",
                      style: TextStyle(
                          fontSize: isLandscape ? 18 : 14
                      ),).p(5),
                    Expanded(child: Container(),),
                    Text("Date: ${(widget.gameObjectsList
                        ?.lastDrawWinningResultVOs?[0].lastDrawDateTime ?? "")
                        .split(" ")[0]}",
                      style: TextStyle(
                          fontSize: isLandscape ? 18 : 14
                      ),).p(5)
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black)
                      ),
                      child: Center(child: Text("First Prize",
                        style: TextStyle(
                            fontSize: isLandscape ? 18 : 14
                        ),).p(10)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black)
                      ),
                      child: Center(
                        child: Text("3 Front", textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                          ),).p(
                            10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black)
                      ),
                      child: Center(
                        child: Text("3 Last", textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                          ),).p(
                            10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black)
                      ),
                      child: Center(
                        child: Text("2 Digit", textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                          ),).p(
                            10),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8))
                      ),
                      child: Center(
                        child: Text("${lastResultDetail[0]}${lastResultDetail[1]}",
                          style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                          ),).p(
                            10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black)
                      ),
                      child: Center(
                        child: Text("${lastResultDetail[2]}/${lastResultDetail[3]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                          ),).p(10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black)
                      ),
                      child: Center(
                        child: Text("${lastResultDetail[4]}/${lastResultDetail[5]}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                            ),
                        ).p(10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: isLandscape ? 60 : 30,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(8))
                      ),
                      child: Center(
                        child: Text(lastResultDetail[6], textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isLandscape ? 18 : 14
                          ),)
                            .p(10),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ).p(10),
        ),
      ).pOnly(bottom: isLandscape ? 70 : 0);
    }
  }

  void initializeData() {
    lotteryGame3DList = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode.toString().toLowerCase().contains("3d")).toList()  ?? [];
    lotteryGame2DList = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode.toString().toLowerCase().contains("2d")).toList()  ?? [];
    lotteryGame1DList = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode.toString().toLowerCase().contains("1d")).toList()  ?? [];
    lastResultDetail  = (widget.gameObjectsList?.lastDrawResult ?? "").replaceAll("#", "").toString().replaceAll("-1", "").split(",");

    lotteryGameMainBetList = widget.gameObjectsList?.betRespVOs?.where((element) => element.winMode == "MAIN").toList()   ?? [];
    if (widget.gameObjectsList?.gameCode?.toUpperCase() == "powerball".toUpperCase()) {
      List<BetRespVOs>? betRespV0sList = widget.gameObjectsList?.betRespVOs?.where((element) => element.betCode?.toUpperCase().contains("plus".toUpperCase()) != true).toList();
      if (betRespV0sList?.isNotEmpty == true) {
        lotteryGameMainBetList = betRespV0sList;
      }
    }
    lotteryGameMainBetList = lotteryGameMainBetList?.isNotEmpty == true ? lotteryGameMainBetList : [];
    lotteryGameSideBetList = widget.gameObjectsList?.betRespVOs?.where((element) => element.winMode == "COLOR").toList()  ?? [];
    calculateTotalAmount();
    lotteryGameSideBetList = widget.gameObjectsList?.betRespVOs?.where((element) => element.winMode != "MAIN").toList()  ?? [];
    maxPanelAllowed = widget.gameObjectsList?.maxPanelAllowed ?? 0;
    print("pick init ----------------------> ${widget.mapThaiLotteryPanelBinList}");
    // listOfPanelDataLength = widget.listPanelData?.length ?? 0;
  }
}
