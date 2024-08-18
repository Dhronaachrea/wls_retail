class DepWithResponse {
  DepWithResponse ({
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });
  late final int responseCode;
  late final String responseMessage;
  late final ResponseData responseData;

  DepWithResponse.fromJson(Map<String, dynamic> json){
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    responseData = ResponseData.fromJson(json['responseData']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['responseCode'] = responseCode;
    _data['responseMessage'] = responseMessage;
    _data['responseData'] = responseData.toJson();
    return _data;
  }
}

class ResponseData {
  ResponseData({
    required this.message,
    required this.statusCode,
    required this.data,
  });
  late final String message;
  late final int statusCode;
  late final Data? data;
  late final dynamic errors;

  ResponseData.fromJson(Map<String, dynamic> json){
    message = json['message'];
    statusCode = json['statusCode'];
    data = json['data'] == null ? null : Data.fromJson(json['data']);
    errors = json['errors'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['statusCode'] = statusCode;
    _data['data'] = data?.toJson();
    _data['errors'] = errors;
    return _data;
  }
}

class Data {
  Data({
    required this.orgTypeCode,
    required this.total,
    required this.address,
    required this.orgName,
    required this.orgId,
    required this.transaction,
  });
  late final String orgTypeCode;
  late final Total total;
  late final String address;
  late final String orgName;
  late final String orgId;
  late final List<Transaction> transaction;

  Data.fromJson(Map<String, dynamic> json){
    orgTypeCode = json['orgTypeCode'];
    total = Total.fromJson(json['total']);
    address = json['address'];
    orgName = json['orgName'];
    orgId = json['orgId'];
    transaction = List.from(json['transaction']).map((e)=>Transaction.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['orgTypeCode'] = orgTypeCode;
    _data['total'] = total.toJson();
    _data['address'] = address;
    _data['orgName'] = orgName;
    _data['orgId'] = orgId;
    _data['transaction'] = transaction.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Total {
  Total({
    required this.registrationDepositReturn,
    required this.netCollection,
    required this.depositReturn,
    required this.registrationDeposit,
    required this.finalDeposit,
    required this.rawNetCollection,
    required this.deposit,
    required this.withdrawal,
  });
  late final String registrationDepositReturn;
  late final String netCollection;
  late final String depositReturn;
  late final String registrationDeposit;
  late final String finalDeposit;
  late final double rawNetCollection;
  late final String deposit;
  late final String withdrawal;

  Total.fromJson(Map<String, dynamic> json){
    registrationDepositReturn = json['registrationDepositReturn'];
    netCollection = json['netCollection'];
    depositReturn = json['depositReturn'];
    registrationDeposit = json['registrationDeposit'];
    finalDeposit = json['finalDeposit'];
    rawNetCollection = json['rawNetCollection'];
    deposit = json['deposit'];
    withdrawal = json['withdrawal'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['registrationDepositReturn'] = registrationDepositReturn;
    _data['netCollection'] = netCollection;
    _data['depositReturn'] = depositReturn;
    _data['registrationDeposit'] = registrationDeposit;
    _data['finalDeposit'] = finalDeposit;
    _data['rawNetCollection'] = rawNetCollection;
    _data['deposit'] = deposit;
    _data['withdrawal'] = withdrawal;
    return _data;
  }
}

class Transaction {
  Transaction({
    required this.registrationDepositReturn,
    required this.txnTyeCode,
    required this.depositReturn,
    required this.txnValue,
    required this.registrationDeposit,
    required this.PlayerMobile,
    required this.balancePostTxn,
    required this.deposit,
    required this.withdrawal,
    required this.userId,
    required this.txnDate,
    required this.txnId,
  });
  late final String registrationDepositReturn;
  late final String txnTyeCode;
  late final String depositReturn;
  late final String txnValue;
  late final String registrationDeposit;
  late final String PlayerMobile;
  late final String balancePostTxn;
  late final String deposit;
  late final String withdrawal;
  late final String userId;
  late final String txnDate;
  late final int txnId;

  Transaction.fromJson(Map<String, dynamic> json){
    registrationDepositReturn = json['registrationDepositReturn'];
    txnTyeCode = json['txnTyeCode'];
    depositReturn = json['depositReturn'];
    txnValue = json['txnValue'];
    registrationDeposit = json['registrationDeposit'];
    PlayerMobile = json['Player_Mobile'];
    balancePostTxn = json['balancePostTxn'];
    deposit = json['deposit'];
    withdrawal = json['withdrawal'];
    userId = json['userId'];
    txnDate = json['txnDate'];
    txnId = json['txnId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['registrationDepositReturn'] = registrationDepositReturn;
    _data['txnTyeCode'] = txnTyeCode;
    _data['depositReturn'] = depositReturn;
    _data['txnValue'] = txnValue;
    _data['registrationDeposit'] = registrationDeposit;
    _data['Player_Mobile'] = PlayerMobile;
    _data['balancePostTxn'] = balancePostTxn;
    _data['deposit'] = deposit;
    _data['withdrawal'] = withdrawal;
    _data['userId'] = userId;
    _data['txnDate'] = txnDate;
    _data['txnId'] = txnId;
    return _data;
  }
}