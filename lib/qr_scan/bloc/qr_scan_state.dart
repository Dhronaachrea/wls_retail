import 'package:wls_pos/sportsLottery/models/response/sp_reprint_response.dart';

abstract class QrScanState {}

class QrScanInitial extends QrScanState {}

class QrScanLoading extends QrScanState {}

class QrScanSuccess extends QrScanState {
  SpRePrintResponse response;

  QrScanSuccess({required this.response});
}

class QrScanError extends QrScanState {
  String errorMessage;

  QrScanError({required this.errorMessage});
}
