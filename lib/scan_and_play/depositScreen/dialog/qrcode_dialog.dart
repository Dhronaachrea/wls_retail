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


class QrCodeDialog {
  Color mColor = WlsPosColor.game_color_orange;
  bool isPrintingFailed = false;
  bool isPrintingSuccess = false;
  bool isBuyNowPrintingStarted = true;
  String mTitle = "Printing";
  String mSubTitle = "";
  String mUrl = "";
  String mAmount = "";

  show({
    required BuildContext context,
    required String title,
    required String buttonText,
    required String url,
    required String amount,
    bool? isBackPressedAllowed,
    bool? isCloseButton = false,
    required VoidCallback onPrintingDone,
  }) {
    mTitle = title;
    mUrl = url;
    mAmount = amount;

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
              return Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 18.0),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
                    child: Stack(
                        children: [
                          Container(
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
                                alertTitle(title),
                                const HeightBox(20),
                                Text(
                                   mAmount,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: isLandscape ? 20 : 18,
                                      color: WlsPosColor.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.network(url,height:300,width:300,fit: BoxFit.cover,
                                    loadingBuilder:(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(50),
                                          child: CircularProgressIndicator(
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(),
                                    const WidthBox(10),
                                    Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(ctx).pop();
                                            onPrintingDone();
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: WlsPosColor.game_color_red,
                                              borderRadius: BorderRadius.all(Radius.circular(6)),
                                            ),
                                            height: isLandscape ? 65 : 45,
                                            child: Center(child: Text("CLOSE", style: TextStyle(color: WlsPosColor.white, fontSize: isLandscape ? 19 : 14))),
                                          ),
                                        )
                                    ),
                                  ],
                                ) ,
                                const HeightBox(20),

                              ],
                            ).pSymmetric(v: 10, h: 30),
                          ).p(4)
                        ]
                    ),
                  )
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
