import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/betAmountBean.dart';
import 'package:wls_pos/lottery/widgets/shimmer_text.dart';
import 'package:wls_pos/lottery/widgets/dialog_shimmer_container.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

const Channel = MethodChannel('com.skilrock.wls_pos/test');
const ChannelWithdrawal = MethodChannel('com.skilrock.longalottoretail/channel_afterWithdrawal');

class PrintingDialog {
  Color mColor = WlsPosColor.game_color_orange;
  bool isPrintingFailed = false;
  bool isPrintingSuccess = false;
  bool isBuyNowPrintingStarted = true;
  String mTitle = "Printing";
  String mSubTitle = "";
  bool mShow = false;


  show({
    required BuildContext context,
    required String title,
    required String buttonText,
    bool? isBackPressedAllowed,
    required Map<String, dynamic> printingDataArgs,
    bool? isCloseButton = false,
    required bool isPrintingForSale,
    required VoidCallback onPrintingDone,
    VoidCallback? OnErrorCloseDialog,
    VoidCallback? onPrintingFailed,
    bool? isRetryButtonAllowed = false,
    bool isAfterWithdrawal = false,
    bool isCancelTicket = false,
    bool isRePrint = false,
    bool isLastResult = false,
    bool isWinClaim = false,
    bool isDepositPrintingStarted = false,
    bool isSportsPoolSale = false,
    bool isBalanceInvoiceReport = false,
    bool isOperationalReport = false
  }) {
    mTitle = title;

    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, StateSetter setInnerState) {
              Future<void> buyNow(BuildContext context,
                  Map<String, dynamic> printingDataArgs) async {
                setInnerState(() {
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse =
                      await Channel.invokeMethod(isSportsPoolSale ? 'sports_buy':'buy', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                      mShow               = true;
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      Navigator.of(context).pop();
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor              = WlsPosColor.game_color_red;
                    isPrintingFailed    = true;
                    mTitle            = "Printing Failed";
                    mSubTitle           = "${e.message}";
                  });
                  if (onPrintingFailed != null) {
                    onPrintingFailed();

                  }
                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              Future<void> cancelTicket(BuildContext context, Map<String, dynamic> printingDataArgs) async{
                setInnerState((){
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse = await Channel.invokeMethod('dgeCancelTicket', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      Navigator.of(context).pop(true);
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor              = WlsPosColor.game_color_red;
                    isPrintingFailed    = true;
                    mTitle            = "Printing Failed";
                    mSubTitle           = "${e.message}";
                  });

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              Future<void> rePrint(BuildContext context, Map<String, dynamic> printingDataArgs) async{
                setInnerState((){
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse = await Channel.invokeMethod(isSportsPoolSale ? 'sports_buy':'dgeReprint', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      Navigator.of(context).pop(true);
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor              = WlsPosColor.game_color_red;
                    isPrintingFailed    = true;
                    mTitle            = "Printing Failed";
                    mSubTitle           = "${e.message}";
                  });

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              Future<void> lastResult(BuildContext context, Map<String, dynamic> printingDataArgs) async{
                setInnerState((){
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse = await Channel.invokeMethod('dgeLastResult', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      Navigator.of(context).pop(true);
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor              = WlsPosColor.game_color_red;
                    isPrintingFailed    = true;
                    mTitle            = "Printing Failed";
                    mSubTitle           = "${e.message}";
                  });

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              Future<void> winningClaim(BuildContext context, Map<String, dynamic> printingDataArgs) async{
                setInnerState((){
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse = await Channel.invokeMethod('winClaim', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      Navigator.of(context).pop(true);
                      print("-------------dialog on printing done.");
                    });
                  }

                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor              = WlsPosColor.game_color_red;
                    isPrintingFailed    = true;
                    mTitle            = "Printing Failed";
                    mSubTitle           = "${e.message}";
                  });
                  if (onPrintingFailed != null) {
                    onPrintingFailed();
                  }


                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              Future<void> depositPrintResult(BuildContext context,
                  Map<String, dynamic> printingDataArgs) async {
                setInnerState(() {
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse = await const MethodChannel(
                          'com.skilrock.longalottoretail/notification_print')
                      .invokeMethod('notificationPrint', printingDataArgs);
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      if (onPrintingFailed == null) {
                        Navigator.of(context).pop(true);
                      }
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  if (onPrintingFailed != null) {
                    onPrintingFailed();

                  }
                  else {
                    setInnerState(() {
                      mColor = WlsPosColor.game_color_red;
                      isPrintingFailed = true;
                      mTitle = "Printing Failed";
                      mSubTitle = "${e.message}";
                    });
                  }
                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }
              Future<void> afterWithdrawal(BuildContext context,
                  Map<String, dynamic> printingDataArgs) async {
                setInnerState(() {
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>WITHDRAWAL>>>");
                  final dynamic receivedResponse = await ChannelWithdrawal.invokeMethod('afterWithdrawal', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingDone();
                      Navigator.of(context).pop();
                      print("-------------dialog on printing done.");
                    });
                  }

                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor              = WlsPosColor.game_color_red;
                    isPrintingFailed    = true;
                    mTitle            =  "Printing Failed";
                    mSubTitle           =  e.message.toString();
                  });

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              Future<void> balanceInvoiceReport(BuildContext context,
                  Map<String, dynamic> printingDataArgs) async {
                setInnerState(() {
                  isBuyNowPrintingStarted = false;
                });
                try {
                  log(" >>>>>> balanceInvoiceReport");
                  final dynamic receivedResponse = await Channel.invokeMethod('balanceInvoiceReport', printingDataArgs);
                  if (receivedResponse) {
                    log(" >>>>>> balanceInvoiceReport  receivedResponse $receivedResponse");
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 1), () async {
                      onPrintingDone();
                      if (onPrintingFailed == null) {
                        Future.delayed(const Duration(seconds: 3), () async {
                          Navigator.of(context).pop(true);
                        });

                      }
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  ShowToast.showToast(context, "e: ${e.message}");

                  if (onPrintingFailed != null) {
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingFailed();
                      Navigator.of(context).pop(true);
                    });

                  } else {
                    setInnerState(() {
                      mColor              = WlsPosColor.game_color_red;
                      isPrintingFailed    = true;
                      mTitle            = "Printing Failed";
                      mSubTitle           = "${e.message}";
                    });
                  }

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }


              Future<void> operationalCashReport(BuildContext context,
                  Map<String, dynamic> printingDataArgs) async {
                setInnerState(() {
                  isBuyNowPrintingStarted = false;
                });
                try {
                  print(" >>>>>> operationalCashReport ");
                  final dynamic receivedResponse = await Channel.invokeMethod('operationalCashReport', printingDataArgs);
                  if (receivedResponse) {
                    log(" >>>>>> operationalCashReport  receivedResponse $receivedResponse");
                    setInnerState(() {
                      isPrintingSuccess   = true;
                      isPrintingFailed    = false;
                      mTitle              = "Printing Success";
                      mColor              = WlsPosColor.shamrock_green;
                      mSubTitle           = "";
                    });
                    Future.delayed(const Duration(seconds: 1), () async {
                      onPrintingDone();
                      if (onPrintingFailed == null) {
                        Future.delayed(const Duration(seconds: 3), () async {
                          Navigator.of(context).pop(true);
                        });

                      }
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  ShowToast.showToast(context, "e: ${e.message}");

                  if (onPrintingFailed != null) {
                    Future.delayed(const Duration(seconds: 3), () async {
                      onPrintingFailed();
                      Navigator.of(context).pop(true);
                    });

                  } else {
                    setInnerState(() {
                      mColor              = WlsPosColor.game_color_red;
                      isPrintingFailed    = true;
                      mTitle            = "Printing Failed";
                      mSubTitle           = "${e.message}";
                    });
                  }

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              if (isBuyNowPrintingStarted && isDepositPrintingStarted && !isAfterWithdrawal) {
                depositPrintResult(context, printingDataArgs);
              } else if (isBuyNowPrintingStarted &&
                  !isCancelTicket &&
                  !isRePrint &&
                  !isLastResult &&
                  !isAfterWithdrawal &&
                  !isWinClaim &&
                  !isBalanceInvoiceReport &&
                  !isOperationalReport
              ) {
                buyNow(context, printingDataArgs);
              } else if (isBuyNowPrintingStarted &&
                  isCancelTicket &&
                  !isRePrint &&
                  !isLastResult &&
                  !isAfterWithdrawal &&
                  !isWinClaim &&
                  !isBalanceInvoiceReport &&
                  !isOperationalReport
              ) {
                cancelTicket(context, printingDataArgs);
              } else if (isBuyNowPrintingStarted &&
                  isRePrint &&
                  !isCancelTicket &&
                  !isLastResult &&
                  !isAfterWithdrawal &&
                  !isWinClaim &&
                  !isBalanceInvoiceReport &&
                  !isOperationalReport
              ) {
                rePrint(context, printingDataArgs);
              } else if (isBuyNowPrintingStarted &&
                  isLastResult &&
                  !isRePrint &&
                  !isCancelTicket &&
                  !isAfterWithdrawal &&
                  !isWinClaim &&
                  !isBalanceInvoiceReport &&
                  !isOperationalReport
              ) {
                lastResult(context, printingDataArgs);
              } else if (isBuyNowPrintingStarted && isWinClaim &&
                  !isAfterWithdrawal &&
                  !isBalanceInvoiceReport &&
              !isOperationalReport) {
                print("Printing for winningClaim");
                winningClaim(context, printingDataArgs);
              }
              else if (isBuyNowPrintingStarted && isAfterWithdrawal ) {
                print("6666666666666666666666666666666666666666");
                afterWithdrawal(context, printingDataArgs);
              }  else if (isBuyNowPrintingStarted && isBalanceInvoiceReport) {
                //BalanceInvoiceReport
                balanceInvoiceReport(context, printingDataArgs);
              }else if (isBuyNowPrintingStarted && isOperationalReport) {
                //Operation Cash Report
                operationalCashReport(context, printingDataArgs);
              }

              return WillPopScope(
                onWillPop: () async {
                  return isBackPressedAllowed ?? true;
                },
                child: Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      height: 250,
                      width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                      child: Stack(
                          children: [
                            DialogShimmerContainer(
                              color: mColor,
                              childWidget: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16)
                                ),
                              ).p(4),
                            ),
                            Container(
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: WlsPosColor.white,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const HeightBox(10),
                                  isPrintingForSale && mShow ? alertBuyDoneTitle(isLandscape) : Container(),
                                  const HeightBox(10),
                                  alertTitle(title),
                                  const HeightBox(10),
                                  alertSubTitle(mSubTitle, isLandscape),
                                  const HeightBox(10),
                                  isPrintingFailed
                                      ? SizedBox(width: 50, height: 50, child: Lottie.asset('assets/lottie/printing_failed.json'))
                                      : isPrintingSuccess
                                      ? SizedBox(width: 70, height: 70, child: Lottie.asset('assets/lottie/printing_success.json'))
                                      : SizedBox(width: 70, height: 70, child: Lottie.asset('assets/lottie/printer.json')),
                                  const HeightBox(10),
                                  isPrintingFailed ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      isCloseButton == true
                                          ? Expanded(
                                          child: InkWell(
                                              onTap: () {
                                                setInnerState(() {
                                                  mColor              = WlsPosColor.game_color_orange;
                                                  isPrintingFailed    = false;
                                                  isPrintingSuccess   = false;
                                                  mTitle              = "Printing";
                                                  isBuyNowPrintingStarted = true;
                                                  mSubTitle           = "";
                                                });
                                                if (!isCancelTicket && !isRePrint) {
                                                  buyNow(context, printingDataArgs);
                                                } else if (isCancelTicket && !isRePrint){
                                                  cancelTicket(context, printingDataArgs);
                                                } else if (isRePrint && !isCancelTicket) {
                                                  rePrint(context, printingDataArgs);
                                                }

                                              },
                                              customBorder: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: WlsPosColor.white,
                                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                    border: Border.all(color: WlsPosColor.game_color_orange)
                                                ),
                                                height: isLandscape ? 45 : 35,
                                                child: Center(
                                                    child: Text(buttonText, style: TextStyle(color: WlsPosColor.game_color_orange, fontSize: isLandscape ? 19 : 14))
                                                ),
                                              )
                                          ))
                                          : const SizedBox(),
                                      const WidthBox(10),
                                      Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                              if(OnErrorCloseDialog!=null) {
                                                OnErrorCloseDialog();
                                              } else {
                                                onPrintingDone();
                                              }
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: WlsPosColor.game_color_red,
                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                              ),
                                              height: isLandscape ? 45 : 35,
                                              child: Center(child: Text("CLOSE", style: TextStyle(color: WlsPosColor.white, fontSize: isLandscape ? 19 : 14))),
                                            ),
                                          )
                                      ),
                                    ],
                                  ) : Container(),
                                ],
                              ).pSymmetric(v: 10, h: 30),
                            ).p(4)
                          ]
                      ),
                    )
                ),
              );
            },
          ),
        );
      },
    );
  }

  alertTitle(String title) {
    return TextShimmer(
      color: mColor,
      text: mTitle,
    );
  }

  alertSubTitle(String subTitle, bool isLandscape, {Color subtitleColor = WlsPosColor.red}) {
    return Center(
      child: Text(
        subTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: isLandscape ? 13 : 10,
            color: WlsPosColor.red
        ),
      ),
    );
  }

  alertBuyDoneTitle(bool isLandscape) {
    return Center(
      child: Text(
        "You purchased successfully.",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: isLandscape ? 15 : 13,
            letterSpacing: 2,
            color: WlsPosColor.game_color_blue
        ),
      ),
    );
  }
}
