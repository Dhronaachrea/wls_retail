import 'dart:convert';
import 'dart:developer';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/lottery/bloc/lottery_bloc.dart';
import 'package:wls_pos/lottery/bloc/lottery_event.dart';
import 'package:wls_pos/lottery/bloc/lottery_state.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/PayOutChangeData.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/advanceDrawBean.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/bankerBean.dart';
import 'package:wls_pos/lottery/models/request/saleRequestBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
 import 'package:wls_pos/lottery/models/response/saleResponseBean.dart' as m_sale_res_bean;
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart' as m_panel_bean;
import 'package:wls_pos/lottery/widgets/advance_date_selection_dialog.dart';
import 'package:wls_pos/lottery/widgets/bet_deletion_dialog.dart';
import 'package:wls_pos/lottery/widgets/grand_prize_widget.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import '../utility/UrlDrawGameBean.dart';
import '../utility/app_constant.dart';
import '../utility/wls_pos_screens.dart';
import 'lottery_game_screen.dart';
import 'models/otherDataClasses/panelBean.dart';

/*
    created by Rajneesh Kr.Sharma on 7 May, 23
*/

class PreviewGameScreen extends StatefulWidget {
  List<m_panel_bean.PanelBean> gameSelectedDetails;
  GameRespVOs? gameObjectsList;
  BetRespVOs? betRespV0s;
  List<PickType>? pickType;
  final Function(String) onComingToPreviousScreen;
  final Function(List<m_panel_bean.PanelBean>, List<List<PanelData>?>?) selectedGamesData;
  List<List<PanelData>?>? mapThaiLotteryPanelBinList;
  PreviewGameScreen({Key? key, required this.gameSelectedDetails, this.gameObjectsList, this.betRespV0s, this.pickType, required this.onComingToPreviousScreen, required this.selectedGamesData, this.mapThaiLotteryPanelBinList}) : super(key: key);

  @override
  State<PreviewGameScreen> createState() => _PreviewGameScreenState();
}

class _PreviewGameScreenState extends State<PreviewGameScreen> {
  int mNumberOfDraws                                  = 1;
  int mIndexConsecutiveDrawsList                      = 0;
  late int drawRespLength;
  List<Map<String, String>> listAdvanceDraws          = [];
  List<String> listConsecutiveDraws                   = [];
  List<m_panel_bean.PanelBean> listPanel              = [];
  String drawCountAdvance                             = "0";
  bool minusDraw                                      = false;
  bool plusDraw                                       = false;
  bool isAdvancePlay                                  = false;
  String betAmount                                    = "";
  String noOfBet                                      = "";
  bool addDrawNotAllowed                              = false;
  bool minusDrawNotAllowed                            = false;
  bool isPurchasing                                   = false;
  bool isAdvanceDateSelectionOptionChosen             = false;
  List<AdvanceDrawBean> mAdvanceDrawBean              = [];
  List<Map<String, String>> listAdvanceMap            = [];
  int noOfDrawsFromDrawBtn                            = 0;
  int drawsCount                                      = 1;
  Map<String, dynamic> printingDataArgs               = {};
  List<List<PanelData>?>  thaiListPanel               = [];
  int drawNo                                          = 1;
  bool isLabelExistsInNumberConfig                    = false;
  int totalCards                                      = 0;
  int pickTypeLength                                  = 0;
  List<m_panel_bean.PanelBean> listUniquePanel        = [];
  bool isUpdatedPayoutConfirmed = false;

  String lastTicketNumber                            = "";
  String lastGameCode                                = "";
  bool isLastResultOrRePrintingOrCancelling          = false;

  @override
  void initState() {
    super.initState();
    log("SelectedPanelDetails: ${jsonEncode(widget.gameSelectedDetails)}");
    initializeInitialValues();

    isLabelExistsInNumberConfig = widget.gameObjectsList?.numberConfig?.range?[0].ball?.where((element) => element.label?.isNotEmpty == true).toList().isNotEmpty == true;
    print("isLabelExistsInNumberConfig: $isLabelExistsInNumberConfig");
    if(isLabelExistsInNumberConfig) {
      for(m_panel_bean.PanelBean panelData in listPanel) {
        print("--------> ${listUniquePanel.where((element) => element.pickedValue == panelData.pickedValue).toList().isEmpty}");
        if (listUniquePanel.where((element) => element.pickedValue == panelData.pickedValue).toList().isEmpty) {
          listUniquePanel.add(panelData);
        }
      }
    }
    log("listUniquePanel: ${jsonEncode(listUniquePanel)}");
    pickTypeLength = widget.pickType?.length ?? 0;  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is GetLoginDataSuccess) {
          if (state.response != null) {
            setState(() {
              isPurchasing = false;
            });
            BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: state.response!));
            PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, onPrintingDone:(){
              SharedPrefUtils.setSaleTicketResponse  = "";
              SharedPrefUtils.setDgeLastSaleTicketNo = lastTicketNumber;
              SharedPrefUtils.setDgeLastSaleGameCode = lastGameCode;
              SharedPrefUtils.setLastReprintTicketNo = lastTicketNumber;

              widget.onComingToPreviousScreen("isBuyPerformed");
              Navigator.of(context).pop(true);
            },
            onPrintingFailed: () {
              SharedPrefUtils.setSaleTicketResponse  = "";
              if (SharedPrefUtils.getDgeLastSaleTicketNo == "" || SharedPrefUtils.getDgeLastSaleTicketNo == "0") {
                SharedPrefUtils.setDgeLastSaleTicketNo = "-1";
                SharedPrefUtils.setDgeLastSaleGameCode = lastGameCode;
              }
              cancelTicket(lastTicketNumber);
            },
            isPrintingForSale: true);

          }
        } else if (state is GetLoginDataError) {

          PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs,
              onPrintingDone:(){
                SharedPrefUtils.setSaleTicketResponse  = "";
                SharedPrefUtils.setDgeLastSaleTicketNo = lastTicketNumber;
                SharedPrefUtils.setDgeLastSaleGameCode = lastGameCode;
                SharedPrefUtils.setLastReprintTicketNo = lastTicketNumber;

                widget.onComingToPreviousScreen("isBuyPerformed");
                Navigator.of(context).pop(true);
          },
              onPrintingFailed: (){
                SharedPrefUtils.setSaleTicketResponse  = "";
                if (SharedPrefUtils.getDgeLastSaleTicketNo == "" || SharedPrefUtils.getDgeLastSaleTicketNo == "0") {
                  SharedPrefUtils.setDgeLastSaleTicketNo = "-1";
                  SharedPrefUtils.setDgeLastSaleGameCode = lastGameCode;
                }
                cancelTicket(lastTicketNumber);
              },
              isPrintingForSale: true);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          return !isPurchasing;
        },
        child: AbsorbPointer(
          absorbing: isPurchasing,
          child: WillPopScope(
            onWillPop: () async{
              return !isPurchasing;
            },
            child: WlsPosScaffold(
              centerTitle: false,
              isHomeScreen: false,
              showAppBar: true,
              backgroundColor: WlsPosColor.white_five,
              drawer: WlsPosDrawer(drawerModuleList: const []),
              onBackButton: () {
                widget.selectedGamesData(listPanel, thaiListPanel);
                Navigator.of(context).pop();
              },
              appBarTitle: const Text("Purchase Details", style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
              body: BlocListener<LotteryBloc, LotteryState>(
                listener: (context, state) {
                  if (state is GameSaleApiLoading) {
                    setState(() {
                      isPurchasing = true;
                    });

                  }
                  else if (state is GameSaleApiSuccess) {
                    lastTicketNumber = state.response.responseData?.ticketNumber.toString() ?? "";
                    lastGameCode = state.response.responseData?.gameCode.toString() ?? "";

                    if(state.response.responseData?.gameCode == "ThaiLottery") {
                      for(int i=0; i< (state.response.responseData?.panelData ?? []).length ; i++) {
                        state.response.responseData?.panelData?[i].pickedValues  = (state.response.responseData?.panelData?[i].pickedValues ?? "").replaceAll("#", "").replaceAll("-1", "");
                        state.response.responseData?.panelData?[i].pickDisplayName = getThaiLotteryCategory(state.response.responseData?.panelData?[i].betType ?? "");
                        state.response.responseData?.panelData?[i].betDisplayName  = getPicDisplayName(state.response.responseData?.panelData?[i].betType ?? "");
                      }
                    }
                    else if(state.response.responseData?.gameCode == "TwoDMYANMAAR") {
                      List<m_sale_res_bean.PanelData>? twoDPanelData = [];
                      Map<String, List<m_sale_res_bean.PanelData>> panelDataMap = {};
                      List<m_sale_res_bean.PanelData>? responsePanelData = state.response.responseData?.panelData ?? [];
                      for(int i=0; i< responsePanelData.length ; i++){
                        responsePanelData[i].pickedValues  = (responsePanelData[i].pickedValues ?? "").replaceAll("#", "").replaceAll("-1", "");
                        String? mBetType = responsePanelData[i].betType == "2D-direct" ? "${responsePanelData[i].betType}_${responsePanelData[i].quickPick}" :responsePanelData[i].betType;
                        if(panelDataMap.containsKey(mBetType)){
                          panelDataMap[mBetType]?.add(responsePanelData[i]);
                        } else {
                          panelDataMap[mBetType ?? ''] = [responsePanelData[i]];
                        }
                      }
                      log("panelDataMap------>: $panelDataMap");
                      int twoDPanelDataIndex = 0;
                      panelDataMap.forEach((key, value) {
                        List<m_sale_res_bean.PanelData> mapValuePanelData = value;
                        for (int mapValuePanelDataIndex = 0; mapValuePanelDataIndex < mapValuePanelData.length; mapValuePanelDataIndex++) {
                          if(mapValuePanelDataIndex == 0){
                            twoDPanelData.add(mapValuePanelData[mapValuePanelDataIndex]);
                          } else {
                            twoDPanelData[twoDPanelDataIndex].betAmountMultiple = (twoDPanelData[twoDPanelDataIndex].betAmountMultiple ?? 0.0) + (mapValuePanelData[mapValuePanelDataIndex].betAmountMultiple ?? 0.0);
                            twoDPanelData[twoDPanelDataIndex].pickedValues = getPickValues(twoDPanelData[twoDPanelDataIndex].betType, twoDPanelData[twoDPanelDataIndex].pickedValues, mapValuePanelData[mapValuePanelDataIndex].pickedValues);
                            twoDPanelData[twoDPanelDataIndex].numberOfLines = (twoDPanelData[twoDPanelDataIndex].numberOfLines??0) + (mapValuePanelData[mapValuePanelDataIndex].numberOfLines??0);
                          }
                        }
                        twoDPanelData[twoDPanelDataIndex].betAmountMultiple = (twoDPanelData[twoDPanelDataIndex].betAmountMultiple??0.0) / mapValuePanelData.length;
                        twoDPanelDataIndex++;
                      });
                      state.response.responseData?.panelData = twoDPanelData;
                      for(int i=0; i< (state.response.responseData?.panelData ?? []).length ; i++){
                        state.response.responseData?.panelData?[i].panelPrice  = (state.response.responseData?.panelData?[i].unitCost?? 1) * (state.response.responseData?.panelData?[i].betAmountMultiple ?? 1) * (state.response.responseData?.panelData?[i].numberOfLines ?? 1);
                        state.response.responseData?.panelData?[i].betAmountMultiple = state.response.responseData?.panelData?[i].betAmountMultiple.toInt();
                        //if(state.response.responseData?.panelData?[i].betType == "2D-series-number" ){
                        List<String>? stringPickValuesList = state.response.responseData?.panelData?[i].pickedValues?.split(',');
                        if(stringPickValuesList != null){
                          Set<String> stringPickValuesSet = {...stringPickValuesList};
                          List<String> newStringPickValuesList = stringPickValuesSet.toList();
                          state.response.responseData?.panelData?[i].pickedValues = newStringPickValuesList.join(',');
                        }
                        // }
                      }
                      // log("twoDPanelData------>: $twoDPanelData");
                      // log("twoDstate.response.responseData?.panelData------>: ${jsonEncode(state.response.responseData?.panelData ?? [])}");
                      // log("twoDstate.response------>: ${jsonEncode(state.response)}");
                    }

                    SharedPrefUtils.setSaleTicketResponse = jsonEncode(state.response);
                    print("saved Data ====> ${SharedPrefUtils.getSaleTicketResponse}");

                    printingDataArgs["saleResponse"]  = jsonEncode(state.response);
                    printingDataArgs["username"]      = UserInfo.userName;
                    printingDataArgs["currencyCode"]  = getDefaultCurrency(getLanguage());
                    printingDataArgs["panelData"]     = jsonEncode(listPanel);
                    log("jsonEncode(listPanel): ${jsonEncode(listPanel)}");
                    log("jsonEncode(state.response): ${jsonEncode(state.response)}");

                    BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));

                  }
                  else if (state is GameSaleApiError) {
                    setState(() {
                      isPurchasing = false;
                    });

                if (state.errorCode == 2012 || state.errorCode == 2014) {
                  /*{
                  "responseCode": 2012,
                  "responseMessage": "Payout has been changed  : [3D-Cat1-Exact3_021_900.0_3.2=400.0, 3D-Cat1-Exact3_024_900.0_3.2=400.0]"
                }*/
                  List<String> errorDataList = state.errorMessage.split(":");
                  String heading = errorDataList[0];
                  List<String> data = errorDataList[1].trim().replaceAll("]", "").replaceAll("[", "").split(",");
                  Map<String, dynamic> errorDataMap = {
                    heading.trim()  : data,
                  };

                  List<String> respDataValue = [];
                  for(var key in errorDataMap.keys) {
                    respDataValue = errorDataMap[key];
                  }
                  List<PayOutChangeData> payOutChangeDataList = [];
                  for(String i in respDataValue) {
                    List<String> d = i.split("_"); // 3D-Cat1-Exact3_021_900.0_3.2=400.0
                    payOutChangeDataList.add(PayOutChangeData(
                        d[0],
                        d[1],
                        d[2],
                        d[3].split("=")[0],
                        d[3].split("=")[1]
                    )
                    );
                  }
                  print("payOutChangeDataList---------------->${payOutChangeDataList}");
                  payoutChangeDialog(payOutChangeDataList);

                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text("Purchased Error: \n ${state.errorMessage}"),
                      ));

                      if (state.errorCode != null) {
                        if (state.errorCode == 102) {
                          Map<String, dynamic> panelDataToBeSave = {"panelData": listPanel, "thaiPanelData": thaiListPanel};
                          SharedPrefUtils.setSelectedPanelData  = jsonEncode(panelDataToBeSave);
                          SharedPrefUtils.setSelectedGameObject = jsonEncode(widget.gameObjectsList);

                          print("UserInfo.getSelectedPanelData: ${jsonDecode(UserInfo.getSelectedPanelData)}");
                          var jsonPanelData = jsonDecode(UserInfo.getSelectedPanelData) as Map<String, dynamic>;
                          print("jsonPanelData: $jsonPanelData");
                          print("jsonPanelData[panelData]: ${jsonPanelData["panelData"]}");
                          print("UserInfo.getSelectedGameObject: ${GameRespVOs.fromJson(jsonDecode(UserInfo.getSelectedGameObject))}");
                          Navigator.of(context).popUntil((route) => false);
                          Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
                        }
                      }
                    }
                  }
                  else if (state is CancelTicketLoading) {
                    cancleTicketApiProgressDialog(); // to open cancel tiket progress dialog
                    setState(() {
                      isLastResultOrRePrintingOrCancelling = true;
                    });
                  }
                  else if (state is CancelTicketSuccess) {
                    setState(() {
                      isLastResultOrRePrintingOrCancelling = false;
                    });
                    // BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
                    /*PrintingDialog().show(context: context, title: context.l10n.printing_started, isRetryButtonAllowed: false, buttonText: context.l10n.retry, printingDataArgs: printingDataArgs, isCancelTicket: true, onPrintingDone:(){
                  }, isPrintingForSale: false);*/
                    Navigator.of(context).pop();//to close cancel ticket progress dialog
                    Navigator.of(context).pop(); //to close print dialog
                    ShowToast.showToast(context,  "Ticket successFully cancelled", type: ToastType.SUCCESS);
                  }
                  else if (state is CancelTicketError) {
                    Navigator.of(context).pop();//to close cancel ticket progress dialog
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
                                                  color: WlsPosColor.marine_two.withOpacity(0.3),
                                                  padding: const EdgeInsets.all(8),
                                                  child: Image.asset("assets/images/infiniti_logo.png", width: 150, height: 80),
                                                ),
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
                },
                child: WillPopScope(
                  onWillPop: () async{
                    widget.selectedGamesData(listPanel, thaiListPanel);
                    return true;
                  },
                  child: SafeArea(
                    child: Stack(
                      children: [
                        (widget.gameObjectsList?.gameCode == "ThaiLottery")
                            ? Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: WlsPosColor.light_dark_white,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                                boxShadow: [
                                  BoxShadow(
                                    color: WlsPosColor.warm_grey_six,
                                    blurRadius: .5,
                                    offset: Offset(.5, 0),
                                  ),
                                  BoxShadow(
                                    color: WlsPosColor.warm_grey_six,
                                    blurRadius: 1.0,
                                    offset: Offset(-.5, -.5),
                                  ),
                                ],
                              ),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(widget.gameObjectsList?.gameName ?? "", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, left: 16)
                              ),
                            ).pOnly(top: 8, right: 8, left: 8),
                            Expanded(
                              flex: 8,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: thaiListPanel.length, // no. of cards
                                  itemBuilder: (BuildContext context, int panelListItemIndex) {

                                    return AnimationConfiguration.staggeredList(
                                      duration: const Duration(milliseconds: 500),
                                      position: panelListItemIndex,
                                      child: FlipAnimation(
                                        flipAxis: FlipAxis.x,
                                        child: FadeInAnimation(
                                          child: Container(
                                            color: WlsPosColor.white,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 250,
                                                      child: GridView.builder(
                                                          gridDelegate:const  SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            childAspectRatio: 4,
                                                          ),
                                                          padding: EdgeInsets.zero,
                                                          shrinkWrap: true,
                                                          itemCount: thaiListPanel[panelListItemIndex]?.length ?? 0,
                                                          physics: const BouncingScrollPhysics(),
                                                          itemBuilder: (BuildContext context, int inx) {
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                                  border: Border.all(color: WlsPosColor.black, width: 0.8)
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Container(
                                                                      height: MediaQuery.of(context).size.height,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:const BorderRadius.horizontal(left: Radius.circular(20)),
                                                                        border: Border.all(color: Colors.black, width: 0.4),
                                                                        color: WlsPosColor.butter_scotch,
                                                                      ),
                                                                      child: Center(
                                                                        child: Text(
                                                                            (thaiListPanel[panelListItemIndex]?[inx].pickedValues ?? " ? ").replaceAll("#", "").replaceAll("-1", ""),
                                                                            textAlign: TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: WlsPosColor.black,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.bold
                                                                            )
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Container(
                                                                      decoration: const BoxDecoration(
                                                                        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                                                                      ),
                                                                      child: Text(
                                                                          "x${formatSlab((thaiListPanel[panelListItemIndex]?[inx].currentPayout ?? "").toString())} pays",
                                                                          textAlign: TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: WlsPosColor.black,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold
                                                                          )
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ).p(2);
                                                          }
                                                      ),
                                                    ),
                                                    Expanded(child: Container()),
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(
                                                          "${getGivenCardTotalAmount(thaiListPanel[panelListItemIndex])} ${getDefaultCurrency(getLanguage())}",
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(
                                                              color: WlsPosColor.black,
                                                              fontWeight: FontWeight.bold
                                                          )
                                                      ).pOnly(top: 8, bottom: 8, left: 16),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${getThaiLotteryCategory(thaiListPanel[panelListItemIndex]?[0].betType ?? "")} : ${getPicDisplayName(thaiListPanel[panelListItemIndex]?[0].betType ?? "")} | ${thaiListPanel[panelListItemIndex]?[0].pickType}",
                                                        textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8),
                                                    Expanded(child: Container()),
                                                    InkWell(
                                                      onTap:() {
                                                        BetDeletionDialog().show(context: context, title: "", buttonText: "OK", isCloseButton: true, panelBeanDetails: listPanel[panelListItemIndex], thaiPanelDataDetails: thaiListPanel[panelListItemIndex], onButtonClick: (PanelBean panelBean) {
                                                          setState(() {
                                                            listPanel.remove(panelBean);
                                                            thaiListPanel.removeAt(panelListItemIndex);

                                                          });
                                                          recalculatePanelAmount();
                                                          if(listPanel.isEmpty) {
                                                            widget.onComingToPreviousScreen("isAllPreviewDataDeleted");
                                                            Navigator.of(context).pop(true);
                                                          }
                                                        });
                                                      },
                                                      child: Ink(
                                                          child: SvgPicture.asset('assets/icons/delete.svg', width: 20, height: 20, color: WlsPosColor.game_color_red)
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                panelListItemIndex != thaiListPanel.length - 1 ? Container(
                                                  decoration: DottedDecoration(
                                                    color: WlsPosColor.ball_border_bg,
                                                    strokeWidth: 0.5,
                                                    linePosition: LinePosition.bottom,
                                                  ),
                                                  height:12,
                                                  width: MediaQuery.of(context).size.width,
                                                ) : Container(),
                                              ],
                                            ).p(8),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              ).pOnly(right: 8, left: 8),
                            ),
                            Container(height: 20, color: WlsPosColor.white_five),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Container(color: WlsPosColor.marigold, child: const Align(alignment: Alignment.center, child: Text("No. of Draw(s)", style: TextStyle(color: WlsPosColor.white, fontSize: 12)))),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Ink(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: WlsPosColor.white,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                                border: Border.all(color: WlsPosColor.game_color_grey, width: .5)
                                            ),
                                            child: AbsorbPointer(
                                              absorbing: minusDrawNotAllowed,
                                              child: InkWell(
                                                onTap: () {
                                                  resetAdvanceDraws();
                                                  setState(() {
                                                    noOfDrawsFromDrawBtn = 0;
                                                    mAdvanceDrawBean.clear();
                                                    listAdvanceMap.clear();
                                                    isAdvancePlay = false;
                                                    if (mIndexConsecutiveDrawsList > 0) {
                                                      mNumberOfDraws = int.parse(listConsecutiveDraws[--mIndexConsecutiveDrawsList]);
                                                    }
                                                    enableDisableDrawsButton();
                                                    recalculatePanelAmount();
                                                  });
                                                },
                                                customBorder: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(child: SvgPicture.asset('assets/icons/minus.svg', width: 20, height: 20, color: mIndexConsecutiveDrawsList == -1 || mIndexConsecutiveDrawsList == 0 ? WlsPosColor.game_color_grey : WlsPosColor.black)),
                                              ),
                                            ),
                                          ).pOnly(right:8),
                                          Align(alignment: Alignment.center, child: Text("$mNumberOfDraws", style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))).pOnly(right: 8),
                                          Ink(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: WlsPosColor.white,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                                border: Border.all(color: WlsPosColor.game_color_grey, width: .5)
                                            ),
                                            child: AbsorbPointer(
                                              absorbing: addDrawNotAllowed,
                                              child: InkWell(
                                                onTap: () {
                                                  resetAdvanceDraws();
                                                  setState(() {
                                                    noOfDrawsFromDrawBtn = 0;
                                                    mAdvanceDrawBean.clear();
                                                    listAdvanceMap.clear();
                                                    isAdvancePlay = false;
                                                    drawRespLength = widget.gameObjectsList?.drawRespVOs?.length ?? 0;
                                                    if (mIndexConsecutiveDrawsList < drawRespLength) {
                                                      mNumberOfDraws = int.parse(listConsecutiveDraws[++mIndexConsecutiveDrawsList]);
                                                    }
                                                  });
                                                  enableDisableDrawsButton();
                                                  recalculatePanelAmount();
                                                },
                                                customBorder: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(child: SvgPicture.asset('assets/icons/plus.svg', width: 20, height: 20, color: mIndexConsecutiveDrawsList == drawRespLength - 1 ? WlsPosColor.game_color_grey : WlsPosColor.black)),
                                              ),
                                            ),
                                          ).pOnly(right:8),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(width: 1, thickness: 1),
                                    Expanded(
                                      child: Material(
                                        child: InkWell(
                                          onTap: () {
                                            if (mAdvanceDrawBean.isEmpty) {
                                              List<DrawRespVOs> drawDateObjectsList = widget.gameObjectsList?.drawRespVOs ?? [];
                                              for (DrawRespVOs drawResp in drawDateObjectsList) {
                                                mAdvanceDrawBean.add(AdvanceDrawBean(drawRespVOs: drawResp, isSelected: false));
                                              }
                                            }
                                            if (mAdvanceDrawBean.isNotEmpty) {
                                              AdvanceDateSelectionDialog().show(context: context, title: "Select Draw", buttonText: "SELECT", isCloseButton: true, listOfDraws: mAdvanceDrawBean, buttonClick: (List<AdvanceDrawBean> advanceDrawBean) {
                                                setState(() {
                                                  if (advanceDrawBean.length > 1) {
                                                    if (advanceDrawBean.where((element) => element.isSelected == true).toList().isNotEmpty) {
                                                      mAdvanceDrawBean = advanceDrawBean;
                                                      noOfDrawsFromDrawBtn = mAdvanceDrawBean.where((element) => element.isSelected == true).toList().length;
                                                      mNumberOfDraws = 0;
                                                      mIndexConsecutiveDrawsList = -1;
                                                      enableDisableDrawsButton();
                                                      recalculatePanelAmount();
                                                    } else {
                                                      resetAdvanceDraws();
                                                      setState(() {
                                                        noOfDrawsFromDrawBtn = 0;
                                                        mAdvanceDrawBean.clear();
                                                        listAdvanceMap.clear();
                                                        isAdvancePlay = false;
                                                        drawRespLength = widget.gameObjectsList?.drawRespVOs?.length ?? 0;
                                                        if (mIndexConsecutiveDrawsList < drawRespLength) {
                                                          mNumberOfDraws = int.parse(listConsecutiveDraws[++mIndexConsecutiveDrawsList]);
                                                        }
                                                      });
                                                      enableDisableDrawsButton();
                                                      recalculatePanelAmount();
                                                    }
                                                  }
                                                });
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                duration: Duration(seconds: 1),
                                                content: Text("No advance draw available."),
                                              ));
                                            }
                                          },
                                          child: Ink(
                                            color: WlsPosColor.light_dark_white,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container (
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                        color: WlsPosColor.white,
                                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                        border: Border.all(color: WlsPosColor.game_color_grey, width: .5)
                                                    ),
                                                    child: Center(child: SvgPicture.asset('assets/icons/draw_list.svg', width: 16, height: 16, color: WlsPosColor.game_color_grey))).pOnly(right: 8),
                                                const Align(alignment: Alignment.center, child: Text("Draw \n List", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 10))).pOnly(right: 8),
                                                Align(alignment: Alignment.center, child: Text(mAdvanceDrawBean.where((element) => element.isSelected == true).toList().isNotEmpty == true ? mAdvanceDrawBean.where((element) => element.isSelected == true).toList().length.toString() : "0", style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))).pOnly(right: 8),
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
                            Expanded(
                              flex: 1,
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
                                          Align(alignment: Alignment.center, child: Text(noOfBet, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                          const Align(alignment: Alignment.center, child: Text("Total Bets", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Align(alignment: Alignment.center, child: Text(betAmount, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                          Align(alignment: Alignment.center, child: Text("Total Bet Value (${getDefaultCurrency(getLanguage())})", style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Material(
                                        child: InkWell(
                                          onTap: () {
                                            proceedToBuy();
                                          },
                                          child: Ink(
                                            color: WlsPosColor.game_color_red,
                                            child: isPurchasing
                                                ? SizedBox(child: Lottie.asset('assets/lottie/buy_loader.json'))
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset('assets/icons/buy.svg', width: 20, height: 20, color: WlsPosColor.white),
                                                const Align(alignment: Alignment.center, child: Text("BUY NOW", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
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
                          ],
                        )
                            : Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: WlsPosColor.light_dark_white,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                                boxShadow: [
                                  BoxShadow(
                                    color: WlsPosColor.warm_grey_six,
                                    blurRadius: .5,
                                    offset: Offset(.5, 0),
                                  ),
                                  BoxShadow(
                                    color: WlsPosColor.warm_grey_six,
                                    blurRadius: 1.0,
                                    offset: Offset(-.5, -.5),
                                  ),
                                ],
                              ),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(widget.gameObjectsList?.gameName ?? "", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, left: 16)
                              ),
                            ).pOnly(top: 8, right: 8, left: 8),
                            isLabelExistsInNumberConfig ? Container(
                              color: WlsPosColor.ball_border_light_bg,
                              child: Row(
                                children: [
                                  Text("Total cards : ${listUniquePanel.length}", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontSize: 14)).pOnly(left: 4, right: 4),
                                  Expanded(child: Container()),
                                  Text("Bet : ${getDefaultCurrency(getLanguage())} ${listUniquePanel.isNotEmpty ? listUniquePanel[0].selectBetAmount : ""}", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontSize: 14)).pOnly(left: 4, right: 4),
                                  InkWell(
                                    onTap:() {
                                      BetDeletionDialog().show(context: context, title: "", buttonText: "OK", isCloseButton: true, panelBeanDetails: listUniquePanel[0], isLabelExistsInNumberConfig:isLabelExistsInNumberConfig, onButtonClick: (PanelBean panelBean) {
                                        setState(() {
                                          listPanel.clear();
                                        });
                                        log("listPanel: ${jsonEncode(listPanel)}");
                                        log("listPanel.length: ${listPanel.length}");
                                        recalculatePanelAmount();
                                        if(listPanel.isEmpty) {
                                          widget.onComingToPreviousScreen("isAllPreviewDataDeleted");
                                          Navigator.of(context).pop(true);
                                        }
                                      });
                                    },
                                    child: Ink(
                                        child: SvgPicture.asset('assets/icons/delete.svg', width: 20, height: 20, color: WlsPosColor.game_color_red)
                                    ),
                                  ),
                                ],
                              ).p(8),
                            ).pOnly(right: 8, left: 8) : Container(),
                            isLabelExistsInNumberConfig
                                ? Expanded(
                              flex: 8,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: listUniquePanel.length,
                                  itemBuilder: (BuildContext context, int panelListItemIndex) {
                                    return AnimationConfiguration.staggeredList(
                                      duration: const Duration(milliseconds: 500),
                                      position: panelListItemIndex,
                                      child: FlipAnimation(
                                        flipAxis: FlipAxis.x,
                                        child: FadeInAnimation(
                                          child: Container(
                                            color: WlsPosColor.white,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                    height:40,
                                                    child:
                                                    pickTypeLength > 1
                                                        ?  labelledGameLabelList[getLabel(listUniquePanel[panelListItemIndex].pickedValue ?? "").toLowerCase()]?.contains("asset") == true
                                                        ? SvgPicture.asset("${labelledGameLabelList[getLabel(listUniquePanel[panelListItemIndex].pickedValue ?? "").toLowerCase()]}", width: 40, height: 40, color: WlsPosColor.shamrock_green)
                                                        : Center(child: Text("${labelledGameLabelList[getLabel(listUniquePanel[panelListItemIndex].pickedValue ?? "")]}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 18)))
                                                        : Center(child: Text("${listUniquePanel[panelListItemIndex].pickedValue}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 18)))
                                                ),
                                                const Text(":", textAlign: TextAlign.left, style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 14)).pOnly(left: 4, right: 4),
                                                Text(getLabel(listUniquePanel[panelListItemIndex].pickedValue ?? ""), textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontSize: 14)),
                                                Expanded(child: Container()),
                                                Center(child: Text("${getNoOfParticularPanelCount(listUniquePanel[panelListItemIndex].pickedValue ?? "")}", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 16))),
                                              ],
                                            ).p(16),
                                          ).pOnly(bottom: 1),
                                        ),
                                      ),
                                    );
                                  }
                              ).pOnly(right: 8, left: 8),
                            )
                                : Expanded(
                              flex: 8,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: widget.gameSelectedDetails.length,
                                  itemBuilder: (BuildContext context, int panelListItemIndex) {
                                    int numberOfLines = widget.gameSelectedDetails[panelListItemIndex].numberOfLines ?? 0;
                                    var listOfUpperLowerLineLength = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumberUpperLowerLine?.length ?? 0;
                                    List<BankerBean> listOfUpperLine = [];
                                    List<BankerBean> listOfLowerLine = [];
                                    for(int i=0; i < listOfUpperLowerLineLength; i++) {
                                      List<BankerBean> tempUpperList = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumberUpperLowerLine?[0]["$i"]?.where((element) => element.isSelectedInUpperLine == true).toList() ?? [];
                                      List<BankerBean> tempLowerList = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumberUpperLowerLine?[0]["$i"]?.where((element) => element.isSelectedInUpperLine == false).toList() ?? [];
                                      if (tempUpperList.isNotEmpty) {
                                        listOfUpperLine.addAll(tempUpperList);

                                      }
                                      if(tempLowerList.isNotEmpty) {
                                        listOfLowerLine.addAll(tempLowerList);
                                      }
                                    }

                                    int listOfUpperLineNosLength  = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumberUpperLowerLine?.length ?? 0;
                                    int listOfLowerLineNosLength  = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumberUpperLowerLine?.length ?? 0;
                                    var listOfOtherPickTypeNos    = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumber;
                                    var listOfSelectedNoPickType  = widget.gameSelectedDetails[panelListItemIndex].listSelectedNumber?[0].length ?? 0;
                                    return AnimationConfiguration.staggeredList(
                                      duration: const Duration(milliseconds: 500),
                                      position: panelListItemIndex,
                                      child: FlipAnimation(
                                        flipAxis: FlipAxis.x,
                                        child: FadeInAnimation(
                                          child: Container(
                                            color: WlsPosColor.white,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                listOfUpperLineNosLength > 0 && listOfLowerLineNosLength > 0
                                                    ? Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text("UL -", textAlign: TextAlign.left, style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, right: 8),
                                                        Container(
                                                            height:40,
                                                            color: WlsPosColor.white,
                                                            child: Container(
                                                              width: 30,
                                                              decoration: BoxDecoration(
                                                                  color: WlsPosColor.white,
                                                                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                                  border: Border.all(color: WlsPosColor.pale_lilac)
                                                              ),
                                                              child: Center(child: Text(listOfUpperLine[0].number ?? "?", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12,fontWeight: FontWeight.bold))),
                                                            ).p(2)
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          const Text("LL -", textAlign: TextAlign.left, style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, left: 16, right: 8),
                                                          Expanded(
                                                            child: Container(
                                                              height:40,
                                                              color: WlsPosColor.white,
                                                              child: ListView.builder(
                                                                  scrollDirection: Axis.horizontal,
                                                                  padding: EdgeInsets.zero,
                                                                  shrinkWrap: true,
                                                                  physics: const BouncingScrollPhysics(),
                                                                  itemCount: listOfLowerLine.length,
                                                                  itemBuilder: (BuildContext context, int lowerLinesNoIndex) {
                                                                    return Container(
                                                                      width: 30,
                                                                      decoration: BoxDecoration(
                                                                          color: WlsPosColor.white,
                                                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                                          border: Border.all(color: WlsPosColor.pale_lilac)
                                                                      ),
                                                                      child: Center(child: Text(listOfLowerLine[lowerLinesNoIndex].number ?? "?", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12,fontWeight: FontWeight.bold))),
                                                                    ).p(2);
                                                                  }
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text("${widget.gameSelectedDetails[panelListItemIndex].amount} ${getDefaultCurrency(getLanguage())}", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, left: 16)
                                                  ],
                                                )
                                                    : widget.gameSelectedDetails[panelListItemIndex].isMainBet == true
                                                    ? Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        width: 200,
                                                        height:40,
                                                        color: WlsPosColor.white,
                                                        child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            padding: EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            itemCount: listOfOtherPickTypeNos?.length ?? 0,
                                                            physics: const BouncingScrollPhysics(),
                                                            itemBuilder: (BuildContext context, int inx) {
                                                              return Container(
                                                                  width: 200,
                                                                  height:40,
                                                                  color: WlsPosColor.white,
                                                                  child: ListView.builder(
                                                                      scrollDirection: Axis.horizontal,
                                                                      padding: EdgeInsets.zero,
                                                                      shrinkWrap: false,
                                                                      itemCount: widget.gameSelectedDetails[panelListItemIndex].listSelectedNumber?[0]["$inx"]?.length,
                                                                      physics: const BouncingScrollPhysics(),
                                                                      itemBuilder: (BuildContext context, int otherPickTypeNosIndex) {
                                                                        return Container(
                                                                          width: 30,
                                                                          decoration: BoxDecoration(
                                                                              color: WlsPosColor.white,
                                                                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                                              border: Border.all(color: WlsPosColor.pale_lilac)
                                                                          ),
                                                                          child: Center(child: Text(widget.gameSelectedDetails[panelListItemIndex].listSelectedNumber?[0]["$inx"]?[otherPickTypeNosIndex] ?? "?", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12,fontWeight: FontWeight.bold))),
                                                                        ).p(2);
                                                                      }
                                                                  ));
                                                            }
                                                        ),
                                                      ),
                                                    ),
                                                    listOfSelectedNoPickType > 1
                                                        ? const Text("+", style: TextStyle(color: WlsPosColor.black, fontSize: 12, fontWeight: FontWeight.bold)).pSymmetric(v:8, h:8)
                                                        : Container(),
                                                    listOfSelectedNoPickType > 1
                                                        ? Expanded(
                                                      child: Container(
                                                          height:40,
                                                          color: WlsPosColor.white, ///////////////////////
                                                          child: ListView.builder(
                                                              scrollDirection: Axis.horizontal,
                                                              padding: EdgeInsets.zero,
                                                              shrinkWrap: true,
                                                              itemCount: widget.gameSelectedDetails[panelListItemIndex].listSelectedNumber?[0]["1"]?.length,
                                                              physics: const BouncingScrollPhysics(),
                                                              itemBuilder: (BuildContext context, int otherPickTypeNosIndex) {
                                                                return Container(
                                                                  width: 30,
                                                                  decoration: BoxDecoration(
                                                                      color: WlsPosColor.white,
                                                                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                                      border: Border.all(color: WlsPosColor.pale_lilac)
                                                                  ),
                                                                  child: Center(child: Text(widget.gameSelectedDetails[panelListItemIndex].listSelectedNumber?[0]["1"]?[otherPickTypeNosIndex] ?? "?", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12,fontWeight: FontWeight.bold))),
                                                                ).p(2);
                                                              }
                                                          )),
                                                    )
                                                        : Container(),

                                                    Expanded(child: Container()),
                                                    Text("${widget.gameSelectedDetails[panelListItemIndex].amount} ${getDefaultCurrency(getLanguage())}", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, left: 16)
                                                  ],
                                                )
                                                    : Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: WlsPosColor.white,
                                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                          border: Border.all(color: WlsPosColor.pale_lilac)
                                                      ),
                                                      child: Center(child: Text(widget.gameSelectedDetails[panelListItemIndex].pickName ?? "?", textAlign: TextAlign.center, style: const TextStyle(color: WlsPosColor.black, fontSize: 12,fontWeight: FontWeight.bold)).p(10)),
                                                    ).p(2),
                                                    Expanded(child: Container()),
                                                    Text("${widget.gameSelectedDetails[panelListItemIndex].amount} ${getDefaultCurrency(getLanguage())}", textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8, left: 16)
                                                  ],
                                                )
                                                ,
                                                Row(
                                                  children: [
                                                    Text(
                                                        widget.gameSelectedDetails[panelListItemIndex].isMainBet == true
                                                            ? numberOfLines > 2
                                                            ? "Main Bet | ${widget.gameSelectedDetails[panelListItemIndex].pickName} | No of lines: ${widget.gameSelectedDetails[panelListItemIndex].numberOfLines}"
                                                            : "Main Bet | ${widget.gameSelectedDetails[panelListItemIndex].pickName} | No of line: ${widget.gameSelectedDetails[panelListItemIndex].numberOfLines}"

                                                            : numberOfLines > 2
                                                            ? "Side Bet | ${widget.gameSelectedDetails[panelListItemIndex].pickName} | No of lines: ${widget.gameSelectedDetails[panelListItemIndex].numberOfLines}"
                                                            : "Side Bet | ${widget.gameSelectedDetails[panelListItemIndex].pickName} | No of line: ${widget.gameSelectedDetails[panelListItemIndex].numberOfLines}",
                                                        textAlign: TextAlign.left, style: const TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold)).pOnly(top: 8, bottom: 8),
                                                    Expanded(child: Container()),
                                                    InkWell(
                                                      onTap:() {
                                                        BetDeletionDialog().show(context: context, title: "", buttonText: "OK", isCloseButton: true, panelBeanDetails: listPanel[panelListItemIndex], onButtonClick: (PanelBean panelBean) {
                                                          setState(() {
                                                            listPanel.remove(panelBean);
                                                          });
                                                          log("listPanel: ${jsonEncode(listPanel)}");
                                                          log("listPanel.length: ${listPanel.length}");
                                                          recalculatePanelAmount();
                                                          if(listPanel.isEmpty) {
                                                            widget.onComingToPreviousScreen("isAllPreviewDataDeleted");
                                                            Navigator.of(context).pop(true);
                                                          }
                                                        });
                                                      },
                                                      child: Ink(
                                                          child: SvgPicture.asset('assets/icons/delete.svg', width: 20, height: 20, color: WlsPosColor.game_color_red)
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                //grand prize
                                                /*Container(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Row(
                                                children: [
                                                  Expanded(child:  widget.gameSelectedDetails[panelListItemIndex].doubleJackpotCost != null ?  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled = !(widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled!);
                                                      });
                                                      recalculatePanelAmount();
                                                    },
                                                    customBorder: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Container(
                                                      width: isLandscape ? 180 : 150,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color: widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled! ? WlsPosColor.shamrock_green : WlsPosColor.white,
                                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                          border: Border.all(color: WlsPosColor.shamrock_green)
                                                      ),
                                                      child: Align(alignment: Alignment.center, child: Text("Double the Grand Prize Add ${widget.gameSelectedDetails[panelListItemIndex].doubleJackpotCost} (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center,style: TextStyle(color: widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled! ? WlsPosColor.white : WlsPosColor.game_color_black, fontSize: isLandscape ? 18 : 10))).p(4),
                                                    ),
                                                  ).p(2): const SizedBox(),),
                                                  Expanded(child: widget.gameSelectedDetails[panelListItemIndex].secureJackpotCost != null ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled = !widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled!;
                                                      });
                                                      recalculatePanelAmount();
                                                    },
                                                    customBorder: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Container(
                                                      width:isLandscape ? 180 : 150,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color: widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled! ? WlsPosColor.shamrock_green : WlsPosColor.white,
                                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                          border: Border.all(color: WlsPosColor.shamrock_green)
                                                      ),
                                                      child: Align(alignment: Alignment.center, child: Text("Secure the Grand Prize Add ${widget.gameSelectedDetails[panelListItemIndex].secureJackpotCost} (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center, style: TextStyle(color: widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled! ? WlsPosColor.white : WlsPosColor.game_color_black, fontSize: isLandscape ? 18 : 10))).p(4),
                                                    ),
                                                  ).p(2) : const SizedBox(),)
                                                ],).p(2),
                                            ),*/
                                                widget.gameObjectsList?.gameCode == "DailyLotto" ? GrandPrizeWidget(
                                                  doubleJackpotOnTap: () {
                                                    setState(() {
                                                      widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled = !(widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled!);
                                                    });
                                                    recalculatePanelAmount();
                                                  },
                                                  secureJackpotOnTap: () {
                                                    setState(() {
                                                      widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled = !widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled!;
                                                    });
                                                    recalculatePanelAmount();
                                                  },
                                                  isLandscape: isLandscape,
                                                  doubleJackpotCost: widget.gameSelectedDetails[panelListItemIndex].doubleJackpotCost,
                                                  isDoubleJackpotEnabled: widget.gameSelectedDetails[panelListItemIndex].isDoubleJackpotEnabled,
                                                  secureJackpotCost: widget.gameSelectedDetails[panelListItemIndex].secureJackpotCost,
                                                  isSecureJackpotEnabled: widget.gameSelectedDetails[panelListItemIndex].isSecureJackpotEnabled,
                                                ): const SizedBox(),
                                                panelListItemIndex != widget.gameSelectedDetails.length - 1 ? Container(
                                                  decoration: DottedDecoration(
                                                    color: WlsPosColor.ball_border_bg,
                                                    strokeWidth: 0.5,
                                                    linePosition: LinePosition.bottom,
                                                  ),
                                                  height:12,
                                                  width: MediaQuery.of(context).size.width,
                                                ) : Container(),
                                              ],
                                            ).p(8),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              ).pOnly(right: 8, left: 8),
                            ),
                            Container(height: 20, color: WlsPosColor.white_five),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Container(color: WlsPosColor.marigold, child: const Align(alignment: Alignment.center, child: Text("No. of Draw(s)", style: TextStyle(color: WlsPosColor.white, fontSize: 12)))),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Ink(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: WlsPosColor.white,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                                border: Border.all(color: WlsPosColor.game_color_grey, width: .5)
                                            ),
                                            child: AbsorbPointer(
                                              absorbing: minusDrawNotAllowed,
                                              child: InkWell(
                                                onTap: () {
                                                  resetAdvanceDraws();
                                                  setState(() {
                                                    noOfDrawsFromDrawBtn = 0;
                                                    mAdvanceDrawBean.clear();
                                                    listAdvanceMap.clear();
                                                    isAdvancePlay = false;
                                                    if (mIndexConsecutiveDrawsList > 0) {
                                                      mNumberOfDraws = int.parse(listConsecutiveDraws[--mIndexConsecutiveDrawsList]);
                                                    }
                                                  });
                                                  enableDisableDrawsButton();
                                                  recalculatePanelAmount();
                                                },
                                                customBorder: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(child: SvgPicture.asset('assets/icons/minus.svg', width: 20, height: 20, color: mIndexConsecutiveDrawsList == -1 || mIndexConsecutiveDrawsList == 0 ? WlsPosColor.game_color_grey : WlsPosColor.black)),
                                              ),
                                            ),
                                          ).pOnly(right:8),
                                          Align(alignment: Alignment.center, child: Text("$mNumberOfDraws", style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))).pOnly(right: 8),
                                          Ink(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: WlsPosColor.white,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                                border: Border.all(color: WlsPosColor.game_color_grey, width: .5)
                                            ),
                                            child: AbsorbPointer(
                                              absorbing: addDrawNotAllowed,
                                              child: InkWell(
                                                onTap: () {
                                                  resetAdvanceDraws();
                                                  setState(() {
                                                    noOfDrawsFromDrawBtn = 0;
                                                    mAdvanceDrawBean.clear();
                                                    listAdvanceMap.clear();
                                                    isAdvancePlay = false;
                                                    drawRespLength = widget.gameObjectsList?.drawRespVOs?.length ?? 0;
                                                    if (mIndexConsecutiveDrawsList < drawRespLength) {
                                                      mNumberOfDraws = int.parse(listConsecutiveDraws[++mIndexConsecutiveDrawsList]);
                                                    }
                                                  });
                                                  enableDisableDrawsButton();
                                                  recalculatePanelAmount();
                                                },
                                                customBorder: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(child: SvgPicture.asset('assets/icons/plus.svg', width: 20, height: 20, color: mIndexConsecutiveDrawsList == drawRespLength - 1 ? WlsPosColor.game_color_grey : WlsPosColor.black)),
                                              ),
                                            ),
                                          ).pOnly(right:8),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(width: 1, thickness: 1),
                                    Expanded(
                                      child: Material(
                                        child: InkWell(
                                          onTap: () {
                                            if (mAdvanceDrawBean.isEmpty) {
                                              List<DrawRespVOs> drawDateObjectsList = widget.gameObjectsList?.drawRespVOs ?? [];
                                              for (DrawRespVOs drawResp in drawDateObjectsList) {
                                                mAdvanceDrawBean.add(AdvanceDrawBean(drawRespVOs: drawResp, isSelected: false));
                                              }
                                            }
                                            if (mAdvanceDrawBean.isNotEmpty) {
                                              AdvanceDateSelectionDialog().show(context: context, title: "Select Draw", buttonText: "SELECT", isCloseButton: true, listOfDraws: mAdvanceDrawBean, buttonClick: (List<AdvanceDrawBean> advanceDrawBean) {
                                                setState(() {
                                                  if (advanceDrawBean.length > 1) {
                                                    if (advanceDrawBean.where((element) => element.isSelected == true).toList().isNotEmpty) {
                                                      mAdvanceDrawBean = advanceDrawBean;
                                                      noOfDrawsFromDrawBtn = mAdvanceDrawBean.where((element) => element.isSelected == true).toList().length;
                                                      mNumberOfDraws = 0;
                                                      mIndexConsecutiveDrawsList = -1;
                                                      enableDisableDrawsButton();
                                                      recalculatePanelAmount();
                                                    } else {
                                                      resetAdvanceDraws();
                                                      setState(() {
                                                        noOfDrawsFromDrawBtn = 0;
                                                        mAdvanceDrawBean.clear();
                                                        listAdvanceMap.clear();
                                                        isAdvancePlay = false;
                                                        drawRespLength = widget.gameObjectsList?.drawRespVOs?.length ?? 0;
                                                        if (mIndexConsecutiveDrawsList < drawRespLength) {
                                                          mNumberOfDraws = int.parse(listConsecutiveDraws[++mIndexConsecutiveDrawsList]);
                                                        }
                                                      });
                                                      enableDisableDrawsButton();
                                                      recalculatePanelAmount();
                                                    }
                                                  }
                                                });
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                duration: Duration(seconds: 1),
                                                content: Text("No advance draw available."),
                                              ));
                                            }
                                          },
                                          child: Ink(
                                            color: WlsPosColor.light_dark_white,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container (
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                        color: WlsPosColor.white,
                                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                                        border: Border.all(color: WlsPosColor.game_color_grey, width: .5)
                                                    ),
                                                    child: Center(child: SvgPicture.asset('assets/icons/draw_list.svg', width: 16, height: 16, color: WlsPosColor.game_color_grey))).pOnly(right: 8),
                                                const Align(alignment: Alignment.center, child: Text("Draw \n List", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 10))).pOnly(right: 8),
                                                Align(alignment: Alignment.center, child: Text(mAdvanceDrawBean.where((element) => element.isSelected == true).toList().isNotEmpty == true ? mAdvanceDrawBean.where((element) => element.isSelected == true).toList().length.toString() : "0", style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))).pOnly(right: 8),
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
                            Expanded(
                              flex: 1,
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
                                          Align(alignment: Alignment.center, child: Text(noOfBet, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                          const Align(alignment: Alignment.center, child: Text("Total Bets", style: TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Align(alignment: Alignment.center, child: Text(betAmount, style: const TextStyle(color: WlsPosColor.game_color_red, fontWeight: FontWeight.bold, fontSize: 16))),
                                          Align(alignment: Alignment.center, child: Text("Total Bet Value (${getDefaultCurrency(getLanguage())})", style: const TextStyle(color: WlsPosColor.game_color_grey, fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Material(
                                        child: InkWell(
                                          onTap: () {
                                            proceedToBuy();
                                          },
                                          child: Ink(
                                            color: WlsPosColor.game_color_red,
                                            child: isPurchasing
                                                ? SizedBox(child: Lottie.asset('assets/lottie/buy_loader.json'))
                                                : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset('assets/icons/buy.svg', width: 20, height: 20, color: WlsPosColor.white),
                                                const Align(alignment: Alignment.center, child: Text("BUY NOW", style: TextStyle(color: WlsPosColor.white, fontWeight: FontWeight.bold, fontSize: 14))).pOnly(left: 4),
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
                          ],
                        ),
                        Visibility(
                          visible: isLastResultOrRePrintingOrCancelling,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: WlsPosColor.black.withOpacity(0.7),
                            child: Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Lottie.asset('assets/lottie/gradient_loading.json'))),
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ),
            )
          ),
        ),
      ),
    );


  }

  proceedToBuy() {
    for(int i=0 ; i < mAdvanceDrawBean.length; i++) {
      if (mAdvanceDrawBean[i].isSelected == true) {
        listAdvanceMap.add({"drawId": mAdvanceDrawBean[i].drawRespVOs?.drawId.toString() ?? ""});
      }
    }
    print("drawsCount------------------->$drawsCount");
    print("listAdvanceMap------------------->$listAdvanceMap");
    print("widget.gameSelectedDetails------------------->${widget.gameSelectedDetails}");
    print("widget.gameObjectsList------------------->${widget.gameObjectsList}");
    print("widget.v------------------->${widget.mapThaiLotteryPanelBinList}");

    ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? rePrintApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_SALE").toList()[0];
    UrlDrawGameBean? buyApiUrlsDetails = getDrawGameUrlDetails(rePrintApiDetails!, context, "buy");

    if(widget.gameObjectsList?.gameCode == "ThaiLottery") {
      List<PanelData>? panelDataList = [];
      for(List<PanelData>? models in widget.mapThaiLotteryPanelBinList ?? []){
        for(PanelData panel in models ?? []){
          panelDataList.add(panel);
        }
      }
      BlocProvider.of<LotteryBloc>(context).add(LotterySaleApi(context: context, isAdvancePlay: listAdvanceMap.isNotEmpty ? true : false, noOfDraws: drawNo, listAdvanceDraws: listAdvanceMap, listPanel: widget.gameSelectedDetails, gameObjectsList: widget.gameObjectsList, thaiListPanelData: panelDataList, isUpdatedPayoutConfirmed: isUpdatedPayoutConfirmed, apiUrlDetails: buyApiUrlsDetails));

    } else {
      BlocProvider.of<LotteryBloc>(context).add(LotterySaleApi(context: context, isAdvancePlay: listAdvanceMap.isNotEmpty ? true : false, noOfDraws: drawsCount, listAdvanceDraws: listAdvanceMap, listPanel: widget.gameSelectedDetails, gameObjectsList: widget.gameObjectsList, apiUrlDetails: buyApiUrlsDetails));
    }
  }

  resetAdvanceDraws() {
    setState(() {
      listAdvanceDraws.clear();
      drawCountAdvance = "0";
    });

  }

  enableDisableDrawsButton() {
    setState(() {
      if (mIndexConsecutiveDrawsList == -1) {
        print("mIndexConsecutiveDrawsList: $mIndexConsecutiveDrawsList");
        addDrawNotAllowed   = false;
        minusDrawNotAllowed = true;

      } else {
        if(mIndexConsecutiveDrawsList != drawRespLength - 1) {
          addDrawNotAllowed = false;

        } else {
          addDrawNotAllowed = true;
        }
        if(!addDrawNotAllowed) {
          if(mIndexConsecutiveDrawsList != 0) {
            minusDrawNotAllowed = false;

          } else {
            minusDrawNotAllowed = true;
          }
        }
      }

    });
  }

  void recalculatePanelAmount() {

    if (widget.gameObjectsList?.gameCode == "ThaiLottery") {
      if(noOfDrawsFromDrawBtn != 0) {
        drawNo = noOfDrawsFromDrawBtn;
      } else {
        drawNo = mNumberOfDraws;
      }
      calculateTotalAmount();
    }
    else {
      print("noOfDrawsFromDrawBtn:::::::::::::::::::::$noOfDrawsFromDrawBtn");
      log("json after delete : ${jsonEncode(listPanel)}");
      double amt = 0;
      for (int index = 0; index < listPanel.length; index++) {
        if(noOfDrawsFromDrawBtn != 0) {
          setState(() {
            listPanel[index].numberOfDraws = noOfDrawsFromDrawBtn;
          });
        } else {
          setState(() {
            listPanel[index].numberOfDraws = mNumberOfDraws;
          });
        }
        print("listPanel[index].numberOfDraws : ${listPanel[index].numberOfDraws}");
        int numberOfDraws = listPanel[index].numberOfDraws ?? 0;
        int numberOfLines = listPanel[index].numberOfLines ?? 0;
        var selectedAmt = 0;
        if(widget.gameObjectsList?.gameCode == "TwoDMYANMAAR"){
          selectedAmt =   listPanel[index].amount?.toInt() ?? 0;
        } else {
          selectedAmt = listPanel[index].selectBetAmount ?? 0;
        }
        var isPowerBallPlusTrue = listPanel.where((element) => element.isPowerBallPlus == true).toList().isNotEmpty;
        print("listPanel[index] isPowerBallPlusTrue: $isPowerBallPlusTrue");
        if (isPowerBallPlusTrue) {
          selectedAmt = selectedAmt * 2;
        }
        if(widget.gameObjectsList?.gameCode == "TwoDMYANMAAR"){
          amt += selectedAmt * numberOfDraws;
        } if(widget.gameObjectsList?.gameCode == "DailyLotto"){
          double totalDoubleJackpotCost = listPanel[index].isDoubleJackpotEnabled! ? selectedAmt * (listPanel[index].doubleJackpotCost ?? 0) : 0;
          double totalSecureJackpotCost =  listPanel[index].isSecureJackpotEnabled! ? (selectedAmt * (listPanel[index].secureJackpotCost ?? 0)) : 0;
          amt += (selectedAmt + totalDoubleJackpotCost + totalSecureJackpotCost) * numberOfDraws;
          widget.gameSelectedDetails[index].amount = (selectedAmt + totalDoubleJackpotCost + totalSecureJackpotCost); // to update amount from new grand buttons
        } else{
          amt += selectedAmt * numberOfDraws * numberOfLines;
        }
        print("amt: $amt");
        /*setState(() {
        listPanel[index].amount = amt.toDouble();
      });*/
      }
      setState(() {
        betAmount = "${getDefaultCurrency(getLanguage())} $amt";
      });
      print("betAmount: $betAmount");
      //calculateTotalAmount();
      calculateNumberOfBets();
    }

  }

  calculateTotalAmount() {
    int amount = 0;
    double dailyLottoAmount = 0;

    if (widget.gameObjectsList?.gameCode == "ThaiLottery") {
      for(List<PanelData>? models in widget.mapThaiLotteryPanelBinList ?? []) {
        for(PanelData? model in models ?? []){
          amount  += (model?.betAmountMultiple ?? 0).toInt() * drawNo;
        }
      }
      print("amount ---------------> $amount");
    } else {
      for (m_panel_bean.PanelBean model in listPanel) {
        if(widget.gameObjectsList?.gameCode == "DailyLotto"){
          dailyLottoAmount = dailyLottoAmount + (model.amount!= null ? model.amount! : 0);
        } else {
          amount = amount + (model.amount!= null ? model.amount!.toInt() : 0);
        }
      }
    }
    setState(() {
      if(widget.gameObjectsList?.gameCode == "DailyLotto"){
        betAmount = "${getDefaultCurrency(getLanguage())} $dailyLottoAmount";
      } else {
        betAmount = "${getDefaultCurrency(getLanguage())} $amount";
      }
    });
    calculateNumberOfBets();
  }

  calculateNumberOfBets() {
    setState(() {
      if (widget.gameObjectsList?.gameCode == "ThaiLottery") {
        int len = 0;
        for(List<PanelData>? models in widget.mapThaiLotteryPanelBinList ?? []) {
          len += models?.length ?? 0;
        }
        noOfBet = "${len}";
        print("no of bets ---------->$len ====> $noOfBet");
      } else {
        noOfBet = "${listPanel.length}";
      }
    });
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
    }

    return null;
  }

  createPanelData(List<dynamic> panelSavedDataList) {
    List<PanelBean> savedPanelBeanList = [];
    for (int i=0; i< panelSavedDataList.length; i++) {
      PanelBean model = PanelBean();

      model.gameName                          = panelSavedDataList[i]["gameName"];
      model.amount                            = panelSavedDataList[i]["amount"];
      model.winMode                           = panelSavedDataList[i]["winMode"];
      model.betName                           = panelSavedDataList[i]["betName"];
      model.pickName                          = panelSavedDataList[i]["pickName"];
      model.betCode                           = panelSavedDataList[i]["betCode"];
      model.pickCode                          = panelSavedDataList[i]["pickCode"];
      model.pickConfig                        = panelSavedDataList[i]["pickConfig"];
      model.isPowerBallPlus                   = panelSavedDataList[i]["isPowerBallPlus"];
      model.selectBetAmount                   = panelSavedDataList[i]["selectBetAmount"];
      model.unitPrice                         = panelSavedDataList[i]["unitPrice"];
      model.numberOfDraws                     = panelSavedDataList[i]["numberOfDraws"];
      model.numberOfLines                     = panelSavedDataList[i]["numberOfLines"];
      model.isMainBet                         = panelSavedDataList[i]["isMainBet"];
      model.betAmountMultiple                 = panelSavedDataList[i]["betAmountMultiple"];
      model.isQuickPick                       = panelSavedDataList[i]["isQuickPick"];
      model.isQpPreGenerated                  = panelSavedDataList[i]["isQpPreGenerated"];

      List<Map<String, List<String>>> listOfSelectedNumber = [];
      if (panelSavedDataList[i]["listSelectedNumber"] != null) {
        Map<String, dynamic> mapOfSelectedNumbers = panelSavedDataList[i]["listSelectedNumber"][0]; // For Eg. {0: [40, 29, 26, 03, 31], 1: [03]}
        for(var i=0;i<mapOfSelectedNumbers.length; i++) {
          List<String> numberList = List<String>.from(mapOfSelectedNumbers.values.toList()[i] as List);

          listOfSelectedNumber.add({mapOfSelectedNumbers.keys.toList()[i]: numberList});
        }
        print("listOfSelectedNumber --> $listOfSelectedNumber");
      }

      List<Map<String, List<BankerBean>>> listSelectedNumberUpperLowerLine = [];
      if (panelSavedDataList[i]["listSelectedNumberUpperLowerLine"] != 0) {
        Map<String, dynamic> mapOfBankerSelectedNumbers = panelSavedDataList[i]["listSelectedNumberUpperLowerLine"][0]; // For Eg. {0: [40, 29, 26, 03, 31], 1: [03]}
        for(var i=0;i<mapOfBankerSelectedNumbers.length; i++) {
          List<BankerBean> bankerBeanList = [];
          for (var bankerDetails in mapOfBankerSelectedNumbers.values.toList()[i]) {
            bankerBeanList.add(BankerBean(number: bankerDetails["number"], color: bankerDetails["number"], index: int.parse(bankerDetails["number"]), isSelectedInUpperLine: bankerDetails["isSelected"]));
          }

          listSelectedNumberUpperLowerLine.add({mapOfBankerSelectedNumbers.keys.toList()[i]: bankerBeanList});
        }
        print("listSelectedNumberUpperLowerLine |>--> $listSelectedNumberUpperLowerLine");
      }

      model.listSelectedNumber                = listOfSelectedNumber.isEmpty ? null : listOfSelectedNumber;
      model.listSelectedNumberUpperLowerLine  = listSelectedNumberUpperLowerLine.isEmpty ? null : listSelectedNumberUpperLowerLine;
      model.pickedValue                       = panelSavedDataList[i]["pickedValue"];
      model.colorCode                         = panelSavedDataList[i]["colorCode"];
      model.totalNumber                       = panelSavedDataList[i]["totalNumber"];
      model.sideBetHeader                     = panelSavedDataList[i]["sideBetHeader"];

      savedPanelBeanList.add(model);
    }
    print("---------> all panelSavedData: $savedPanelBeanList");
  }

  void initializeInitialValues() {
    log("previewScreen: panel Data:  ${jsonEncode(widget.gameSelectedDetails)}");
    drawRespLength        = widget.gameObjectsList?.drawRespVOs?.length ?? 0;
    listPanel             = widget.gameSelectedDetails;
    listConsecutiveDraws  = widget.gameObjectsList?.consecutiveDraw?.split(",") ?? [];
    thaiListPanel         = widget.mapThaiLotteryPanelBinList ?? [];
    print("thaiListPAnel =================>$thaiListPanel");
    if (listConsecutiveDraws.isNotEmpty) {
      mNumberOfDraws      = int.parse(listConsecutiveDraws[0]);
      drawsCount          = int.parse(listConsecutiveDraws[0]);
    }

    enableDisableDrawsButton();
    recalculatePanelAmount();
    calculateTotalAmount();
  }

  getGivenCardTotalAmount(List<PanelData>? thaiPanelList) {
    int cardTotalAmount = 0;
    for(PanelData? panel in thaiPanelList ?? []) {
      cardTotalAmount += (panel?.betAmountMultiple ?? 0).toInt();
    }
    return cardTotalAmount * drawNo;
  }

  String formatSlab(String slab){
    List<String> num = slab.split(".");
    if ((num.length > 1) && (num[1] != "0")){
      return slab.toString();
    } else {
      return num[0];
    }
  }

  String getLabel(String number) {
    List<Ball> ballObjectList = widget.gameObjectsList?.numberConfig?.range?[0].ball?.where((element) => element.number == number).toList() ?? [];
    if (ballObjectList.isNotEmpty) {
      print("ballObjectList[0].label: ${ballObjectList[0].label}");
      return ballObjectList[0].label ?? "";
    }
    return "";
  }

  int getNoOfParticularPanelCount(String number) {
    return listPanel.where((element) => element.pickedValue?.contains(number) == true).toList().length;
  }

  payoutChangeDialog(List<PayOutChangeData> payOutChangeDataList) {
    return showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const HeightBox(15),
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: WlsPosColor.game_color_grey,
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Center(child: Icon(Icons.question_mark_rounded, color: WlsPosColor.white,))
                  ),
                  const HeightBox(15),
                  const Text(
                    "Payout Changes!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const HeightBox(10),
                  const Center(
                    child: Text(
                      "PLEASE NOTE: The odds have been Updated to:",
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  const HeightBox(10),
                  SizedBox(
                    height: (payOutChangeDataList.length == 1) ? 150 : 250,
                    child: ListView.builder(
                      itemCount: payOutChangeDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                //const Icon(Icons.circle_rounded, color: WlsPosColor.black, size: 10,),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      """'x${payOutChangeDataList[index].newSlabNumber}' as only '${getDefaultCurrency(getLanguage())} ${payOutChangeDataList[index].slabLimit}' amount is available in 'x${payOutChangeDataList[index].slabNumber}' odds for numbers (${(payOutChangeDataList[index].betType ?? "").split("-")[0]} : ${getPicDisplayName(payOutChangeDataList[index].betType ?? "")} | Number - ${payOutChangeDataList[index].pickNumber})""",
                                      style: const TextStyle(
                                          fontSize: 16
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 5,
                                    ).p(8),
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              decoration: DottedDecoration(
                                color: WlsPosColor.ball_border_bg,
                                strokeWidth: 0.5,
                                linePosition: LinePosition.bottom,
                              ),
                              height:5,
                              width: MediaQuery.of(context).size.width,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  const Text(
                    "Do you want to continue?",
                    style: TextStyle(
                        fontSize: 16
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ).pOnly(bottom: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all( color: WlsPosColor.reddish_pink),
                                color: WlsPosColor.white
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  color: WlsPosColor.reddish_pink,
                                  fontSize: 18
                              ),
                              textAlign: TextAlign.center,
                            ).p(10),
                          ),
                        ),
                      ),
                      const WidthBox(10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // call sale api
                            setState(() {
                              isUpdatedPayoutConfirmed = true;
                              listAdvanceMap.clear();
                              Navigator.pop(context);
                            });
                            proceedToBuy();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: WlsPosColor.reddish_pink
                            ),
                            child: const Text(
                              "Agree",
                              style: TextStyle(
                                  color: WlsPosColor.white,
                                  fontSize: 18
                              ),
                              textAlign: TextAlign.center,
                            ).p(10),
                          ),
                        ),
                      ),
                    ],
                  ).p(12)
                ],
              ).p(10),
            ),
          );
        }
    );
  }

  String? getPickValues(String? betType, String? twoDPanelDataPickedValues, String? mapPanelDataPickedValues) {
    return "$twoDPanelDataPickedValues,$mapPanelDataPickedValues";
  }

  cancelTicket(String ticketNo) {
    ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? cancelTicketApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_CANCEL_TICKET").toList()[0];
    UrlDrawGameBean? cancelTicketApiUrlsDetails = getDrawGameUrlDetails(cancelTicketApiDetails!, context, "cancelTicket");
    BlocProvider.of<LotteryBloc>(context).add(
        CancelTicketApi(
            context:context,
            apiUrlDetails: cancelTicketApiUrlsDetails,
            ticketNo: ticketNo
        )
    );
  }

  cancleTicketApiProgressDialog(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          backgroundColor: const Color(0x00ffffff),
          elevation: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
            child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Lottie.asset('assets/lottie/buy_loader.json'),),),
        ),
          ),
        ),
      );
    },
    );
  }
}
