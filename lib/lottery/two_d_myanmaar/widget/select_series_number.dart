import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/betAmountBean.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class SelectSeriesNumber {
  int selectedSeriesNumber = 0;
  show({
    required BuildContext context,
    required String title,
    required String buttonText,
    required List<FiveByNinetyBetAmountBean> listOfAmounts,
    bool? isBackPressedAllowed,
    required Function(int) buttonClick,
    bool? isCloseButton = false,
  }) {
    for(FiveByNinetyBetAmountBean i in listOfAmounts) {
      if(i.isSelected == true) {
        selectedSeriesNumber = i.amount ?? 0;
      }
    }

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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const HeightBox(10),
                            alertTitle(title),
                            const HeightBox(20),
                            GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: isLandscape ? 2 : 1,
                                  crossAxisCount: isLandscape ? 6 : 5,
                                ),
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: listOfAmounts.length,
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
                                        if (listOfAmounts[index].amount != null) {
                                          selectedSeriesNumber = listOfAmounts[index].amount!;
                                        }

                                        setInnerState(() {
                                          for(FiveByNinetyBetAmountBean i in listOfAmounts) {
                                            i.isSelected = false;
                                          }
                                          listOfAmounts[index].isSelected = true;
                                        });
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:  listOfAmounts[index].isSelected == true ? WlsPosColor.game_color_red : WlsPosColor.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                                            border:  listOfAmounts[index].isSelected == true ? Border.all(color: Colors.transparent, width: 2) : Border.all(color: WlsPosColor.ball_border_bg, width: 1)
                                        ),
                                        child: Center(child: Text("${listOfAmounts[index].amount}", style: TextStyle(color: listOfAmounts[index].isSelected == true ? WlsPosColor.white : WlsPosColor.ball_border_bg, fontSize: 12, fontWeight: listOfAmounts[index].isSelected == true ? FontWeight.bold : FontWeight.w400))),
                                      ),
                                    ).p(2),
                                  );
                                }),
                            const HeightBox(20),
                            buttons(buttonClick, buttonText, ctx, isLandscape),
                            const HeightBox(10),
                          ],
                        ).pSymmetric(v: 20, h: 50),
                      ],
                    ),
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

  confirmButton(Function(int) buttonClick, String buttonText, BuildContext ctx, bool isLandscape) {
    return InkWell(
      onTap: () {
        Navigator.of(ctx).pop();
        buttonClick(selectedSeriesNumber);
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

  buttons(Function(int) buttonClick,
      String buttonText, BuildContext ctx, bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: confirmButton(buttonClick, buttonText, ctx, isLandscape)),
      ],
    );
  }
}
