class CheckAvailabilityRequest {
  String? userName;
  String? domainName;

  CheckAvailabilityRequest(
      {
        this.userName,
        this.domainName
      });

  CheckAvailabilityRequest.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    domainName = json['domainName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['domainName'] = this.domainName;
    return data;
  }
}
