import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/betAmountBean.dart';
import 'package:wls_pos/lottery/widgets/dialog_shimmer_container.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class SavedPanelDataConfirmationDialog {
  show({
    required BuildContext context,
    required String title,
    required String subTitle,
    required String buttonText,
    required Function(bool) buttonClick,
    bool? isBackPressedAllowed,
    bool? isCloseButton = false,
  }) {
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
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      DialogShimmerContainer(
                        color: const Color(0xFF80DDFF),
                        childWidget: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16)
                          ),
                        ).p(4),
                      ),
                      Container(
                        height: 200,
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
                            const HeightBox(10),
                            alertSubTitle(subTitle),
                            const HeightBox(40),
                            buttons(isCloseButton ?? false,buttonText, ctx, buttonClick),
                          ],
                        ).pSymmetric(v: 10, h: 30),
                      ).p(4)
                    ]
                  ),
                )
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
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: WlsPosColor.shamrock_green
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
    .move(delay: 200.ms, duration: 300.ms);
  }

  static alertSubTitle(String title) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
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

  confirmButton(Function(bool)? buttonClick, String buttonText, BuildContext ctx) {
    return InkWell(
      onTap: () {
        if(buttonClick != null) {
          Navigator.of(ctx).pop();
          buttonClick(true);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
            color: WlsPosColor.shamrock_green,
            borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        height: 35,
        child: Center(child: Text(buttonText, style: const TextStyle(color: WlsPosColor.white))),
      ),
    );
  }

  buttons(bool isCloseButton, String buttonText, BuildContext ctx, Function(bool)? buttonClick) {
    return Row(
      children: [
        Expanded(child: confirmButton(buttonClick, buttonText, ctx)),
        const WidthBox(10),
        isCloseButton ? Expanded(child: closeButton(ctx, buttonText, buttonClick)) : const SizedBox(),
      ],
    );
  }

  static closeButton(BuildContext ctx, String buttonText, Function(bool)? buttonClick) {
    return InkWell(
      onTap: () {
        if (buttonClick != null) {
          buttonClick(false);
        }
        Navigator.of(ctx).pop();
      },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      child: Container(
        decoration: BoxDecoration(
            color: WlsPosColor.game_color_red,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            border: Border.all(color: WlsPosColor.game_color_red)
        ),
        height: 35,
        child: const Center(
            child: Text("No, Ignore", style: TextStyle(color: WlsPosColor.white))
        ),
      )
    );
  }


}
