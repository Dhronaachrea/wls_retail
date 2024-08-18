import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/diposit_withdrawal/model/check_availability_response.dart';
import 'package:wls_pos/scan_and_play/depositScreen/model/qrCodeResponse.dart';
import 'package:wls_pos/scan_and_play/depositScreen/model/sendOtpResponse.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';
import '../../../diposit_withdrawal/model/rePrintApiReponse.dart';
import '../../../utility/app_constant.dart';
import '../../../utility/shared_pref.dart';
import '../../../utility/user_info.dart';
import '../../../utility/utils.dart';
import '../../../utility/wls_pos_color.dart';
import '../deposit_logic.dart';
import '../model/checkAvailability_request.dart';
import '../model/deposit_coupon_reversal/coupon_reversal_request.dart';
import '../model/deposit_coupon_reversal/coupon_reversal_response.dart';
import '../model/deposit_request.dart';
import '../model/deposit_response.dart';
import 'deposit_event.dart';
import 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  DepositBloc() : super(DepositInitial()) {
    on<DepositApiData>(_getDepositResponse);
    on<CheckAvailabilityApiData>(_checkAvailability);
    on<SendOtpApiData>(_sendOtp);
    on<ScanQrCodeData>(_onQrCodeScan);
    on<CouponReversalApi>(_getCouponReversal);
    on<RePrintQrCodeData>(_onRePrintCode);
  }

  _getDepositResponse(
      DepositApiData event, Emitter<DepositState> emitter) async {
    emit(DepositLoading());

    BuildContext context = event.context;

    DepositRequest model = DepositRequest(
        deviceType: terminal,
        appType: appType,
        aliasName: SharedPrefUtils.getScanAndPlayAliasName,
        couponCount: 1,
        responseType: responseType,
        retailerName: UserInfo.orgName,
        amount: event.amount,
        userName: event.userName,
        gameCode: gameCode,
        serviceCode: serviceCode,
        providerCode: serviceCode);

    Map<String, dynamic>? _model = model.toJson();

    var response = await DepositLogic.depositData(context, _model);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(DepositError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            DepositResponse _response = value as DepositResponse;

            emit(DepositSuccess(response: _response));
          },
          responseFailure: (value) {
            DepositResponse errorResponse = value as DepositResponse;
            print(
                "bloc responseFailure: ${errorResponse.errorMessage} =======> ");

            if (errorResponse.errorCode == 12429) {
              // session expire
              BuildContext? context = navigatorKey.currentContext;
              UserInfo.logout();
              if (context != null) {
                Navigator.of(context).popUntil((route) => false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: WlsPosColor.tomato,
                  content: const Text("Session Expired, Please Login",
                      style: TextStyle(color: WlsPosColor.white)),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height - 100,
                      right: 20,
                      left: 20),
                ));
                Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
              }
            } else {
              emit(DepositError(
                  errorMessage:
                      errorResponse.errorMessage ?? "Something Went Wrong!"));
            }
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(DepositError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _checkAvailability(
      CheckAvailabilityApiData event, Emitter<DepositState> emitter) async {
    emit(CheckAvailabilityLoading());

    BuildContext context = event.context;

    CheckAvailabilityRequest model = CheckAvailabilityRequest(
      userName: event.mobileNumber,
      domainName: domainNameInfiniti,
    );

    Map<String, dynamic>? _model = model.toJson();

    var response = await DepositLogic.checkAvailability(context, _model);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(CheckAvailabilityError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            CheckAvailabilityResponse _response =
                value as CheckAvailabilityResponse;

            if (value.errorCode == 505) {
              emit(CheckAvailabilitySuccess(response: _response));
            } else {
              emit(CheckAvailabilityError(errorMessage: value.respMsg));
            }
          },
          responseFailure: (value) {
            print("bloc responseFailure: ${value} =======> ");
            if (value.errorCode == 505) {
              CheckAvailabilityResponse _response =
                  value as CheckAvailabilityResponse;

              emit(CheckAvailabilitySuccess(response: _response));
            } else {
              emit(CheckAvailabilityError(errorMessage: value.respMsg));
            }
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(CheckAvailabilityError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _sendOtp(SendOtpApiData event, Emitter<DepositState> emitter) async {
    emit(SendOtpLoading());

    BuildContext context = event.context;

    Map<String, String> _model = {
      "aliasName": SharedPrefUtils.getScanAndPlayAliasName,
      "mobileNo": event.mobileNumber,
      "verificationType": "LINK",
    };
    var response = await DepositLogic.sendOtp(context, _model);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(SendOtpError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            SendOtpResponse _response = value as SendOtpResponse;

            emit(SendOtpSuccess(response: _response));
          },
          responseFailure: (value) {
            print("bloc responseFailure: ${value} =======> ");

            emit(SendOtpError(errorMessage: value.respMsg));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(SendOtpError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _onQrCodeScan(ScanQrCodeData event, Emitter<DepositState> emitter) async {
    emit(ScanQrCodeLoading());

    BuildContext context = event.context;

    Map<String, String> _model = {
      "qrCodeData": event.data,
    };
    var response = await DepositLogic.scanQrCode(context, _model);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(ScanQrCodeError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            QrCodeResponse _response = value as QrCodeResponse;

            emit(ScanQrCodeSuccess(response: _response));
          },
          responseFailure: (value) {
            print("bloc responseFailure: ${value} =======> ");

            QrCodeResponse _response = value as QrCodeResponse;

            emit(ScanQrCodeError(errorMessage: _response.errorMessage.toString()));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(ScanQrCodeError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _getCouponReversal(
      CouponReversalApi event, Emitter<DepositState> emitter) async {
    emit(CouponReversalLoading());

    BuildContext context = event.context;

    CouponReversalRequest model = CouponReversalRequest(
        aliasName: SharedPrefUtils.getScanAndPlayAliasName,
        deviceType: terminal,
        couponCode: event.couponCode,
        gameCode: gameCode,
        serviceCode: serviceCode,
        providerCode: serviceCode);

    Map<String, dynamic>? _model = model.toJson();

    var response = await DepositLogic.couponReversalApi(context, _model);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(CouponReversalError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            CouponReversalResponse _response = value as CouponReversalResponse;

            emit(CouponReversalSuccess(response: _response));
          },
          responseFailure: (value) {
            CouponReversalResponse errorResponse =
                value as CouponReversalResponse;
            print(
                "bloc responseFailure: ${errorResponse.errorMessage} =======> ");

            // emit(CouponReversalError(
            //     errorMessage: loadLocalizedData(
            //             "BONUS_${errorResponse.errorCode ?? ""}",
            //             LongaLottoRetailApp.of(context).locale.languageCode) ??
            //         errorResponse.errorMessage ??
            //         ""));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(CouponReversalError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _onRePrintCode(RePrintQrCodeData event, Emitter<DepositState> emitter) async {
    emit(ReprintQrCodeLoading());

    BuildContext context = event.context;

    Map<String, String> _model = {
      "qrCodeData": event.data,
      "aliasName": SharedPrefUtils.getScanAndPlayAliasName,
      "isUpdate": event.isUpdate,
    };

    var response = await DepositLogic.reprintQrCode(context, _model);
    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(ReprintQrCodeError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            RePrintQrCodeResponse _response = value as RePrintQrCodeResponse;

            emit(ReprintQrCodeSuccess(response: _response));
          },
          responseFailure: (value) {
            print("bloc responseFailure: ${value} =======> ");

            RePrintQrCodeResponse _response = value as RePrintQrCodeResponse;

            emit(ReprintQrCodeError(errorMessage: _response.errorMessage.toString()));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(ReprintQrCodeError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

}
