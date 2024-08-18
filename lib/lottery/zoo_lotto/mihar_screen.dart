import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/betAmountBean.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/widgets/added_bet_cart_msg.dart';
import 'package:wls_pos/lottery/widgets/other_available_bet_amounts.dart';
import 'package:wls_pos/lottery/zoo_lotto/widgets/number_button.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

class MiharScreen extends StatefulWidget {
  final BetRespVOs? betData;
  final GameRespVOs? gameObjectsList;
  final List<PanelBean>? mPanelBinList;

  const MiharScreen(
      {Key? key, this.betData, this.gameObjectsList, this.mPanelBinList})
      : super(key: key);

  @override
  _MiharScreenState createState() => _MiharScreenState();
}

class _MiharScreenState extends State<MiharScreen> {
  var _numberForm = GlobalKey<FormState>();
  List<String> code = ['', '', '', ''];
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  String controllerNum1 = '';
  String controllerNum2 = '';
  String controllerNum3 = '';
  String controllerNum4 = '';
  SuperTooltip? tooltip;
  SuperTooltip? tooltip1;
  SuperTooltip? tooltip2;
  SuperTooltip? tooltip3;

  Map<String, bool> selectedBetAmountValue = {};
  bool isOtherAmountAvailable = false;
  List<FiveByNinetyBetAmountBean> listBetAmount = [];
  String selectedBetAmount = "0";
  String selectedMultipleBetAmount = "0";
  List<List<String>> gameNumberList = [];
  List<String> gameNameList = [];
  List<String> imageNameList = [];
  final FlipCardController _flipController = FlipCardController();
  String ballPickInstructions = "To play, Enter 4 digit of your choice";
  List<ZooPickDataList> pickDataList = [];
  List<ZooPickDataList> selectedPickDataList = [];
  ZooPickDataList? zooPickDataModelList;
  int selectedAnimalCount = 0;
  int selectedPickDataCount = 0;
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();

  String otherNumber = 'Other';

  @override
  void initState() {
    super.initState();
    setBetAmount();
    setInitialBetAmount();
    if (widget.betData!.pickTypeData!.pickType![0].code!
        .toUpperCase()
        .contains('TRIO FAMILIA')) {
      selectedAnimalCount = 3;
      setState(() {
        selectedPickDataCount = 0;
      });
    } else if (widget.betData!.pickTypeData!.pickType![0].code!
            .toUpperCase()
            .contains('QUADRA') ||
        widget.betData!.pickTypeData!.pickType![0].code!
            .toUpperCase()
            .contains('TRINCA')) {
      setState(() {
        selectedPickDataCount = 1;
      });
    } else {
      selectedAnimalCount = 1;
      setState(() {
        selectedPickDataCount = 0;
      });
    }
    getGameList(widget.gameObjectsList!.numberConfig!.range![2].ball!);
    _controller.text = (widget.betData!.pickTypeData!.pickType![0].code!
                    .toUpperCase() ==
                'TRINCA' ||
            widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() ==
                'TRINCA 1-5')
        ? 'X'
        : '';
    if (widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() ==
            'TRINCA' ||
        widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() ==
            'TRINCA 1-5') {
      ballPickInstructions = "To play, Enter 3 digit of your choice";
    } else if (widget.betData!.pickTypeData!.pickType![0].code!
        .toUpperCase()
        .contains("QUADRA")) {
      ballPickInstructions = "To play, Enter 4 digit of your choice";
    } else if (widget.betData!.pickTypeData!.pickType![0].code!
        .toUpperCase()
        .contains('TRIO FAMILIA')) {
      ballPickInstructions = "To play, Select 3 option of your choice";
    } else {
      ballPickInstructions = "To play, Select 1 option of your choice";
    }
    focusNodes = List.generate(4, (index) => FocusNode());
    controllers = List.generate(4, (index) {
      final ctrl = TextEditingController();
      ctrl.value;
      return ctrl;
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // give the focus to the first node.
      focusNodes[0].requestFocus();
    });

    tooltip = SuperTooltip(
      popupDirection: TooltipDirection.down,
      content: Container(
        alignment: Alignment.center,
        height: 160,
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '1',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: '2',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: '3',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '4',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: '5',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: '6',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '7',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: '8',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: '9',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '0',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip);
                    }),
                NumberButton(
                    number: 'CLEAR',
                    widthsize: 80,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller,
                    numberClick: (value) {
                      controllerNum1 = value;
                      {
                        if (_flipController.state?.isFront == false) {
                          _flipController.state?.toggleCard();
                        }
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );

    tooltip1 = SuperTooltip(
      popupDirection: TooltipDirection.down,
      content: Container(
        alignment: Alignment.center,
        height: 160,
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '1',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }

                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: '2',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: '3',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '4',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: '5',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: '6',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '7',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: '8',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: '9',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '0',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip1);
                    }),
                NumberButton(
                    number: 'CLEAR',
                    widthsize: 80,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller1,
                    numberClick: (value) {
                      controllerNum2 = value;
                      if (_flipController.state?.isFront == false) {
                        _flipController.state?.toggleCard();
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );

    tooltip2 = SuperTooltip(
      popupDirection: TooltipDirection.down,
      content: Container(
        alignment: Alignment.center,
        height: 160,
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '1',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: '2',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: '3',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '4',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: '5',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: '6',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '7',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: '8',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: '9',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '0',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip2);
                    }),
                NumberButton(
                    number: 'CLEAR',
                    widthsize: 80,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller2,
                    numberClick: (value) {
                      controllerNum3 = value;
                      if (_flipController.state?.isFront == false) {
                        _flipController.state?.toggleCard();
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );

    tooltip3 = SuperTooltip(
      popupDirection: TooltipDirection.down,
      content: Container(
        alignment: Alignment.center,
        height: 160,
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '1',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }

                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: '2',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: '3',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '4',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: '5',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: '6',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '7',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: '8',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: '9',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberButton(
                    number: '0',
                    widthsize: 40,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      String numLength = controllerNum1 +
                          controllerNum2 +
                          controllerNum3 +
                          controllerNum4;
                      if (numLength.length == 4) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      } else if ((widget
                                      .betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA' ||
                              widget.betData!.pickTypeData!.pickType![0].code!
                                      .toUpperCase() ==
                                  'TRINCA 1-5') &&
                          numLength.length == 3) {
                        if (_flipController.state?.isFront == true) {
                          _flipController.state?.toggleCard();
                        }
                      }
                      updateToolTip(tooltip3);
                    }),
                NumberButton(
                    number: 'CLEAR',
                    widthsize: 80,
                    heightsize: 40,
                    color: WlsPosColor.white,
                    controller: _controller3,
                    numberClick: (value) {
                      controllerNum4 = value;
                      if (_flipController.state?.isFront == false) {
                        _flipController.state?.toggleCard();
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    focusNodes.forEach((focusNode) {
      focusNode.dispose();
    });
    controllers.forEach((controller) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return SafeArea(
      top: true,
      bottom: true,
      left: false,
      right: false,
      child: WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        backgroundColor: WlsPosColor.light_dark_white,
        onBackButton: (widget.mPanelBinList == null ||
                widget.mPanelBinList?.isEmpty == true)
            ? null
            : () {
                AddedBetCartMsg().show(
                    context: context,
                    title: "Bet on cart !",
                    subTitle:
                        "You have some item in your cart. If you leave the game your cart will be cleared.",
                    buttonText: "CLEAR",
                    isCloseButton: true,
                    buttonClick: () {
                      widget.mPanelBinList!.clear();
                      Navigator.of(context).pop();
                    });
              },
        appBarTitle: Text(widget.betData!.betDispName!.toUpperCase(),
            style: const TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: widget.betData!.betCode!.contains('Groupo')
                        ? GridView.builder(
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: isLandscape ? 1.5 : 0.65,
                          crossAxisCount: isLandscape ? 5 : 3,
                        ),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: pickDataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Ink(
                            decoration: BoxDecoration(
                              color: WlsPosColor.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: pickDataList[index].isSelected!
                                      ? WlsPosColor.zoo_game_color_green
                                      : WlsPosColor.black,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                _changeSelection(
                                    enable: !(pickDataList[index].isSelected!),
                                    index: index);
                              },
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Ink(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 2, right: 2),
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: pickDataList[
                                                  index]
                                                      .isSelected!
                                                      ? WlsPosColor
                                                      .zoo_game_color_green
                                                      : WlsPosColor.white,
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(50)),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: pickDataList[
                                                    index]
                                                        .isSelected!
                                                        ? WlsPosColor
                                                        .zoo_game_color_green
                                                        : WlsPosColor.black,
                                                  ),
                                                ),
                                                child: Text(
                                                    getNameAndNumber(
                                                        pickDataList[index]
                                                            .gameNameList![0],
                                                        'number'),
                                                    style: TextStyle(
                                                        color: pickDataList[index]
                                                            .isSelected!
                                                            ? WlsPosColor.white
                                                            : WlsPosColor.black)),
                                              ),
                                              Text(
                                                  getNameAndNumber(
                                                      pickDataList[index]
                                                          .gameNameList![0],
                                                      'name'),
                                                  style: TextStyle(
                                                      color: pickDataList[index]
                                                          .isSelected!
                                                          ? WlsPosColor
                                                          .zoo_game_color_green
                                                          : WlsPosColor.black,
                                                      fontWeight:
                                                      FontWeight.bold))
                                            ],
                                          ),
                                          pickDataList[index].isSelected!
                                              ? Container(
                                            margin: EdgeInsets.only(
                                                left: 2, right: 2),
                                            decoration: BoxDecoration(
                                              color: WlsPosColor
                                                  .zoo_game_color_green,
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(50)),
                                              border: Border.all(
                                                  width: 1,
                                                  color: WlsPosColor
                                                      .zoo_game_color_green),
                                            ),
                                            child: SvgPicture.asset(
                                                'assets/icons/check.svg',
                                                color: WlsPosColor.white,
                                                width: 15,
                                                height: 15),
                                          )
                                              : const SizedBox(),
                                        ],
                                      ).py8(),
                                    ),
                                    Image.asset(
                                      width: 100,
                                      height: 100,
                                      'assets/images/animals/${imageNameList[index]}.jpg',
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 100,
                                          width: 100,
                                          alignment: Alignment.center,
                                          child: Text('Image Error!',
                                              style: TextStyle(
                                                  color: WlsPosColor.red)),
                                        );
                                      },
                                      // homeModuleCodesList.contains(
                                      //     homeModuleList[index]?[0]
                                      //         .moduleCode)
                                      //     ? "assets/icons/${homeModuleList[index]?[0].moduleCode}.png"
                                      //     : "assets/images/splash_logo.png"
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 30,
                                        width: context.screenWidth,
                                        alignment: Alignment.center,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                            NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: pickDataList[index]
                                                .gameNumberList![0]
                                                .length,
                                            itemBuilder: (context, i) {
                                              return Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                        pickDataList[index]
                                                            .gameNumberList![
                                                        0][i],
                                                        // gameNumberList[index][i],
                                                        style: const TextStyle(
                                                            color:
                                                            WlsPosColor.black,
                                                            fontWeight:
                                                            FontWeight.bold)),
                                                    i == 3
                                                        ? SizedBox()
                                                        : Container(
                                                      margin:
                                                      EdgeInsets.only(
                                                          left: 2,
                                                          right: 2),
                                                      height: 10,
                                                      width: 1,
                                                      color: WlsPosColor
                                                          .light_grey,
                                                    )
                                                  ]).pOnly(left: 2, right: 2);
                                            }),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ).p(6);
                        })
                        : Form(
                        key: _numberForm,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(
                                builder: (childContext) => Container(
                                  width: 60,
                                  height: customKeyboardTopPadding + 60,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    focusNode: focusNode1,
                                    autofocus: (widget.betData!.pickTypeData!
                                        .pickType![0].code!
                                        .toUpperCase() == 'TRINCA' ||
                                        widget.betData!.pickTypeData!
                                            .pickType![0].code!
                                            .toUpperCase() == 'TRINCA 1-5')
                                        ? false
                                        : true,
                                    // showCursor: (widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() == 'TRINCA' ||
                                    //     widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() == 'TRINCA 1-5')
                                    //     ? false
                                    //     : true,
                        showCursor: false,
                                    controller: _controller,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    cursorColor: WlsPosColor.black,
                                    onTap: () {
                                      (widget.betData!.pickTypeData!
                                          .pickType![0].code!
                                          .toUpperCase() == 'TRINCA' ||
                                          widget.betData!.pickTypeData!
                                              .pickType![0].code!
                                              .toUpperCase() == 'TRINCA 1-5')
                                          ? null
                                          : tooltip!.show(childContext);
                                    },
                                    style: TextStyle(
                                        color: (widget.betData!.pickTypeData!
                                            .pickType![0].code!
                                            .toUpperCase() == 'TRINCA' ||
                                            widget.betData!.pickTypeData!
                                                .pickType![0].code!
                                                .toUpperCase() == 'TRINCA 1-5')
                                            ? WlsPosColor.black_four
                                            .withOpacity(0.5)
                                            : WlsPosColor.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: (widget.betData!.pickTypeData!
                                                .pickType![0].code!
                                                .toUpperCase() == 'TRINCA' ||
                                                widget.betData!.pickTypeData!
                                                    .pickType![0].code!
                                                    .toUpperCase() == 'TRINCA 1-5')
                                                ? WlsPosColor.light_grey
                                                : WlsPosColor.black_four),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ).pOnly(bottom: customKeyboardTopPadding),
                                ),
                              ),
                              Builder(
                                builder: (childContext) => Container(
                                  width: 60,
                                  height: customKeyboardTopPadding + 60,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    autofocus: true,
                                    showCursor: false,
                                    focusNode: focusNode2,
                                    controller: _controller1,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    cursorColor: WlsPosColor.light_grey,
                                    onTap: () {
                                      tooltip1!.show(childContext);
                                    },
                                    style: TextStyle(color: WlsPosColor.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.black_four),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    validator: (inputValue) {
                                      if (inputValue!.isEmpty) {
                                        return "Please enter number";
                                      }
                                      return null;
                                    },
                                  ).pOnly(bottom: customKeyboardTopPadding),
                                ),
                              ),
                              Builder(
                                builder: (childContext) => Container(
                                  width: 60,
                                  height: customKeyboardTopPadding + 60,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    autofocus: true,
                                    showCursor: false,
                                    focusNode: focusNode3,
                                    controller: _controller2,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    cursorColor: WlsPosColor.light_grey,
                                    onTap: () {
                                      tooltip2!.show(childContext);
                                    },
                                    style: TextStyle(color: WlsPosColor.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.black_four),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    validator: (inputValue) {
                                      if (inputValue!.isEmpty) {
                                        return "Please enter number";
                                      }
                                      return null;
                                    },
                                  ).pOnly(bottom: customKeyboardTopPadding),
                                ),
                              ),
                              Builder(
                                builder: (childContext) => Container(
                                  width: 60,
                                  height: customKeyboardTopPadding + 60,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    autofocus: true,
                                    showCursor: false,
                                    focusNode: focusNode4,
                                    controller: _controller3,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    cursorColor: WlsPosColor.light_grey,
                                    onTap: () {
                                      tooltip3!.show(childContext);
                                    },
                                    style: TextStyle(color: WlsPosColor.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.light_grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: WlsPosColor.black_four),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    validator: (inputValue) {
                                      if (inputValue!.isEmpty) {
                                        return "Please enter number";
                                      }
                                      return null;
                                    },
                                  ).pOnly(bottom: customKeyboardTopPadding),
                                ),
                              ),
                            ],
                          ).pOnly(left: 60, right: 60, top: 40, bottom: 10),
                        )),
                  ),
                  Container(
                    color: WlsPosColor.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MySeparator(width: 3),
                        listBetAmount.isNotEmpty
                            ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "Bet Amount (${getDefaultCurrency(getLanguage())})",
                                        style: const TextStyle(
                                            color: WlsPosColor.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)))
                                .pOnly(top: 10, bottom: 2)
                            : Container(),
                        listBetAmount.isNotEmpty
                            ? Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: SizedBox(
                                      height: 40,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          // itemCount: listBetAmount.length,
                                          itemCount: 5,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                if (listBetAmount[index]
                                                        .amount !=
                                                    null) {
                                                  setSelectedBetAmountForHighlighting(
                                                      index);
                                                  selectedBetAmountValue
                                                      .clear();
                                                  setState(() {
                                                    selectedBetAmountValue[
                                                        listBetAmount[index]
                                                            .amount
                                                            .toString()] = true;
                                                    selectedBetAmount =
                                                        listBetAmount[index]
                                                            .amount
                                                            .toString();
                                                  });
                                                  onBetAmountClick(
                                                      listBetAmount[index]
                                                          .amount!);
                                                }
                                              },
                                              customBorder:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Container(
                                                width: 50,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: selectedBetAmountValue[
                                                                "${listBetAmount[index].amount}"] ==
                                                            true
                                                        ? WlsPosColor.red
                                                        : WlsPosColor.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(6)),
                                                    border: Border.all(
                                                        color: WlsPosColor
                                                            .game_color_red)),
                                                child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            "${listBetAmount[index].amount}",
                                                            style: TextStyle(
                                                                color: selectedBetAmountValue[
                                                                            "${listBetAmount[index].amount}"] ==
                                                                        true
                                                                    ? WlsPosColor
                                                                        .white
                                                                    : WlsPosColor
                                                                        .game_color_red,
                                                                fontSize: 10)))
                                                    .p(4),
                                              ),
                                            ).p(2);
                                          }),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      isOtherAmountAvailable = true;
                                      if (isOtherAmountAvailable) {
                                        OtherAvailableBetAmountAlertDialog()
                                            .show(
                                                context: context,
                                                title:
                                                    "Select Amount (${getDefaultCurrency(getLanguage())})",
                                                buttonText: "Select",
                                                isCloseButton: true,
                                                listOfAmounts: listBetAmount,
                                                buttonClick:
                                                    (selectedBetAmountNumber) {
                                                  setState(() {
                                                    selectedBetAmountValue
                                                        .clear();
                                                    selectedBetAmountValue[
                                                            "$selectedBetAmountNumber"] =
                                                        true;
                                                    selectedBetAmount =
                                                        selectedBetAmountNumber
                                                            .toString();
                                                  });
                                                  onBetAmountClick(
                                                      selectedBetAmountNumber);
                                                  otherNumber =
                                                      selectedBetAmountNumber >
                                                              5
                                                          ? selectedBetAmountNumber
                                                              .toString()
                                                          : "Other";
                                                });
                                      }
                                    },
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      decoration: BoxDecoration(
                                          color: otherNumber == "Other"
                                              ? WlsPosColor.white
                                              : WlsPosColor.game_color_red,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(6)),
                                          border: Border.all(
                                              color:
                                                  WlsPosColor.game_color_red)),
                                      child: Stack(
                                        children: [
                                          Align(
                                              alignment: Alignment.center,
                                              child: Text(otherNumber,
                                                      style: TextStyle(
                                                          color: otherNumber ==
                                                                  "Other"
                                                              ? WlsPosColor
                                                                  .game_color_red
                                                              : WlsPosColor
                                                                  .white,
                                                          fontSize: 14))
                                                  .pOnly(top: 5, bottom: 10)),
                                          Align(
                                              alignment: Alignment.bottomRight,
                                              child: SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child: Lottie.asset(
                                                      'assets/lottie/tap.json'))),
                                        ],
                                      ),
                                    ),
                                  ).p(2)
                                ],
                              )
                            : Container(),
                        // listBetAmount.isNotEmpty
                        //     ? const HeightBox(50)
                        //     : Container()
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FlipCard(
                controller: _flipController,
                flipOnTouch: false,
                fill: Fill.fillBack,
                // Fill the back side of the card to make in the same size as the front.
                direction: FlipDirection.VERTICAL,
                // default
                side: CardSide.FRONT,
                // The side to initially display.
                front: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: WlsPosColor.ball_border_light_bg,
                  child: Center(
                      child: Text(ballPickInstructions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: WlsPosColor.game_color_grey,
                              fontSize: 14))),
                ),
                back: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: WlsPosColor.ball_border_light_bg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              reset();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/icons/reset.svg',
                                        width: 16,
                                        height: 16,
                                        color: WlsPosColor.game_color_red)
                                    .pOnly(bottom: 2),
                                const Align(
                                    alignment: Alignment.center,
                                    child: Text("Reset",
                                        style: TextStyle(
                                            color: WlsPosColor.game_color_grey,
                                            fontSize: 12))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Text(selectedPickDataCount.toString(),
                                    // selectedAnimalCount.toString(),
                                    style: const TextStyle(
                                        color: WlsPosColor.game_color_red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            Align(
                                alignment: Alignment.center,
                                child: Text("No. Selected",
                                    style: const TextStyle(
                                        color: WlsPosColor.game_color_grey,
                                        fontSize: 12))),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Text(getBetValue(),
                                    style: const TextStyle(
                                        color: WlsPosColor.game_color_red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            Align(
                                alignment: Alignment.center,
                                child: Text(
                                    "Bet Value (${getDefaultCurrency(getLanguage())})",
                                    style: const TextStyle(
                                        color: WlsPosColor.game_color_grey,
                                        fontSize: 12))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              addBet();
                            },
                            child: Ink(
                              color: WlsPosColor.game_color_red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/icons/plus.svg',
                                      width: 16,
                                      height: 16,
                                      color: WlsPosColor.white),
                                  const Align(
                                          alignment: Alignment.center,
                                          child: Text("ADD BET",
                                              style: TextStyle(
                                                  color: WlsPosColor.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)))
                                      .pOnly(left: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  onBetAmountClick(int amount) {
    if (selectedAnimalCount > 0) {
      selectedPickDataList.clear();
      for (int i = 0; i < pickDataList.length; i++) {
        if (pickDataList[i].isSelected!) {
          pickDataList[i].amount = amount.toString();
          selectedPickDataList.add(pickDataList[i]);
          setState(() {
            selectedMultipleBetAmount = amount.toString();
            selectedBetAmount = amount.toString();
            // (int.parse(amount.toString()) * selectedPickDataCount)
            //     .toString();
          });
        }
      }
    } else {
      setState(() {
        selectedBetAmount = amount.toString();
        selectedMultipleBetAmount = amount.toString();
      });
    }
    // betValueCalculation(mRangeObjectIndex);
  }

  void getGameList(List<Ball> list) {
    List<String> configNumber = [];
    list.forEachIndexed((index, element) {
      configNumber.add(element.number!);
      if ((++index) % 4 == 0) {
        zooPickDataModelList = ZooPickDataList();
        gameNumberList.add(configNumber);
        gameNameList.add(element.label!);

        zooPickDataModelList!.isSelected = false;
        zooPickDataModelList!.amount = selectedBetAmount;
        zooPickDataModelList!.gameNumberList = gameNumberList;
        zooPickDataModelList!.gameNameList = gameNameList;
        zooPickDataModelList!.imageNameList = [];
        pickDataList.add(zooPickDataModelList!);

        configNumber = [];
        gameNumberList = [];
        gameNameList = [];
      }
    });
  }

  String getNameAndNumber(String gameNameList, String type) {
    if (type == 'name')
      imageNameList
          .add(gameNameList.split(',')[1] + gameNameList.split(',')[0]);
    return type == 'name'
        ? gameNameList.split(',')[0]
        : gameNameList.split(',')[1];
  }

  setBetAmount() {
    double unitPrice = widget.betData!.unitPrice ?? 1.0;
    int maxBetAmtMul = widget.betData!.maxBetAmtMul ?? 0;
    int count = maxBetAmtMul ~/ unitPrice;
    // int count = 5;
    for (int index = 1; index <= count; index++) {
      int amount = (index * 1).toInt();
      FiveByNinetyBetAmountBean model = FiveByNinetyBetAmountBean();
      model.amount = amount;
      model.isSelected = false;
      listBetAmount.add(model);
    }

    if (listBetAmount.isNotEmpty) {
      setSelectedBetAmountForHighlighting(0);
      // int amtListLength = listBetAmount.length;
      // int amtListHalfLength = amtListLength ~/ 2;
      setState(() {
        // listBetAmountLength = amtListLength > 5 ? amtListHalfLength : amtListLength;

        if (listBetAmount.length > 5) {
          isOtherAmountAvailable = true;
        } else if (listBetAmount.length == 5) {
          isOtherAmountAvailable = false;
        } else if (listBetAmount.length == 4) {
          isOtherAmountAvailable = false;
        } else if (listBetAmount.length == 3) {
          isOtherAmountAvailable = false;
        } else if (listBetAmount.length == 2) {
          isOtherAmountAvailable = false;
        } else if (listBetAmount.length == 1) {
          isOtherAmountAvailable = false;
        }
      });
    }
  }

  setInitialBetAmount() {
    if (listBetAmount.isNotEmpty) {
      selectedBetAmount = "${listBetAmount[0].amount ?? 0}";
      selectedMultipleBetAmount = "${listBetAmount[0].amount ?? 0}";
      selectedBetAmountValue[listBetAmount[0].amount.toString()] = true;
    } else {
      selectedBetAmount = "0";
      selectedMultipleBetAmount = "0";
    }
  }

  setSelectedBetAmountForHighlighting(int position) {
    if (listBetAmount.isNotEmpty) {
      for (int index = 0; index < listBetAmount.length; index++) {
        listBetAmount[index].isSelected = position == index;
      }
    }
  }

  void reset() {
    selectedBetAmountValue.clear();
    selectedPickDataList.clear();
    selectedPickDataCount = 0;
    for (var data in pickDataList) {
      data.isSelected = false;
    }
    setInitialBetAmount();
    setState(() {
      _controller1.clear();
      _controller2.clear();
      _controller3.clear();
      controllerNum1 = '';
      controllerNum2 = '';
      controllerNum3 = '';
      controllerNum4 = '';
      otherNumber = "Other";
    });
    if ((widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() ==
            'TRINCA' ||
        widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase() ==
            'TRINCA 1-5')) {
      focusNode2.requestFocus();
    } else {
      focusNode1.requestFocus();
      _controller.clear();
    }

    if (_flipController.state?.isFront == false) {
      _flipController.state?.toggleCard();
    }
  }

  addBet() {
    PanelBean model = PanelBean();
    model.gameName = widget.betData!.pickTypeData!.pickType![0].name;
    model.betCode = widget.betData!.betCode;
    model.pickCode = widget.betData!.pickTypeData!.pickType![0].code;
    // model.pickConfig = widget.betData!.pickTypeData!.pickType![0].range![0].pickConfig;
    model.pickConfig = widget.betData!.betCode!.contains('Groupo')
        ? widget.betData!.pickTypeData!.pickType![0].range![0].pickConfig
        : "Number";
    // model.betAmountMultiple = int.parse(selectedBetAmount);
    model.betAmountMultiple = int.parse(selectedBetAmount);
    model.betAmountMultipleNumber = int.parse(selectedBetAmount);
    model.amount = double.tryParse(selectedBetAmount);
    model.isQuickPick = false;
    model.pickedValue = widget.betData!.betCode!.contains('Groupo')
        ? getPickedValue(selectedPickDataList)
        : getPickedMilharValues(
            widget.betData!.pickTypeData!.pickType![0].code!.toUpperCase());
    model.isQpPreGenerated = false;
    model.numberOfDraws = 1;
    model.selectedPickDataList = selectedPickDataList;
    widget.mPanelBinList!.add(model);
    Navigator.pushReplacementNamed(context, WlsPosScreen.zooLottoGameScreen,
        arguments: {
          "gameObjectsList": widget.gameObjectsList,
          "listPanelData": widget.mPanelBinList,
        });
  }

  void _changeSelection({required bool enable, required int index}) {
    if (enable) {
      if (selectedPickDataCount < selectedAnimalCount) {
        selectedPickDataList.add(pickDataList[index]);
        selectedPickDataCount++;
        setState(() {
          pickDataList[index].isSelected = enable;
          pickDataList[index].amount = selectedMultipleBetAmount;
          selectedBetAmount = selectedMultipleBetAmount;
          // selectedBetAmount = (int.parse(selectedMultipleBetAmount) *
          //         selectedPickDataCount)
          //     .toString();
        });
        if (selectedPickDataCount == selectedAnimalCount) {
          if (_flipController.state?.isFront == true) {
            _flipController.state?.toggleCard();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
              "You can't choose more than ${selectedAnimalCount} animals! "),
        ));
      }
    } else {
      selectedPickDataList.remove(pickDataList[index]);
      selectedPickDataCount--;
      if (selectedPickDataCount < selectedAnimalCount) {
        if (_flipController.state?.isFront == false) {
          _flipController.state?.toggleCard();
        }
      }
      setState(() {
        pickDataList[index].isSelected = enable;
        pickDataList[index].amount = selectedMultipleBetAmount;
        selectedBetAmount = selectedMultipleBetAmount;
        // selectedBetAmount =
        //     (int.parse(selectedMultipleBetAmount) * selectedPickDataCount)
        //         .toString();
      });
    }
  }

  String getPickedValue(List<ZooPickDataList> selectedPickDataList) {
    String pickedTypeValues = '';
    String preValue = '-1#-1#';

    for (int i = 0; i < selectedPickDataList.length; i++) {
      if (i == 0)
        pickedTypeValues =
            preValue + (selectedPickDataList[i].gameNameList![0]).split(',')[1];
      else
        pickedTypeValues = pickedTypeValues +
            ',' +
            preValue +
            (selectedPickDataList[i].gameNameList![0]).split(',')[1];
    }
    return pickedTypeValues;
  }

  getPickedMilharValues(String gameCodeName) {
    String? pickValue;
    if (gameCodeName == "TRINCA" || gameCodeName == 'TRINCA 1-5') {
      pickValue =
          '-1' + '#' + controllerNum2 + '#' + controllerNum3 + controllerNum4;
    } else {
      pickValue = controllerNum1 +
          '#' +
          controllerNum2 +
          '#' +
          controllerNum3 +
          controllerNum4;
    }
    return pickValue;
  }

  String getBetValue() {
    // String betValue = '1';
    // if(selectedPickDataCount > 0)
    // betValue = (int.parse(selectedBetAmount) * selectedPickDataCount).toString();
    return selectedBetAmount;
  }

  void updateToolTip(SuperTooltip? _tooltip) {
    _tooltip?.close();
  }
}

class ZooPickDataList {
  String? amount;
  bool? isSelected;
  List<List<String>>? gameNumberList;
  List<String>? gameNameList;
  List<String>? imageNameList;

  ZooPickDataList({
    this.isSelected,
    this.gameNameList,
    this.gameNumberList,
    this.imageNameList,
    this.amount,
  });

  ZooPickDataList.fromJson(Map<String, dynamic> json) {
    isSelected = json['isSelected'];
    gameNameList = json['gameNameList'];
    gameNumberList = json['gameNumberList'];
    imageNameList = json['imageNameList'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isSelected'] = this.isSelected;
    data['gameNameList'] = this.gameNameList;
    data['gameNumberList'] = this.gameNumberList;
    data['imageNameList'] = this.imageNameList;
    data['amount'] = this.amount;
    return data;
  }
}
