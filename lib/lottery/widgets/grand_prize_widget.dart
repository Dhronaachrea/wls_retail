import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class GrandPrizeWidget extends StatelessWidget {
  final VoidCallback doubleJackpotOnTap;
  final VoidCallback secureJackpotOnTap;
  final bool isLandscape;
  final double? doubleJackpotCost;
  final bool? isDoubleJackpotEnabled;
  final double? secureJackpotCost;
  final bool? isSecureJackpotEnabled;

  const GrandPrizeWidget({super.key, required this.doubleJackpotOnTap, required this.secureJackpotOnTap, required this.isLandscape, required this.doubleJackpotCost, required this.isDoubleJackpotEnabled, required this.secureJackpotCost, required this.isSecureJackpotEnabled});

  @override
  Widget build(BuildContext context) {
   return  Container(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Expanded(child:  doubleJackpotCost != null ?  InkWell(
            onTap: (){
              doubleJackpotOnTap();
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              width: isLandscape ? 180 : 150,
              height: 40,
              decoration: BoxDecoration(
                  color: isDoubleJackpotEnabled! ? WlsPosColor.shamrock_green : WlsPosColor.white,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  border: Border.all(color: WlsPosColor.shamrock_green)
              ),
              child: Align(alignment: Alignment.center, child: Row(
                children: [
                  SvgPicture.asset('assets/icons/grand_double.svg',
                  width: 20,
                  height: 20,
                  color: isDoubleJackpotEnabled! ? WlsPosColor.white : WlsPosColor.game_color_black,
                  ),
                  VerticalDivider(
                    color:   isDoubleJackpotEnabled! ? WlsPosColor.white : WlsPosColor.shamrock_green,
                    thickness: 2,
                  ),
                  Expanded(child: Text("Double the Grand Prize Add $doubleJackpotCost (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center,style: TextStyle(color: isDoubleJackpotEnabled! ? WlsPosColor.white : WlsPosColor.game_color_black, fontSize: isLandscape ? 18 : 10))),
                ],
              )).p(4),
            ),
          ).p(2): const SizedBox(),),
          Expanded(child:secureJackpotCost != null ? InkWell(
            onTap: (){
              secureJackpotOnTap();
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              width:isLandscape ? 180 : 150,
              height: 40,
              decoration: BoxDecoration(
                  color: isSecureJackpotEnabled! ? WlsPosColor.shamrock_green : WlsPosColor.white,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  border: Border.all(color: WlsPosColor.shamrock_green)
              ),
              child: Align(alignment: Alignment.center, child: Row(
                children: [
                  SvgPicture.asset('assets/icons/grand_secure.svg',
                    width: 20,
                    height: 20,
                    color: isSecureJackpotEnabled! ? WlsPosColor.white : WlsPosColor.game_color_black,
                  ),
                  VerticalDivider(
                    color:   isSecureJackpotEnabled! ? WlsPosColor.white : WlsPosColor.shamrock_green,
                    thickness: 2,
                  ),
                  Expanded(child: Text("Secure the Grand Prize Add $secureJackpotCost (${getDefaultCurrency(getLanguage())})", textAlign: TextAlign.center, style: TextStyle(color: isSecureJackpotEnabled! ? WlsPosColor.white : WlsPosColor.game_color_black, fontSize: isLandscape ? 18 : 10))),
                ],
              )).p(4),
            ),
          ).p(2) : const SizedBox(),)
        ],).p(2),
    );
  }
}
