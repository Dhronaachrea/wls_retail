import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/change_pin/bloc/change_pin_bloc.dart';
import 'package:wls_pos/change_pin/bloc/change_pin_state.dart';

import '../utility/user_info.dart';
import '../utility/widgets/shake_animation.dart';
import '../utility/widgets/show_snackbar.dart';
import '../utility/widgets/wls_pos_scaffold.dart';
import '../utility/widgets/wls_pos_text_field_underline.dart';
import '../utility/wls_pos_color.dart';
import '../utility/wls_pos_screens.dart';
import 'bloc/change_pin_event.dart';

class ChangePin extends StatefulWidget {
  const ChangePin({Key? key}) : super(key: key);

  @override
  State<ChangePin> createState() => _ChangePinState();
}

final _changePinForm = GlobalKey<FormState>();
var autoValidate = AutovalidateMode.disabled;
ShakeController oldPasswordController = ShakeController();
TextEditingController oldPasswordTextEditController = TextEditingController();

ShakeController newPasswordController = ShakeController();
TextEditingController newPasswordTextEditController = TextEditingController();

ShakeController confirmPasswordController = ShakeController();
TextEditingController confirmPasswordTextEditController =
    TextEditingController();

bool newPassword = true;
bool confirmPassword = true;
bool loading = false;

class _ChangePinState extends State<ChangePin> {
  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return BlocListener<ChangePinBloc, ChangePinState>(
        listener: (context, state) {
          setState(() {
            if (state is ChangePinLoading) {
              loading = true;
            } else if (state is ChangePinError) {
              loading = false;
              ShowToast.showToast(context, state.errorMessage.toString(),
                  type: ToastType.ERROR);
            } else if (state is ChangePinSuccess) {
              loading = false;
              ShowToast.showToast(
                  context, "Password has been Changed SuccessFully.",
                  type: ToastType.SUCCESS);
              UserInfo.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  WlsPosScreen.loginScreen, (Route<dynamic> route) => false);
            }
          });
        },
        child: WlsPosScaffold(
          showAppBar: true,
          centerTitle: false,
          resizeToAvoidBottomInset: false,
          body: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
              child: Form(
                key: _changePinForm,
                autovalidateMode: autoValidate,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        _oldPassword(),
                        _spacer(),
                        _newPassword(),
                        _spacer(),
                        _confirmPassword(),
                        loading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 38),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : Container(),
                      ],
                    ).pOnly(top: 10, left: 10, right: 10, bottom: 10),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  _oldPassword() {
    return ShakeWidget(
      controller: oldPasswordController,
      child: WlsPosTextFieldUnderline(
        maxLength: 16,
        inputType: TextInputType.text,
        hintText: "Old Password",
        controller: oldPasswordTextEditController,
      ),
    );
  }

  _newPassword() {
    return ShakeWidget(
      controller: newPasswordController,
      child: WlsPosTextFieldUnderline(
        maxLength: 16,
        inputType: TextInputType.text,
        hintText: "New Password",
        controller: newPasswordTextEditController,
        obscureText: newPassword,
        suffixIcon: IconButton(
          icon: Icon(
            newPassword ? Icons.visibility_off : Icons.remove_red_eye_rounded,
            color: WlsPosColor.black_four,
          ),
          onPressed: () {
            setState(() {
              newPassword = !newPassword;
            });
          },
        ),
      ),
    );
  }

  _confirmPassword() {
    return ShakeWidget(
      controller: confirmPasswordController,
      child: WlsPosTextFieldUnderline(
        maxLength: 16,
        inputType: TextInputType.text,
        hintText: "Confirm Password",
        controller: confirmPasswordTextEditController,
        obscureText: confirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            confirmPassword
                ? Icons.visibility_off
                : Icons.remove_red_eye_rounded,
            color: WlsPosColor.black_four,
          ),
          onPressed: () {
            setState(() {
              confirmPassword = !confirmPassword;
            });
          },
        ),
      ),
    );
  }

  _submitButton() {
    return GestureDetector(
      onTap: () {
        if (_changePinForm.currentState!.validate()) {
          var oldPassword = oldPasswordTextEditController.text.trim();
          var newPassword = newPasswordTextEditController.text.trim();
          var confirmPassword = confirmPasswordTextEditController.text.trim();

          BlocProvider.of<ChangePinBloc>(context).add(ChangePinApi(
              context: context,
              oldPassword: oldPassword,
              newPassword: newPassword,
              confirmPassword: confirmPassword));
        } else {
          setState(() {
            autoValidate = AutovalidateMode.onUserInteraction;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 80),
        color: WlsPosColor.tomato,
        width: double.infinity,
        height: 50,
        child: const Center(
          child: Text(
            "PROCEED",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: WlsPosColor.white,
            ),
          ),
        ),
      ),
    );
  }

  _spacer() {
    return const SizedBox(height: 10);
  }
}
