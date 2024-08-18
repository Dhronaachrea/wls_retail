import 'package:wls_pos/scan_and_play/depositScreen/model/qrCodeResponse.dart';
import 'package:wls_pos/scan_and_play/depositScreen/model/sendOtpResponse.dart';

import '../../../diposit_withdrawal/model/check_availability_response.dart';
import '../../../diposit_withdrawal/model/rePrintApiReponse.dart';
import '../model/deposit_coupon_reversal/coupon_reversal_response.dart';
import '../model/deposit_response.dart';

abstract class DepositState {}

class DepositInitial extends DepositState {}

class DepositLoading extends DepositState {}

class DepositSuccess extends DepositState {
  DepositResponse response;

  DepositSuccess({required this.response});
}

class DepositError extends DepositState {
  String errorMessage;

  DepositError({required this.errorMessage});
}

class CheckAvailabilityInitial extends DepositState {}

class CheckAvailabilityLoading extends DepositState {}

class CheckAvailabilitySuccess extends DepositState {
  CheckAvailabilityResponse response;

  CheckAvailabilitySuccess({required this.response});
}

class CheckAvailabilityError extends DepositState {
  String errorMessage;

  CheckAvailabilityError({required this.errorMessage});
}

class SendOtpLoading extends DepositState {}

class SendOtpSuccess extends DepositState {
  SendOtpResponse response;

  SendOtpSuccess({required this.response});
}

class SendOtpError extends DepositState {
  String errorMessage;

  SendOtpError({required this.errorMessage});
}


class ScanQrCodeLoading extends DepositState {}

class ScanQrCodeSuccess extends DepositState {
  QrCodeResponse response;

  ScanQrCodeSuccess({required this.response});
}

class ScanQrCodeError extends DepositState {
  String errorMessage;

  ScanQrCodeError({required this.errorMessage});
}

class CouponReversalLoading extends DepositState {}

class CouponReversalSuccess extends DepositState {
  CouponReversalResponse response;

  CouponReversalSuccess({required this.response});
}

class CouponReversalError extends DepositState {
  String errorMessage;

  CouponReversalError({required this.errorMessage});
}


class ReprintQrCodeLoading extends DepositState {}

class ReprintQrCodeSuccess extends DepositState {
  RePrintQrCodeResponse response;

  ReprintQrCodeSuccess({required this.response});
}

class ReprintQrCodeError extends DepositState {
  String errorMessage;

  ReprintQrCodeError({required this.errorMessage});
}


