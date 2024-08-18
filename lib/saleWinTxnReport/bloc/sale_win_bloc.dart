import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/saleWinTxnReport/bloc/sale_win_event.dart';
import 'package:wls_pos/saleWinTxnReport/bloc/sale_win_state.dart';
import 'package:wls_pos/saleWinTxnReport/sale_list_logic.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/user_info.dart';

import '../model/get_sale_report_model.dart';
import '../model/get_sale_report_response.dart';
import '../model/get_service_list_response.dart';

class SaleWinBloc extends Bloc<SaleWinEvent, SaleWinState> {
  SaleWinBloc() : super(SaleListInitial()) {
    on<SaleList>(_getSaleList);
    on<SaleWinTxnReport>(_getSaleTaxReportList);
  }

  _getSaleList(SaleList event, Emitter<SaleWinState> emitter) async {
    emit(SaleListLoading());

    BuildContext context = event.context;

    var response = await SaleListLogic.getSaleList(context);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(SaleListError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            GetServiceListResponse _response = value as GetServiceListResponse;

            emit(SaleListSuccess(response: _response));
          },
          responseFailure: (value) {
            GetServiceListResponse errorResponse =
                value as GetServiceListResponse;
            print(
                "bloc responseFailure: ${errorResponse.responseData?.message} =======> ");
            emit(SaleListError(
                errorMessage: errorResponse.responseData?.message ??
                    "Something Went Wrong!"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(SaleListError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _getSaleTaxReportList(
      SaleWinTxnReport event, Emitter<SaleWinState> emit) async {
    emit(SaleWinTaxListLoading());
    BuildContext context = event.context;
    GetSaleReportModel model = GetSaleReportModel(
      appType: appType,
      languageCode: languageCode,
      orgId: UserInfo.organisationID,
      orgTypeCode: orgTypeCode,
      serviceCode: event.serviceCode,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    Map<String, dynamic>? _model = model.toJson();

    var response = await SaleListLogic.getSaleTxnReport(context, _model);

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(SaleWinTaxListError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            GetSaleReportResponse _response = value as GetSaleReportResponse;

            emit(SaleWinTaxListSuccess(response: _response));
          },
          responseFailure: (value) {
            GetSaleReportResponse errorResponse = value as GetSaleReportResponse;
            print(
                "bloc responseFailure: ${errorResponse.responseData?.message} =======> ");
            emit(SaleWinTaxListError(
                errorMessage: errorResponse.responseData?.message ??
                    "Something Went Wrong!"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(SaleWinTaxListError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }
  
}
