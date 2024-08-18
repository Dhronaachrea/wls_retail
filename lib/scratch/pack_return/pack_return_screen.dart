import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan/scan.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_bloc.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_event.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_state.dart';
import 'package:wls_pos/scratch/pack_return/model/pack_return_note_request.dart';
import 'package:wls_pos/scratch/pack_return/model/pack_return_note_response.dart';
import 'package:wls_pos/scratch/pack_return/model/response/game_vise_inventory_response.dart';
import 'package:wls_pos/scratch/pack_return/widget/select_book.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/scanner_error.dart';
import 'package:wls_pos/utility/widgets/shake_animation.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/widgets/wls_pos_text_field_underline.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import 'model/bookSelectionDetailModel.dart';
import 'model/book_and_pack_model.dart';
import 'model/request/game_vise_inventory_request.dart';
import 'model/request/pack_return_submit_request.dart';
import 'model/response/pack_return_submit_response.dart';

class PackReturnScreen extends StatefulWidget {
  final MenuBeanList? scratchList;

  const PackReturnScreen({Key? key, required this.scratchList}) : super(key: key);

  @override
  State<PackReturnScreen> createState() => _PackReturnScreenState();
}

class _PackReturnScreenState extends State<PackReturnScreen> {

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
    PackReturnNoteResponse? packReturnNoteResponse;
  GameViseInventoryResponse? gameViseInventoryResponse;
  int selectedNumbersOfBook = 0;
  int maxSelectNumbersOfBook = 0;
  List<BookAndPackModel>? selectedBookAndPack;

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
      appBarTitle: Text( widget.scratchList?.caption ?? "Pack Return"),
      body: BlocListener<PackBloc, PackState>(
        listener: (context, state) {
          if (state is PackLoading) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is PackReturnNoteSuccess) {
            PackReturnNoteResponse response = state.response;
            packReturnNoteResponse = response;
            log("pack return note success: ${jsonEncode(response)}");
            //packReturnNoteResponse?.games?.forEach((element) { maxSelectedBookAndTicketNumber = maxSelectedBookAndTicketNumber + (element.booksQuantity ?? 0);});
            packReturnNoteResponse?.games?.forEach((element) {maxSelectNumbersOfBook = maxSelectNumbersOfBook + ( element.booksQuantity ?? 0);});

            setState(() {
              isLoading = false;
              mAnimatedButtonSize = 280.0;
              mButtonTextVisibility = true;
              mButtonShrinkStatus = ButtonShrinkStatus.over;
            });
          }
          if (state is PackError) {
            setState(() {
              isLoading = false;
              mAnimatedButtonSize = 280.0;
              mButtonTextVisibility = true;
              mButtonShrinkStatus = ButtonShrinkStatus.over;
              barCodeController.clear();
              packReturnNoteResponse = null;
              gameViseInventoryResponse = null;
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
          if (state is GameViseInventorySuccess) {
            GameViseInventoryResponse response = state.response;
           gameViseInventoryResponse = response;
            String trimmedChallanNumber = barCodeController.text.trim();
            var requestData = PackReturnNoteRequest(
                dlChallanNumber: trimmedChallanNumber,
                userName: UserInfo.userName,
                userSessionId: UserInfo.userToken);

            BlocProvider.of<PackBloc>(context).add(PackReturnNoteApi(
              context: context,
              scratchList: widget.scratchList,
              requestData: requestData,
            ));
          }
          if (state is PackReturnSubmitSuccess) {
            PackReturnSubmitResponse packReturnSubmitResponse = state.response;
            setState(() {
              isLoading = false;
              mAnimatedButtonSize = 280.0;
              mButtonTextVisibility = true;
              mButtonShrinkStatus = ButtonShrinkStatus.over;
              packReturnNoteResponse = null;
              gameViseInventoryResponse = null;
            });
            Alert.show(
              type: AlertType.success,
              isDarkThemeOn: false,
              buttonClick: () {
                Navigator.of(context).pop();
              },
              title: "Success!",
              subtitle: packReturnSubmitResponse.responseCode == 1000
                  ? "Book Returned Successfully"
                  : packReturnSubmitResponse.responseMessage ?? "Success",
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
                packReturnNoteResponse != null &&
                        gameViseInventoryResponse != null
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                              "$selectedNumbersOfBook book selected out of $maxSelectNumbersOfBook",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: WlsPosColor.tomato,
                              )),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedNumbersOfBook = 0;
                                selectedBookAndPack = null;
                              });

                              List<GameDetails> gameDetailsList = gameViseInventoryResponse?.inventoryResponse?.gameDetails ?? [];
                              List<String> bookList = [];
                              List<BookSelectionDetailModel>?  bookSelectionDetailModel = [];
                              List<TotalBook>?  totalBooks = [];
                              for(GameDetails gameDetail in gameDetailsList) {
                                bookList.addAll(gameDetail.bookList ?? []);
                                for(String books in bookList) {
                                  bookSelectionDetailModel?.add(BookSelectionDetailModel(bookNumber: books, isSelected: false));
                                }
                                totalBooks.add(TotalBook(bookDetailsData: bookSelectionDetailModel, gameId: gameDetail.gameId));
                                bookSelectionDetailModel = [];
                                bookList = [];
                              }

                              List<Games>? gameList =  packReturnNoteResponse?.games ?? [];
                              for(int i =0 ; i< totalBooks.length;i++){
                                List<Games> gameListObjectList = gameList.where((element) => element.gameId == totalBooks[i].gameId).toList();
                                if(gameListObjectList.isNotEmpty) {
                                  totalBooks[i].bookQuantity = gameListObjectList[0].booksQuantity;
                                }
                              }

                              SelectBook().show(
                                context: context,
                                  title: "Book To Return",
                                  buttonText: "OK",
                                  totalBook : totalBooks,
                                  buttonClick: (List<BookAndPackModel> returnedSelectedBookAndPack ) {
                                  log("data : ${jsonEncode(returnedSelectedBookAndPack)}");
                                setState(() {
                                  selectedBookAndPack = returnedSelectedBookAndPack;
                                  for (var element in returnedSelectedBookAndPack) {
                                    if(element.bookList != null && element.bookList!.isNotEmpty){
                                      selectedNumbersOfBook = selectedNumbersOfBook + element.bookList!.length;
                                    }
                                  }
                                });
                              },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(
                                      color: WlsPosColor.ball_border_bg,
                                      width: 1)),
                              child: const Center(
                                child: Text(
                                  "View Books",
                                  style: TextStyle(
                                    color: WlsPosColor.tomato,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).pSymmetric(h: 20, v: 10)
                    : Container(),
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
                        print("Something Went wrong with bar code: $e");
                      }
                    },
                  ),
                  // ScanView(
                  //   controller: _scanController,
                  //   scanAreaScale: .7,
                  //   scanLineColor: WlsPosColor.tomato,
                  //   onCapture: (data) {
                  //     setState(() {
                  //       barCodeController.text = data;
                  //     });
                  //   },
                  // ),
                ),
                packReturnNoteResponse != null &&
                    gameViseInventoryResponse != null ? _returnButton() : _submitButton(),
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
          maxLength: 17,
          inputType: TextInputType.text,
          hintText: "Return Note",
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
        ).p20());
  }

  String validateInput(TotalTextFields textField) {
    switch (textField) {
      case TotalTextFields.userName:
        var mobText = barCodeController.text.trim();
        if (mobText.isEmpty) {
          return "Please Enter Ticket Number";
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
          var requestData = GameViseInventoryRequest(
              //dlChallanNumber: barCodeController.text,
              userName: UserInfo.userName,
              userSessionId: UserInfo.userToken);

          BlocProvider.of<PackBloc>(context).add(GameViseInventoryApi(
            context: context,
            scratchList: widget.scratchList,
            requestData: requestData,
          ));
        } else {
          setState(() {
            autoValidate = AutovalidateMode.onUserInteraction;
          });
        }
      },
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
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

  _returnButton() {
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
        if (selectedBookAndPack != null) {
          setState(() {
            mAnimatedButtonSize = 50.0;
            mButtonTextVisibility = false;
            mButtonShrinkStatus = ButtonShrinkStatus.notStarted;
          });
          String trimmedChallanNumber = barCodeController.text.trim();
          var requestData = PackReturnSubmitRequest(
            dlChallanNumber: trimmedChallanNumber,
            userName: UserInfo.userName,
            userSessionId: UserInfo.userToken,
            packsToReturn: selectedBookAndPack,
          );
          BlocProvider.of<PackBloc>(context).add(PackReturnSubmitApi(
            context: context,
            scratchList: widget.scratchList,
            requestData: requestData,
          ));
        } else {
          setState(() {
            autoValidate = AutovalidateMode.onUserInteraction;
          });
        }
      },
      child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                WlsPosColor.tomato,
                WlsPosColor.tomato,
              ]),
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
                        "Return Book",
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
