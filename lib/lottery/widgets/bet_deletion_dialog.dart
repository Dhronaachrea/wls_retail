import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/models/request/saleRequestBean.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class BetDeletionDialog {
  show({
    required BuildContext context,
    required String title,
    required String buttonText,
    required PanelBean panelBeanDetails,
    List<PanelData>? thaiPanelDataDetails,
    bool? isBackPressedAllowed,
    bool? isLabelExistsInNumberConfig,
    required Function(PanelBean) onButtonClick,
    bool? isCloseButton = false,
  }) {
    var numberOfLines = panelBeanDetails.numberOfLines ?? 0;
    var mIsLabelExistsInNumberConfig = isLabelExistsInNumberConfig ?? false;

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
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                backgroundColor: WlsPosColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
                  child: mIsLabelExistsInNumberConfig
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/deletion.svg", width: 70, height: 70, color: WlsPosColor.game_color_red),
                      Center(
                          child: Text(
                              "Are you sure you want to delete above ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: WlsPosColor.red,
                                  fontSize: isLandscape ? 20 : 14,
                                  fontWeight: FontWeight.w400
                              )
                          ).p(10)
                      ),
                      const HeightBox(20),
                      buttons(isCloseButton ?? false, onButtonClick, buttonText, ctx, panelBeanDetails, isLandscape),
                      const HeightBox(10),
                    ],
                  ).pSymmetric(v: 20, h: 50)
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/deletion.svg", width: 70, height: 70, color: WlsPosColor.game_color_red),
                      Container(
                        decoration: DottedDecoration(
                          color: WlsPosColor.ball_border_bg,
                          strokeWidth: 0.5,
                          linePosition: LinePosition.bottom,
                        ),
                        height:12,
                      ),
                      const HeightBox(10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: (thaiPanelDataDetails != null)//getThaiLotteryNoList(thaiPanelDataDetails)
                                ? Center(
                              child: Text(
                                  "${getThaiLotteryNoList(thaiPanelDataDetails)}",
                                  textAlign: TextAlign.left, style: TextStyle(color: WlsPosColor.black, fontSize: isLandscape ? 20 : 16)
                              ),
                            )
                                : panelBeanDetails.isMainBet == true
                                ? Center(child: Text(panelBeanDetails.pickedValue ?? "?", overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: WlsPosColor.black, fontSize: isLandscape ? 18 :13,fontWeight: FontWeight.bold)))

                                : Center(child: Text(panelBeanDetails.pickName ?? "?", overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: WlsPosColor.black, fontSize: isLandscape ? 18 :13,fontWeight: FontWeight.bold))),
                          ),
                          Container(width: 1, color: WlsPosColor.game_color_grey, height: 20),
                          Text("${panelBeanDetails.amount} ${getDefaultCurrency(getLanguage())}", textAlign: TextAlign.left, style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: isLandscape ? 18 :13))
                        ],
                      ),
                      const HeightBox(10),
                      (thaiPanelDataDetails != null)//getThaiLotteryNoList(thaiPanelDataDetails)
                          ? Center(
                        child: Text(
                            "${thaiPanelDataDetails[0].betType}   |   ${thaiPanelDataDetails[0].pickType}",
                            textAlign: TextAlign.left, style: TextStyle(color: WlsPosColor.black, fontSize: isLandscape ? 18 : 12)
                        ),
                      )
                          : Text(
                          panelBeanDetails.isMainBet == true
                              ? numberOfLines > 2
                              ? "Main Bet   |   ${panelBeanDetails.pickName}   |   No of lines: ${panelBeanDetails.numberOfLines}"
                              : "Main Bet   |   ${panelBeanDetails.pickName}   |   No of line: ${panelBeanDetails.numberOfLines}"

                              : numberOfLines > 2
                              ? "Side Bet   |   ${panelBeanDetails.pickName}   |   No of lines: ${panelBeanDetails.numberOfLines}"
                              : "Side Bet   |   ${panelBeanDetails.pickName}   |   No of line: ${panelBeanDetails.numberOfLines}",
                          textAlign: TextAlign.left, style:  TextStyle(color: WlsPosColor.black, fontSize: isLandscape ? 18 : 12)),
                      Container(
                        decoration: DottedDecoration(
                          color: WlsPosColor.ball_border_bg,
                          strokeWidth: 0.5,
                          linePosition: LinePosition.bottom,
                        ),
                        height:12,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Center(child: Text("Are you sure you want to delete above ?", textAlign: TextAlign.center, style: TextStyle(color: WlsPosColor.red, fontSize: isLandscape ? 18 : 14, fontWeight: FontWeight.w400)).p(10)),
                      const HeightBox(20),
                      buttons(isCloseButton ?? false, onButtonClick, buttonText, ctx, panelBeanDetails, isLandscape),
                      const HeightBox(10),
                    ],
                  ).pSymmetric(v: 20, h: 50),
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

  confirmButton(Function(PanelBean) panelBeanCallback, String buttonText, BuildContext ctx, PanelBean panelBeanDetails, bool isLandscape) {
    return InkWell(
      onTap: () {
        panelBeanCallback(panelBeanDetails);
        Navigator.of(ctx).pop();
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

  buttons(bool isCloseButton, Function(PanelBean) panelBean, String buttonText, BuildContext ctx, PanelBean panelBeanDetails, bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isCloseButton ? Expanded(child: closeButton(ctx, isLandscape)) : const SizedBox(),
        const WidthBox(10),
        Expanded(child: confirmButton(panelBean, buttonText, ctx, panelBeanDetails, isLandscape))
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

  getThaiLotteryNoList(List<PanelData> dataList) {
    List<String> numbers = [];
    for(PanelData data in dataList){
      numbers.add((data.pickedValues ?? "").replaceAll("#", "").replaceAll("-1", ""));
    }

    return numbers.join(",");
  }
}
