import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan/scan.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/qr_scan/bloc/models/response/qrScanApiResponse.dart';
import 'package:wls_pos/qr_scan/bloc/qr_scan_bloc.dart';
import 'package:wls_pos/qr_scan/bloc/qr_scan_event.dart';
import 'package:wls_pos/qr_scan/bloc/qr_scan_state.dart';
import 'package:wls_pos/sportsLottery/models/response/reprint_main_addOn_response.dart';
import 'package:wls_pos/sportsLottery/models/response/sp_reprint_response.dart' as spPrintResponse;
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/shake_animation.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/widgets/wls_pos_text_field_underline.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import '../utility/widgets/scanner_error.dart';
import 'package:wls_pos/purchase_details/model/response/sale_response_model.dart' as sleResponse;


class QrScanScreen extends StatefulWidget {
  String titleName;

  QrScanScreen({Key? key, required this.titleName}) : super(key: key);

  @override
  _QrScanScreenState createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  var isLoading = false;

  TextEditingController barCodeController = TextEditingController();
  ShakeController barCodeShakeController = ShakeController();
  bool isGenerateOtpButtonPressed = false;
  final _loginForm = GlobalKey<FormState>();
  var autoValidate = AutovalidateMode.disabled;
  double mAnimatedButtonSize = 280.0;
  bool mButtonTextVisibility = true;
  ButtonShrinkStatus mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
  //final ScanController _scanController = ScanController();
  final MobileScannerController _scanController = MobileScannerController();

  Map<String, dynamic> printingDataArgs               = {};

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
      resizeToAvoidBottomInset: false,
      showAppBar: true,
      centerTitle: false,
      appBarTitle: Text(widget.titleName!),
      body: BlocListener<QrScanBloc, QrScanState>(
        listener: (context, state) {
          if (state is QrScanLoading) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is QrScanSuccess) {
            spPrintResponse.SpRePrintResponse winClaimResponse = state.response;
            setState(() {
              isLoading = false;
            });
            if (androidInfo?.model == "V2" ||
                androidInfo?.model == "M1" ||
                androidInfo?.model == "T2mini") {
              bool winingStatus = state.response.responseData?.winningStatus == "WIN";
              if (winingStatus) {
                spPrintResponse.SpRePrintResponse response = state.response;
                String? selectionString = response.responseData?.selectionJson;
                if(selectionString!= null){
                  String formattedSelectionString = selectionString.replaceAll("\\","",);
                  var selectionJson = json.decode(formattedSelectionString);
                  var reprintMainAndAddOnDraw =  ReprintMainAndAddOnDraw.fromJson(selectionJson);
                  sleResponse.SaleResponseModel saleResponseModel = sleResponse.SaleResponseModel(
                      responseData: sleResponse.ResponseData(
                        ticketNumber: response.responseData?.lastTicketNo ?? "",
                        drawDateTime: response.responseData?.drawDateTime ?? "",
                        drawNo: response.responseData?.drawNo,
                        totalSaleAmount: response.responseData?.saleAmount,
                        gameCode:  response.responseData?.merchantGameCode,
                        mainDrawData: sleResponse.MainDrawData(
                          boards: reprintMainAndAddOnDraw.mainDraw,
                        ),
                        addOnDrawData: sleResponse.MainDrawData(
                          boards: reprintMainAndAddOnDraw.addOnDraw,
                        ),
                      )

                  );
                  Map<String,dynamic> printingDataArgs = {};
                  log("saleResponseModel: $saleResponseModel");
                  printingDataArgs["statusMessage"]  = response.responseData?.statusMessage;
                  printingDataArgs["winningStatus"]  = response.responseData?.winningStatus;
                  printingDataArgs["winningAmount"]  = response.responseData?.winningAmount;

                  printingDataArgs["saleResponse"]  = jsonEncode(saleResponseModel);
                  printingDataArgs["username"]      = UserInfo.userName;
                  printingDataArgs["currencyCode"]  = getDefaultCurrency(getLanguage());
                  PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isSportsPoolSale: true, isWinClaim: true, onPrintingDone:() {
                  }, isPrintingForSale: false);
                }
              }

            } else {
              Alert.show(
                isDarkThemeOn: false,
                type: AlertType.success,
                buttonClick: () {
                  // _scanController.resume();
                  Navigator.of(context).pop();
                },
                title: 'Success!',
                subtitle: winClaimResponse.responseMessage ?? '',
                otherData: Column(
                  children: [
                    Text(
                      "Ticket Number : ${winClaimResponse.responseData?.ticketNo}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: WlsPosColor.black,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      "Draw ID : ${winClaimResponse.responseData?.drawId}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: WlsPosColor.black,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      "Total Sale Amount : ${ getDefaultCurrency(getLanguage())} ${winClaimResponse.responseData?.saleAmount}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: WlsPosColor.black,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      "WinningAmount : ${ getDefaultCurrency(getLanguage())} ${winClaimResponse.responseData?.winningAmount}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: WlsPosColor.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ).pOnly(bottom: 10),
                buttonText: 'ok'.toUpperCase(),
                context: context,
              );
            }
          }
          if (state is QrScanError) {
            setState(() {
              isLoading = false;
              mAnimatedButtonSize = 280.0;
              mButtonTextVisibility = true;
              mButtonShrinkStatus = ButtonShrinkStatus.over;
            });
            // Navigator.of(context).pop();
            Alert.show(
              isDarkThemeOn: false,
              type: AlertType.error,
              buttonClick: () {
                // _scanController.resume();
                Navigator.of(context).pop();
              },
              title: 'Error!',
              subtitle: state.errorMessage,
              buttonText: 'ok'.toUpperCase(),
              context: context,
            );
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _loginForm,
            autovalidateMode: autoValidate,
            child: Column(
              children: <Widget>[
                barCodeTextField(),
                SizedBox(
                  height: context.screenHeight * 0.55,
                  child: MobileScanner(
                    errorBuilder: (context, error, child) {
                      return ScannerError(
                        context: context,
                        error: error,
                      );
                    },
                    controller: _scanController,
                    onDetect: (capture) {
                      try {
                        final List<Barcode> barcodes = capture.barcodes;
                        String? data = barcodes[0].rawValue;
                        if (data != null) {
                          setState(() {
                            barCodeController.text = data;
                          });
                        }
                      } catch (e) {
                        print("Something went wrong with bar code: $e");
                      }
                    },
                  ),
                ),
                // SizedBox(
                //   height: context.screenHeight * 0.55,
                //   child: ScanView(
                //     controller: _scanController,
                //     scanAreaScale: .7,
                //     scanLineColor: WlsPosColor.tomato,
                //     onCapture: (data) {
                //       setState(() {
                //         barCodeController.text = data;
                //       });
                //       // BlocProvider.of<QrScanBloc>(context).add(GetQrScanDataApi(context: context));
                //     },
                //   ),
                // ),
                _submitButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  barCodeTextField() {
    return ShakeWidget(
        controller: barCodeShakeController,
        child: WlsPosTextFieldUnderline(
          maxLength: 25,
          inputType: TextInputType.text,
          hintText: "Ticket Number",
          controller: barCodeController,
          underLineType: false,
          validator: (value) {
            if (validateInput(TotalTextFields.userName).isNotEmpty) {
              if (isGenerateOtpButtonPressed) {
                barCodeShakeController.shake();
              }
              return validateInput(TotalTextFields.userName);
            } else {
              return null;
            }
          },
          // isDarkThemeOn: isDarkThemeOn,
        ).p20());
  }

  String validateInput(TotalTextFields textField) {
    switch (textField) {
      case TotalTextFields.userName:
        var mobText = barCodeController.text.trim();
        if (mobText.isEmpty) {
          return "Please Enter Ticket Number.";
        }
        break;
    }
    return "";
  }

  _submitButton() {
    return InkWell(
      onTap: () {
        setState(() {
          isGenerateOtpButtonPressed = true;
        });
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            isGenerateOtpButtonPressed = false;
          });
        });
        if (_loginForm.currentState!.validate()) {
          var userName = barCodeController.text.trim();
          setState(() {
            mAnimatedButtonSize = 50.0;
            mButtonTextVisibility = false;
            mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
          });
          BlocProvider.of<QrScanBloc>(context).add(GetWinClaimDataApi(
              context: context, barCodetext: barCodeController.text));
        } else {
          setState(() {
            autoValidate = AutovalidateMode.onUserInteraction;
          });
        }
      },
      child: Container(
          decoration: BoxDecoration(
              color: WlsPosColor.icon_green,
              borderRadius: BorderRadius.circular(60)),
          child: AnimatedContainer(
            width: mAnimatedButtonSize,
            height: 50,
            onEnd: () {
              setState(() {
                if (mButtonShrinkStatus != ButtonShrinkStatus.over) {
                  mButtonShrinkStatus = ButtonShrinkStatus.started;
                } else {
                  mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
                }
              });
            },
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
                width: mAnimatedButtonSize,
                height: 50,
                child: mButtonShrinkStatus == ButtonShrinkStatus.started
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                      color: WlsPosColor.white_two),
                )
                    : Center(
                    child: Visibility(
                      visible: mButtonTextVisibility,
                      child: const Text(
                        "Proceed",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: WlsPosColor.white,
                        ),
                      ),
                    ))),
          )).pOnly(top: 30),
    );
  }
}
