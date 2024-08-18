import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/login/models/response/GetLoginDataResponse.dart';
import 'package:wls_pos/lottery/lottery_logic.dart';
import 'package:wls_pos/lottery/models/request/CancelTicketRequest.dart';
import 'package:wls_pos/lottery/models/request/fetch_game_data_request.dart';
import 'package:wls_pos/lottery/models/response/CancelTicketResponse.dart' as cancel_ticket_resp;
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import '../models/request/saleRequestBean.dart';
import 'lottery_event.dart';
import 'lottery_state.dart';
import 'package:wls_pos/lottery/models/request/RePrintRequest.dart';
import 'package:wls_pos/lottery/models/request/ResultRequest.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart' as re_print_resp;
import 'package:wls_pos/lottery/models/response/ResultResponse.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart' as m_panel_bean;
import 'package:wls_pos/lottery/models/response/saleResponseBean.dart' as sale_response;


class LotteryBloc extends Bloc<LotteryEvent, LotteryState> {
  LotteryBloc() : super(LotteryInitial()) {
    on<FetchGameDataApi>(_onLotteryEvent);
    // on<FetchGameDataApi>(_onFetchGameDataEvent);
    on<RePrintApi>(_onRePrintEvent);
    on<ResultApi>(_onResultEvent);
    on<CancelTicketApi>(_onCancelTicketEvent);
    on<LotterySaleApi>(_onLotterySaleApiEvent);
  }
}

_onLotteryEvent(FetchGameDataApi event, Emitter<LotteryState> emit) async{
  emit(FetchGameLoading());

  BuildContext context = event.context;

  var response = await LotteryLogic.callFetchGameData(context, FetchGameDataRequest(
      lastTicketNumber : SharedPrefUtils.getDgeLastSaleTicketNo.isNotEmpty ? UserInfo.getDgeLastSaleTicketNo : "0",
      retailerId       : UserInfo.userId,
      sessionId         : UserInfo.userToken
    ).toJson(),
    event.gameCodeList
  );
  try {
    response.when(idle: () {

    }, networkFault: (value) {
      emit(FetchGameError(errorMessage: value["occurredErrorDescriptionMsg"]));

    }, responseSuccess: (value) {
      FetchGameDataResponse successResponse =  value as FetchGameDataResponse;

      emit(FetchGameSuccess(response: successResponse));

    }, responseFailure: (value) {
      print("bloc responseFailure:");
      emit(FetchGameError(errorMessage: "responseFailure"));

    }, failure: (value) {
      print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      emit(FetchGameError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    print("error=========> $e");
  }

}

_onRePrintEvent(RePrintApi event, Emitter<LotteryState> emit) async{
  emit(RePrintLoading());

  BuildContext context = event.context;
  UrlDrawGameBean? urlDetails = event.apiUrlDetails;
  String ticketNumber = SharedPrefUtils.getLastReprintTicketNo.replaceAll('"', "");
  String gameCode = UserInfo.getDgeLastSaleGameCode.replaceAll('"', "");
  print("relative url -------> ${urlDetails?.url}");

  var response = await LotteryLogic.callRePrint(context,
      urlDetails?.basePath ?? "",
      urlDetails?.url ?? "",
      RePrintRequest(
          gameCode: gameCode,
          purchaseChannel: purchaseChannel,
          ticketNumber: ticketNumber,
          isPwt: false
      ).toJson());

  try {
    response.when(idle: () {

    }, networkFault: (value) {
      emit(RePrintError(errorMessage: value["occurredErrorDescriptionMsg"]));

    }, responseSuccess: (value) {
      re_print_resp.RePrintResponse successResponse =  value as re_print_resp.RePrintResponse;
      emit(RePrintSuccess(response: successResponse));

    }, responseFailure: (value) {
      print("bloc responseFailure:");
      re_print_resp.RePrintResponse errorResponse =  value as re_print_resp.RePrintResponse;
      emit(RePrintError(errorMessage: errorResponse.responseMessage ?? "responseFailure"));

    }, failure: (value) {
      print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      emit(RePrintError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    print("error=========> $e");
    emit(RePrintError(errorMessage: "Technical Issue !"));
  }

}

_onCancelTicketEvent(CancelTicketApi event, Emitter<LotteryState> emit) async{
  emit(CancelTicketLoading());

  BuildContext context = event.context;
  UrlDrawGameBean? urlDetails = event.apiUrlDetails;
  String ticketNumber = event.ticketNo ?? SharedPrefUtils.getLastReprintTicketNo.replaceAll('"', ""); //UserInfo.getDgeLastSaleTicketNo.replaceAll('"', "");
  String gameCode = UserInfo.getDgeLastSaleGameCode.replaceAll('"', "");

  var response = await LotteryLogic.callCancelTicket(context,
      urlDetails?.basePath ?? "",
      urlDetails?.url ?? "",
      CancelTicketRequest(
          autoCancel: event.ticketNo!=null?"CANCELSALE":"CANCELMANUAL",
          cancelChannel: deviceType,
          gameCode: gameCode,
          isAutoCancel: false,
          modelCode: "NA",
          sessionId: UserInfo.userToken,
          ticketNumber: ticketNumber,
          userId: UserInfo.userId
      ).toJson());

  try {
    response.when(idle: () {

    }, networkFault: (value) {
      emit(CancelTicketError(errorMessage: value["occurredErrorDescriptionMsg"]));

    }, responseSuccess: (value) {
      cancel_ticket_resp.CancelTicketResponse successResponse =  value as cancel_ticket_resp.CancelTicketResponse;

      emit(CancelTicketSuccess(response: successResponse));

    }, responseFailure: (value) {
      print("bloc responseFailure:");
      cancel_ticket_resp.CancelTicketResponse errorResponse =  value as cancel_ticket_resp.CancelTicketResponse;
      emit(CancelTicketError(errorMessage: errorResponse.responseMessage ?? "responseFailure"));

    }, failure: (value) {
      print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      emit(CancelTicketError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    print("error=========> $e");
    emit(RePrintError(errorMessage: "Technical Issue !"));
  }

}

_onResultEvent(ResultApi event, Emitter<LotteryState> emit) async{
  emit(ResultLoading());

  BuildContext context = event.context;
  UrlDrawGameBean? urlDetails = event.apiUrlDetails;
  String fromDateTime = event.fromDateTime;
  String toDateTime = event.toDateTime;
  String gameCode = event.gameCode;
  print("relative url -------> ${urlDetails?.url}");

  /*{
    "ticketNumber":"30040700006714821880",
  "gameCode":"FiveByNinety",
  "purchaseChannel":"RETAIL",
  "isPwt":false

  }*/

  var response = await LotteryLogic.callResult(context,
      urlDetails?.basePath ?? "",
      urlDetails?.url ?? "",
      ResultRequest(
        fromDate: fromDateTime,
        toDate: toDateTime,
        merchantCode: "LotteryRMS",
        gameCode: gameCode,
        orderByOperator: "DESC",
        orderByType: "draw_datetime",
        page: 1,
        size: 5,
        domainCode: "1",
      ).toJson());

  response.when(idle: () {

  }, networkFault: (value) {
    emit(ResultError(errorMessage: value["occurredErrorDescriptionMsg"]));

  }, responseSuccess: (value) {
    ResultResponse successResponse =  value as ResultResponse;

    emit(ResultSuccess(response: successResponse));

  }, responseFailure: (value) {
    print("bloc responseFailure:");
    ResultResponse errorResponse =  value as ResultResponse;
    emit(ResultError(errorMessage: errorResponse.responseMessage ?? "responseFailure"));

  }, failure: (value) {
    print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
    emit(ResultError(errorMessage: value["occurredErrorDescriptionMsg"]));
  });

  try {


  } catch(e) {
    print("result error =========> $e");
    emit(ResultError(errorMessage: "Technical Issue !"));
  }

}

_onLotterySaleApiEvent(LotterySaleApi event, Emitter<LotteryState> emit) async{
  emit(GameSaleApiLoading());

  BuildContext context = event.context;
  bool isAdvancePlay = event.isAdvancePlay ?? false;
  List<Map<String, String>> listAdvanceDraws = event.listAdvanceDraws ?? [];
  List<m_panel_bean.PanelBean> mListPanel = event.listPanel ?? [];
  GameRespVOs? gameObjectsList = event.gameObjectsList;
  int? noOfDraws = event.noOfDraws; // Only used for lottoAmigo game
  List<PanelData>? thaiPanelData = event.thaiListPanelData;
  UrlDrawGameBean? urlDetails = event.apiUrlDetails;

  var noOfDrawsCount = mListPanel[0].numberOfDraws;
  /*for(var i in mListPanel) {
    if (i.numberOfDraws != null) {
      noOfDrawsCount += i.numberOfDraws ?? 0;
    } else {
      break;

    }
  }*/

  print("noOfDrawsCount: $noOfDrawsCount");

  log("${mListPanel[0].numberOfDraws}");

  SaleRequestBean model = SaleRequestBean();
  model.modelCode = "";

  MerchantData merchantDataModel  = MerchantData();
  merchantDataModel.userId        = int.parse(UserInfo.userId);
  merchantDataModel.userName      = UserInfo.userName;
  merchantDataModel.sessionId     = UserInfo.userToken;
  GetLoginDataResponse loginResponse        = GetLoginDataResponse.fromJson(jsonDecode(UserInfo.getUserInfo));

  merchantDataModel.aliasName     = "${loginResponse.responseData?.data?.domainId}";

  model.merchantData              = merchantDataModel;
  model.gameCode                  = gameObjectsList?.gameCode ?? "NA";
  model.currencyCode              = getDefaultCurrency(getLanguage());
  model.purchaseDeviceId          = "1";
  model.purchaseDeviceType        = "POS_Web";
  model.lastTicketNumber          = SharedPrefUtils.getDgeLastSaleTicketNo.isNotEmpty ? UserInfo.getDgeLastSaleTicketNo : "0";
  model.merchantCode              = "LotteryRMS";
  model.modelCode                 = "NA";
  model.isAdvancePlay             = isAdvancePlay;

  if(gameObjectsList?.gameCode == "BingoSeventyFive3" || gameObjectsList?.gameCode == "BichoRapido") {
    // for lotto amigo game
    model.noOfDraws              = noOfDraws;
  } else {
    model.noOfDraws              = noOfDrawsCount;
  }

  if(event.isUpdatedPayoutConfirmed != null) {
    model.isUpdatedPayoutConfirmed  = event.isUpdatedPayoutConfirmed;
  } else {
    model.isUpdatedPayoutConfirmed  = false;
  }
  if (gameObjectsList?.id != null) {
    model.gameId                  = gameObjectsList?.id ?? 0;
  }


  List<DrawData> list = [];
  if (isAdvancePlay && listAdvanceDraws.isNotEmpty) {
    for (var advanceDraw in listAdvanceDraws) {
      DrawData drawData = DrawData();
      drawData.drawId   = advanceDraw["drawId"];
      list.add(drawData);
    }
  }
  model.drawData = list;

  List<PanelData> listPanel       = [];
  if(gameObjectsList?.gameCode == "ThaiLottery") {
    print("lottery bloc1 ---------------. ${event.noOfDraws}");
    print("lottery bloc2 ---------------. ${noOfDrawsCount}");
    listPanel = thaiPanelData ?? [];
    model.noOfDraws = event.noOfDraws;
    model.noOfPanels = listPanel.length;
  } else if (gameObjectsList?.gameCode == "TwoDMYANMAAR"){
    for (m_panel_bean.PanelBean panelData in mListPanel) {
      List<String> pickedValuesList = panelData.pickedValue?.split(',')??[];
      print("pickedValuesList-----> $pickedValuesList");
        for(String pickedValue in pickedValuesList) {
          PanelData modelPanel          = PanelData();
        modelPanel.pickType           = panelData.pickCode;
        modelPanel.betType            = panelData.betCode;
        modelPanel.pickConfig         = panelData.pickConfig;
        modelPanel.betAmountMultiple  = panelData.betAmountMultiple;
        modelPanel.quickPick          = panelData.isQuickPick;
        modelPanel.qpPreGenerated     = panelData.isQpPreGenerated;
          var firstValue = pickedValue[0];
          var secondValue = pickedValue[1];
          modelPanel.pickedValues = "-1#$firstValue#$secondValue";
        listPanel.add(modelPanel);
      }
    }
  } else {
    for (m_panel_bean.PanelBean panelData in mListPanel) {
      PanelData modelPanel          = PanelData();
      modelPanel.pickType           = panelData.pickCode;
      modelPanel.betType            = panelData.betCode;
      modelPanel.pickConfig         = panelData.pickConfig;
      modelPanel.betAmountMultiple  = panelData.betAmountMultiple;
      modelPanel.quickPick          = panelData.isQuickPick;
      modelPanel.qpPreGenerated     = panelData.isQpPreGenerated;
      if(gameObjectsList?.gameCode == "TwoDMYANMAAR"){
        var pickedValue = panelData.pickedValue;
        var firstValue = pickedValue![0];
        var secondValue = pickedValue[1];
        modelPanel.pickedValues = "-1#$firstValue#$secondValue";

      } else{
        modelPanel.pickedValues       = panelData.pickedValue;
      }
      if(gameObjectsList?.gameCode == "DailyLotto") {
       /* modelPanel.doubleJackpotCost = panelData.doubleJackpotCost;
        modelPanel.secureJackpotCost = panelData.secureJackpotCost;*/
        if (panelData.isDoubleJackpotEnabled != null) {
          modelPanel.doubleJackpot = panelData.isDoubleJackpotEnabled;
        }
        if (panelData.isSecureJackpotEnabled != null) {
          modelPanel.secureJackpot = panelData.isSecureJackpotEnabled;
        }
      }
      listPanel.add(modelPanel);
    }
  }


  model.isPowerballPlusPlayed     = mListPanel.where((element) => element.isPowerBallPlus == true).toList().isNotEmpty ? true : false;
  model.panelData                 = listPanel;

  var response = await LotteryLogic.callLotterySaleApi(context,urlDetails?.basePath ?? "",
      urlDetails?.url ?? "", model.toJson());
  try {
    response.when(idle: () {

    }, networkFault: (value) {
      emit(GameSaleApiError(errorMessage: value["occurredErrorDescriptionMsg"]));

    }, responseSuccess: (value) {
      sale_response.SaleResponseBean successResponse =  value as sale_response.SaleResponseBean;
      emit(GameSaleApiSuccess(response: successResponse));

    }, responseFailure: (value) {
      sale_response.SaleResponseBean errorResponse =  value as sale_response.SaleResponseBean;
      if (kDebugMode) {
        print("bloc responseFailure:");
      }
      emit(GameSaleApiError(errorMessage: errorResponse.responseMessage ?? "responseFailure", errorCode: errorResponse.responseCode));

    }, failure: (value) {
      if (kDebugMode) {
        print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      }
      emit(GameSaleApiError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    if (kDebugMode) {
      print("on callLotterySaleApi bloc, exception => $e");
    }
  }

}

