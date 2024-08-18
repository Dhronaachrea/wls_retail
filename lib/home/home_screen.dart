import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/home/bloc/home_bloc.dart';
import 'package:wls_pos/home/bloc/home_event.dart' as homeEvent;
import 'package:wls_pos/home/bloc/home_state.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart' as rePrintResp;
import 'package:wls_pos/lottery/models/response/saleResponseBean.dart' as saleResponseBean;
import 'package:wls_pos/lottery/widgets/cancel_ticket_confirmation_dialog.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/date_alert_dialog.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';
import '../login/models/response/GetLoginDataResponse.dart';
import '../lottery/bloc/lottery_bloc.dart';
import '../lottery/models/otherDataClasses/bankerBean.dart';
import '../lottery/models/otherDataClasses/panelBean.dart';
import '../lottery/models/request/saleRequestBean.dart';
import '../lottery/models/response/fetch_game_data_response.dart';
import '../lottery/preview_game_screen.dart';
import '../lottery/widgets/saved_panel_data_confirmation_dialog.dart';
import 'dart:math' as math;

import '../utility/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _mIsDrawerVisible = false;
  bool isNoInternet = false;
  bool _mAppBarBalanceChipVisible = false;
  List<List<ModuleBeanLst>?> homeModuleList = [];
  List<List<ModuleBeanLst>?> drawerModuleList = [];
  bool isLastResultOrRePrintingOrCancelling = false;

  @override
  void initState() {
    super.initState();
    /*SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values);*/

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //checkSessionWasExpired(context);
    });
    BlocProvider.of<HomeBloc>(context).add(homeEvent.GetConfigData(context: context));
  }

  alertDialogForLastSaleTicket(BuildContext context) {

    ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? rePrintApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_REPRINT").toList()[0];
    UrlDrawGameBean? rePrintApiUrlsDetails = getDrawGameUrlDetails(rePrintApiDetails!, context, "reprintTicket");

    return Alert.show(
        context: context,
        title: "Confirmation",
        subtitle:"We encountered an issue with printing the last ticket. Would you like to try printing it again?",
        type: AlertType.confirmation,
        buttonText: "OK",
        isDarkThemeOn: false,
        showAlertIcon: false,
        buttonClick: () {
          print("ok button is clicked");
          //call reprint api
          print("reprint url =======> $rePrintApiUrlsDetails");
          BlocProvider.of<HomeBloc>(context).add(
              homeEvent.RePrintApi(
                  context:context,
                  apiUrlDetails: rePrintApiUrlsDetails
              )
          );

        },
        isCloseButton: true,
        showCloseBtn: true,
        closeButtonClick: (){
          print("close button is clicked");

          CancelTicketConfirmationDialog().show(
              context: context,
              title: "Alert",
              subTitle: "We encountered an issue with printing the last ticket. Are you sure you want to close it?",
              buttonText: "Yes",
              isCloseButton: true,
              buttonClick: () {
                saleResponseBean.SaleResponseBean lastSaleTicketResp = saleResponseBean.SaleResponseBean.fromJson(jsonDecode(SharedPrefUtils.getSaleTicketResponse));

                String ticketNumber = lastSaleTicketResp.responseData?.ticketNumber ?? "";
                String gameCode = lastSaleTicketResp.responseData?.gameCode ?? "";

                SharedPrefUtils.setDgeLastSaleTicketNo = ticketNumber;
                SharedPrefUtils.setDgeLastSaleGameCode = gameCode;
                SharedPrefUtils.setLastReprintTicketNo = ticketNumber;

                SharedPrefUtils.setSaleTicketResponse = "";

              },
              cancelButtonClick: (ctx) {
                print("cancel dialog");

                Navigator.of(ctx).pop();
                alertDialogForLastSaleTicket(context);
              }
          );
          //Navigator.of(context).pop();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WlsPosScaffold(
      showAppBar: true,
      isHomeScreen: true,
      mAppBarBalanceChipVisible: _mAppBarBalanceChipVisible,
      drawerEnableOpenDragGesture: _mIsDrawerVisible,
      showDrawerIcon: _mIsDrawerVisible,
      drawer: WlsPosDrawer(drawerModuleList: drawerModuleList),
      backgroundColor:
          _mIsDrawerVisible ? WlsPosColor.light_dark_white : WlsPosColor.white,
      appBarTitle:
          Image.asset("assets/images/splash_logo.png", width: 70, height: 70),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        color: WlsPosColor.app_blue,
        displacement: 60,
        edgeOffset: 1,
        strokeWidth: 2,
        onRefresh: () {
          setState(() {
            _mIsDrawerVisible = false;
            homeModuleList.clear();
            drawerModuleList.clear();
          });
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              BlocProvider.of<HomeBloc>(context)
                  .add(homeEvent.GetUserMenuListApiData(context: context));
            },
          );
        },
        child: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is UserMenuListLoading) {
                setState(() {
                  _mIsDrawerVisible = false;
                });
              } else if (state is UserMenuListSuccess) {
                setState(() {
                  print("---> UserMenuListSuccess");
                  isNoInternet = false;
                  for (var moduleCodeVar in homeModuleCodesList) {
                    if (state.response.responseData?.moduleBeanLst?.where(
                            (element) =>
                                (element.moduleCode == moduleCodeVar)) !=
                        null) {
                      if (state.response.responseData?.moduleBeanLst
                              ?.where((element) =>
                                  (element.moduleCode == moduleCodeVar))
                              .toList()
                              .isNotEmpty ==
                          true) {
                        homeModuleList.add(state
                            .response.responseData?.moduleBeanLst
                            ?.where((element) =>
                                (element.moduleCode == moduleCodeVar))
                            .toList());
                      }
                    }
                  }
                  List<ModuleBeanLst>? tempDrawGameBeanList = (state
                       .response.responseData?.moduleBeanLst
                       ?.where((element) =>
                   (element.moduleCode == lotteryModuleCode))
                       .toList());
                  if(tempDrawGameBeanList != null && tempDrawGameBeanList.isNotEmpty){
                    ModuleBeanLst? drawGameBeanList = tempDrawGameBeanList[0];
                    UserInfo.setDrawGameBeanListData(
                        jsonEncode(drawGameBeanList));
                  }
               /*   ModuleBeanLst? drawGameBeanList = (state
                      .response.responseData?.moduleBeanLst
                      ?.where((element) =>
                          (element.moduleCode == lotteryModuleCode))
                      .toList())?[0]   ;
                  UserInfo.setDrawGameBeanListData(
                      jsonEncode(drawGameBeanList)); */

                  for (var moduleCodeVar in drawerModuleCodesList) {
                    if (state.response.responseData?.moduleBeanLst?.where(
                            (element) =>
                                (element.moduleCode == moduleCodeVar)) !=
                        null) {
                      drawerModuleList.add(state
                          .response.responseData?.moduleBeanLst
                          ?.where((element) =>
                              (element.moduleCode == moduleCodeVar))
                          .toList());
                    }
                  }
                  if (drawerModuleList.isNotEmpty) {
                    _mIsDrawerVisible = true;
                  } else {
                    _mIsDrawerVisible = false;
                  }
                });
                if(SharedPrefUtils.getSaleTicketResponse.isNotEmpty) {
                  // open dialog
                  alertDialogForLastSaleTicket(context);
                }
              } else if (state is UserMenuListError) {
                setState(() {
                  _mIsDrawerVisible = false;
                  isNoInternet = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(state.errorMessage),
                ));
              }
              else if (state is UserConfigSuccess) {
                if (state.response.responseData?.data?[0].cURRENCYLIST !=
                    null) {
                  SharedPrefUtils.setCurrencyListConfig =
                      state.response.responseData?.data?[0].cURRENCYLIST! ?? "";
                  SharedPrefUtils.setScanAndPlayAliasName =
                      state.response.responseData?.data?[0].SCAN_N_PLAY_ALIAS_NAME! ?? "poc.igamew.com";
                  //SharedPrefUtils.setCurrencyListConfig = "en#.#EUR#N~fr#,#EUR#N#";
                }
                BlocProvider.of<AuthBloc>(context).add(AppStarted());
                setState(() {
                  _mAppBarBalanceChipVisible = true;
                });
                print(
                    "SharedPrefUtils.getCurrencyListConfig: ${SharedPrefUtils.getCurrencyListConfig}");
                if (state.response.responseData?.statusCode == 0) {
                  BlocProvider.of<HomeBloc>(context)
                      .add(homeEvent.GetUserMenuListApiData(context: context));
                }
              }
              else if (state is UserConfigError) {
                ShowToast.showToast(context, state.errorMessage.toString(),
                    type: ToastType.ERROR);
              }
              else if (state is RePrintLoading) {
                setState(() {
                  isLastResultOrRePrintingOrCancelling = true;
                });
              }
              else if (state is RePrintSuccess) {

                setState(() {
                  isLastResultOrRePrintingOrCancelling = false;
                });

                rePrintResp.ResponseData? response = state.response.responseData;
                UserInfo.setLastSaleGameCode(response?.gameCode ?? "");
                SharedPrefUtils.setLastReprintTicketNo = response?.ticketNumber ?? "0";
                //SharedPrefUtils.setDgeLastSaleTicketNo = response?.ticketNumber ?? "0";

                Map<String,dynamic> printingDataArgs      = {};
                printingDataArgs["saleResponse"]          = jsonEncode(state.response);
                GetLoginDataResponse loginResponse        = GetLoginDataResponse.fromJson(jsonDecode(UserInfo.getUserInfo));
                printingDataArgs["username"]              = loginResponse.responseData?.data?.orgName ?? "";
                printingDataArgs["currencyCode"]          = getDefaultCurrency(getLanguage());
                printingDataArgs["panelData"]             = jsonEncode(state.response.responseData?.panelData ?? []);
                saleResponseBean.SaleResponseBean lastSaleTicketResp = saleResponseBean.SaleResponseBean.fromJson(jsonDecode(SharedPrefUtils.getSaleTicketResponse));
                lastSaleTicketResp.responseData?.ticketNumber = state.response.responseData?.ticketNumber ?? "0";
                SharedPrefUtils.setSaleTicketResponse = jsonEncode(lastSaleTicketResp);

                PrintingDialog().show(context: context, title: "Printing started", isRetryButtonAllowed: false, buttonText: 'Retry', printingDataArgs: printingDataArgs,
                    isRePrint: true, onPrintingDone:() {
                      SharedPrefUtils.setSaleTicketResponse = "";
                    }, onPrintingFailed: () {
                      print("print fail ----------------> ");
                      SharedPrefUtils.setSaleTicketResponse = jsonEncode(lastSaleTicketResp);
                    },
                    OnErrorCloseDialog:()
                    {
                      alertDialogForLastSaleTicket(context);
                    }
                    , isPrintingForSale: false);

                ShowToast.showToast(context, "Reprint Successful, Your Remaining reprint count: ${state.response.responseData?.retailerReprintCount ?? "0"}",type: ToastType.SUCCESS);
              }
              else if (state is RePrintError) {

                setState(() {
                  isLastResultOrRePrintingOrCancelling = false;
                });
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      onWillPop: () async {
                        return false;
                      },
                      child: StatefulBuilder(
                        builder: (context, StateSetter setInnerState) {
                          return Dialog(
                              insetPadding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 18.0),
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: WlsPosColor.white,
                                            borderRadius: BorderRadius.circular(12)
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const HeightBox(10),
                                            Container(
                                                color: WlsPosColor.marine_two,
                                                child: Image.asset("assets/images/splash_logo.png", width: 150, height: 50)),
                                            const HeightBox(4),
                                            Text(
                                              state.errorMessage,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: WlsPosColor.black,
                                              ),
                                            ),
                                            const HeightBox(30),
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: WlsPosColor.game_color_red,
                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                ),
                                                height: 45,
                                                child: const Center(child: Text("Close", style: TextStyle(color: WlsPosColor.white, fontSize: 14))),
                                              ),
                                            ),
                                            const HeightBox(20),

                                          ],
                                        ).pSymmetric(v: 10, h: 30),
                                      ).p(4)
                                    ]
                                ),
                              )
                          );
                        },
                      ),
                    );
                  },
                );
              }
              /*else if (state is UserConfigSuccess) {
                if (state.response.responseData?.data?[0].cURRENCYLIST !=
                    null) {
                  SharedPrefUtils.setCurrencyListConfig =
                      state.response.responseData?.data?[0].cURRENCYLIST! ?? "";
                }
                BlocProvider.of<AuthBloc>(context).add(AppStarted());
                setState(() {
                  _mAppBarBalanceChipVisible = true;
                });
                if (state.response.responseData?.statusCode == 0) {
                  BlocProvider.of<HomeBloc>(context)
                      .add(GetUserMenuListApiData(context: context));
                }
              }
              else if (state is UserConfigError) {
                ShowToast.showToast(context, state.errorMessage.toString(),
                    type: ToastType.ERROR);
              }*/
            },
            child: isNoInternet
                ? Stack(
                    // Stack is used to bring No Internet column widget at center
                    children: [
                        Align(
                          child: ListView.builder(
                            // ListView widget is used so that Refresh indicator can work properly at case of single child(non-scrollable-widgets).
                            itemCount: 1,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 200,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                      SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: Lottie.asset(
                                              'assets/lottie/no_internet.json')),
                                      const HeightBox(10),
                                      const Text("No Internet",
                                              style: TextStyle(
                                                  color: WlsPosColor
                                                      .game_color_red,
                                                  letterSpacing: 2,
                                                  fontSize: 18))
                                          .animate(
                                              onPlay: (controller) => controller
                                                  .repeat(reverse: true))
                                          .flipH(
                                              duration: const Duration(
                                                  milliseconds: 300))
                                          .move(
                                              delay: 150.ms, duration: 1100.ms),
                                      const Expanded(
                                          flex: 1, child: SizedBox()),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Transform.rotate(
                                        angle: -math.pi / 2.5,
                                        child: Lottie.asset(
                                            'assets/lottie/pull_to_refresh.json'))),
                                const Text("Swipe to refresh",
                                    style: TextStyle(
                                        color: WlsPosColor.app_blue,
                                        letterSpacing: 2,
                                        fontSize: 14))
                              ],
                            )),
                      ])
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: isLandscape ? 2 : 0.8,
                      // landscape ---> 2 // potrate ---> 0.8
                      crossAxisCount: isLandscape
                          ? 3
                          : 2, // landscape ---> 3  // potrate ---> 0.8
                    ),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _mIsDrawerVisible ? homeModuleList.length : 10,
                    itemBuilder: (BuildContext context, int index) {
                      return _mIsDrawerVisible
                          ? Ink(
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
                                  print(homeModuleList[index]
                                      ?[0]); // Use to acquire index
                                  print(jsonEncode(homeModuleList[index]
                                      ?[0])); // Use to acquire index value
                                  print("tap on index $index");
                                  if (homeModuleList[index]?[0].moduleCode ==
                                      sportsModuleCode) {
                                    Navigator.pushNamed(context,
                                        WlsPosScreen.sportsLotteryScreen);
                                  } else if (homeModuleList[index]?[0]
                                          .moduleCode ==
                                      lotteryModuleCode) {
                                    Navigator.pushNamed(
                                        context, WlsPosScreen.lotteryScreen);
                                  } else if (homeModuleList[index]?[0]
                                          .moduleCode ==
                                      scanNPlay) {
                                    Navigator.pushNamed(context,
                                        WlsPosScreen.scanAndPlayScreen);
                                  } else {
                                    List<MenuBeanList>? scratchList =
                                        homeModuleList[index]?[0].menuBeanList;

                                    Navigator.pushNamed(
                                        context, WlsPosScreen.scratchScreen,
                                        arguments: scratchList);
                                  }
                                },
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Ink(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          width: 100,
                                          height: 100,
                                          homeModuleCodesList.contains(
                                                  homeModuleList[index]?[0]
                                                      .moduleCode)
                                              ? "assets/icons/${homeModuleList[index]?[0].moduleCode}.png"
                                              : "assets/images/splash_logo.png"),
                                      Text(
                                              homeModuleList[index]?[0]
                                                      .displayName ??
                                                  "NA",
                                              style: const TextStyle(
                                                  color: WlsPosColor.black,
                                                  fontWeight: FontWeight.bold))
                                          .py8()
                                    ],
                                  ),
                                ),
                              ),
                            ).p(6)
                          : Shimmer.fromColors(
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
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          )),
                                    ).pOnly(bottom: 10),
                                    Container(
                                      width: 80,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[400]!,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          )),
                                    ),
                                  ],
                                ),
                              ).p(6),
                            );
                    }).p(10)),
      ),
    );
  }

  void checkSessionWasExpired(BuildContext context) {
    print("UserInfo.getSelectedPanelData: ${UserInfo.getSelectedPanelData}");
    if (UserInfo.getSelectedPanelData.isNotEmpty &&
        UserInfo.getSelectedGameObject.isNotEmpty) {
      SavedPanelDataConfirmationDialog().show(
          context: context,
          title: "Your picked data are waiting !",
          subTitle:
              "You may not purchase those picked data, It's time to purchase it",
          buttonText: "Preview",
          isCloseButton: true,
          buttonClick: (bool isPreviewSelected) {
            if (isPreviewSelected) {
              var jsonPanelData = jsonDecode(UserInfo.getSelectedPanelData)
                  as Map<String, dynamic>;
              print("jsonPanelData: $jsonPanelData");
              List<PanelBean> panelData =
                  createPanelData(jsonPanelData["panelData"]);
              List<List<PanelData>> thaiPanelData =
                  createThaiPanelData(jsonPanelData["thaiPanelData"]);
              GameRespVOs gameRespObject = GameRespVOs.fromJson(
                  jsonDecode(UserInfo.getSelectedGameObject));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider<LotteryBloc>(
                            create: (BuildContext context) => LotteryBloc(),
                          )
                        ],
                        child: PreviewGameScreen(
                            gameSelectedDetails: panelData,
                            gameObjectsList: gameRespObject,
                            mapThaiLotteryPanelBinList: thaiPanelData,
                            onComingToPreviousScreen:
                                (String onComingToPreviousScreen) {
                              switch (onComingToPreviousScreen) {
                                case "isAllPreviewDataDeleted":
                                  {
                                    break;
                                  }

                                case "isBuyPerformed":
                                  {
                                    SharedPrefUtils.removeValue(
                                        PrefType.appPref.value);
                                    break;
                                  }
                              }
                            },
                            selectedGamesData:
                                (List<PanelBean> selectedAllGameData,
                                    List<List<PanelData>?>?
                                        selectedAllThaiGameData) {})),
                    //child: LotteryScreen()),
                  ));
            } else {
              SharedPrefUtils.removeValue(PrefType.appPref.value);
            }
          });
    }
  }

  List<PanelBean> createPanelData(List<dynamic> panelSavedDataList) {
    List<PanelBean> savedPanelBeanList = [];
    for (int i = 0; i < panelSavedDataList.length; i++) {
      PanelBean model = PanelBean();

      model.gameName = panelSavedDataList[i]["gameName"];
      model.amount = panelSavedDataList[i]["amount"];
      model.winMode = panelSavedDataList[i]["winMode"];
      model.betName = panelSavedDataList[i]["betName"];
      model.pickName = panelSavedDataList[i]["pickName"];
      model.betCode = panelSavedDataList[i]["betCode"];
      model.pickCode = panelSavedDataList[i]["pickCode"];
      model.pickConfig = panelSavedDataList[i]["PickConfig"];
      model.isPowerBallPlus = panelSavedDataList[i]["isPowerBallPlus"];
      model.selectBetAmount = panelSavedDataList[i]["selectBetAmount"];
      model.unitPrice = panelSavedDataList[i]["unitPrice"];
      model.numberOfDraws = panelSavedDataList[i]["numberOfDraws"];
      model.numberOfLines = panelSavedDataList[i]["numberOfLines"];
      model.isMainBet = panelSavedDataList[i]["isMainBet"];
      model.betAmountMultiple = panelSavedDataList[i]["betAmountMultiple"];
      model.isQuickPick = panelSavedDataList[i]["isQuickPick"];
      model.isQpPreGenerated = panelSavedDataList[i]["isQpPreGenerated"];

      List<Map<String, List<String>>> listOfSelectedNumber = [];
      if (panelSavedDataList[i]["listSelectedNumber"] != null) {
        Map<String, dynamic> mapOfSelectedNumbers = panelSavedDataList[i]
                ["listSelectedNumber"]
            [0]; // For Eg. {0: [40, 29, 26, 03, 31], 1: [03]}
        Map<String, List<String>> selectedNumbers = {};
        for (var i = 0; i < mapOfSelectedNumbers.length; i++) {
          List<String> numberList = List<String>.from(
              mapOfSelectedNumbers.values.toList()[i] as List);
          selectedNumbers[mapOfSelectedNumbers.keys.toList()[i]] = numberList;
        }

        listOfSelectedNumber.add(selectedNumbers);
        print("listOfSelectedNumber --> $listOfSelectedNumber");
      }

      List<Map<String, List<BankerBean>>> listSelectedNumberUpperLowerLine = [];
      if (panelSavedDataList[i]["listSelectedNumberUpperLowerLine"] != null) {
        Map<String, dynamic> mapOfBankerSelectedNumbers = panelSavedDataList[i]
                ["listSelectedNumberUpperLowerLine"]
            [0]; // For Eg. {0: [40, 29, 26, 03, 31], 1: [03]}
        Map<String, List<BankerBean>> bankersSelectedNumber = {};
        for (var i = 0; i < mapOfBankerSelectedNumbers.length; i++) {
          List<BankerBean> bankerBeanList = [];
          for (var bankerDetails
              in mapOfBankerSelectedNumbers.values.toList()[i]) {
            bankerBeanList.add(BankerBean(
                number: bankerDetails["number"],
                color: bankerDetails["number"],
                index: int.parse(bankerDetails["number"]),
                isSelectedInUpperLine: bankerDetails["isSelected"]));
          }
          bankersSelectedNumber[mapOfBankerSelectedNumbers.keys.toList()[i]] =
              bankerBeanList;
        }

        listSelectedNumberUpperLowerLine.add(bankersSelectedNumber);
        print(
            "listSelectedNumberUpperLowerLine |>--> $listSelectedNumberUpperLowerLine");
      }

      model.listSelectedNumber =
          listOfSelectedNumber.isEmpty ? null : listOfSelectedNumber;
      model.listSelectedNumberUpperLowerLine =
          listSelectedNumberUpperLowerLine.isEmpty
              ? null
              : listSelectedNumberUpperLowerLine;
      model.pickedValue = panelSavedDataList[i]["pickedValue"];
      model.colorCode = panelSavedDataList[i]["colorCode"];
      model.totalNumber = panelSavedDataList[i]["totalNumber"];
      model.sideBetHeader = panelSavedDataList[i]["sideBetHeader"];

      savedPanelBeanList.add(model);
    }
    print("---------> all panelSavedData: $savedPanelBeanList");
    print(
        "---------> all panelSavedData: json --> ${jsonEncode(savedPanelBeanList)}");

    return savedPanelBeanList;
  }

  List<List<PanelData>> createThaiPanelData(
      List<List<PanelData>> thaiPanelSavedDataList) {
    List<PanelData> savedPanelBeanList = [];
    List<List<PanelData>> finalsavedPanelBeanList = [];
    for (int i = 0; i < thaiPanelSavedDataList.length; i++) {
      for (int j = 0; j < thaiPanelSavedDataList[i].length; j++) {
        PanelData model = PanelData();

        /* int? betAmountMultiple;
        String? betType;
        String? pickConfig;
        String? pickType;
        String? pickedValues;
        bool? qpPreGenerated;
        bool? quickPick;
        int? totalNumbers;
        double? currentPayout;*/

        model.betType = thaiPanelSavedDataList[i][j].betType;
        model.pickType = thaiPanelSavedDataList[i][j].pickType;
        model.totalNumbers = thaiPanelSavedDataList[i][j].totalNumbers;
        model.currentPayout = thaiPanelSavedDataList[i][j].currentPayout;
        model.pickedValues = thaiPanelSavedDataList[i][j].pickedValues;
        model.pickConfig = thaiPanelSavedDataList[i][j].pickConfig;
        model.betAmountMultiple =
            thaiPanelSavedDataList[i][j].betAmountMultiple;
        model.quickPick = thaiPanelSavedDataList[i][j].quickPick;
        model.qpPreGenerated = thaiPanelSavedDataList[i][j].qpPreGenerated;

        /*model.pickedValue                       = thaiPanelSavedDataList[i][j]["pickedValue"];
        model.colorCode                         = thaiPanelSavedDataList[i][j]["colorCode"];
        model.totalNumber                       = thaiPanelSavedDataList[i][j]["totalNumber"];
        model.sideBetHeader                     = thaiPanelSavedDataList[i][j]["sideBetHeader"];*/

        savedPanelBeanList.add(model);
      }

      finalsavedPanelBeanList.add(savedPanelBeanList);
    }
    print("---------> all panelSavedData: $savedPanelBeanList");
    print(
        "---------> all panelSavedData: json --> ${jsonEncode(savedPanelBeanList)}");

    return finalsavedPanelBeanList;
  }
}
