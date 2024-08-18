import 'package:flutter/cupertino.dart';

abstract class DepositEvent {}

class DepositApiData extends DepositEvent {
  BuildContext context;
  String url;
  String retailerName;
  String amount;
  String userName;

  DepositApiData({
    required this.context,
    required this.url,
    required this.retailerName,
    required this.amount,
    required this.userName,
  });
}

class CheckAvailabilityApiData extends DepositEvent {
  BuildContext context;
  String mobileNumber;

  CheckAvailabilityApiData({required this.context, required this.mobileNumber});
}

class SendOtpApiData extends DepositEvent {
  BuildContext context;
  String mobileNumber;

  SendOtpApiData({required this.context, required this.mobileNumber});
}

class ScanQrCodeData extends DepositEvent {
  BuildContext context;
  String data;

  ScanQrCodeData({required this.context, required this.data});
}

class RePrintQrCodeData extends DepositEvent {
  BuildContext context;
  String data;
  String isUpdate;

  RePrintQrCodeData(
      {required this.context, required this.data, required this.isUpdate});
}

class CouponReversalApi extends DepositEvent {
  BuildContext context;
  String couponCode;

  CouponReversalApi({required this.context, required this.couponCode});
}
