import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/splash/bloc/splash_bloc.dart';
import 'package:wls_pos/splash/bloc/splash_state.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

import '../utility/shared_pref.dart';
import '../utility/user_info.dart';
import 'bloc/splash_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<SplashBloc>(context).add(GetConfigData(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
        body: BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is DefaultConfigLoading) {
        } else if (state is DefaultConfigSuccess) {

          SharedPrefUtils.setDepositMaxLimit  = state.response.responseData!.data!.ANON_DEPOSIT_LIMIT.toString();
          UserInfo.isLoggedIn()
              ? Navigator.pushReplacementNamed(context, WlsPosScreen.homeScreen)
              : Navigator.pushReplacementNamed(
                  context, WlsPosScreen.loginScreen);
        } else if (state is DefaultConfigError) {
          ShowToast.showToast(context, state.errorMessage);
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/splash_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Center(
              child: Image.asset(
                width: 300,
                height: 300,
                "assets/images/splash_logo.png",
              ),
            ),
          )),
    ));
  }
}
