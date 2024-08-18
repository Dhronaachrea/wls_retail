import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/change_pin/bloc/change_pin_state.dart';
import 'package:wls_pos/change_pin/change_pin_logic.dart';
import 'package:wls_pos/change_pin/model/change_pin_model.dart';
import 'package:wls_pos/login/login_logic.dart';
import 'package:wls_pos/login/models/response/LoginTokenResponse.dart';
import 'package:wls_pos/utility/user_info.dart';

import '../model/response/change_pin_response.dart';
import 'change_pin_event.dart';

class ChangePinBloc extends Bloc<ChangePinEvent, ChangePinState> {

  ChangePinBloc() : super(ChangePinInitial()) {
    on<ChangePinApi>(_onChangePinPostApiEvent);
  }

  _onChangePinPostApiEvent(ChangePinApi event,
      Emitter<ChangePinState> emit) async {
    emit(ChangePinLoading());
    BuildContext context = event.context;
    String oldPassword = event.oldPassword;
    String newPassword = event.newPassword;
    String confirmNewPassword = event.confirmPassword;

    Map<String, String> params = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword
    };
    ChangePinModel model = ChangePinModel(confirmNewPassword: confirmNewPassword,
    newPassword: newPassword,oldPassword: oldPassword);

    Map<String, dynamic>? _model = model.toJson();

    var response = await ChangePinLogic.onChangePin(context,_model, params,);

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(ChangePinError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            ChangePinResponse _response = value as ChangePinResponse;

            emit(ChangePinSuccess(response: _response));
          },
          responseFailure: (value) {
            ChangePinResponse errorResponse = value as ChangePinResponse;
            print(
                "bloc responseFailure: ${errorResponse.responseData
                    ?.message} =======> ");
            emit(ChangePinError(
                errorMessage: errorResponse.responseData?.message ??
                    "Something Went Wrong!"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(ChangePinError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }
}
