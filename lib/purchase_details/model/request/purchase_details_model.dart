import 'package:wls_pos/purchase_details/model/request/purchase_list_model.dart';
import 'package:wls_pos/purchase_details/model/request/sports_pool_sale_model.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';

class PurchaseDetailsModel {
  ResponseData? responseData;
  int drawGameSelectedIndex = 0;
  int numOfLines = 0;
  double betValue = 0;
  String? currency;
  List<PurchaseListItemModel>? purchaseListItemModelList;
  SportsPoolSaleModel? sportsPoolSaleModel;

  PurchaseDetailsModel({
    required this.responseData,
    required this.drawGameSelectedIndex,
    required this.numOfLines,
    required this.betValue,
    required this.currency,
    required this.purchaseListItemModelList,
    required this.sportsPoolSaleModel,
  });
}
