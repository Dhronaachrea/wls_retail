class SaleTicketRequest {
  String? gameType;
  String? soldChannel;
  List<String>? ticketNumberList;
  String? modelCode;
  String? terminalId;
  String? userName;
  String? userSessionId;
  //String? retailerOrgId;

  SaleTicketRequest(
      {this.gameType,
        this.soldChannel,
        this.ticketNumberList,
        this.modelCode,
        this.terminalId,
        this.userName,
        this.userSessionId,
       //this.retailerOrgId,
      });

  SaleTicketRequest.fromJson(Map<String, dynamic> json) {
    gameType = json['gameType'];
    soldChannel = json['soldChannel'];
    ticketNumberList = json['ticketNumberList'].cast<String>();
    //modelCode = json['modelCode'];
    terminalId = json['terminalId'];
    userName = json['userName'];
    userSessionId = json['userSessionId'];
    //retailerOrgId = json['retailerOrgId'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gameType'] = this.gameType;
    data['soldChannel'] = this.soldChannel;
    data['ticketNumberList'] = this.ticketNumberList;
    if(modelCode != null){
      data['modelCode'] = this.modelCode;
    }
    data['terminalId'] = this.terminalId;
    data['userName'] = this.userName;
    data['userSessionId'] = this.userSessionId;
    //data['retailerOrgId'] = this.retailerOrgId;
    return data;
  }
}
