import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/utility/secured_shared_pref.dart';
import 'package:wls_pos/utility/shared_pref.dart';

class UserInfo {
  static final UserInfo _instance = UserInfo._ctor();
  static ModuleBeanLst? mLotteryMenuList;
  static ModuleBeanLst? mScratchMenuList;
  static ModuleBeanLst? mReportMenuList;
  static ModuleBeanLst? mUserMenuList;


  factory UserInfo() {
    return _instance;
  }

  UserInfo._ctor();

  static bool isLoggedIn() {
    return SharedPrefUtils.playerToken != '';
  }

  static logout() async {
    SharedPrefUtils.removeValue(PrefType.userPref.value);
    SharedPrefUtils.removeValue(PrefType.appPref.value);
    //SecuredSharedPrefUtils.removeValue(PrefType.appPref.value);
  }

  static setPlayerToken(String token) {
    SharedPrefUtils.playerToken = token;
  }

  static setPlayerId(String playerId) {
    SharedPrefUtils.playerId = playerId;
  }

  static setTotalBalance(String totalBalance) {
    SharedPrefUtils.totalBalance = totalBalance;
  }

  static setOrganisation(String org) {
    SharedPrefUtils.organisation = org;
  }

  static setOrganisationId(String org) {
    SharedPrefUtils.organisationID = org;
  }

  static setUserInfoData(String data) {
    SharedPrefUtils.loginResponse = data;
  }
  static setUserName(String data) {
    SharedPrefUtils.userName = data;
  }
  static setOrgName(String data) {
    SharedPrefUtils.orgName = data;
  }

  static setDrawGameBeanListData(String data) {
    SharedPrefUtils.drawGameMenuBeanList = data;
  }

  static setLotteryMenuBeanList(String data) {
    SharedPrefUtils.setLotteryMenuBeanList = data;
  }

  static setLastSaleTicketNo(String data) {
    SharedPrefUtils.setDgeLastSaleTicketNo = data;
  }

  static setLastSaleGameCode(String data) {
    SharedPrefUtils.setDgeLastSaleGameCode = data;
  }

  static setSportsPoolLastOrderId(String data){
    SecuredSharedPrefUtils.setSportsPoolLastOrderId = data;
  }

  static setSportsPoolLastItemId(String data){
    SecuredSharedPrefUtils.setSportsPoolLastItemId = data;
  }
  static setDomainId(String org) {
    SharedPrefUtils.domainID = org;
  }

  static String get domainID => SharedPrefUtils.domainID;

  static String get userToken => SharedPrefUtils.playerToken;

  static String get userId => SharedPrefUtils.playerId;

  static String get totalBalance => SharedPrefUtils.totalBalance;

  static String get organisation => SharedPrefUtils.organisation;

  static String get organisationID => SharedPrefUtils.organisationID;
  static String get orgName => SharedPrefUtils.orgName;

  static String get userName => SharedPrefUtils.userName;


  static String get getUserInfo => SharedPrefUtils.loginResponse;

  static String get getDrawGameBeanList => SharedPrefUtils.drawGameMenuBeanList;

  static String get getLotteryMenuBeanList => SharedPrefUtils.getLotteryMenuBeanList;

  static String get getSelectedPanelData    => SharedPrefUtils.getSelectedPanelData;
  static String get getSelectedGameObject   => SharedPrefUtils.getSelectedGameObject;

  static String get getDgeLastSaleTicketNo  => SharedPrefUtils.getDgeLastSaleTicketNo;
  static String get getDgeLastSaleGameCode  => SharedPrefUtils.getDgeLastSaleGameCode;

  static Future<String> get getSportsPoolLastOrderId  => SecuredSharedPrefUtils.getSportsPoolLastOrderId;
  static Future<String> get getSportsPoolLastItemId  => SecuredSharedPrefUtils.getSportsPoolLastItemId;
}
