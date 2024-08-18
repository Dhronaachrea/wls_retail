import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/routes/app_routes.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/secured_shared_pref.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefUtils.init();
  SecuredSharedPrefUtils.securedInit();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => AuthBloc(),
      ),
      BlocProvider(
        create: (context) => LoginBloc(),
      ),
    ],
    child: const WlsPosApp(),
  ));
}

class WlsPosApp extends StatefulWidget {
  const WlsPosApp({Key? key}) : super(key: key);

  //static WlsPosAppState of(BuildContext context) => context.findAncestorStateOfType<WlsPosAppState>();

  @override
  State<WlsPosApp> createState() => WlsPosAppState();
}

class WlsPosAppState extends State<WlsPosApp> {
  final AppRoute mWlsPosRoute = AppRoute();

  @override
  void initState() {
    initPlatform(); //to initialize device info
    super.initState();BlocProvider.of<AuthBloc>(context).add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        //localizationsDelegates: AppLocalizations.localizationsDelegates,
        //supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (setting) => mWlsPosRoute.router(setting),
        navigatorKey: navigatorKey
    );
  }
}
