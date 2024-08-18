import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/game_result/bloc/game_result_bloc.dart';
import 'package:wls_pos/game_result/bloc/game_result_event.dart';
import 'package:wls_pos/game_result/bloc/game_result_state.dart';
import 'package:wls_pos/game_result/models/response/gameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/pick4GameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/soccerGameResultApiResponse.dart';
import 'package:wls_pos/game_result/widgets/game4DrawResult.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/soccer_draw_result.dart';
import 'package:wls_pos/utility/widgets/date_alert_dialog.dart';
import 'package:wls_pos/utility/widgets/draw_result.dart';
import 'package:wls_pos/utility/widgets/drop_down_list.dart';
import 'package:wls_pos/utility/widgets/selectdate/bloc/select_date_bloc.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

class GameResultScreen extends StatefulWidget {
  // List<ResponseData>? gameListData;
  var gameListData;

  GameResultScreen({Key? key, this.gameListData}) : super(key: key);

  @override
  _GameResultScreenState createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  bool mIsShimmerLoading = false;
  String? fromDate;
  String? toDate;
  String? gameId;
  String? gameName;
  var contentList = [];

  @override
  void initState() {
    fromDate = context.read<SelectDateBloc>().fromGameDate;
    toDate = context.read<SelectDateBloc>().toGameDate;
    gameId = widget.gameListData![0].id.toString();
    gameName = widget.gameListData![0].gameName.toString();

    BlocProvider.of<GameResultBloc>(context).add(GameResultApiData(
        context: context,
        fromDate: fromDate!,
        toDate: toDate!,
        gameId: gameId!,
        gameName: gameName!));

    // _controller = ScrollController()..addListener(_loadMore);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        backgroundColor: mIsShimmerLoading
            ? WlsPosColor.light_dark_white
            : WlsPosColor.white,
        appBarTitle: const Text("Result",
            style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: WlsPosColor.app_blue,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        child: DropDownList(
                            gameListData: widget.gameListData!,
                            onSelectedGame: (int selectIndex) {
                              gameId = widget.gameListData![selectIndex].id
                                  .toString();
                              gameName = widget
                                  .gameListData![selectIndex].gameName
                                  .toString();
                              BlocProvider.of<GameResultBloc>(context).add(
                                  GameResultApiData(
                                      context: context,
                                      fromDate: fromDate!,
                                      toDate: toDate!,
                                      gameId: gameId!,
                                      gameName: gameName!));
                            }).pOnly(left: 10, right: 10)),
                  ),
                  BlocListener<SelectDateBloc, SelectDateState>(
                    listener: (context, state) {
                      if (state is DateUpdated) {
                        toDate = state.toDate;
                        fromDate = state.fromDate;
                      }
                    },
                    child: InkWell(
                      onTap: () {
                        DateAlert.show(
                          isDarkThemeOn: false,
                          buttonClick: (String fromDate, String toDate) {
                            // context.read<SelectDateBloc>().add(
                            //       PickToDate(context: context),
                            //     );
                            BlocProvider.of<GameResultBloc>(context).add(
                                GameResultApiData(
                                    context: context,
                                    fromDate: fromDate,
                                    toDate: toDate,
                                    gameId: gameId!,
                                    gameName: gameName!));
                            // context.watch<SelectDateBloc>().fromDate;
                          },
                          title: '',
                          subtitle: '',
                          buttonText: 'ok'.toUpperCase(),
                          context: context,
                        );
                      },
                      child: Container(
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: WlsPosColor.white,
                          )),
                    ),
                  )
                ],
              ).pOnly(bottom: 10),
            ),
            BlocBuilder<GameResultBloc, GameResultState>(
                builder: (context, state) {
              if (state is GameResultLoading) {
                return Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ).p(10);
              } else if (state is GameResultSuccess) {
                GameResultApiResponse gameResultApiResponse =
                    state.gameResultApiResponse;

                contentList = gameResultApiResponse.responseData.content;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showDateRange(fromDate, toDate),
                      contentList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: contentList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context,
                                            WlsPosScreen
                                                .gameResultDetailsScreen,
                                            arguments: contentList[index]);
                                      },
                                      child: Column(
                                        children: [
                                          DrawResult(
                                              contentValue: contentList[index]),
                                          const MySeparator(
                                            width: 3,
                                            color: WlsPosColor.white_two,
                                          ).pOnly(bottom: 10)
                                        ],
                                      ),
                                    );
                                  }).pOnly(top: 10),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: const Text('No Data Available!',
                                  style: TextStyle(color: Colors.black))),
                    ],
                  ),
                );
              } else if (state is SoccerGameResultSuccess) {
                SoccerGameResultApiResponse soccerGameResultApiResponse =
                    state.soccerGameResultApiResponse;

                contentList = soccerGameResultApiResponse.responseData.content;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showDateRange(fromDate, toDate),
                      contentList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: contentList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context,
                                            WlsPosScreen
                                                .soccerGameResultDetailsScreen,
                                            arguments: contentList[index]);
                                      },
                                      child: Column(
                                        children: [
                                          SoccerDrawResult(
                                              contentValue: contentList[index]),
                                          const MySeparator(
                                            width: 3,
                                            color: WlsPosColor.white_two,
                                          ).pOnly(bottom: 10)
                                        ],
                                      ),
                                    );
                                  }).pOnly(top: 10),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: const Text('No Data Available!',
                                  style: TextStyle(color: Colors.black))),
                    ],
                  ),
                );
              } else if (state is Pick4GameResultSuccess) {
                Pick4GameResultApiResponse pick4GameResultApiResponse =
                    state.pick4gameResultApiResponse;

                contentList = pick4GameResultApiResponse.responseData.content;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showDateRange(fromDate, toDate),
                      contentList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: contentList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context,
                                            WlsPosScreen
                                                .pick4GameResultDetailsScreen,
                                            arguments: contentList[index]);
                                      },
                                      child: Column(
                                        children: [
                                          Game4DrawResult(
                                              contentValue: contentList[index]),
                                          const MySeparator(
                                            width: 3,
                                            color: WlsPosColor.white_two,
                                          ).pOnly(bottom: 10)
                                        ],
                                      ),
                                    );
                                  }).pOnly(top: 10),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: const Text('No Data Available!',
                                  style: TextStyle(color: Colors.black))),
                    ],
                  ),
                );
              } else if (state is GameResultError) {
                var errorMsg = state.errorMessage;
                return Container(
                  alignment: Alignment.center,
                  child: Text(errorMsg),
                ).p(10);
              }
              return Column(
                children: [
                  Container(
                    color: WlsPosColor.white,
                    // constraints: BoxConstraints(
                    //   minHeight: context.screenHeight / 7,
                    // ),
                    child: const Text('Loading...').pSymmetric(v: 16, h: 10),
                  ),
                ],
              );
            })
          ],
        ));
  }

  Widget showDateRange(String? fromDate, String? toDate) {
    return Text("Date Range: $fromDate to $toDate", textAlign: TextAlign.center,).p(8);
  }
}
