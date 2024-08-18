import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan/scan.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/bloc/ticket_validation_and_claim_bloc.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/bloc/ticket_validation_and_claim_event.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/bloc/ticket_validation_and_claim_state.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/scanner_error.dart';
import 'package:wls_pos/utility/widgets/shake_animation.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/widgets/wls_pos_text_field_underline.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import '../../utility/widgets/alert_type.dart';
import 'model/response/ticket_claim_response.dart';
import 'model/response/ticket_validation_response.dart';

class TicketValidationAndClaimScreen extends StatefulWidget {
  MenuBeanList? scratchList;
  TicketValidationAndClaimScreen({Key? key, required this.scratchList}) : super(key: key);

  @override
  State<TicketValidationAndClaimScreen> createState() => _TicketVState();
}

class _TicketVState extends State<TicketValidationAndClaimScreen> {

  TextEditingController barCodeController = TextEditingController();
  ShakeController barCodeShakeController = ShakeController();
  bool isGenerateOtpButtonPressed = false;
  final _loginForm = GlobalKey<FormState>();
  var autoValidate = AutovalidateMode.disabled;
  double mAnimatedButtonSize = 280.0;
  bool mButtonTextVisibility = true;
  ButtonShrinkStatus mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
  //final ScanController _scanController = ScanController();
  final MobileScannerController _scanController = MobileScannerController(autoStart: true);
  var isLoading = false;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
      resizeToAvoidBottomInset: false,
      showAppBar: true,
      centerTitle: false,
      appBarTitle: Flexible(child: Text( widget.scratchList?.caption ?? "Ticket Validation & Claim",style: const TextStyle(fontSize: 15))),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is GetLoginDataSuccess) {
            if (state.response != null) {
              BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: state.response!));
            }
          } else if (state is GetLoginDataError) {

          }
        },
        child:  BlocListener<TicketValidationAndClaimBloc, TicketValidationAndClaimState>(
          listener: (context, state) {
            if (state is TicketValidationAndClaimLoading || state is TicketClaimLoading) {
              setState(() {
                isLoading = true;
              });
            }
            if (state is TicketValidationAndClaimSuccess) {
              TicketValidationResponse response = state.response;
              Alert.show(
                type: AlertType.confirmation,
                isDarkThemeOn: false,
                isCloseButton: true,
                buttonClick: () {
                  BlocProvider.of<TicketValidationAndClaimBloc>(context).add(TicketClaimApi(context: context, scratchList: widget.scratchList, barCodeText: barCodeController.text.trim()));
                },
                closeButtonClick: (){
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.of(context).pop();
                },
                title: "Claim Ticket",
                subtitle: "",
                buttonText: "Claim".toUpperCase(),
                otherData: response.responseCode == 1000 ?
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    //Ticket number
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Ticket Number ",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        state.response.ticketNumber ?? "",
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Winning amount
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Winning Amount",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        ( state.response.winningAmount ?? "0").toString(),
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Tax amount
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Tax Amount ",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        ( state.response.taxAmount ?? "0").toString(),
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Net Winning Amount
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Net Winning Amount",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        state.response.netWinningAmount.toString() ?? "",
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    const HeightBox(5),
                  ],
                )
                    : Container(),
                context: context,
              );
            }
            if (state is TicketClaimSuccess) {
              TicketClaimResponse response = state.response;
              setState(() {
                isLoading = false;
              });
              BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
              Alert.show(
                type: AlertType.success,
                isDarkThemeOn: false,
                buttonClick: () {
                  _scanController.start();
                  Navigator.of(context).pop();
                },
                title: "Success!",
                subtitle: response.responseMessage ?? "Success",
                buttonText: "ok".toUpperCase(),
                otherData: response.responseCode == 1000?
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    //Invoice number
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Invoice Number",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        state.response.transactionNumber ?? "",
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Invoice Date
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Invoice Date ",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        response.transactionDate ?? "",
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Ticket number
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Ticket Number ",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        state.response.ticketNumber ?? "",
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Winning amount
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Winning Amount ",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        ( state.response.winningAmount ?? "0").toString(),
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    //Tax amount
                    const HeightBox(5),
                    const Opacity(
                      opacity : 0.5,
                      child:Text(
                          "Tax Amount",
                          style: TextStyle(
                              color:  WlsPosColor.brownish_grey_two,
                              fontWeight: FontWeight.w500,
                              fontFamily: "",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ),
                          textAlign: TextAlign.left
                      ),
                    ),
                    const HeightBox(2),
                    Text(
                        ( state.response.taxAmount ?? "0").toString(),
                        style: const TextStyle(
                            color:  WlsPosColor.greyish,
                            fontWeight: FontWeight.w500,
                            fontFamily: "",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0
                        ),
                        textAlign: TextAlign.left
                    ),
                    const HeightBox(5),
                  ],
                )
                    : Container(),
                context: context,
              );
            }
            if (state is TicketValidationAndClaimError) {
              setState(() {
                isLoading = false;
                mAnimatedButtonSize = 280.0;
                mButtonTextVisibility = true;
                mButtonShrinkStatus = ButtonShrinkStatus.over;
                barCodeController.clear();
              });
              Alert.show(
                type: AlertType.error,
                isDarkThemeOn: false,
                buttonClick: () {
                  _scanController.start();
                },
                title: "Error!",
                subtitle: state.errorMessage,
                buttonText: "ok".toUpperCase(),
                context: context,
              );
            }
            if (state is TicketClaimError) {
              setState(() {
                isLoading = false;
                mAnimatedButtonSize = 280.0;
                mButtonTextVisibility = true;
                mButtonShrinkStatus = ButtonShrinkStatus.over;
                barCodeController.clear();
              });
              // Navigator.of(context).pop();
              Alert.show(
                type: AlertType.error,
                isDarkThemeOn: false,
                buttonClick: () {
                  _scanController.start();
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
                        try{
                          final List<Barcode> barcodes = capture.barcodes;
                          String? data = barcodes[0].rawValue;
                          if( data != null){
                            setState(() {
                              barCodeController.text = data;
                            });
                          }
                        } catch(e){
                          print("Something Went wrong with bar code: $e");
                        }
                      },),
                    // ScanView(
                    //   controller: _scanController,
                    //   scanAreaScale: .7,
                    //   scanLineColor: WlsPosColor.tomato,
                    //   onCapture: (data) {
                    //     setState(() {
                    //       barCodeController.text = data;
                    //     });
                    //     // BlocProvider.of<QrScanBloc>(context).add(GetQrScanDataApi(context: context));
                    //   },
                    // ),
                  ),
                  _submitButton()
                ],
              ),
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
          maxLength: 16,
          inputType: TextInputType.text,
          hintText:  "Barcode Number",
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
        ).p20()
    );
  }

  String validateInput(TotalTextFields textField) {
    switch (textField) {
      case TotalTextFields.userName:
        var mobText = barCodeController.text.trim();
        if (mobText.isEmpty) {
          return "Please Enter BarCode Number.";
        }
        break;
      case TotalTextFields.password:
      // TODO: Handle this case.
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
          setState(() {
            mAnimatedButtonSize = 50.0;
            mButtonTextVisibility = false;
            mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
          });
          BlocProvider.of<TicketValidationAndClaimBloc>(context).add(TicketValidationAndClaimApi(context: context, scratchList: widget.scratchList, barCodeText: barCodeController.text.trim()));
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
