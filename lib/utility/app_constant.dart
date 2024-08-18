const lotteryModuleCode       = "DRAW_GAME";
const scratchModuleCode       = "SCRATCH";
const sportsModuleCode        = "SLE";
const scanAndPlay             = "M_SCAN_AND_PLAY_VALIDATE";
const scanNPlay             = "ScanNPlay";
const reportModuleCode        = "REPORTS";
const organizationModuleCode  = "USERS";
const clientId                = "RMS";
const merchantCode            = "INFINITI";
const purchaseChannel         = "RETAIL";
const merchantPwd             = "ph2Nj5knd4IjWBVLc4mhmYHo1hQDEdS3FlIC2KskHpeHFhsqxD";// clientSecret
const loginToken              = "duneZvJEQi5slDeevoVUEZOmE6pvVcl9MWVFED4lWaA";
const rmsMerchantId           = 1;
const orgTypeCode           = "RET";
const appType               = "Android_Mobile";
const languageCode            = "en";
const deviceType              = "ANDROID";
const sportsPoolDomainName    = "ice.igamew.com" /*"www.retail.co.in"*/;
const String domainNameInfiniti = "ice.igamew.com";

const terminal              = "TERMINAL";
const responseType              = "QR_CODE";
const serviceCode              = "RMS_COUPON";
const gameCode                = "ALL_GAMES";



const homeModuleCodesList     = {lotteryModuleCode, scratchModuleCode, sportsModuleCode,scanNPlay,};
const drawerModuleCodesList   = {reportModuleCode, organizationModuleCode};

Map<String, String> labelledGameLabelList = {
  "aquarius"    : "assets/icons/aquarius.svg",
  "aries"       : "assets/icons/aries.svg",
  "cancer"      : "assets/icons/cancer.svg",
  "capricorn"   : "assets/icons/capricorn.svg",
  "gemini"      : "assets/icons/gemini.svg",
  "leo"         : "assets/icons/leo.svg",
  "libra"       : "assets/icons/libra.svg",
  "pisces"      : "assets/icons/pisces.svg",
  "sagittarius" : "assets/icons/sagittarius.svg",
  "scorpio"     : "assets/icons/scorpio.svg",
  "taurus"      : "assets/icons/taurus.svg",
  "virgo"       : "assets/icons/virgo.svg",
  "zero"        : "0",
  "one"         : "1",
  "two"         : "2",
  "three"       : "3",
  "four"        : "4",
  "five"        : "5",
  "six"         : "6",
  "seven"       : "7",
  "eight"       : "8",
  "nine"        : "9"
};

//drawer ICONS constant
const PAYMENT_REPORT           = "M_PAYMENT_REPORT";
const OLA_REPORT               = "M_OLA_REPORT";
const CHANGE_PASSWORD          = "M_CHANGE_PASS";
const DEVICE_REGISTRATION      = "M_DEVICE_REGISTRATION";
const LOGOUT                   = "M_LOGOUT";
const BILL_REPORT              = "M_BILL_REPORT";
const M_LEDGER                 = "M_LEDGER";
const USER_REGISTRATION        = "M_USER_REG";
const USER_SEARCH              = "M_USER_SEARCH";
const ACCOUNT_SETTLEMENT       = "M_INTRA_ORG_SETTLEMENT";
const SETTLEMENT_REPORT        = "M_SETTLEMENT_REPORT";
const SALE_WINNING_REPORT      = "M_SALE_REPORT";
const INTRA_ORG_CASH_MGMT      = "M_INTRA_ORG_CASH_MGMT";
const M_SUMMARIZE_LEDGER       = "M_SUMMARIZE_LEDGER";
const COLLECTION_REPORT        = "FIELDEX_COLLECTION";
const ALL_RETAILERS            = "ALL_RETAILERS";
const QR_CODE_REGISTRATION     = "M_QRCODE_REGISTRATION";
const NATIVE_DISPLAY_QR        = "NATIVE_DISPLAY_QR";
const BALANCE_REPORT           = "M_BALANCE_INVOICE_REPORT";
const OPERATIONAL_REPORT       = "M_OPERATIONAL_CASH_REPORT";

//enum
enum GameType {
  game,
  toss,
}

const int totalPriceOption        = 5;
const int numOfBingoCards         =  15;
const double customKeyboardTopPadding = 60;
const int scratchResponseCode = 1000;
