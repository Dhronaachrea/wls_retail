class FetchGameDataRequest {
  String? lastTicketNumber;
  String? retailerId;
  String? sessionId;

  FetchGameDataRequest(
      {this.lastTicketNumber, this.retailerId, this.sessionId});

  FetchGameDataRequest.fromJson(Map<String, dynamic> json) {
    lastTicketNumber = json['lastTicketNumber'];
    retailerId = json['retailerId'];
    sessionId = json['sessionId'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['lastTicketNumber'] = lastTicketNumber ?? "";
    data['retailerId'] = retailerId ?? "";
    data['sessionId'] = sessionId ?? "";
    return data;
  }
}
