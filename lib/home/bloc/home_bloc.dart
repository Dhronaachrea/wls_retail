import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/home/home_logic.dart';
import 'package:wls_pos/home/models/request/UserMenuListRequest.dart';
import 'package:wls_pos/home/models/response/get_config_response.dart';
import 'package:wls_pos/login/models/response/GetLoginDataResponse.dart';
import 'package:wls_pos/login/models/response/GetLoginDataResponse.dart';
import 'package:wls_pos/lottery/lottery_logic.dart';
import 'package:wls_pos/lottery/models/request/CancelTicketRequest.dart';
import 'package:wls_pos/lottery/models/request/RePrintRequest.dart';
import 'package:wls_pos/lottery/models/response/CancelTicketResponse.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';

import '../../lottery/models/response/saleResponseBean.dart';
import '../models/response/UserMenuApiResponse.dart';
import '../models/response/get_config_response.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<GetUserMenuListApiData>(_onHomeEvent);
    on<GetConfigData>(_onConfigEvent);
    on<RePrintApi>(_onRePrintEvent);
    on<CancelTicketApi>(_onCancelTicketEvent);
  }
}

_onHomeEvent(GetUserMenuListApiData event, Emitter<HomeState> emit) async {
  emit(UserMenuListLoading());

  BuildContext context = event.context;

  var response = await HomeLogic.callUserMenuList(
      context,
      UserMenuListRequest(
        userId: UserInfo.userId,
        appType: appType,
        engineCode: clientId, // RMS
        languageCode: languageCode,
      ).toJson());

  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(UserMenuListError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          UserMenuApiResponse successResponse = value as UserMenuApiResponse;

          List<ModuleBeanLst> fetchGameListModuleBean = successResponse.responseData?.moduleBeanLst?.where((element) => element.moduleCode == "DRAW_GAME").toList() ?? [];
          if (fetchGameListModuleBean.isNotEmpty == true) {
            var fetchGameListMenuBean = fetchGameListModuleBean[0].menuBeanList?.where((element) => element.menuCode == "DGE_GAME_LIST").toList();
            if (fetchGameListMenuBean?.isNotEmpty == true) {
              UserInfo.setLotteryMenuBeanList(jsonEncode(fetchGameListMenuBean?[0]));
            }
          }

          emit(UserMenuListSuccess(response: successResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          emit(UserMenuListError(errorMessage: "responseFailure"));
        },
        failure: (value) {
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(UserMenuListError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        });
  } catch (e) {
    print("error=========> $e");
    emit(UserMenuListError(errorMessage: "Technical Issue !"));
  }
}

_onConfigEvent(GetConfigData event, Emitter<HomeState> emit) async {
  emit(UserMenuListLoading());

  BuildContext context = event.context;
  GetLoginDataResponse loginResponse        = GetLoginDataResponse.fromJson(jsonDecode(UserInfo.getUserInfo));

  log("savedLoginResponse: $loginResponse");
  Map<String, String> param = {
    'domainId': "${loginResponse.responseData?.data?.domainId}" ?? "1",
  };

  var response = await HomeLogic.callConfigData(context, param);

  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(UserConfigError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          GetConfigResponse successResponse = value as GetConfigResponse;
          emit(UserConfigSuccess(response: successResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          emit(UserConfigError(errorMessage: "responseFailure"));
        },
        failure: (value) {
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(UserConfigError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        });
  } catch (e) {
    print("error=========> $e");
  }
}
_onRePrintEvent(RePrintApi event, Emitter<HomeState> emit) async{
  emit(RePrintLoading());

  BuildContext context = event.context;
  UrlDrawGameBean? urlDetails = event.apiUrlDetails;
  SaleResponseBean lastSaleTicketResp = SaleResponseBean.fromJson(jsonDecode(SharedPrefUtils.getSaleTicketResponse));

  String ticketNumber = lastSaleTicketResp?.responseData?.ticketNumber ?? "";
  String gameCode = lastSaleTicketResp?.responseData?.gameCode ?? "";
  print("relative url -------> ${urlDetails?.url}");

  var response = await HomeLogic.callRePrint(context,
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
      RePrintResponse successResponse =  value as RePrintResponse;
      emit(RePrintSuccess(response: successResponse));

    }, responseFailure: (value) {
      print("bloc responseFailure:");
      RePrintResponse errorResponse =  value as RePrintResponse;
      emit(RePrintError(errorMessage: errorResponse.responseMessage??"ResponseFailure"));

    }, failure: (value) {
      print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      emit(RePrintError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    print("error=========> $e");
    emit(RePrintError(errorMessage: "Technical Issue !"));
  }

}

_onCancelTicketEvent(CancelTicketApi event, Emitter<HomeState> emit) async{
  emit(CancelTicketLoading());

  BuildContext context = event.context;
  UrlDrawGameBean? urlDetails = event.apiUrlDetails;
  SaleResponseBean lastSaleTicketResp = SaleResponseBean.fromJson(jsonDecode(SharedPrefUtils.getSaleTicketResponse));

  String ticketNumber = lastSaleTicketResp?.responseData?.ticketNumber ?? "";
  String gameCode = lastSaleTicketResp?.responseData?.gameCode ?? "";

  var response = await LotteryLogic.callCancelTicket(context,
      urlDetails?.basePath ?? "",
      urlDetails?.url ?? "",
      CancelTicketRequest(
          autoCancel: "CANCELMANUAL",
          cancelChannel: deviceType,
          gameCode: gameCode,
          isAutoCancel: false,
          modelCode: "NA",
          sessionId: UserInfo.userToken,
          ticketNumber: ticketNumber,
          userId: UserInfo.userId
      ).toJson());
  SharedPrefUtils.setSaleTicketResponse = "";
  try {
    response.when(idle: () {

    }, networkFault: (value) {
      emit(CancelTicketError(errorMessage: value["occurredErrorDescriptionMsg"]));

    }, responseSuccess: (value) {
      CancelTicketResponse successResponse =  value as CancelTicketResponse;

      emit(CancelTicketSuccess(response: successResponse));

    }, responseFailure: (value) {
      print("bloc responseFailure:");
      CancelTicketResponse errorResponse =  value as CancelTicketResponse;
      emit(CancelTicketError(errorMessage: errorResponse.responseMessage??"ResponseFailure"));

    }, failure: (value) {
      print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      emit(CancelTicketError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    print("error=========> $e");
    emit(RePrintError(errorMessage: "Technical Issue !"));
  }

}