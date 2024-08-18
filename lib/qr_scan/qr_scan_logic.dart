import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/qr_scan/bloc/models/response/qrScanApiResponse.dart';
import 'package:wls_pos/qr_scan/repository/qr_scan_repository.dart';
import 'package:wls_pos/utility/result.dart';

import '../sportsLottery/models/response/sp_reprint_response.dart';

class QrScanLogic {
  static Future<Result<dynamic>> callQrScanData(
      BuildContext context, Map<String, String> param) async {
    Map<String, String> header = {
      // "Authorization" : "Bearer ${UserInfo.userToken}"
      "Authorization": "Bearer v8RTJ0Ai21bkLoo-apZanYi7SG_-avf2t76bjXCNSQY"
    };
    // header for scratch
    /*Map<String, String> header = {
      "clientId": "RMS1",
      "clientSecret": "13f1JiFyWSZ0XI/3Plxr3mv7gbNObpU1",
      "Content-Type": headerValues['Content-Type']
    };*/

    dynamic jsonMap = await QrScanRepository.callQrScan(context, param);
    try {
      var respObj = SpRePrintResponse.fromJson( jsonMap
          //hardcoded data {"responseCode":1000,"responseMessage":"SUCCESS","responseData":{"id":2944,"year":2023,"month":7,"day":10,"ticketDate":"2023-07-10 00:00:00","deviceId":"MOBILE","randomNo":230,"lastRandomNo":265,"lastTicketNo":"16889856423570000850851","dayOfYear":191,"txnOfDay":12,"ticketNo":"16889857019240000850525","domainId":1,"saleAmountDomain":1.0,"oneWayEncLastTicketNo":null,"twoWayEncLastTicketNo":null,"oneWayEncTicketNo":null,"twoWayEncTicketNo":null,"tpTxnId":"8346","saleReturnTpTxnId":null,"tpErrorResponse":null,"authoriserRemarks":"Success","gameId":1,"merchantId":1,"merchantGameCode":"SOCCER_4","currency":"EUR","currencyDomain":"EUR","currencySystem":"EUR","userId":102,"merchantPlayerId":"850","ticketType":"SINGLE","userType":"RETAILER","txnCount":1,"noOfTicketPerLine":1,"saleAmount":1.0,"cancelledAmount":0.0,"winningStatus":"WIN","winningAmount":0.66,"winningAmountDomain":0.66,"saleAmountSystem":1.0,"mainDrawSaleAmountSystem":1.0,"addonDrawSaleAmountSystem":0.0,"payoutTransactionId":436,"cancelledAmountSystem":0.0,"winningAmountSystem":0.66,"mainDrawWinningAmountSystem":0.66,"addonDrawWinningAmountSystem":0.0,"payoutRetailerUserId":102,"paidAt":"2023-09-05 14:48:30","successAt":"2023-07-10 16:11:42","status":"PAYOUT_DONE","transactionStatus":"SUCCESS","settlementStatus":"SUCCESS","reprintCount":0,"lastReprintAt":null,"payoutValidTill":"2023-10-11 16:44:17","drawId":30,"addonDrawId":null,"orderId":"1688985699593070","itemId":"1688985699593298","highWinningRequestId":null,"cancelledRemarks":null,"cancelledBy":null,"cancelledByUserName":null,"cancelledByUserId":null,"settledAt":"2023-09-05 14:48:29","isHighWin":false,"isQuickPick":null,"selectionJson":"{\"mainDraw\":[{\"marketName\":\"Half time 1X2\",\"marketCode\":\"HALF_TIME_ONE_X_TWO\",\"events\":[{\"eventId\":87,\"options\":[{\"id\":690,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"KJK8123456784 VS 0J1234A \",\"homeTeamName\":\"KJ123456781\",\"AwayTeamName\":\"0J1234A\"},{\"eventId\":88,\"options\":[{\"id\":698,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"03KJ VS. 04KJ\",\"homeTeamName\":\"03KJ\",\"AwayTeamName\":\"04KJ\"},{\"eventId\":89,\"options\":[{\"id\":706,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"05KJ VS. 06KJ\",\"homeTeamName\":\"05KJ\",\"AwayTeamName\":\"06KJ\"},{\"eventId\":90,\"options\":[{\"id\":714,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"07KJ VS. 08KJ\",\"homeTeamName\":\"07KJ\",\"AwayTeamName\":\"08KJ\"}],\"marketId\":4},{\"marketName\":\"1X2\",\"marketCode\":\"ONE_X_TWO\",\"events\":[{\"eventId\":87,\"options\":[{\"id\":694,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"KJK8123456784 VS 0J1234A \",\"homeTeamName\":\"KJ123456781\",\"AwayTeamName\":\"0J1234A\"},{\"eventId\":88,\"options\":[{\"id\":702,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"03KJ VS. 04KJ\",\"homeTeamName\":\"03KJ\",\"AwayTeamName\":\"04KJ\"},{\"eventId\":89,\"options\":[{\"id\":710,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"05KJ VS. 06KJ\",\"homeTeamName\":\"05KJ\",\"AwayTeamName\":\"06KJ\"},{\"eventId\":90,\"options\":[{\"id\":718,\"code\":\"H\",\"name\":\"HOME\",\"displayName\":null}],\"eventName\":\"07KJ VS. 08KJ\",\"homeTeamName\":\"07KJ\",\"AwayTeamName\":\"08KJ\"}],\"marketId\":1}]}","createdAt":"2023-07-10 16:11:42","updatedAt":"2023-09-05 14:48:30","service":"SPORTS_POOL","betTransactions":null,"markedByScheduler":false,"cancelledAt":null,"sessionUserId":null,"sessionUserName":null,"cancelationRemarks":null,"mainBoardData":null,"addOnBoardData":null,"eventIds":null,"sportEventMarketOptionById":null,"processMethod":null,"rgRespJson":null,"merchantErrorCode":0,"statusMessage":"Payout already done","drawNo":8,"saleStartDateTime":"2023-07-10 12:35:17","drawFreezeDateTime":"2023-07-10 12:35:17","drawDateTime":"2023-07-10 12:43:27"}}
      );
      if (respObj.responseCode == 1000) {
        return Result.responseSuccess(data: respObj);
      } else if (respObj.responseCode == 401 || respObj.responseCode == 100 || respObj.responseCode == 1055 || respObj.responseCode == 1305) {
        return Result.failure(data: respObj);
      } else {
        return jsonMap["occurredErrorDescriptionMsg"] != null
            ? jsonMap["occurredErrorDescriptionMsg"] == "No connection"
            ? Result.networkFault(data: jsonMap)
            : Result.failure(data: jsonMap)
            : Result.responseFailure(data: respObj);
      }
    } catch (e) {
      if (jsonMap["occurredErrorDescriptionMsg"] == "No connection") {
        return Result.networkFault(data: jsonMap);
      } else {
        return Result.failure(
            data: jsonMap["occurredErrorDescriptionMsg"] != null
                ? jsonMap
                : {"occurredErrorDescriptionMsg": e});
      }
    }
  }
}
