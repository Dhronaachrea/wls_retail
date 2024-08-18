import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/purchase_details/logic/purchase_logic.dart';
import 'package:wls_pos/purchase_details/model/request/sports_pool_sale_model.dart';
import 'package:wls_pos/purchase_details/model/response/sale_response_model.dart';
import 'package:wls_pos/sportsLottery/models/response/rms_response_json_model.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/user_info.dart';

part 'game_sale_event.dart';

part 'game_sale_state.dart';

class GameSaleBloc extends Bloc<GameSaleEvent, GameSaleState> {
  GameSaleBloc() : super(GameSaleInitial()) {
    on<GameSale>(onGameSale);
  }

  Future<FutureOr<void>> onGameSale(
      GameSale event, Emitter<GameSaleState> emit) async {
    BuildContext context = event.context;
    SportsPoolSaleModel? sportsPoolSaleModel = event.sportsPoolSaleModel;

    Map<String, dynamic>? saleInfo = sportsPoolSaleModel?.toJson();

    Map<String, String> param = {
      'retailerId': UserInfo.userId,/*'850'*/
      'stake': sportsPoolSaleModel?.totalSaleAmount.toString() ?? '0',
      'domainName': sportsPoolDomainName,
      'retailerToken': UserInfo.userToken, //'P9X2W4GDE5MqYBe68vGblqzCVb3sOMt1io_I55X-MkE'

    };

    var response = await PurchaseLogic.callSaleApi(context, saleInfo!, param);

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(GameSaleError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            SaleResponseModel successResponse = value as SaleResponseModel;
            emit(GameSaleSuccess(response: successResponse));
          },
          responseFailure: (value) {
            SaleResponseModel errorResponse = value as SaleResponseModel;
            print(
                "bloc responseFailure: ${errorResponse.responseData?.message} =======> ");
            String? errorMessage;
            if(errorResponse.responseData != null){
              if(errorResponse.responseData?.transactionStatus != null && errorResponse.responseData?.transactionStatus == "FAILED" && errorResponse.responseData?.rgRespJson != null){
                String rgRespJson = errorResponse.responseData?.rgRespJson ?? '';
                String? formattedRqResponseJson = rgRespJson.replaceAll("\\", "");
                RmsResponseJsonModel rmsResponseJsonModel = RmsResponseJsonModel.fromJson(jsonDecode(formattedRqResponseJson));
                 errorMessage = rmsResponseJsonModel.rmsResponse?.responseData?.message ?? "Something Went Wrong!" ;
              } else {
                errorMessage = errorResponse.responseData?.message ?? "Something Went Wrong!";
              }
            } else {
              errorMessage = errorResponse.responseMessage ?? "Something Went Wrong!";
            }
            emit(GameSaleError(
                errorMessage: errorMessage));
          },
          failure: (value) {
            if(value.responseCode == 401 || value.responseCode == 100)
            {
              emit(GameSaleError(errorMessage: value.responseMessage));
            }
            else
            {
              emit(GameSaleError(errorMessage: value["occurredErrorDescriptionMsg"]));
            }
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          });
    } catch (e) {
      print("error=========> $e");
    }
  }
}
