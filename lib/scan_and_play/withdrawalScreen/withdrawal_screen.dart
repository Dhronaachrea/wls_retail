import 'dart:ffi';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan/scan.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../lottery/widgets/printing_dialog.dart';
import '../../utility/app_constant.dart';
import '../../utility/date_format.dart';
import '../../utility/shared_pref.dart';
import '../../utility/user_info.dart';
import '../../utility/utils.dart';
import '../../utility/widgets/scanner_error.dart';
import '../../utility/widgets/show_snackbar.dart';
import '../../utility/widgets/wls_pos_text_field_underline.dart';
import '../../utility/wls_pos_color.dart';
import 'bloc/withdrawal_bloc.dart';
import 'bloc/withdrawal_event.dart';
import 'bloc/withdrawal_state.dart';
import 'model/Pending_withdrawal_response.dart';
import 'model/update_qr_withdrawal_request.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  //final ScanController _scanController = ScanController();

  final MobileScannerController _scanController =
      MobileScannerController(autoStart: true);
  final otpController = TextEditingController();

  // final MobileScannerController _scanController = MobileScannerController(
  //     autoStart: true,
  //     detectionSpeed: DetectionSpeed.normal,
  //     facing: CameraFacing.back);
  // QRViewController? controller;

  bool flashOn = false;

  bool _pendingWithdrawalLoader = false;
  String mRequestId = "";
  String mAmount = "";
  String mTxnId = "";
  String mCurrentData = "";
  int mOtpCount = 0;
  bool isVerifyOtpErrorOrSuccess = false;

  @override
  void initState() {
    super.initState();
    // String codeParam = "6014a374-eccd-4ce8-a4af-9e30c41da003";
    //
    // if (codeParam.length > 10) {
    //   BlocProvider.of<WithdrawalBloc>(context).add(PendingWithdrawalApiData(
    //     context: context,
    //     id: codeParam,
    //   ));
    // }
    var now = DateTime.now();
    var formatter = DateFormat('dd MMM yyyy, hh:mm aaa');
    mCurrentData = formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    //    FocusScope.of(context).requestFocus(FocusNode());
    return BlocListener<WithdrawalBloc, WithdrawalState>(
        listener: (context, state) {
          if (state is PendingWithdrawalLoading) {
            setState(() {
              _pendingWithdrawalLoader = true;
              otpController.clear();
              mOtpCount = 0;
            });
          } else if (state is PendingWithdrawalError) {
            _scanController.start();

            setState(() {
              _pendingWithdrawalLoader = false;
            });
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
          } else if (state is PendingWithdrawalSuccess) {
            setState(() {
              _pendingWithdrawalLoader = false;
            });
            _scanController.stop();
            if (state.response.data!.isNotEmpty &&
                state.response.data!.length > 1) {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: StatefulBuilder(
                      builder: (context_, StateSetter setInnerState) {
                        return Dialog(
                            insetPadding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 15.0),
                            backgroundColor: WlsPosColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    "Pending Withdrawal List",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: WlsPosColor.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(
                                        top: 5, left: 10, right: 10),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "Please select which transaction you want to withdraw",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: WlsPosColor.black,
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: LimitedBox(
                                    maxHeight: 400,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: state.response.data!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            mRequestId = state
                                                .response.data![index].requestId
                                                .toString();
                                            mAmount = state
                                                .response.data![index].netAmount
                                                .toString();

                                            showAcceptDialog();
                                          },
                                          child: Card(
                                            color: WlsPosColor.light_dark_white,
                                            margin: const EdgeInsets.only(
                                                right: 10,
                                                left: 10,
                                                bottom: 10),
                                            elevation: 10,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        textAlign:
                                                            TextAlign.start,
                                                        "Request ID: ${state.response.data![index].requestId!}",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5.0),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            text:
                                                                'Withdraw Amount: ',
                                                            style: const TextStyle(
                                                                color:
                                                                    WlsPosColor
                                                                        .black),
                                                            /*defining default style is optional */
                                                            children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      "${getDefaultCurrency(getLanguage())}${state.response.data![index].netAmount!}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: WlsPosColor
                                                                          .dark_green)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                                "assets/images/timer.png",
                                                                width: 15,
                                                                height: 15),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                                formatDate(
                                                                  date: state
                                                                      .response
                                                                      .data![
                                                                          index]
                                                                      .createdAt!,
                                                                  inputFormat:
                                                                      "yyyy-MM-dd HH:mm:ss.S",
                                                                  outputFormat:
                                                                      Format
                                                                          .apiDateFormat2,
                                                                ),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: WlsPosColor
                                                                        .black))
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          "assets/images/withdraw.png",
                                                          width: 30,
                                                          height: 30),
                                                      const Text("Withdraw",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: WlsPosColor
                                                                  .black))
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _scanController.start();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: WlsPosColor.red,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                    ),
                                    height: 45,
                                    child: const Center(
                                        child: Text("Close",
                                            style: TextStyle(
                                                color: WlsPosColor.white,
                                                fontSize: 14))),
                                  ),
                                )
                              ],
                            ));
                      },
                    ),
                  );
                },
              );
            } else if (state.response.data!.isNotEmpty) {
              mRequestId = state.response.data![0].requestId.toString();
              mAmount = state.response.data![0].netAmount.toString();

              showAcceptDialog();
            }
          } else if (state is UpdateWithdrawalLoading) {

            setState(() {
              _pendingWithdrawalLoader = true;
              isVerifyOtpErrorOrSuccess = true;
            });
          } else if (state is UpdateWithdrawalError) {
            mOtpCount++;

            setState(() {
              _pendingWithdrawalLoader = false;
              isVerifyOtpErrorOrSuccess = false;
            });
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
          } else if (state is UpdateWithdrawalSuccess) {
            mOtpCount = 0;
            print("----------------------------------this is Success");
            Navigator.pop(context);


            setState(() {
              _pendingWithdrawalLoader = false;
              isVerifyOtpErrorOrSuccess = false;
            });

            mTxnId = state.response.data!.userTxnId.toString();
            mAmount = state.response.data!.amount.toString();
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0)), //this right here
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      margin: const EdgeInsets.only(top: 40),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              "Pay Now",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: WlsPosColor.black,
                                  fontWeight: FontWeight.w500),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const Text(
                                "Please Pay to Customer",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: WlsPosColor.black,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Text(
                                "${getDefaultCurrency(getLanguage())}: $mAmount ",
                                style: const TextStyle(
                                    fontSize: 22,
                                    color: WlsPosColor.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text(
                                "ID: $mTxnId",
                                style: const TextStyle(
                                    fontSize: 22,
                                    color: WlsPosColor.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text(
                                mCurrentData,
                                style: const TextStyle(
                                    fontSize: 22,
                                    color: WlsPosColor.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Map<String, dynamic> printingDataArgs = {};

                                printingDataArgs["username"] =
                                    UserInfo.userName ?? "";
                                printingDataArgs["withdrawalAmt"] = mAmount;

                                PrintingDialog().show(
                                    context: context,
                                    title: "Printing started",
                                    isRetryButtonAllowed: true,
                                    buttonText: "Retry",
                                    printingDataArgs: printingDataArgs,
                                    isAfterWithdrawal: true,
                                    onPrintingDone: () {
                                      Navigator.of(context).pop();
                                      _scanController.start();
                                    },
                                    isPrintingForSale: false);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: WlsPosColor.shamrock_green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                margin: const EdgeInsets.only(
                                    top: 20, left: 20, right: 20),
                                width: double.infinity,
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text(
                                      "Close & Print",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
            widget.onTap();
          } else if (state is ScanQrCodeLoading) {
          } else if (state is ScanQrCodeSuccess) {
            if (state.response.data.toString() != "") {
              BlocProvider.of<WithdrawalBloc>(context)
                  .add(PendingWithdrawalApiData(
                context: context,
                id: state.response.data.toString(),
              ));
            }
          } else if (state is ScanQrCodeError) {
            ShowToast.showToast(context, state.errorMessage.toString(),
                type: ToastType.ERROR);
            setState(() {
              _pendingWithdrawalLoader = false;
              _scanController.start();
            });
          }
        },
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text(
                "Scan QR Code",
                style: TextStyle(
                    color: WlsPosColor.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width > 700
                  ? MediaQuery.of(context).size.width / 4
                  : MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  MobileScanner(
                    errorBuilder: (context, error, child) {
                      return ScannerError(
                        context: context,
                        error: error,
                      );
                    },
                    controller: _scanController,
                    onDetect: (capture) {
                      setState(() {
                        _pendingWithdrawalLoader = true;
                      });
                      _scanController.stop();
                      try {
                        setState(() {
                          List<Barcode> barcodes = capture.barcodes;
                          String? data = barcodes[0].rawValue;
                          if (data != null) {
                            Uri uri = Uri.parse(data);
                            print("URI: $uri");
                            String? dataValue = uri.queryParameters['data'];
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              BlocProvider.of<WithdrawalBloc>(context).add(
                                  ScanQrCodeData(
                                      context: context,
                                      data: dataValue.toString()));
                            });
                            /* BlocProvider.of<WithdrawalBloc>(context)
                                .add(PendingWithdrawalApiData(
                              context: context,
                              id: codeParam.toString(),
                            ));*/
                          }
                        });
                      } catch (e) {
                        _scanController.start();
                        setState(() {
                          _pendingWithdrawalLoader = false;
                        });
                        print("Something Went wrong with bar code: $e");
                      }
                    },
                  ),
                  // ScanView(
                  //   controller: _scanController,
                  //   scanAreaScale:
                  //       MediaQuery.of(context).size.width > 700 ? 1 : .7,
                  //   scanLineColor: WlsPosColor.tomato,
                  //   onCapture: (data) {
                  //     setState(() {
                  //       Uri uri = Uri.dataFromString(data);
                  //       String? codeParam = uri.queryParameters['couponCode'];
                  //
                  //       if (codeParam != null && codeParam.length > 10) {
                  //         BlocProvider.of<WithdrawalBloc>(context)
                  //             .add(PendingWithdrawalApiData(
                  //           context: context,
                  //           id: codeParam,
                  //         ));
                  //       }
                  //     });
                  //   },
                  // ),
                  Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          // on and off splash
                          setState(() {
                            flashOn = !flashOn;

                            _scanController.toggleTorch();
                          });
                        },
                        child: Icon(
                          (flashOn ? Icons.flash_on : Icons.flash_off),
                          color: WlsPosColor.reddish_pink,
                          size: 30,
                        ).p(10),
                      )),
                  _pendingWithdrawalLoader
                      ? const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator())
                      : Container()
                ],
              ),
            ),
          ],
        ));
  }

  String getLatestAmount(PendingWithdrawalResponse pendingResponse) {
    List<Data> upcomingList = pendingResponse.data ?? [];
    if (upcomingList.isNotEmpty) {
      upcomingList.sort((a, b) {
        int comparingValue = int.parse(a.requestId.toString()) ?? 0;
        int compareValueTo = int.parse(b.requestId.toString()) ?? 0;
        return comparingValue.compareTo(compareValueTo);
      });

      return upcomingList.last.netAmount.toString();
    }
    return "";
  }

  void showOtpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context_, StateSetter setInnerState) {
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
                            Image.asset("assets/images/infiniti_logo.png",
                                width: 150, height: 100),
                            const HeightBox(4),
                            const Text(
                              "Verify OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: WlsPosColor.black,
                              ),
                            ),
                            const HeightBox(20),
                            WlsPosTextFieldUnderline(
                                controller: otpController,
                                hintText: "Please Enter Otp",
                                maxLength: 6,
                                borderColor: Colors.black,
                                textStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                inputType: TextInputType.number,
                                onEditingComplete: () {},
                                inputDecoration: const InputDecoration(
                                  counterText: "",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: WlsPosColor.gray),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: WlsPosColor.gray),
                                  ),
                                  // isDarkThemeOn: isDarkThemeOn,
                                )),
                            const HeightBox(30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                 Expanded(
                                        child: InkWell(
                                        onTap: () {
                                          if (mOtpCount > 2) {
                                            Navigator.of(context_).pop();
                                            mOtpCount = 0;
                                            showMaxLimit();
                                          } else {
                                            if (!otpController
                                                    .text.isEmptyOrNull &&
                                                otpController.text.length >=
                                                    4) {

                                              var data =
                                                  UpdateQrWithdrawalRequest(
                                                requestId: mRequestId,
                                                amount: mAmount,
                                                device: terminal,
                                                appType: appType,
                                                retailerId: UserInfo.userId,
                                                verificationCode: otpController
                                                    .text
                                                    .toString(),
                                              );
                                              BlocProvider.of<WithdrawalBloc>(
                                                      context)
                                                  .add(UpdateWithdrawalApiData(
                                                context: context,
                                                updateQrWithdrawalRequest: data,
                                              ));
                                            } else {
                                              ShowToast.showToast(context,
                                                  "Please enter valid otp");
                                            }
                                          }
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: WlsPosColor.game_color_green,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                          ),
                                          height: 45,
                                          child: const Center(
                                              child: Text("Submit",
                                                  style: TextStyle(
                                                      color: WlsPosColor.white,
                                                      fontSize: 14))),
                                        ),
                                      )),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    setState(() {
                                      _pendingWithdrawalLoader = false;
                                    });
                                    _scanController.start();
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: WlsPosColor.game_color_red,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                    ),
                                    height: 45,
                                    child: const Center(
                                        child: Text("Cancel",
                                            style: TextStyle(
                                                color: WlsPosColor.white,
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

  void showAcceptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context_, StateSetter setInnerState) {
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
                                  Image.asset("assets/images/infiniti_logo.png",
                                      width: 150, height: 100),
                                  const HeightBox(4),
                                  const Text(
                                    "Are you sure you want to withdrawal this amount?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: WlsPosColor.black,
                                    ),
                                  ),
                                  const HeightBox(20),
                                  Text(
                                    "Amount : ${getDefaultCurrency(getLanguage())} ${mAmount}",
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
                                          setState(() {
                                            _pendingWithdrawalLoader = true;
                                          });

                                          Navigator.of(ctx).pop();

                                          showOtpDialog();
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: WlsPosColor.game_color_green,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                          ),
                                          height: 45,
                                          child: const Center(
                                              child: Text("Accept",
                                                  style: TextStyle(
                                                      color: WlsPosColor.white,
                                                      fontSize: 14))),
                                        ),
                                      )),
                                      const WidthBox(10),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                          setState(() {
                                            _scanController.start();
                                          });
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
                                                      color: WlsPosColor.white,
                                                      fontSize: 14))),
                                        ),
                                      )),
                                    ],
                                  ),
                                  const HeightBox(20),
                                ],
                              ).pSymmetric(v: 10, h: 30))
                          .p(4)
                    ]),
                  ));
            },
          ),
        );
      },
    );
  }

  void showMaxLimit() {
    Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Alert!",
                      style: TextStyle(
                          fontSize: 28,
                          color: WlsPosColor.red,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: const Text(
                        "Maximum Attempts reached, Please try again later",
                        style: TextStyle(
                            fontSize: 22,
                            color: WlsPosColor.black,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();

                        _scanController.start();

                        setState(() {
                          _pendingWithdrawalLoader = false;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: WlsPosColor.shamrock_green,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        margin:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        width: double.infinity,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              "Close",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
