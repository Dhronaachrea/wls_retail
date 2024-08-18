import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/scan_and_play/withdrawalScreen/bloc/withdrawal_bloc.dart';
import 'package:wls_pos/scan_and_play/withdrawalScreen/withdrawal_screen.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import '../login/bloc/login_bloc.dart';
import '../login/bloc/login_event.dart';
import '../login/bloc/login_state.dart';
import '../utility/auth_bloc/auth_bloc.dart';
import '../utility/widgets/primary_button.dart';
import 'depositScreen/bloc/deposit_bloc.dart';
import 'depositScreen/deposit_screen.dart';

class ScanAndPlayScreen extends StatefulWidget {
  const ScanAndPlayScreen({super.key});

  @override
  State<ScanAndPlayScreen> createState() => _ScanAndPlayScreenState();
}

class _ScanAndPlayScreenState extends State<ScanAndPlayScreen>
    with SingleTickerProviderStateMixin {
  var isDeposit = true;
  late TabController _tabController;

  @override
  void initState() {
    secureScreen();
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }


  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    var body1 = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/banner.png",
                  width: double.infinity,
                  height: 80,
                  fit: BoxFit.fill,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: PrimaryButton(
                            width: double.infinity,
                            fillDisableColor:
                                isDeposit ? WlsPosColor.gray : WlsPosColor.red,
                            fillEnableColor:
                                isDeposit ? WlsPosColor.gray : WlsPosColor.red,
                            textColor: WlsPosColor.white,
                            borderColor: isDeposit
                                ? WlsPosColor.dark_gray
                                : WlsPosColor.red,
                            text: 'Deposit',
                            isCancelBtn: true,
                            fontWeight: FontWeight.w500,
                            onPressed: () {
                              setState(() {
                                isDeposit = true;
                                _tabController.index = 0;
                              });
                            }),
                      ),
                      Tab(
                          child: PrimaryButton(
                            width: double.infinity,
                              fillDisableColor: !isDeposit
                                  ? WlsPosColor.gray
                                  : WlsPosColor.red,
                              fillEnableColor: !isDeposit
                                  ? WlsPosColor.gray
                                  : WlsPosColor.red,
                              textColor: WlsPosColor.white,
                              borderColor: !isDeposit
                                  ? WlsPosColor.dark_gray
                                  : WlsPosColor.red,
                              text: 'Withdrawal',
                              fontWeight: FontWeight.w500,
                              isCancelBtn: true,
                              onPressed: () {
                                setState(() {
                                  isDeposit = false;
                                  _tabController.index = 1;
                                });
                              })),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.36,
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  MultiBlocProvider(
                      providers: [
                        BlocProvider<DepositBloc>(
                          create: (context) => DepositBloc(),
                        ),
                      ],
                      child: DepositScreen(
                        onTap: () {
                          BlocProvider.of<LoginBloc>(context)
                              .add(GetLoginDataApi(context: context));
                        },
                      )),
                  MultiBlocProvider(
                      providers: [
                        BlocProvider<WithdrawalBloc>(
                          create: (context) => WithdrawalBloc(),
                        ),
                      ],
                      child: WithdrawalScreen(
                        onTap: () {
                          BlocProvider.of<LoginBloc>(context)
                              .add(GetLoginDataApi(context: context));
                        },
                      ))
                ]),
          )
        ],
      ),
    );

    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is GetLoginDataSuccess) {
            if (state.response != null) {
              //var dummyResponse = """{"responseCode":0,"responseMessage":"Success","responseData":{"message":"Success","statusCode":0,"data":{"lastName":"williams","userStatus":"ACTIVE","walletType":"PREPAID","mobileNumber":"8505957513","isHead":"YES","orgId":2,"accessSelfDomainOnly":"YES","balance":"70,00 ","qrCode":null,"orgCode":"ORGRET101test1111231","parentAgtOrgId":0,"parentMagtOrgId":0,"creditLimit":"0,00 ","userBalance":"-266 000,00 ","distributableLimit":"0,00 ","orgTypeCode":"RET","mobileCode":"+91","orgName":"ret_test_1011111231","userId":672,"isAffiliate":"NO","domainId":1,"walletMode":"COMMISSION","orgStatus":"ACTIVE","firstName":"ret","regionBinding":"REGION","rawUserBalance":-266000.0,"parentSagtOrgId":0,"username":"monuret"}}}""";
              //BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: GetLoginDataResponse.fromJson(jsonDecode(dummyResponse))));
              BlocProvider.of<AuthBloc>(context)
                  .add(UpdateUserInfo(loginDataResponse: state.response!));
            }
          }
        },
        child: WlsPosScaffold(
          showAppBar: true,
          appBarTitle: const Text("Scan N Play").p(10),
          resizeToAvoidBottomInset: true,
          body: body1,
        ));
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _tabController.dispose();
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);

  }
}
