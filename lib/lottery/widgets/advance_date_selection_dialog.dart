import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/advanceDrawBean.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class AdvanceDateSelectionDialog {
  List<AdvanceDrawBean> betDateSelectedObjectList = [];
  show({
    required BuildContext context,
    required String title,
    required String buttonText,
    required List<AdvanceDrawBean> listOfDraws,
    bool? isBackPressedAllowed,
    required Function(List<AdvanceDrawBean>) buttonClick,
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
                  width: MediaQuery.of(context).size.width * (isLandscape ? 0.5 : 1),
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
                          GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: isLandscape ? 3 : 2,
                                crossAxisCount: isLandscape ? 3 : 2,
                              ),
                              shrinkWrap: true,
                              itemCount: listOfDraws.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Ink(
                                  decoration: const BoxDecoration(
                                      color: WlsPosColor.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(6),
                                      )
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setInnerState(() {
                                        /*for(AdvanceDrawBean i in listOfDraws) {
                                          i.isSelected = false;
                                        }*/
                                        print("listOfDraws[index].isSelected: ${listOfDraws[index].isSelected}");
                                        if (listOfDraws[index].isSelected == true) {
                                          listOfDraws[index].isSelected = false;

                                        } else {
                                          listOfDraws[index].isSelected = true;
                                        }
                                        betDateSelectedObjectList = listOfDraws;
                                      });

                                    },
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:  listOfDraws[index].isSelected == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                          border:  listOfDraws[index].isSelected == true ? Border.all(color: Colors.transparent, width: 2) : Border.all(color: WlsPosColor.ball_border_bg, width: 1)
                                      ),
                                      child: Center(child: Text(formatDate(date: listOfDraws[index].drawRespVOs?.drawDateTime ?? "", inputFormat: "yyyy-MM-dd HH:mm:ss", outputFormat: "MMM dd, HH:mm") ?? "", style: TextStyle(color: listOfDraws[index].isSelected == true ? WlsPosColor.white : WlsPosColor.ball_border_bg, fontSize: 12, fontWeight: listOfDraws[index].isSelected == true ? FontWeight.bold : FontWeight.w400))),
                                    ),
                                  ).p(2),
                                ).pSymmetric(v: 2, h: 2);
                              }),
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
        color: WlsPosColor.black,
        fontWeight: FontWeight.w700,
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

  confirmButton(Function(List<AdvanceDrawBean>)? buttonClick, String buttonText, BuildContext ctx, bool isLandscape) {
    return InkWell(
      onTap: () {
        if(buttonClick != null) {
          buttonClick(betDateSelectedObjectList);
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
        child: Center(child: Text("OK", style: TextStyle(color: WlsPosColor.white, fontSize: isLandscape ? 19 : 14))),
      ),
    );
  }

  buttons(bool isCloseButton, Function(List<AdvanceDrawBean>) buttonClick,
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
          child: Center(child: Text("Cancel", style: TextStyle(color: WlsPosColor.game_color_red, fontSize: isLandscape ? 19 : 14))),
        )
    );
  }
}
