import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/primary_button.dart';
import 'package:wls_pos/utility/widgets/selectdate/bloc/select_date_bloc.dart';
import 'package:wls_pos/utility/widgets/selectdate/select_date.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class DateAlert {
  static show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String buttonText,
    bool? isBackPressedAllowed,
    Function(String fromDate, String toDate)? buttonClick,
    bool isDarkThemeOn = true,
    bool? isCloseButton = false,
    AlertType? type = AlertType.error,
  }) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return BlocProvider.value(
          value: BlocProvider.of<SelectDateBloc>(context),
          child: BlocBuilder<SelectDateBloc, SelectDateState>(
              builder: (context, state) {
            return WillPopScope(
              onWillPop: () async {
                return isBackPressedAllowed ?? true;
              },
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 24.0),
                backgroundColor: WlsPosColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const HeightBox(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SelectDate(
                          title: "From",
                          date: context.watch<SelectDateBloc>().fromDate,
                          onTap: () {
                            context.read<SelectDateBloc>().add(
                                  PickFromDate(context: context),
                                );
                          },
                        ),
                        SelectDate(
                          title: "To",
                          date: context.watch<SelectDateBloc>().toDate,
                          onTap: () {
                            context.read<SelectDateBloc>().add(
                                  PickToDate(context: context),
                                );
                          },
                        ),
                      ],
                    ).pSymmetric(v: 16, h: 10),
                    const HeightBox(20),
                    buttons(isCloseButton ?? false, buttonClick!, buttonText,
                        ctx, isDarkThemeOn, context),
                    const HeightBox(10),
                  ],
                ).pSymmetric(v: 20),
              ),
            );
          }),
        );
      },
    );
  }

  static alertTitle(String title, bool isDarkThemeOn, AlertType type) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        color: _getTextColor(isDarkThemeOn, type),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static alertSubtitle(String subtitle, bool isDarkThemeOn) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isDarkThemeOn ? WlsPosColor.white : WlsPosColor.black,
        fontSize: 16.0,
      ),
    );
  }

  static confirmButton(Function(String fromDate, String toDate) buttonClick, String buttonText,
      BuildContext ctx, bool isDarkThemeOn, BuildContext context) {
    return PrimaryButton(
      width: 200,
      height: 52,
      fillDisableColor:
          isDarkThemeOn ? WlsPosColor.white : WlsPosColor.marigold,
      onPressed: buttonClick != null
          ? () {
              Navigator.of(ctx).pop();
              buttonClick(context.read<SelectDateBloc>().fromGameDate,context.read<SelectDateBloc>().toGameDate);
            }
          : () {
              Navigator.of(ctx).pop();
            },
      text: buttonText,
      isDarkThemeOn: isDarkThemeOn,
    );
  }

  static buttons(bool isCloseButton, Function(String fromDate, String toDate) buttonClick,
      String buttonText, BuildContext ctx, bool isDarkThemeOn,BuildContext context) {
    return confirmButton(buttonClick, buttonText, ctx, isDarkThemeOn, context);
  }

  static _getTextColor(bool isDarkThemeOn, AlertType type) {
    Color color;
    switch (type) {
      case AlertType.success:
        color = WlsPosColor.shamrock_green;
        break;
      case AlertType.error:
        color = WlsPosColor.reddish_pink;
        break;
      case AlertType.warning:
        color = WlsPosColor.marigold;
        break;
      case AlertType.confirmation:
        color =
            isDarkThemeOn ? WlsPosColor.butter_scotch : WlsPosColor.marigold;
        break;
      default:
        color = WlsPosColor.reddish_pink;
    }
    return color;
  }
}
