import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/balance_invoice_report/balance_invoice_report_screen.dart';
import 'package:wls_pos/balance_invoice_report/bloc/balance_invoice_report_bloc.dart';
import 'package:wls_pos/change_pin/bloc/change_pin_bloc.dart';
import 'package:wls_pos/diposit_withdrawal/bloc/depwith_bloc.dart';
import 'package:wls_pos/diposit_withdrawal/deposit_withdrawal_screen.dart';
import 'package:wls_pos/game_result/bloc/game_result_bloc.dart';
import 'package:wls_pos/game_result/game_result_details_screen.dart';
import 'package:wls_pos/game_result/game_result_screen.dart';
import 'package:wls_pos/game_result/models/response/gameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/pick4GameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/soccerGameResultApiResponse.dart';
import 'package:wls_pos/game_result/pick4_game_result_details_screen.dart';
import 'package:wls_pos/game_result/soccer_game_result_screen.dart';
import 'package:wls_pos/home/bloc/home_bloc.dart';
import 'package:wls_pos/home/home_screen.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/ledger_report/bloc/ledger_report_bloc.dart';
import 'package:wls_pos/ledger_report/ledger_report_screen.dart';
import 'package:wls_pos/login/bloc/login_bloc.dart';
import 'package:wls_pos/login/login_screen.dart';
import 'package:wls_pos/lottery/bingo/bingo_purchase_detail.dart';
import 'package:wls_pos/lottery/bingo/bloc/bingo_bloc.dart';
import 'package:wls_pos/lottery/models/otherDataClasses/panelBean.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/lottery/zoo_lotto/draw_zoo_lotto.dart';
import 'package:wls_pos/lottery/zoo_lotto/mihar_screen.dart';
import 'package:wls_pos/lottery/zoo_lotto/purchase_details/zoo_purchase_details.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/bloc/winning_claim_bloc.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/winning_claim_screen.dart';
import 'package:wls_pos/operational_report/bloc/operational_report_bloc.dart';
import 'package:wls_pos/operational_report/operational_report_screen.dart';
import 'package:wls_pos/pick_4/pick_4_draw_screen.dart';
import 'package:wls_pos/purchase_details/bloc/game_sale_bloc.dart';
import 'package:wls_pos/purchase_details/model/request/purchase_details_model.dart';
import 'package:wls_pos/purchase_details/purchase_details.dart';
import 'package:wls_pos/qr_scan/bloc/qr_scan_bloc.dart';
import 'package:wls_pos/qr_scan/qr_scan_screen.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/bloc/inv_flow_bloc.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/inventory_flow_screen.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/bloc/inv_rep_bloc.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/inventory_report_screen.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_bloc.dart';
import 'package:wls_pos/scratch/packOrder/pack_order_screen.dart';
import 'package:wls_pos/scratch/packReceive/pack_reveice_screen.dart';
import 'package:wls_pos/scratch/pack_activation/pack_activation_screen.dart';
import 'package:wls_pos/scratch/pack_return/pack_return_screen.dart';
import 'package:wls_pos/scratch/scratch_screen.dart';
import 'package:wls_pos/splash/splash_screen.dart';
import 'package:wls_pos/sportsLottery/sports_cricket_screen.dart';
import 'package:wls_pos/sportsLottery/sports_game_screen.dart';
import 'package:wls_pos/sportsLottery/bloc/sports_lottery_game_bloc.dart';
import 'package:wls_pos/sportsLottery/sports_lottery_screen.dart';
import 'package:wls_pos/summarize_ledger_report/summarize_ledger_report_screen.dart';
import 'package:wls_pos/utility/widgets/selectdate/bloc/select_date_bloc.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';
import 'package:wls_pos/lottery/bloc/lottery_bloc.dart';
import 'package:wls_pos/lottery/lottery_screen.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart' as sports_pool_game_response;
import 'package:wls_pos/lottery/models/response/ResultResponse.dart' as result;
import 'package:wls_pos/lottery_bottom_nav/last_result_dialog/result_preview.dart';
import 'package:wls_pos/scratch/saleTicket/bloc/sale_ticket_bloc.dart';
import 'package:wls_pos/scratch/saleTicket/sale_ticket_screen.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/bloc/ticket_validation_and_claim_bloc.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/ticket_validation_and_claim_screen.dart';

import '../change_pin/change_pin.dart';
import '../saleWinTxnReport/bloc/sale_win_bloc.dart';
import '../lottery/bingo/bingo_game_screen.dart';
import '../lottery/bingo/model/data/bingo_purchase_detail_data.dart';
import '../lottery/lottery_game_screen.dart';
import '../lottery/pick_type_screen.dart';
import '../saleWinTxnReport/sale_win_transaction_report.dart';
import '../scan_and_play/depositScreen/bloc/deposit_bloc.dart';
import '../scan_and_play/scan_and_play_screen.dart';
import '../scan_and_play/scanner_view/Scan_screen.dart';
import '../splash/bloc/splash_bloc.dart';
import '../summarize_ledger_report/bloc/summarize_ledger_bloc.dart';

class AppRoute {
  router(RouteSettings setting) {
    switch (setting.name) {
      case WlsPosScreen.splashScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SplashBloc>(
                  create: (BuildContext context) => SplashBloc(),
                )
              ],
              child: const SplashScreen(),
            ));

      case WlsPosScreen.homeScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<HomeBloc>(
                  create: (BuildContext context) => HomeBloc(),
                )
              ],
              child: const HomeScreen(),
            ));
      case WlsPosScreen.scratchScreen:
        List<MenuBeanList>? scratchList =
        setting.arguments as List<MenuBeanList>?;
        return MaterialPageRoute(
          builder: (context) => ScratchScreen(scratchList: scratchList),
        );

      case WlsPosScreen.qrScanScreen:
        String? titleName = setting.arguments as String?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<QrScanBloc>(
                  create: (BuildContext context) => QrScanBloc(),
                )
              ],
              child: QrScanScreen(titleName: titleName!),
            ));

      case WlsPosScreen.loginScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<LoginBloc>(
                  create: (BuildContext context) => LoginBloc(),
                )
              ],
              child: const LoginScreen(),
            ));

      case WlsPosScreen.lotteryScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<LotteryBloc>(
                  create: (BuildContext context) => LotteryBloc(),
                ),
                BlocProvider<WinningClaimBloc>(
                  create: (BuildContext context) => WinningClaimBloc(),
                )
              ],
              child: const LotteryScreen(),
            ));

      case WlsPosScreen.ledgerReportScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<LedgerReportBloc>(
                  create: (BuildContext context) => LedgerReportBloc(),
                ),
                BlocProvider<SelectDateBloc>(
                  create: (BuildContext context) => SelectDateBloc(),
                ),
                BlocProvider<DepWithBloc>(
                  create: (BuildContext context) => DepWithBloc(),
                )
              ],
              child: const LedgerReportScreen(),
            ));

      case WlsPosScreen.operationalReportScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<OperationalReportBloc>(
                  create: (BuildContext context) => OperationalReportBloc(),
                ),
                BlocProvider<SelectDateBloc>(
                  create: (BuildContext context) => SelectDateBloc(),
                ),
              ],
              child: const OperationalReportScreen(),
            ));

      case WlsPosScreen.balanceInvoiceReportScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<BalanceInvoiceReportBloc>(
                  create: (BuildContext context) => BalanceInvoiceReportBloc(),
                ),
                BlocProvider<SelectDateBloc>(
                  create: (BuildContext context) => SelectDateBloc(),
                ),
              ],
              child: const BalanceInvoiceReportScreen(),
            ));

      case WlsPosScreen.depositWithdrawalScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SelectDateBloc>(
                  create: (BuildContext context) => SelectDateBloc(),
                ),
                BlocProvider<DepWithBloc>(
                  create: (BuildContext context) => DepWithBloc(),
                )
              ],
              child: const DepositWithdrawalScreen(),
            ));
      case WlsPosScreen.sportsLotteryScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SportsLotteryGameBloc>(
                  create: (BuildContext context) => SportsLotteryGameBloc(),
                )
              ],
              child: const SportsLotteryScreen(),
            ));
      case WlsPosScreen.sportsGameScreen:
        sports_pool_game_response.ResponseData responseData =
        setting.arguments as sports_pool_game_response.ResponseData;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                //ToDo need to remove
                BlocProvider<DepWithBloc>(
                  create: (BuildContext context) => DepWithBloc(),
                )
              ],
              child: SportsGameScreen(responseData: responseData),
            ));
      case WlsPosScreen.sportsCricketScreen:
      // sports_pool_game_response.ResponseData responseData =
      // setting.arguments as sports_pool_game_response.ResponseData;
        List<dynamic> responseData = setting.arguments as List<dynamic>;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                //ToDo need to remove
                BlocProvider<DepWithBloc>(
                  create: (BuildContext context) => DepWithBloc(),
                )
              ],
              child: SportsCricketScreen(args: responseData),
            ));
      case WlsPosScreen.purchaseDetailsScreen:
        PurchaseDetailsModel purchaseDetailsModel =
        setting.arguments as PurchaseDetailsModel;
        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                //ToDo need to remove
                BlocProvider<GameSaleBloc>(
                  create: (BuildContext context) => GameSaleBloc(),
                )
              ],
              child: PurchaseDetails(
                purchaseDetailsModel: purchaseDetailsModel,
              ),
            ));

      case WlsPosScreen.changePin:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider<ChangePinBloc>(
                      create: (BuildContext context) => ChangePinBloc(),
                    )
                  ],
                  child: const ChangePin(),
                ));
      case WlsPosScreen.bingoGameScreen:
        GameRespVOs? gameObjectsList = setting.arguments as GameRespVOs?;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<BingoBloc>(
                create: (BuildContext context) => BingoBloc(),
              )
            ],
            child: BingoGameScreen(particularGameObjects: gameObjectsList),
          ),
        );
      case WlsPosScreen.bingoPurchaseDetail:
        BingoPurchaseDetailData bingoPurchaseDetailData = setting.arguments as BingoPurchaseDetailData;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<LotteryBloc>(
                create: (BuildContext context) => LotteryBloc(),
              ),
              BlocProvider<LoginBloc>(
                create: (BuildContext context) => LoginBloc(),
              ),
            ],
            child: BingoPurchaseDetailScreen(bingoPurchaseDetailData: bingoPurchaseDetailData),
          ),
        );
      case WlsPosScreen.saleWinTxn:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider<SaleWinBloc>(
                      create: (BuildContext context) => SaleWinBloc(),
                    ),
                    BlocProvider<SelectDateBloc>(
                      create: (BuildContext context) => SelectDateBloc(),
                    ),
                  ],
                  child: const SaleWinTransactionReport(),
                ));

      case WlsPosScreen.summarizeLedgerReport:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider<SelectDateBloc>(
                      create: (BuildContext context) => SelectDateBloc(),
                    ),
                    BlocProvider<SummarizeLedgerBloc>(
                      create: (BuildContext context) => SummarizeLedgerBloc(),
                    )
                  ],
                  child: const SummarizeLedgerReportScreen(),
                ));

      case WlsPosScreen.gameResultScreen:
        var gameListData = setting.arguments;
        // return MaterialPageRoute(builder: (context) => GameResultScreen(gameListData: gameListData));
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    //ToDo need to remove
                    BlocProvider<GameResultBloc>(
                      create: (BuildContext context) => GameResultBloc(),
                    ),
                    BlocProvider<SelectDateBloc>(
                      create: (BuildContext context) => SelectDateBloc(),
                    )
                  ],
                  child: GameResultScreen(gameListData: gameListData),
                ));
      case WlsPosScreen.gameResultDetailsScreen:
        Content? contentValue = setting.arguments as Content;
        return MaterialPageRoute(
            builder: (context) =>
                GameResultDetailsScreen(contentValue: contentValue));
      case WlsPosScreen.soccerGameResultDetailsScreen:
        SoccerContent? contentValue = setting.arguments as SoccerContent;
        return MaterialPageRoute(
            builder: (context) =>
                SoccerGameResultDetailsScreen(contentValue: contentValue));
      case WlsPosScreen.pick4GameResultDetailsScreen:
        Pick4Content? contentValue = setting.arguments as Pick4Content;
        return MaterialPageRoute(
            builder: (context) =>
                Pick4GameResultDetailsScreen(contentValue: contentValue));
      case WlsPosScreen.pick4DrawScreen:
        List<dynamic> responseData = setting.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) => Pick4DrawScreen(args: responseData),
        );

      case WlsPosScreen.winningClaimScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<WinningClaimBloc>(
                  create: (BuildContext context) => WinningClaimBloc(),
                )
              ],
              child: const WinningClaimScreen(),
            )
        );

      case WlsPosScreen.resultPreviewScreen:
        List<result.ResponseData>? resultList = setting.arguments as List<result.ResponseData>?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<LotteryBloc>(
                  create: (BuildContext context) => LotteryBloc(),
                )
              ],
              child: ResultPreview(resultList: resultList),
            )
        );

      case WlsPosScreen.saleTicketScreen:
        MenuBeanList? scratchList = setting.arguments as MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SaleTicketBloc>(
                  create: (BuildContext context) => SaleTicketBloc(),
                ),
                BlocProvider<PackBloc>(
                  create: (BuildContext context) => PackBloc(),
                )
              ],
              child: SaleTicketScreen(scratchList: scratchList,),
            )
        );

      case WlsPosScreen.ticketValidationAndClaimScreen:
        MenuBeanList? scratchList = setting.arguments as MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<TicketValidationAndClaimBloc>(
                  create: (BuildContext context) => TicketValidationAndClaimBloc(),
                )
              ],
              child: TicketValidationAndClaimScreen(scratchList: scratchList,),
            )
        );

      case WlsPosScreen.pickTypeScreen:
        return MaterialPageRoute(
            builder: (_) =>  PickTypeScreen()
        );

      case WlsPosScreen.gameScreen:
        return MaterialPageRoute(
            builder: (_) =>  MultiBlocProvider(
              providers: [
                BlocProvider<LotteryBloc>(
                  create: (BuildContext context) => LotteryBloc(),
                )
              ],

              child: GameScreen(),
            )
        );

      case WlsPosScreen.zooLottoGameScreen:
        var arguments = (setting.arguments ?? <String, dynamic>{}) as Map;
        GameRespVOs? gameObjectsList = arguments['gameObjectsList'] as GameRespVOs?;
        List<PanelBean>? listPanelData = arguments['listPanelData'] as List<PanelBean>?;
        return MaterialPageRoute(
            builder: (_) =>  DrawZooLottoScreen(gameObjectsList: gameObjectsList, listPanelData: listPanelData)
        );

      case WlsPosScreen.miharGameScreen:
        final args = setting.arguments as Map?;
        BetRespVOs? betData = args!['betData'];
        final GameRespVOs? gameObjectsList = args['gameObjectsList'];
        final List<PanelBean>? mPanelBinList = args['panelBinList'];
        return MaterialPageRoute(
            builder: (_) =>  MiharScreen(betData: betData, gameObjectsList: gameObjectsList, mPanelBinList: mPanelBinList)
        );

      case WlsPosScreen.zooPurchaseDetailsScreen:
        final args = setting.arguments as Map?;
        final GameRespVOs? gameObjectsList = args!['gameObjectsList'];
        final List<PanelBean>? mPanelBinList = args['listPanelData'];
        final Function(String) onComingToPreviousScreen = args['onComingToPreviousScreen'];
        return MaterialPageRoute(
            builder: (_) =>  MultiBlocProvider(
              providers: [
                BlocProvider<LotteryBloc>(
                  create: (BuildContext context) => LotteryBloc(),
                ),
                BlocProvider<LoginBloc>(
                  create: (BuildContext context) => LoginBloc(),
                )
              ],
              child: ZooPurchaseDetails(gameObjectsList: gameObjectsList, mPanelBinList: mPanelBinList, onComingToPreviousScreen: onComingToPreviousScreen),
            )
        );

      case WlsPosScreen.inventoryFlowScreen:
        MenuBeanList? menuBeanList = setting.arguments as  MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) =>  MultiBlocProvider(
              providers: [
                BlocProvider<InvFlowBloc>(
                  create: (BuildContext context) => InvFlowBloc(),
                ),
                BlocProvider<SelectDateBloc>(
                  create: (BuildContext context) => SelectDateBloc(),
                )
              ],

              child: InventoryFlowScreen(menuBeanList : menuBeanList),
            )
        );

      case WlsPosScreen.inventoryReportScreen:
        MenuBeanList? menuBeanList = setting.arguments as  MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) =>  MultiBlocProvider(
              providers: [
                BlocProvider<InvRepBloc>(
                  create: (BuildContext context) => InvRepBloc(),
                )
              ],

              child: InventoryReportScreen(menuBeanList : menuBeanList),
            )
        );

      case WlsPosScreen.packOrderScreen:
        MenuBeanList? scratchList = setting.arguments as MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<PackBloc>(
                  create: (BuildContext context) => PackBloc(),
                )
              ],
              child: PackOrderScreen(scratchList: scratchList,),
            )
        );
      case WlsPosScreen.packReceiveScreen:
        MenuBeanList? scratchList = setting.arguments as MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<PackBloc>(
                  create: (BuildContext context) => PackBloc(),
                )
              ],
              child: PackReceiveScreen(scratchList: scratchList,),
            )
        );

      case WlsPosScreen.packActivationScreen:
        MenuBeanList? scratchList = setting.arguments as MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<PackBloc>(
                  create: (BuildContext context) => PackBloc(),
                )
              ],
              child: PackActivationScreen(scratchList: scratchList,),
            )
        );

      case WlsPosScreen.packReturnScreen:
        MenuBeanList? scratchList = setting.arguments as MenuBeanList?;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<PackBloc>(
                  create: (BuildContext context) => PackBloc(),
                )
              ],
              child: PackReturnScreen(scratchList: scratchList,),
            )
        );
      case WlsPosScreen.scanAndPlayScreen:
        return MaterialPageRoute(
            builder: (context) => const ScanAndPlayScreen());
      case WlsPosScreen.scanAndPlayScannerScreen:
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<DepositBloc>(
                    create: (BuildContext context) => DepositBloc(),
                  )
                ],
                child: ScanScreen()
            ));
      default:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
