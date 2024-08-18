import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan/scan.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../login/models/response/GetLoginDataResponse.dart';
import '../../lottery/widgets/printing_dialog.dart';
import '../../utility/shared_pref.dart';
import '../../utility/user_info.dart';
import '../../utility/utils.dart';
import '../../utility/widgets/primary_button.dart';
import '../../utility/widgets/scanner_error.dart';
import '../../utility/widgets/show_snackbar.dart';
import '../../utility/widgets/wls_pos_text_field_underline.dart';
import '../../utility/wls_pos_color.dart';
import '../../utility/wls_pos_screens.dart';
import 'bloc/deposit_bloc.dart';
import 'bloc/deposit_event.dart';
import 'bloc/deposit_state.dart';
import 'dialog/qrcode_dialog.dart';
import 'package:http/http.dart' as http;

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  TextEditingController textController = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();

  bool _loader = false;
  bool isBuyNowPrintingStarted = false;
  bool isPrintingSuccess = true;
  String mMobileNumberString = "Enter Mobile Number(Optional)";
  String couponCodeVar = "";
  String qrCodeUrl = "";

  final MobileScannerController _scanController =
      MobileScannerController(autoStart: true);
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositLoading) {
            setState(() {
              _loader = true;
            });
          } else if (state is DepositError) {
            setState(() {
              _loader = false;
            });
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
            mobileNumber.clear();
          } else if (state is DepositSuccess) {
            setState(() {
              _loader = false;
            });

            if (state.response.data?.couponQRCodeUrl?.isNotEmptyAndNotNull ==
                true) {
              setState(() {
                qrCodeUrl = state.response.data?.couponQRCodeUrl ?? "";
                if (state.response.data?.couponCode != null) {
                  if (state.response.data?.couponCode?.isNotEmpty == true) {
                    couponCodeVar =
                        state.response.data?.couponCode?[0].couponCode ?? "";
                  }
                }
              });

              SharedPrefUtils.setQrUrl =
                  state.response.data?.couponQRCodeUrl ?? "";
              SharedPrefUtils.setQrPhoneNumber = mobileNumber.text.toString();
              SharedPrefUtils.setQrAmount = textController.text.toString();
              SharedPrefUtils.setQrCouponCode = couponCodeVar;

              if (couponCodeVar.isNotEmpty) {
                if (androidInfo?.model == "V2" ||
                    androidInfo?.model == "M1" ||
                    androidInfo?.model == "CTA Q7" ||
                    androidInfo?.model == "T2mini") {
                  Map<String, dynamic> printingDataArgs = {};
                  printingDataArgs["userName"] = UserInfo.userName;
                  printingDataArgs["userId"] = UserInfo.userId;
                  printingDataArgs["currencyCode"] =
                      getDefaultCurrency(getLanguage());
                  printingDataArgs["Amount"] = textController.text.toString();
                  printingDataArgs["url"] =
                      state.response.data?.couponQRCodeUrl.toString();
                  printingDataArgs["couponCode"] = couponCodeVar;

                  PrintingDialog().show(
                      context: context,
                      title: "Printing started",
                      isCloseButton: true,
                      buttonText: 'Retry',
                      printingDataArgs: printingDataArgs,
                      isRePrint: false,
                      isDepositPrintingStarted: true,
                      onPrintingDone: () {
                        Navigator.pop(context);
                      },
                      onPrintingFailed: () {
                        if (couponCodeVar.isNotEmptyAndNotNull) {
                          BlocProvider.of<DepositBloc>(context).add(
                              CouponReversalApi(
                                  context: context, couponCode: couponCodeVar));
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      isPrintingForSale: false);
                } else {
                  QrCodeDialog().show(
                    context: context,
                    title: "QR CODE",
                    buttonText: "buttonText",
                    url: state.response.data!.couponQRCodeUrl.toString(),
                    amount:
                        "${getDefaultCurrency(getLanguage())} ${textController.text.toString()}",
                    onPrintingDone: () {},
                  );
                }
                widget.onTap();
              }
              else {
                ShowToast.showToast(context, "Unable to print QR",
                    type: ToastType.ERROR);
              }
            }
            else {
              ShowToast.showToast(context, "Qr code unavailable",
                  type: ToastType.ERROR);
            }

            clearFields();
          } else if (state is ReprintQrCodeLoading) {
            setState(() {
              _loader = true;
            });
          } else if (state is ReprintQrCodeError) {
            setState(() {
              _loader = false;
            });
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
          } else if (state is ReprintQrCodeSuccess) {

            SharedPrefUtils.setQrUrl =
                state.response.data?.qrCodeUrl.toString() ?? "";

            if (androidInfo?.model == "V2" ||
                androidInfo?.model == "M1" ||
                androidInfo?.model == "T2mini") {
              Map<String, dynamic> printingDataArgs = {};
              printingDataArgs["userName"] = UserInfo.userName;
              printingDataArgs["userId"] = UserInfo.userId;
              printingDataArgs["currencyCode"] =
                  getDefaultCurrency(getLanguage());
              printingDataArgs["Amount"] = SharedPrefUtils.getQrAmount;
              printingDataArgs["url"] =
                  state.response.data?.qrCodeUrl.toString();
              printingDataArgs["couponCode"] = SharedPrefUtils.getQrCouponCode;

              PrintingDialog().show(
                  context: context,
                  title: "Printing started",
                  isCloseButton: true,
                  buttonText: 'Retry',
                  printingDataArgs: printingDataArgs,
                  isRePrint: false,
                  isDepositPrintingStarted: true,
                  onPrintingDone: () {
                  },
                  isPrintingForSale: false);
            } else {
              QrCodeDialog().show(
                context: context,
                title: "QR CODE",
                buttonText: "buttonText",
                url: state.response.data!.qrCodeUrl.toString(),
                amount:
                    "${getDefaultCurrency(getLanguage())} ${SharedPrefUtils.getQrAmount}",
                onPrintingDone: () {},
              );
            }

            setState(() {
              _loader = false;
            });
          } else if (state is CheckAvailabilityLoading) {
            setState(() {
              _loader = true;
            });
          } else if (state is CheckAvailabilitySuccess) {
            setState(() {
              _loader = false;
            });
            userAlreadyRegistered();
          } else if (state is CheckAvailabilityError) {
            setState(() {
              _loader = false;
            });
            showVerificationDialog(mobileNumber.text.toString());
          } else if (state is SendOtpLoading) {
            setState(() {
              _loader = true;
            });
          } else if (state is SendOtpSuccess) {
            setState(() {
              _loader = false;
            });
            clearFields();

            ShowToast.showToast(context, "Otp Sent", type: ToastType.SUCCESS);
          } else if (state is SendOtpError) {
            setState(() {
              _loader = false;
            });
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
          } else if (state is ScanQrCodeLoading) {
          } else if (state is ScanQrCodeSuccess) {
            setState(() {
              _loader = false;
            });
            String pattern = r'^(?:[+0][1-9])?[0-9]{10,12}$';
            RegExp regExp = RegExp(pattern);

            if (regExp.hasMatch(state.response.data.toString())) {
              mobileNumber.text = state.response.data.toString();
            } else {
              ShowToast.showToast(context, "Invalid QrCode");
            }
          } else if (state is ScanQrCodeError) {
            setState(() {
              _loader = false;
            });
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
          } else if (state is CouponReversalSuccess) {
            Navigator.pop(context);
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext ctx) {
                return WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: StatefulBuilder(
                    builder: (context, StateSetter setInnerState) {
                      return Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 18.0),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Stack(children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: WlsPosColor.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const HeightBox(10),
                                    Image.asset(
                                        "assets/images/infiniti_logo.png",
                                        width: 150,
                                        height: 100),
                                    const HeightBox(4),
                                    Text(
                                      "Unable to print QR",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: WlsPosColor.black,
                                      ),
                                    ),
                                    const HeightBox(30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const SizedBox(),
                                        const WidthBox(10),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            Navigator.of(ctx).pop();
                                            widget.onTap();
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: WlsPosColor.game_color_red,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                            ),
                                            height: 45,
                                            child: const Center(
                                                child: Text("Close",
                                                    style: TextStyle(
                                                        color:
                                                            WlsPosColor.white,
                                                        fontSize: 19))),
                                          ),
                                        )),
                                      ],
                                    ),
                                    const HeightBox(20),
                                  ],
                                ).pSymmetric(v: 10, h: 30),
                              ).p(4)
                            ]),
                          ));
                    },
                  ),
                );
              },
            );
          } else if (state is CouponReversalError) {
            Navigator.pop(context);
            {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext ctx) {
                  return WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: StatefulBuilder(
                      builder: (context, StateSetter setInnerState) {
                        return Dialog(
                            insetPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 18.0),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Stack(children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: WlsPosColor.white,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const HeightBox(10),
                                      Image.asset(
                                          "assets/images/infiniti_logo.png",
                                          width: 150,
                                          height: 100),
                                      const HeightBox(4),
                                      const Text(
                                        "Unable to print now. Coupon reversal initiated",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: WlsPosColor.black,
                                        ),
                                      ),
                                      const HeightBox(30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const SizedBox(),
                                          const WidthBox(10),
                                          Expanded(
                                              child: InkWell(
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color:
                                                    WlsPosColor.game_color_red,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(6)),
                                              ),
                                              height: 45,
                                              child: const Center(
                                                  child: Text("Close",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontSize: 14))),
                                            ),
                                          )),
                                        ],
                                      ),
                                      const HeightBox(20),
                                    ],
                                  ).pSymmetric(v: 10, h: 30),
                                ).p(4)
                              ]),
                            ));
                      },
                    ),
                  );
                },
              );
            }
          }
        },
        child: SingleChildScrollView(
            child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/icon_pin.png",
                              width: 30,
                              height: 30,
                            ),
                            Text(
                              UserInfo.userName,
                              style: const TextStyle(
                                  color: WlsPosColor.gray,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "ID : ${UserInfo.userId}",
                              style: const TextStyle(
                                  color: WlsPosColor.gray,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        //showScannerDialog(context);
                        var results = await Navigator.pushNamed(
                            context, WlsPosScreen.scanAndPlayScannerScreen);
                        if (results != null) {
                          String pattern = r'^(?:[+0][1-9])?[0-9]{8,12}$';
                          RegExp regExp = RegExp(pattern);

                          if (regExp.hasMatch(results.toString())) {
                            mobileNumber.text = results.toString();
                          } else {
                            ShowToast.showToast(context, "Deposit Not Allowed",
                                type: ToastType.ERROR);
                          }
                        }
                      },
                      child: Image.asset(
                        "assets/icons/scan_here_for_topup.png",
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: WlsPosTextFieldUnderline(
                  maxLength: 6,
                  inputType: TextInputType.number,
                  controller: textController,
                  onChanged: (text) {
                    if (int.parse(text) >
                        int.parse(SharedPrefUtils.depositMaxLimit)) {
                      setState(() {
                        mMobileNumberString = "Enter Mobile Number";
                      });
                    } else {
                      setState(() {
                        mMobileNumberString = "Enter Mobile Number(Optional)";
                      });
                    }
                  },
                  inputDecoration: const InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: WlsPosColor.gray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: WlsPosColor.gray),
                      ),
                      labelText: "Enter deposit amount",
                      labelStyle: TextStyle(color: WlsPosColor.gray)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: WlsPosTextFieldUnderline(
                  maxLength: 14,
                  disableSpace: true,
                  inputType: TextInputType.number,
                  controller: mobileNumber,
                  inputDecoration: InputDecoration(
                      counterText: "",
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: WlsPosColor.gray),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: WlsPosColor.gray),
                      ),
                      labelText: mMobileNumberString,
                      labelStyle: const TextStyle(color: WlsPosColor.gray)),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 40.0),
                child: _loader
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                            color: WlsPosColor.app_bg),
                      )
                    : PrimaryButton(
                        borderColor: WlsPosColor.app_bg,
                        btnBgColor1: WlsPosColor.app_bg,
                        btnBgColor2: WlsPosColor.app_bg,
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: 52,
                        textColor: WlsPosColor.white,
                        text: 'Print QR Code',
                        fontWeight: FontWeight.w700,
                        onPressed: () {
                          //check if amount is valid or not
                          if (textController.text.isNotEmpty &&
                              int.parse(textController.text.toString()) > 0) {
                            proceedToApiCall();
                          } else {
                            ShowToast.showToast(
                                context, "Please enter valid amount",
                                type: ToastType.ERROR);
                          }
                        }),
              ),
              _loader
                  ? Container()
                  : Container(
                      margin: const EdgeInsets.only(top: 10.0),
                      child: PrimaryButton(
                          borderColor: WlsPosColor.app_bg,
                          btnBgColor1: WlsPosColor.app_bg,
                          btnBgColor2: WlsPosColor.app_bg,
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: 52,
                          textColor: WlsPosColor.white,
                          text: 'Re-Print QR Code',
                          fontWeight: FontWeight.w700,
                          onPressed: () {
                            if (SharedPrefUtils.getQrUrl.isNotEmptyAndNotNull) {
                              _saveImage(
                                  context,
                                  SharedPrefUtils.getQrUrl,
                                  SharedPrefUtils.getQrPhoneNumber.text
                                          .toString()
                                          .isNotEmptyAndNotNull
                                      ? "YES"
                                      : "NO");
                            }
                          }),
                    ),
            ],
          ),
        )));
  }

  //first check checkAvailability
  void checkAvailability() {
      BlocProvider.of<DepositBloc>(context).add(CheckAvailabilityApiData(
          context: context, mobileNumber: mobileNumber.text.toString()));
  }

  Future<int?> getBatteryInfo() async {
    var batteryInfo = await BatteryInfoPlugin().androidBatteryInfo;
    return batteryInfo?.batteryLevel;
  }

  void proceedToApiCall() {
    getBatteryInfo().then((value) {
      if (value != null) {
        if (value > 10) {
          FocusScope.of(context).requestFocus(FocusNode());
          if (textController.text.isNotEmpty) {
            //  if (getFormattedUserBalance()) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext ctx) {
                return WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: StatefulBuilder(
                    builder: (context, StateSetter setInnerState) {
                      return Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 18.0),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Stack(children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: WlsPosColor.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const HeightBox(10),
                                    Image.asset(
                                        "assets/images/infiniti_logo.png",
                                        width: 150,
                                        height: 100),
                                    const HeightBox(4),
                                    Text(
                                      "Are you sure you want deposit this amount : ${getDefaultCurrency(getLanguage())} ${getThousandSeparatorFormatAmount(textController.text)}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: WlsPosColor.black,
                                      ),
                                    ),
                                    const HeightBox(30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: WlsPosColor.game_color_red,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                            ),
                                            height: 45,
                                            child: const Center(
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        color:
                                                            WlsPosColor.white,
                                                        fontSize: 14))),
                                          ),
                                        )),
                                        const WidthBox(10),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();

                                            //check if amount is lest then Max deposit amount
                                            if (int.parse(textController.text
                                                    .toString()) <=
                                                int.parse(SharedPrefUtils
                                                    .depositMaxLimit)) {
                                              if (mobileNumber
                                                  .text.isNotEmpty) {
                                                //if mobile number entered then check valid number
                                                checkAvailability();
                                              } else {
                                                //provide coupon APi
                                                userAlreadyRegistered();
                                              }
                                            } else {
                                              //mandatory to check if move is more than max deposit for validation or registration
                                              if (mobileNumber
                                                  .text.isNotEmpty) {
                                                //if mobile number entered then check valid number
                                                checkAvailability();
                                              } else {
                                                ShowToast.showToast(context,
                                                    "Please enter mobile number",
                                                    type: ToastType.ERROR);
                                              }
                                            }
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color:
                                                  WlsPosColor.game_color_green,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                            ),
                                            height: 45,
                                            child: const Center(
                                                child: Text("Continue",
                                                    style: TextStyle(
                                                        color:
                                                            WlsPosColor.white,
                                                        fontSize: 14))),
                                          ),
                                        )),
                                      ],
                                    ),
                                    const HeightBox(20),
                                  ],
                                ).pSymmetric(v: 10, h: 30),
                              ).p(4)
                            ]),
                          ));
                    },
                  ),
                );
              },
            );
            /*  } else {
              ShowToast.showToast(
                  context, "Insufficient Balance For Transaction",
                  type: ToastType.ERROR);
            }*/
          } else {
            ShowToast.showToast(context, "Please enter valid amount",
                type: ToastType.ERROR);
          }
        } else {
          ShowToast.showToast(context, "Please charge the device",
              type: ToastType.ERROR);
        }
      }
    });
  }

  bool getFormattedUserBalance() {
    GetLoginDataResponse loginResponse =
        GetLoginDataResponse.fromJson(jsonDecode(UserInfo.getUserInfo));
    String balance =
        loginResponse.responseData?.data?.balance?.toString() ?? "";
    String creditLimit =
        loginResponse.responseData?.data?.creditLimit?.toString() ?? "";
    String splitBalance = balance.split(",")[0];
    String splitCreditLimit = creditLimit.split(",")[0];
    String formattedBalance = splitBalance.replaceAll(" ", '');
    String formattedCreditLimit = splitCreditLimit.replaceAll(" ", '');
    if ((int.parse(formattedBalance) + int.parse(formattedCreditLimit)) >=
        int.parse(textController.text)) {
      return true;
    }
    return false;
  }

  //if userAlready Registered
  void userAlreadyRegistered() {
      BlocProvider.of<DepositBloc>(context).add(DepositApiData(
          context: context,
          url: "",
          retailerName: UserInfo.userName,
          amount: textController.text.toString(),
          userName: mobileNumber.text.toString()));
  }

  //if user Not Registered
  void sendOtp() {
      BlocProvider.of<DepositBloc>(context).add(SendOtpApiData(
          context: context, mobileNumber: mobileNumber.text.toString()));
  }

  //confirmation dialog if user is not registered
  void showVerificationDialog(String mobile) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 80,
                        height: 80,
                        child: Lottie.asset('assets/lottie/no_data.json')),
                    const Text(
                      'User Not Found!!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        'Otp will be shared with provided mobile number - $mobile',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    WlsPosColor.navy_blue)),
                            onPressed: () {
                              sendOtp();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Continue",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(WlsPosColor.red)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Cancel",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void clearFields() {
    FocusScope.of(context).unfocus();
    textController.clear();
    mobileNumber.clear();
    setState(() {
      mMobileNumberString = "Enter Mobile Number(Optional)";
    });
  }

  //scanner dialog

  void showScannerDialog(BuildContext buildContext) {
    timer = Timer.periodic(const Duration(seconds: 10),
        (Timer t) => _scanController.resetZoomScale());
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, StateSetter setInnerState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                //this right here
                child: SizedBox(
                  height: 500,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Scan QR Code",
                          style: TextStyle(
                              color: WlsPosColor.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 350,
                          child: MobileScanner(
                            errorBuilder: (context, error, child) {
                              return ScannerError(
                                context: context,
                                error: error,
                              );
                            },
                            controller: _scanController,
                            onDetect: (capture) {
                              _scanController.stop();
                              try {
                                setState(() {
                                  List<Barcode> barcodes = capture.barcodes;
                                  String? data = barcodes[0].rawValue;
                                  if (data != null) {
                                    Uri uri = Uri.parse(data);
                                    print("URI: $uri");
                                    String? dataValue =
                                        uri.queryParameters['data'];
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      BlocProvider.of<DepositBloc>(buildContext)
                                          .add(ScanQrCodeData(
                                              context: buildContext,
                                              data: dataValue.toString()));
                                      Navigator.of(context).pop();
                                      _loader = true;
                                    });
                                  }
                                });
                              } catch (e) {
                                _scanController.start();

                                print("Something Went wrong with bar code: $e");
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        WlsPosColor.red)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _saveImage(
      BuildContext context, String url, String isUpdate) async {
    setState(() {
      _loader=true;
    });
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(url));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename = '${dir.path}/image.png';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      String? result = await Scan.parse(file.path);
       await File(file.path).delete(); // path is the path to the file. If it is a string, convert to path using File()

      if (result.isNotEmptyAndNotNull) {
        Uri uri = Uri.parse(result.toString());
        print("URI: $uri");
        String? dataValue = uri.queryParameters['data'];
        print("dataValue: $dataValue");

          BlocProvider.of<DepositBloc>(context).add(RePrintQrCodeData(
              context: context,
              data: dataValue.toString(),
              isUpdate: isUpdate));

      }
    } catch (e) {
      setState(() {
        _loader=false;
      });
      print("exception------"+e.toString());
    }
  }
}

