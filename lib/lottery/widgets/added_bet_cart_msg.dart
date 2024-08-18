import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/betAmountBean.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class AddedBetCartMsg {
  show({
    required BuildContext context,
    required String title,
    required String subTitle,
    required String buttonText,
    bool? isBackPressedAllowed,
    required VoidCallback buttonClick,
    bool? isCloseButton = false,
  }) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, StateSetter setInnerState) {
            return WillPopScope(
              onWillPop: () async{
                return isBackPressedAllowed ?? true;
              },
              child: Dialog(
                insetPadding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                backgroundColor: WlsPosColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const HeightBox(10),
                          alertTitle(title),
                          const HeightBox(20),
                          alertSubTitle(subTitle, isLandscape),
                          const HeightBox(20),
                          buttons(isCloseButton ?? false, buttonClick, buttonText, ctx, isLandscape),
                          const HeightBox(10),
                        ],
                      ).pSymmetric(v: 20, h: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static alertTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        color: WlsPosColor.black
      ),
    );
  }

  static alertSubTitle(String title, bool isLandscape) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isLandscape ? 15 : 12,
          color: WlsPosColor.game_color_grey
        ),
      ),
    );
  }

  static alertSubtitle(String subtitle) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: WlsPosColor.black,
        fontSize: 16.0,
      ),
    );
  }

  confirmButton(VoidCallback? buttonClick, String buttonText, BuildContext ctx, bool isLandscape) {
    return InkWell(
      onTap: () {
        if(buttonClick != null) {
          buttonClick();
          Navigator.of(ctx).pop();
        } else {
          Navigator.of(ctx).pop();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
            color: WlsPosColor.game_color_red,
            borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        height: isLandscape ? 60 : 35,
        child: Center(child: Text("CLEAR", style: TextStyle(color: WlsPosColor.white, fontSize: isLandscape ? 19 : 14))),
      ),
    );
  }

  buttons(bool isCloseButton, VoidCallback buttonClick,
      String buttonText, BuildContext ctx, bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isCloseButton ? Expanded(child: closeButton(ctx, isLandscape)) : const SizedBox(),
        const WidthBox(10),
        Expanded(child: confirmButton(buttonClick, buttonText, ctx, isLandscape)),
      ],
    );
  }

  static closeButton(BuildContext ctx, bool isLandscape) {
    return InkWell(
      onTap: () {
        Navigator.of(ctx).pop();
      },
      child: Container(
        decoration: BoxDecoration(
            color: WlsPosColor.white,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            border: Border.all(color: WlsPosColor.game_color_red)
        ),
        height: isLandscape ? 60 : 35,
        child: Center(child: Text("STAY", style: TextStyle(color: WlsPosColor.game_color_red, fontSize: isLandscape ? 19 : 14))),
      )
    );
  }
}
