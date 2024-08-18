import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan/scan.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_bloc.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_event.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_state.dart';
import 'package:wls_pos/scratch/pack_activation/model/game_list_response.dart';
import 'package:wls_pos/scratch/pack_activation/model/pack_activation_request.dart';
import 'package:wls_pos/scratch/pack_activation/model/pack_activation_response.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/scanner_error.dart';
import 'package:wls_pos/utility/widgets/shake_animation.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/widgets/wls_pos_text_field_underline.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
class PackActivationScreen extends StatefulWidget {
  MenuBeanList? scratchList;
  PackActivationScreen({Key? key, required this.scratchList}) : super(key: key);

  @override
  State<PackActivationScreen> createState() => _PackActivationScreenState();
}

class _PackActivationScreenState extends State<PackActivationScreen> {

  TextEditingController barCodeController = TextEditingController();
  ShakeController barCodeShakeController = ShakeController();
  bool isGenerateOtpButtonPressed = false;
  final _loginForm = GlobalKey<FormState>();
  var autoValidate = AutovalidateMode.disabled;
  double mAnimatedButtonSize = 280.0;
  bool mButtonTextVisibility = true;
  ButtonShrinkStatus mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
 // final ScanController _scanController = ScanController();
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
      appBarTitle: Text( widget.scratchList?.caption ?? "Pack Activation"),
      body: BlocListener<PackBloc, PackState>(
        listener: (context, state) {
          if (state is PackLoading) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is GameListSuccess) {
            GameListResponse gameListResponse = state.response;
            setState(() {
              isLoading = false;
            });
            List<String>? bookNumberList = [];
            List<String>? packNumberList = [];
            bookNumberList.add(getBookNumber(barCodeController.text, gameListResponse));
            // for(var bookNumberData in gameListResponse.games!)
            // {
            //   bookNumberList.add(bookNumberData.bookNumberDigits.toString());
            //   packNumberList.add(bookNumberData.packNumberDigits.toString());
            // }

            var requestData = PackActivationRequest(
                bookNumbers: bookNumberList,
                gameType: 'SCRATCH',
                packNumbers: packNumberList,
                userName: UserInfo.userName,
                userSessionId: UserInfo.userToken
            );

            BlocProvider.of<PackBloc>(context).add(PackActivationApi(
                context: context,
                scratchList: widget.scratchList,
                requestData: requestData
            ));
          }
          if( state is PackActivationSuccess) {
            PackActivationResponse packActivationResponse = state.response;
            setState(() {
              isLoading = false;
              mAnimatedButtonSize = 280.0;
              mButtonTextVisibility = true;
              mButtonShrinkStatus = ButtonShrinkStatus.over;
            });
            Alert.show(
              type: AlertType.success,
              isDarkThemeOn: false,
              buttonClick: () {
                Navigator.of(context).pop();
              },
              title: 'Success!',
              subtitle: packActivationResponse.responseMessage!,
              buttonText: 'ok'.toUpperCase(),
              context: context,
            );
          }
          if (state is PackError) {
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
              title: "Error!",
              subtitle: state.errorMessage,
              buttonText: "OK",
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
                  child: MobileScanner(  errorBuilder: (context, error, child) {
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
    );
  }

  barCodeTextField() {
    return ShakeWidget(
        controller: barCodeShakeController,
        child: WlsPosTextFieldUnderline(
          maxLength: 16,
          //inputType: TextInputType.,
          hintText: "Book Number",
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
          return "Please Enter Book Number";
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
          BlocProvider.of<PackBloc>(context).add(GameListApi(
            context: context,
            scratchList: widget.scratchList,
          ));
        } else {
          setState(() {
            autoValidate = AutovalidateMode.onUserInteraction;
          });
        }
      },
      child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [
                    WlsPosColor.tomato,
                    WlsPosColor.tomato,
                  ]
              ),
              borderRadius: BorderRadius.circular(10)),
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

  String getBookNumber(String scanText, GameListResponse gameListResponse)
  {
    int gameNumberLength = gameListResponse.games![0].gameNumber.toString().length;
    int bookNumberDigits = gameListResponse.games![0].bookNumberDigits;
    String textValue = '';
    if(scanText.contains('-'))
      {
        textValue = scanText;
      }
    else
      {
        if(scanText.length <= 9)
        {
          textValue = scanText.substring(0, gameNumberLength) + "-" + scanText.substring(3, scanText.length );
        }
        else
        {
          textValue = scanText.substring(0, gameNumberLength) + "-" + scanText.substring(3, gameNumberLength * bookNumberDigits) + "-" + scanText.substring(gameNumberLength + bookNumberDigits, scanText.length);
        }
      }
    return textValue;
  }

}
