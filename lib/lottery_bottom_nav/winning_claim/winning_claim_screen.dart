import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/response/TicketVerifyResponse.dart' as winning_claim;
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/response/TicketVerifyResponse.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/auth_bloc/auth_bloc.dart';
import 'package:wls_pos/utility/shared_pref.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/scanner_error.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';
import '../../../utility/widgets/show_snackbar.dart';
import 'bloc/winning_claim_bloc.dart';
import 'bloc/winning_claim_event.dart';
import 'bloc/winning_claim_state.dart';
import 'models/request/ClaimWinPayPwtRequest.dart';

class WinningClaimScreen extends StatefulWidget {
  const WinningClaimScreen({Key? key}) : super(key: key);

  @override
  State<WinningClaimScreen> createState() => _WinningClaimScreenState();
}

class _WinningClaimScreenState extends State<WinningClaimScreen> {

  TextEditingController box1 = TextEditingController();
  TextEditingController box2 = TextEditingController();
  TextEditingController box3 = TextEditingController();
  TextEditingController box4 = TextEditingController();
  TextEditingController box5 = TextEditingController();
  UrlDrawGameBean?  verifyTicketUrls;
  UrlDrawGameBean?  winClaimUrls;
  int focusedField = 0;
  // final ScanController _scanController = ScanController();
  final MobileScannerController _scanController = MobileScannerController(autoStart: true);
  bool flashOn = false;
  String ticketNo = "";
  winning_claim.ResponseData? verifyResponse;
  double mAnimatedButtonSize = 280.0;
  bool mButtonTextVisibility = true;
  ButtonShrinkStatus mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
  Map<String, dynamic> printingDataArgs               = {};
  bool isClaiming = false;

  @override
  void initState() {
    log("winning claim screen");
    ModuleBeanLst? drawerModuleBeanList     = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? winningClaimMenuBeanList  = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_WIN_CLAIM").toList()[0];
    verifyTicketUrls  = getDrawGameUrlDetails(winningClaimMenuBeanList!, context, "verifyTicket");
    winClaimUrls      = getDrawGameUrlDetails(winningClaimMenuBeanList, context, "claimWin");
    log("verifyTicketUrls: ${verifyTicketUrls?.url}");
    log("verifyTicketUrls:basePath: ${verifyTicketUrls?.basePath}");
    log("winClaimUrls: ${winClaimUrls?.url}");
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is GetLoginDataLoading) {
          setState(() {
            isClaiming = true;
          });

        } else if (state is GetLoginDataSuccess) {
          BlocProvider.of<AuthBloc>(context).add(UpdateUserInfo(loginDataResponse: state.response!));
          setState(() {
            isClaiming = false;
          });
          PrintingDialog().show(context: context, title: "Printing started", isCloseButton: false, buttonText: "Retry", printingDataArgs: printingDataArgs, isWinClaim: true,
              onPrintingDone:(){
                Navigator.of(context).pop(true);
              },
              onPrintingFailed:() {
                resetTextFields();
                resetScanner();
              },
              isPrintingForSale: false);

        } else if (state is GetLoginDataError) {
          setState(() {
            isClaiming = false;
          });
          PrintingDialog().show(context: context, title: "Printing started", isCloseButton: false, buttonText: "Retry", printingDataArgs: printingDataArgs, isWinClaim: true,
              onPrintingDone:(){
                Navigator.of(context).pop(true);
              },
              onPrintingFailed:() {
                resetTextFields();
                resetScanner();
              },
              isPrintingForSale: false);
        }
      },
      child: BlocListener<WinningClaimBloc, WinningClaimState>(
        listener: (context, state) {
          if (state is TicketVerifyApiLoading) {

          }
          else if (state is TicketVerifySuccess) {
            var responseTicketNumber = "";
            resetLoader();
            setState(() {
              TicketVerifyResponse? response = state.response;
              winning_claim.ResponseData? data = state.response?.responseData;
              verifyResponse = data;

              bool showError = false;
              String showErrorMsg = "";
              if (response == null) {
                ShowToast.showToast(context, "response is null", type: ToastType.ERROR);
              } else if (response.responseCode == 0) {
                responseTicketNumber = response.responseData?.ticketNumber ?? "";
                var responseDrawData = response.responseData?.drawData ?? [];
                for (int k = 0; k < responseDrawData.length; k++) {
                  var panelWinList = responseDrawData[k].panelWinList ?? [];
                  for (int j = 0; j < panelWinList.length; j++) {
                    var winClaimAmount = response.responseData?.winClaimAmount ?? 0;
                    if (responseDrawData[k].panelWinList?[j].status?.toUpperCase() == "UNCLAIMED" && winClaimAmount > 0) {
                      showError = false;
                      break;
                    } else {
                      showError = true;
                    }
                  }
                  if (!showError) {
                    break;
                  }
                }

                for (int i = 0; i < responseDrawData.length; i++) {
                  bool isWinning = false;
                  var panelWinList = responseDrawData[i].panelWinList ?? [];
                  for (int j = 0; j < panelWinList.length; j++) {
                    var winClaimAmount = response.responseData?.winClaimAmount ?? 0;
                    if (responseDrawData[i].panelWinList?[j].status?.toUpperCase() == "UNCLAIMED" && winClaimAmount > 0) {
                      //Utils.playWinningSound(this, R.raw.small_2);
                      //CustomSuccessDialog.getProgressDialog().
                      //showDialogClaim(this, response, this, getString(R.string.winning_claim), false, true);
                      showConfirmDialog(context, responseTicketNumber, winClaimAmount);
                      isWinning = true;
                      break;
                    } else if (showError && ((j + 1) == panelWinList.length)) {
                      if (showError && responseDrawData[i].winStatus?.toUpperCase()  == "WIN!!") {
                        List<String> time = responseDrawData[i].drawTime?.split(":") ?? [];
                        String boldStatus = "Ticket already claimed !";
                        showErrorMsg = "$showErrorMsg ${responseDrawData[i].drawDate} ${time[0]}:${time[1]}\n$boldStatus\n\n";

                      } else if (responseDrawData[i].winStatus?.toUpperCase()  == "NON WIN!!") {
                        List<String> time = responseDrawData[i].drawTime?.split(":") ?? [];
                        String boldStatus = "Better luck next time";
                        showErrorMsg = "$showErrorMsg ${responseDrawData[i].drawDate} ${time[0]}:${time[1]}\n$boldStatus\n\n";
                      } else {
                        List<String> time = responseDrawData[i].drawTime?.split(":") ?? [];
                        String boldStatus = responseDrawData[i].winStatus ?? "";

                        /*SpannableString bold_status = new SpannableString(response.getResponseData().getDrawData().get(i).getWinStatus());
                        bold_status.setSpan(new StyleSpan(Typeface.BOLD), 0, response.getResponseData().getDrawData().get(i).getWinStatus().length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);*/
                        showErrorMsg = "${"$showErrorMsg ${responseDrawData[i].drawDate} ${time[0]}:${time[1]}"}\n$boldStatus\n\n";
                      }
                    }
                  }


                  if (isWinning) {
                    break;
                  }
                }
                if (showError) {
                  showErrorDialog(context, showErrorMsg);
                  //Utils.showCustomErrorDialog(this, getString(R.string.winning_claim), showErrorMsg);
                }

              }

            });
          }
          else if (state is TicketVerifyError) {
            resetLoader();
            if (state.errorCode == 102) {
              Navigator.of(context).popUntil((route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor:WlsPosColor.tomato,
                    content: const Text("Session Expired, Please Login", style: TextStyle(color: WlsPosColor.white)),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 100,
                        right: 20,
                        left: 20),));
              Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
            } else {
              resetScanner();
              ShowToast.showToast(context, state.errorMessage, type: ToastType.ERROR);
            }
          }
          else if( state is ClaimWinPayPwtSuccess) {
            resetLoader();
            setState(() {
              isClaiming = false;
            });
            if (SharedPrefUtils.getLastWinningTicketNo.isNotEmpty) {
              SharedPrefUtils.setLastWinningTicketNo = state.response?.responseData?.ticketNumber ?? SharedPrefUtils.getLastWinningTicketNo;
            } else {
              SharedPrefUtils.setLastWinningTicketNo = state.response?.responseData?.ticketNumber ?? "";
            }

            SharedPrefUtils.setLastWinningSaleTicketNo = ticketNo;
            log("AFTER SAVING LastWinningSaleTicket -> ${SharedPrefUtils.getLastWinningSaleTicketNo}");


            printingDataArgs["winClaimedResponse"]  = jsonEncode(state.response);
            printingDataArgs["lastWinningSaleTicketNo"]  = SharedPrefUtils.getLastWinningSaleTicketNo;
            printingDataArgs["username"]      = UserInfo.userName;
            printingDataArgs["currencyCode"]  = getDefaultCurrency(getLanguage());
            printingDataArgs["languageCode"]  = "en";

            BlocProvider.of<LoginBloc>(context).add(GetLoginDataApi(context: context));
            /*ModuleBeanLst? drawerModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
            MenuBeanList? rePrintApiDetails = drawerModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_REPRINT").toList()[0];
            UrlDrawGameBean? rePrintApiUrlsDetails = getDrawGameUrlDetails(rePrintApiDetails!, context, "reprintTicket");
            BlocProvider.of<WinningClaimBloc>(context).add(
                RePrintApiClaim(
                    context:context,
                    apiUrlDetails: rePrintApiUrlsDetails,
                    gameCode: "${verifyResponse?.gameCode ?? 0}",
                    claimTicketNumber: "${verifyResponse?.ticketNumber}"

                )
            );*/
            // now call rePrint Api
          }
          else if( state is ClaimWinPayPwtError)
          {
            resetLoader();
            if (state.errorCode == 102) {
              Navigator.of(context).popUntil((route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor:WlsPosColor.tomato,
                    content: Text("Session Expired, Please Login", style: const TextStyle(color: WlsPosColor.white)),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 100,
                        right: 20,
                        left: 20),));
              Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
            } else {
              resetScanner();
              ShowToast.showToast(context, state.errorMessage, type: ToastType.ERROR);
            }
          }
        },
        child: SafeArea(
          child: WlsPosScaffold(
            resizeToAvoidBottomInset: false,
            showAppBar: true,
            appBarTitle: const Text("Winning Claim", style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
            body: Stack(
              children: [
                SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 63,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: (focusedField == 1) ? WlsPosColor.black : WlsPosColor.warm_grey_seven)
                              ),
                              child: TextField(
                                controller: box1,
                                maxLines: 1,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                                cursorColor: WlsPosColor.black,
                                onTap: () {
                                  setState(() {
                                    focusedField = 1;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if(value.length == 4) {
                                      FocusScope.of(context).nextFocus();
                                      focusedField = 2;
                                    }
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ).pOnly(left: 10, right: 10),
                            ),
                            Container(
                              width: 63,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color:(focusedField == 2) ? WlsPosColor.black : WlsPosColor.warm_grey_seven)
                              ),
                              child: TextField(
                                controller: box2,
                                maxLines: 1,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                                cursorColor: WlsPosColor.black,
                                onChanged: (value) {
                                  setState(() {
                                    if(value.length == 4) {
                                      FocusScope.of(context).nextFocus();
                                      focusedField = 3;
                                    } else if (value.isEmpty) {
                                      FocusScope.of(context).previousFocus();
                                      focusedField = 1;
                                    }
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    focusedField = 2;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ).pOnly(left: 10, right: 10),
                            ),
                            Container(
                              width: 63,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color:(focusedField == 3) ? WlsPosColor.black : WlsPosColor.warm_grey_seven)
                              ),
                              child: TextField(
                                controller: box3,
                                maxLines: 1,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                                cursorColor: WlsPosColor.black,
                                onChanged: (value) {
                                  setState(() {
                                    if(value.length == 4) {
                                      FocusScope.of(context).nextFocus();
                                      focusedField = 4;
                                    } else if (value.isEmpty) {
                                      FocusScope.of(context).previousFocus();
                                      focusedField = 2;
                                    }
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    focusedField = 3;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ).pOnly(left: 10, right: 10),
                            ),
                            Container(
                              width: 63,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color:(focusedField == 4) ? WlsPosColor.black : WlsPosColor.warm_grey_seven)
                              ),
                              child: TextField(
                                controller: box4,
                                maxLines: 1,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                                cursorColor: WlsPosColor.black,
                                onTap: () {
                                  setState(() {
                                    focusedField = 4;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if(value.length == 4) {
                                      FocusScope.of(context).nextFocus();
                                      focusedField = 5;
                                    } else if (value.isEmpty) {
                                      FocusScope.of(context).previousFocus();
                                      focusedField = 3;
                                    }
                                  });

                                  /*if (value.isEmpty) {
                                setState(() {
                                  FocusScope.of(context).previousFocus();
                                  focusedField = 3;
                                });
                              }*/
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ).pOnly(left: 10, right: 10),
                            ),
                            Container(
                              width: 63,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color:(focusedField == 5) ? WlsPosColor.black : WlsPosColor.warm_grey_seven)
                              ),
                              child: TextField(
                                controller: box5,
                                maxLines: 1,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                                cursorColor: WlsPosColor.black,
                                onTap: () {
                                  setState(() {
                                    focusedField = 5;
                                  });
                                },
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      FocusScope.of(context).previousFocus();
                                      focusedField = 4;
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ).pOnly(left: 10, right: 10),
                            ),
                          ],
                        ).p(10),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.53,
                            child: InkWell(
                              onDoubleTap: () {
                                _scanController.start();
                              },
                              child: Stack(
                                  children: [

                                    MobileScanner(
                                      errorBuilder: (context, error, child) {
                                        return ScannerError(
                                          context: context,
                                          error: error,
                                        );
                                      },
                                      controller: _scanController,
                                      onDetect: (capture) {
                                        String data = capture.barcodes[0].rawValue ?? "";
                                        setState(() {
                                          if(data.length >= 20) {
                                            if(data.contains("-")) {
                                              List<String> numList  = data.split("-");
                                              box1.text = numList[0];
                                              box2.text = numList[1];
                                              box3.text = numList[2];
                                              box4.text = numList[3];
                                              box5.text = numList[4];
                                            } else {
                                              List<String> numList = [];
                                              for(int i=0 ; i<20; i+=4){
                                                numList.add(data.substring(i,i+4));
                                              }
                                              box1.text = numList[0];
                                              box2.text = numList[1];
                                              box3.text = numList[2];
                                              box4.text = numList[3];
                                              box5.text = numList[4];

                                            }
                                            setState(() {
                                              ticketNo = "${box1.text}${box2.text}${box3.text}${box4.text}${box5.text}".trim();
                                              if (ticketNo.isEmpty || ticketNo.length < 20) {
                                                ShowToast.showToast(context, "Please enter ticket number", type: ToastType.ERROR);

                                              } else {
                                                setState(() {
                                                  mAnimatedButtonSize   = 50.0;
                                                  mButtonTextVisibility = false;
                                                  mButtonShrinkStatus   = ButtonShrinkStatus.notStarted;
                                                });
                                                _scanController.stop();
                                                BlocProvider.of<WinningClaimBloc>(context).add(
                                                    TicketVerifyApi(
                                                        context: context,
                                                        ticketNumber: ticketNo,
                                                        apiDetails: verifyTicketUrls
                                                    )
                                                );
                                              }
                                            });


                                          } else {
                                            ShowToast.showToast(context, "Unable to scan properly.", type: ToastType.ERROR);
                                            resetUI();
                                          }
                                        });
                                      },
                                    ),
                                    /*ScanView(
                                      controller: _scanController,
                                      scanAreaScale: .7,
                                      scanLineColor: WlsPosColor.tomato,
                                      onCapture: (data) {
                                        setState(() {
                                          if(data.length >= 20) {
                                            if(data.contains("-")) {
                                              List<String> numList  = data.split("-");
                                              box1.text = numList[0];
                                              box2.text = numList[1];
                                              box3.text = numList[2];
                                              box4.text = numList[3];
                                              box5.text = numList[4];
                                            } else {
                                              List<String> numList = [];
                                              for(int i=0 ; i<20; i+=4){
                                                numList.add(data.substring(i,i+4));
                                              }
                                              box1.text = numList[0];
                                              box2.text = numList[1];
                                              box3.text = numList[2];
                                              box4.text = numList[3];
                                              box5.text = numList[4];

                                            }
                                            setState(() {
                                              ticketNo = "${box1.text}${box2.text}${box3.text}${box4.text}${box5.text}".trim();
                                              if (ticketNo.isEmpty || ticketNo.length < 20) {
                                                ShowToast.showToast(context, "Please enter ticket number", type: ToastType.ERROR);

                                              } else {
                                                setState(() {
                                                  mAnimatedButtonSize   = 50.0;
                                                  mButtonTextVisibility = false;
                                                  mButtonShrinkStatus   = ButtonShrinkStatus.notStarted;
                                                });
                                                _scanController.pause();
                                                BlocProvider.of<WinningClaimBloc>(context).add(
                                                    TicketVerifyApi(
                                                        context: context,
                                                        ticketNumber: ticketNo,
                                                        apiDetails: verifyTicketUrls
                                                    )
                                                );
                                              }
                                            });


                                          } else {
                                            ShowToast.showToast(context, "Unable to scan properly.", type: ToastType.ERROR);
                                            resetUI();
                                          }
                                        });
                                      },
                                    ),*/
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            // on and off splash
                                            setState(() {
                                              flashOn = !flashOn;
                                              _scanController.toggleTorch();
                                            });
                                          },
                                          child: Icon(
                                            (flashOn ? Icons.flash_on : Icons.flash_off),
                                            color: WlsPosColor.reddish_pink,
                                            size: 30,
                                          ).p(10),
                                        )
                                    ),
                                  ]
                              ),
                            )
                        ).p(20),
                        Material(
                          color: WlsPosColor.game_color_red,
                          borderRadius: BorderRadius.circular(60),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                ticketNo = "${box1.text}${box2.text}${box3.text}${box4.text}${box5.text}".trim();
                                if (ticketNo.isEmpty || ticketNo.length < 20) {
                                  ShowToast.showToast(context, "Please enter ticket number", type: ToastType.ERROR);

                                } else {
                                  setState(() {
                                    mAnimatedButtonSize   = 50.0;
                                    mButtonTextVisibility = false;
                                    mButtonShrinkStatus   = ButtonShrinkStatus.notStarted;
                                  });
                                  _scanController.stop();
                                  BlocProvider.of<WinningClaimBloc>(context).add(
                                      TicketVerifyApi(
                                          context: context,
                                          ticketNumber: ticketNo,
                                          apiDetails: verifyTicketUrls
                                      )
                                  );
                                }
                              });
                            },
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
                                    child: CircularProgressIndicator(color: WlsPosColor.white),
                                  )
                                      : Center(child:
                                  Visibility(
                                    visible: mButtonTextVisibility,
                                    child: const Text("VERIFY",
                                      style: TextStyle(fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: WlsPosColor.white,
                                      ),
                                    ),
                                  ))
                              ),
                            ),
                          ),
                        ),
                        const HeightBox(20)
                      ],
                    )
                ),
                Visibility(
                  visible: isClaiming,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: WlsPosColor.black.withOpacity(0.7),
                    child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                            width: 70,
                            height: 70,
                            child: Lottie.asset('assets/lottie/gradient_loading.json'))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showErrorDialog(BuildContext context, String showErrorMsg) {
    return showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return Transform.scale(
            scale: curve,
            child: Dialog(
              elevation: 3.0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
              backgroundColor: WlsPosColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HeightBox(40),
                  Text(
                    "Ticket's status",
                    style: const TextStyle(
                        color: WlsPosColor.game_color_red,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  const HeightBox(20),
                  Center(child: Text(showErrorMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black)).pOnly(bottom: 10)),
                  InkWell(
                    onTap: () {
                      resetScanner();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: WlsPosColor.red
                      ),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "OK",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: WlsPosColor.white, fontSize: 18, fontWeight: FontWeight.bold),
                          )
                      ),
                    ),
                  ),
                  const HeightBox(20)
                ],
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400));
  }

  showConfirmDialog(BuildContext context, String? ticketNumber, double? winClaimAmount){
    return showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (BuildContext _,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return Transform.scale(
            scale: curve,
            child: Dialog(
                elevation: 30.0,
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HeightBox(40),
                          const Text(
                            "Success",
                            style: TextStyle(
                                color: WlsPosColor.shamrock_green,
                                fontSize: 20,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const HeightBox(20),
                          Column(
                            children: [
                              //const Text("You are claiming for following draws", style: TextStyle(color: WlsPosColor.game_color_blue, fontSize: 12)).pOnly(bottom: 8),


                              const Text("Ticket Number:", style: TextStyle(color: WlsPosColor.warm_grey_three, fontSize: 12)),
                              Text("$ticketNumber\n", style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),

                              const Text("Winning Amount:", style: TextStyle(color: WlsPosColor.warm_grey_three, fontSize: 12)),
                              Text("$winClaimAmount\n", style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),

                              /*Text("Tax Amount:", style: TextStyle(color: WlsPosColor.warm_grey_three, fontSize: 15, fontWeight: FontWeight.w500)),
                              Text("300\n", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),),*/
                            ],
                          ),
                          const HeightBox(10),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    resetUI();
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 1,color: Colors.red),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white
                                    ),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Cancel",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.red, fontSize: 18),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isClaiming = true;
                                    });
                                    _scanController.stop();
                                    Navigator.pop(context);
                                    BlocProvider.of<WinningClaimBloc>(context).add(
                                        ClaimWinPayPwtApi(
                                          context: context,
                                          apiDetails: winClaimUrls,
                                          request: ClaimWinPayPwtRequest(
                                              interfaceType: "WEB",
                                              merchantCode: "LotteryRMS",
                                              saleMerCode: "NDGE",
                                              sessionId: UserInfo.userToken,
                                              ticketNumber: ticketNo,
                                              userName: UserInfo.userName,
                                              verificationCode: "54564456415",
                                              termminalId: "NA",
                                              modelCode: "NA"
                                          ),
                                        )
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red
                                    ),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Claim",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white, fontSize: 18),
                                        )
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ).pOnly(top: 40),
                    Positioned.fill(
                      top: 10,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.white,
                          ),
                          child: SizedBox(width: 70, height: 70, child: Lottie.asset('assets/lottie/printing_success.json')),
                        ),
                      ),
                    )
                  ],
                )
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400));
  }

  resetLoader() {
    setState(() {
      mAnimatedButtonSize   = 280.0;
      mButtonTextVisibility = true;
      mButtonShrinkStatus   = ButtonShrinkStatus.over;
    });
  }

  void resetUI() {
    box1.clear();
    box2.clear();
    box3.clear();
    box4.clear();
    box5.clear();
    _scanController.start();
  }

  resetScanner() {
    _scanController.start();
  }

  void resetTextFields() {
    box1.clear();
    box2.clear();
    box3.clear();
    box4.clear();
    box5.clear();
  }

}
