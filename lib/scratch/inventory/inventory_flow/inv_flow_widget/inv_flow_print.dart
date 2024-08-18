import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/widgets/shimmer_text.dart';
import 'package:wls_pos/lottery/widgets/dialog_shimmer_container.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

const Channel = MethodChannel('com.skilrock.wls_pos/test');

class InvFlowPrint {
  Color mColor = WlsPosColor.game_color_orange;
  bool isPrintingFailed = false;
  bool isPrintingSuccess = false;
  bool isPrintingStarted = true;
  String mTitle = "Printing";
  String mSubTitle = "";

  show({
    required BuildContext context,
    required String title,
    bool? isBackPressedAllowed,
    required Map<String, dynamic> printingDataArgs,
    bool? isCloseButton = false,
    required bool isPrintingForSale,
  }) {
    mTitle = title;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: StatefulBuilder(
            builder: (context, StateSetter setInnerState) {
              Future<void> invFlowPrint(BuildContext context,
                  Map<String, dynamic> printingDataArgs) async {
                setInnerState(() {
                  isPrintingStarted = false;
                });
                try {
                  print(" >>>>>>");
                  final dynamic receivedResponse = await Channel.invokeMethod(
                      'invFlowPrint', printingDataArgs);
                  print("receivedResponse --> $receivedResponse");
                  if (receivedResponse) {
                    setInnerState(() {
                      isPrintingSuccess = true;
                      isPrintingFailed = false;
                      mTitle = "Printing Success";
                      mColor = WlsPosColor.shamrock_green;
                      mSubTitle = "";
                    });
                    Future.delayed(const Duration(seconds: 3), () async {
                      Navigator.of(context).pop();
                      print("-------------dialog on printing done.");
                    });
                  }
                } on PlatformException catch (e) {
                  setInnerState(() {
                    mColor = WlsPosColor.game_color_red;
                    isPrintingFailed = true;
                    mTitle = "Printing Failed";
                    mSubTitle = "${e.message}";
                  });

                  print("----mColor----> $mColor");
                  print("----1111111---- ${e.message}");
                }
              }

              if (isPrintingStarted) {
                invFlowPrint(context, printingDataArgs);
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
                      width: MediaQuery.of(context).size.width,
                      child: Stack(children: [
                        DialogShimmerContainer(
                          color: mColor,
                          childWidget: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16)),
                          ).p(4),
                        ),
                        Container(
                          height: 250,
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
                              isPrintingForSale
                                  ? alertPrintDoneTitle()
                                  : Container(),
                              const HeightBox(10),
                              alertTitle(title),
                              const HeightBox(10),
                              alertSubTitle(mSubTitle),
                              const HeightBox(10),
                              isPrintingFailed
                                  ? SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Lottie.asset(
                                          'assets/lottie/printing_failed.json'))
                                  : isPrintingSuccess
                                      ? SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Lottie.asset(
                                              'assets/lottie/printing_success.json'))
                                      : SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Lottie.asset(
                                              'assets/lottie/printer.json')),
                              const HeightBox(10),
                              InkWell(
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: WlsPosColor.game_color_red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                  ),
                                  height: 35,
                                  child: const Center(
                                      child: Text("OK",
                                          style: TextStyle(
                                              color: WlsPosColor.white))),
                                ),
                              ),
                            ],
                          ).pSymmetric(v: 10, h: 30),
                        ).p(4)
                      ]),
                    )),
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

  alertSubTitle(String subTitle, {Color subtitleColor = WlsPosColor.red}) {
    return Center(
      child: Text(
        subTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: WlsPosColor.red),
      ),
    );
  }

  alertPrintDoneTitle() {
    return const Center(
      child: Text(
        "You Print successfully.",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13, letterSpacing: 2, color: WlsPosColor.game_color_blue),
      ),
    );
  }
}
