import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/qr_scan/bloc/models/request/qrScanRequest.dart';
//import 'package:wls_pos/qr_scan/bloc/models/response/qrScanApiResponse.dart';
import 'package:wls_pos/qr_scan/bloc/qr_scan_event.dart';
import 'package:wls_pos/qr_scan/bloc/qr_scan_state.dart';
import 'package:wls_pos/qr_scan/qr_scan_logic.dart';
import 'package:wls_pos/sportsLottery/models/response/sp_reprint_response.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/user_info.dart';

class QrScanBloc extends Bloc<QrScanEvent, QrScanState> {
  QrScanBloc() : super(QrScanInitial()) {
    on<GetWinClaimDataApi>(_onQrScanEvent);
  }
}

_onQrScanEvent(GetWinClaimDataApi event, Emitter<QrScanState> emit) async {
  emit(QrScanLoading());

  BuildContext context = event.context;
  String? barCodetext = event.barCodetext;

  var response = await QrScanLogic.callQrScanData(
      context,
      QrScanRequest(
              deviceId: "MOBILE",
              retailerId: UserInfo.userId,
              //retailerId: "838",
              retailerToken: UserInfo.userToken,
              //retailerToken: "wnH3ThvpC2PzVQI1PddhVP4Z0Bn72qbvjwh2rMucfyU",
              ticketNo: barCodetext,
              //ticketNo: '16829349971520000838601',
              domainName: sportsPoolDomainName,
      )
          .toJson());

  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(QrScanError(errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          SpRePrintResponse successResponse = value as SpRePrintResponse;

          emit(QrScanSuccess(response: successResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          emit(QrScanError(errorMessage: "responseFailure"));
        },
        failure: (value) {
          if(value.responseCode == 401 || value.responseCode == 100 ||  value.responseCode == 1055 || value.responseCode == 1305)
          {
            SpRePrintResponse failedResponse = value as SpRePrintResponse;
            emit(QrScanError(errorMessage: failedResponse.responseMessage??''));
            print("bloc failure: ${failedResponse.responseMessage}");
          }
          else
          {
            emit(QrScanError(errorMessage: value["occurredErrorDescriptionMsg"]));
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          }

        });
  } catch (e) {
    print("error=========> $e");
  }
}
