import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/LanguageBotttomSheet.dart';
import 'package:wls_pos/utility/widgets/shake_animation.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_text_field_underline.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userController  = TextEditingController();
  TextEditingController passController  = TextEditingController();
  ShakeController userShakeController   = ShakeController();
  ShakeController passShakeController   = ShakeController();
  bool obscurePass        = true;
  bool isGenerateOtpButtonPressed = false;
  final _loginForm        = GlobalKey<FormState>();
  var autoValidate        = AutovalidateMode.disabled;
  String lang = "eng";
  bool isLoggingIn = false;
  double mAnimatedButtonSize = 280.0;
  bool mButtonTextVisibility = true;
  ButtonShrinkStatus mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
  FocusNode usernameFocusNode               = FocusNode();
  FocusNode passwordFocusNode               = FocusNode();

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          setState(() {
            if (state is LoginTokenLoading) {
              setState(() {
                isLoggingIn = true;
              });
            }
            else if (state is LoginTokenSuccess) {
              BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
            } else if (state is LoginTokenError) {
              resetLoader();
              setState(() {
                isLoggingIn = false;
              });
              ShowToast.showToast(context, state.errorMessage.toString(), type: ToastType.ERROR);
            } else if (state is GetLoginDataError) {
              resetLoader();
              UserInfo.setPlayerToken("");
              UserInfo.setPlayerId("");
              ShowToast.showToast(context, state.errorMessage.toString(), type: ToastType.ERROR);
            } else if (state is GetLoginDataSuccess) {
              ShowToast.showToast(context, "SuccessFully Login.", type: ToastType.SUCCESS);
              Navigator.of(context).pushNamedAndRemoveUntil(WlsPosScreen.homeScreen, (Route<dynamic> route) => false);
              //Navigator.of(context).pushNamedAndRemoveUntil(WlsPosScreen.lotteryScreen, (Route<dynamic> route) => false);
            }

          });
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: const BoxDecoration(
                color: WlsPosColor.white,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/pattern_bg.png")
                )
            ),
            child: Form(
              key: _loginForm,
              autovalidateMode: autoValidate,
              child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ClipPath(
                            clipper: CurveClipper(),
                            child: Container(
                              color: WlsPosColor.app_bg,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 2.55,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height/2.55,
                                child: const Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w400
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
                                child: Column(
                                  children: [
                                    _userTextField(),
                                    _passTextField(),
                                  ],
                                ),
                              ),
                              _submitButton()
                            ],
                          ).pOnly(top: 30, left: 35, right: 35, bottom: 50)
                        ],
                      ),
                    ),

                    /*Container(
                      margin: const EdgeInsets.fromLTRB(0, 50, 10, 0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          //width: MediaQuery.of(context).size.width/3,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder( // <-- SEE HERE
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0),
                                    ),
                                  ),
                                  builder: (context) {
                                    return LanguageBottomSheet(
                                        lang: lang,
                                        mCallBack: (String selectedLanguage) {
                                          setState(() {
                                            lang = selectedLanguage;
                                          });
                                        }
                                    );
                                  }
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children:  [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(6,6,10,6),
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(5,0,0,0),
                                    child: const Text(
                                      "Select Language",
                                      style: TextStyle(
                                        color: WlsPosColor.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),*/

                  ]
              ),
            ),
          ),
        )
    );
  }

  _userTextField() {
    return ShakeWidget(
      controller: userShakeController,
      child: WlsPosTextFieldUnderline(
        maxLength: 16,
        inputType: TextInputType.text,
        hintText: "Username",
        focusNode: usernameFocusNode,
        controller: userController,
        onEditingComplete: () {
          if(userController.text.isNotEmpty && passController.text.isEmpty) {
            passwordFocusNode.requestFocus();
          } else {
            proceedToLogin();
          }
        },
        validator: (value) {
          if (validateInput(TotalTextFields.userName).isNotEmpty) {
            if (isGenerateOtpButtonPressed) {
              userShakeController.shake();
            }
            return validateInput(TotalTextFields.userName);
          } else {
            return null;
          }
        },
        // isDarkThemeOn: isDarkThemeOn,
      ).pSymmetric(v: 8),
    );
  }

  _passTextField() {
    return ShakeWidget(
      controller: passShakeController,
      child: WlsPosTextFieldUnderline(
        hintText: "Password",
        controller: passController,
        maxLength: 16,
        focusNode: passwordFocusNode,
        inputType: TextInputType.text,
        obscureText: obscurePass,
        onEditingComplete: () {
          proceedToLogin();
        },
        validator: (value) {
          if (validateInput(TotalTextFields.password).isNotEmpty) {
            if (isGenerateOtpButtonPressed) {
              passShakeController.shake();
            }
            return validateInput(TotalTextFields.password);
          } else {
            return null;
          }
        },
        suffixIcon: IconButton(
          icon: Icon(
            obscurePass ? Icons.visibility_off : Icons.remove_red_eye_rounded,
            color: WlsPosColor.black_four,
          ),
          onPressed: () {
            setState(() {
              obscurePass = !obscurePass;
            });
          },
        ),
        // isDarkThemeOn: isDarkThemeOn,
      ).pSymmetric(v: 8),
    );
  }

  _submitButton() {
    return AbsorbPointer(
      absorbing: isLoggingIn,
      child: InkWell(
        onTap: () {
          proceedToLogin();
        },
        child:  Container(
            decoration: BoxDecoration(
                color: WlsPosColor.app_bg,
                borderRadius: BorderRadius.circular(60)
            ),
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
                    child: CircularProgressIndicator(color: WlsPosColor.white_two),
                  )
                      : Center(child:
                  Visibility(
                    visible: mButtonTextVisibility,
                    child: const Text("Submit",
                      style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: WlsPosColor.white,
                      ),
                    ),
                  ))
              ),
            )
        ).pOnly(top: 30),
      ),
    );
  }

  String validateInput(TotalTextFields textField) {
    switch (textField) {
      case TotalTextFields.userName:
        var mobText = userController.text.trim();
        if (mobText.isEmpty) {
          return "Please Enter Your Username.";
        }
        break;

      case TotalTextFields.password:
        var passText = passController.text.trim();
        if (passText.isEmpty) {
          return  "Please Enter Your Password.";
        } else if (passText.length <= 7) {
          return "Password should be in range(min 8)";
        }
        break;
    }
    return "";
  }

  resetLoader() {
    mAnimatedButtonSize   = 280.0;
    mButtonTextVisibility = true;
    mButtonShrinkStatus   = ButtonShrinkStatus.over;
  }

  void proceedToLogin() {
    FocusScope.of(context).unfocus();
    setState(() {
      isGenerateOtpButtonPressed = true;
    });
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isGenerateOtpButtonPressed = false;
      });
    });
    if (_loginForm.currentState!.validate()) {
      var userName  = userController.text.trim();
      var password  = passController.text.trim();

      setState(() {
        mAnimatedButtonSize   = 50.0;
        mButtonTextVisibility = false;
        mButtonShrinkStatus   = ButtonShrinkStatus.notStarted;
      });
      BlocProvider.of<LoginBloc>(context).add(LoginTokenApi(context: context, userName: userName, password: password));
    }
    else {
      setState(() {
        autoValidate = AutovalidateMode.onUserInteraction;
      });
    }
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 70;
    Offset controlPoint = Offset(size.width / 2 , size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
