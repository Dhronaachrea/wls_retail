import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/summarize_ledger_report/bloc/summarize_ledger_state.dart';

import '../utility/date_format.dart';
import '../utility/utils.dart';
import '../utility/widgets/selectdate/bloc/select_date_bloc.dart';
import '../utility/widgets/selectdate/forward.dart';
import '../utility/widgets/selectdate/select_date.dart';
import '../utility/widgets/wls_pos_scaffold.dart';
import '../utility/wls_pos_color.dart';
import 'bloc/summarize_ledger_bloc.dart';
import 'bloc/summarize_ledger_event.dart';

class SummarizeLedgerReportScreen extends StatefulWidget {
  const SummarizeLedgerReportScreen({Key? key}) : super(key: key);

  @override
  State<SummarizeLedgerReportScreen> createState() =>
      _SummarizeLedgerReportScreenState();
}

int selectedIndex = 0;

class _SummarizeLedgerReportScreenState
    extends State<SummarizeLedgerReportScreen> {
  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        appBarTitle: const Text('Summarize Report'),
        body: Column(
          children: [
            Container(
              color: WlsPosColor.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SelectDate(
                    title: "From",
                    date: context.watch<SelectDateBloc>().fromDate,
                    onTap: () {
                      context.read<SelectDateBloc>().add(
                        PickFromDate(context: context),
                      );
                    },
                  ),
                  SelectDate(
                    title: "To",
                    date: context.watch<SelectDateBloc>().toDate,
                    onTap: () {
                      context.read<SelectDateBloc>().add(
                        PickToDate(context: context),
                      );

                    },
                  ),
                  Forward(
                    onTap: () {
                      initData();
                    },
                  ),
                ],
              ).pSymmetric(v: 16, h: 10),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    decoration: BoxDecoration(
                        border:
                        Border.all(color: WlsPosColor.brownish_grey_six)),
                    alignment: Alignment.center,
                    child: DefaultTabController(
                      length: 2,
                      child: TabBar(
                        onTap: (int index) {
                          selectedIndex = index;
                          initData();
                        },
                        labelColor: WlsPosColor.white_five,
                        unselectedLabelColor: WlsPosColor.brownish_grey_six,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            0,
                          ),
                          color: WlsPosColor.brownish_grey_six,
                        ),
                        tabs: const [
                          Tab(
                            text: 'Default',
                          ),
                          Tab(
                            text: 'Date Wise',
                          )
                        ],
                      ),
                    )),
              ],
            ),
            BlocBuilder<SummarizeLedgerBloc, SummarizeLedgerState>(
                builder: (context, state) {
                  if (state is SummarizeLedgerLoading) {
                    return const Expanded(
                        child: Center(child: CircularProgressIndicator()));
                  } else if (state is SummarizeLedgerDateWiseSuccess) {
                    return Expanded(
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    color:  WlsPosColor.warm_grey_three.withOpacity(0.2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          "Opening Balance",
                                          //context.l10n.opening_balance.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style:  TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12,
                                              color: WlsPosColor.warm_grey_three),
                                        ).p(10),
                                        Text(
                                            state.response.responseData?.data
                                                ?.openingBalance
                                                .toString() ??
                                                "",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: WlsPosColor.game_color_green))
                                            .pOnly(bottom: 10)
                                      ],
                                    ).pOnly(left: 5, right: 5),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: WlsPosColor.warm_grey_three.withOpacity(0.4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          "Net Movement",
                                          //context.l10n.net_movement.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12,
                                              color: WlsPosColor.warm_grey_three),
                                        ).p(10),
                                        Text(  state.response.responseData?.data?.netBalanceMovement.toString() ?? "",
                                            //"${getDefaultCurrency(getLanguage())} ${openingBalance ?? ""}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: WlsPosColor.red))
                                            .pOnly(bottom: 10)
                                      ],
                                    ).pOnly(left: 5, right: 5),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color:  WlsPosColor.warm_grey_three.withOpacity(0.2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          "Closing Balance",
                                          //context.l10n.closing_balance.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12,
                                              color: WlsPosColor.warm_grey_three),
                                        ).p(10),
                                        Text(state.response.responseData?.data
                                            ?.closingBalance
                                            .toString() ??
                                            "",
                                            //"${getDefaultCurrency(getLanguage())} ${closingBalance ?? ""}",
                                            style:  const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: WlsPosColor.game_color_green))
                                            .pOnly(bottom: 10)
                                      ],
                                    ).pOnly(left: 5, right: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /*Container(
                            color: WlsPosColor.light_dark_white,
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Opening balance",
                                  style: TextStyle(
                                      color: WlsPosColor.warm_grey_three,
                                      fontSize: 16),
                                ),
                                Text(
                                  state.response.responseData?.data
                                      ?.rawOpeningBalance
                                      .toString() ??
                                      "",
                                  style: TextStyle(color: WlsPosColor.dark_green),
                                )
                              ],
                            ),
                          ),*/
                          Expanded(
                              child: state.response.responseData!.data!.ledgerData!
                                  .isNotEmpty
                                  ? ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: state.response.responseData!.data!
                                      .ledgerData!.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                  const Divider(height: 5),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 10),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Date : ${state.response.responseData!.data!.ledgerData![index].date}",
                                            style: const TextStyle(
                                              color:
                                              WlsPosColor.brownish_grey_six,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            state
                                                .response
                                                .responseData!
                                                .data!
                                                .ledgerData![index]
                                                .txnData![0]
                                                .serviceName ??
                                                "",
                                            style: const TextStyle(
                                                color: WlsPosColor
                                                    .brownish_grey_six,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .txnData![0]
                                                          .key1Name ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .txnData![0]
                                                          .key1 ??
                                                          "",
                                                      style: const TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .txnData![0]
                                                          .key2Name ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .txnData![0]
                                                          .key2 ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Net Amount",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .txnData![0]
                                                          .rawNetAmount ??
                                                          "",
                                                      style: const TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  })
                                  : Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No Data Available!',
                                      style: TextStyle(
                                          color: WlsPosColor.black_four
                                              .withOpacity(0.5)),
                                    ).p(10),
                                  ))),
                          /*Container(
                            color: WlsPosColor.light_dark_white,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Closing balance",
                                  style: TextStyle(
                                      color: WlsPosColor.warm_grey_three,
                                      fontSize: 16),
                                ),
                                Text(
                                  state.response.responseData?.data
                                      ?.rawClosingBalance
                                      .toString() ??
                                      "",
                                  style: TextStyle(color: WlsPosColor.dark_green),
                                )
                              ],
                            ),
                          ),*/
                        ],
                      ),
                    );
                  } else if (state is SummarizeLedgerDefaultSuccess) {
                    return Expanded(
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    color:  WlsPosColor.warm_grey_three.withOpacity(0.2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          "Opening Balance",
                                          //context.l10n.opening_balance.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style:  TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12,
                                              color: WlsPosColor.warm_grey_three),
                                        ).p(10),
                                        Text(
                                            state.response.responseData?.data
                                                ?.openingBalance
                                                .toString() ??
                                                "",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: WlsPosColor.game_color_green))
                                            .pOnly(bottom: 10)
                                      ],
                                    ).pOnly(left: 5, right: 5),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: WlsPosColor.warm_grey_three.withOpacity(0.4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          "Net Movement",
                                          //context.l10n.net_movement.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12,
                                              color: WlsPosColor.warm_grey_three),
                                        ).p(10),
                                        Text(  state.response.responseData?.data?.netBalanceMovement.toString() ?? "",
                                            //"${getDefaultCurrency(getLanguage())} ${openingBalance ?? ""}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: WlsPosColor.red))
                                            .pOnly(bottom: 10)
                                      ],
                                    ).pOnly(left: 5, right: 5),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color:  WlsPosColor.warm_grey_three.withOpacity(0.2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          "Closing Balance",
                                          //context.l10n.closing_balance.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12,
                                              color: WlsPosColor.warm_grey_three),
                                        ).p(10),
                                        Text(state.response.responseData?.data
                                            ?.closingBalance
                                            .toString() ??
                                            "",
                                            //"${getDefaultCurrency(getLanguage())} ${closingBalance ?? ""}",
                                            style:  const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: WlsPosColor.game_color_green))
                                            .pOnly(bottom: 10)
                                      ],
                                    ).pOnly(left: 5, right: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                         /* Container(
                            color: WlsPosColor.light_dark_white,
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Opening balance",
                                  style: TextStyle(
                                      color: WlsPosColor.warm_grey_three,
                                      fontSize: 16),
                                ),
                                Text(
                                  state.response.responseData?.data
                                      ?.rawOpeningBalance
                                      .toString() ??
                                      "",
                                  style: TextStyle(color: WlsPosColor.dark_green),
                                )
                              ],
                            ),
                          ),*/
                          Expanded(
                              child: state.response.responseData!.data!.ledgerData!
                                  .isNotEmpty
                                  ? ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: state.response.responseData!.data!
                                      .ledgerData!.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                  const Divider(height: 5),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 10),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state
                                                .response
                                                .responseData!
                                                .data!
                                                .ledgerData![index]
                                                .serviceName ??
                                                "",
                                            style: TextStyle(
                                                color: WlsPosColor
                                                    .brownish_grey_six,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .key1Name ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .key1 ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .key2Name ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .key2 ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Net Amount",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      state
                                                          .response
                                                          .responseData!
                                                          .data!
                                                          .ledgerData![
                                                      index]
                                                          .netAmount ??
                                                          "",
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey_six,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  })
                                  : Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No Data Available!',
                                      style: TextStyle(
                                          color: WlsPosColor.black_four
                                              .withOpacity(0.5)),
                                    ).p(10),
                                  ))),

                          /*Container(
                            color: WlsPosColor.light_dark_white,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Closing balance",
                                  style: TextStyle(
                                      color: WlsPosColor.warm_grey_three,
                                      fontSize: 16),
                                ),
                                Text(
                                  state.response.responseData?.data
                                      ?.rawClosingBalance
                                      .toString() ??
                                      "",
                                  style: TextStyle(color: WlsPosColor.dark_green),
                                )
                              ],
                            ),
                          ),*/
                        ],
                      ),
                    );
                  }
                  return Container();
                })
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    BlocProvider.of<SummarizeLedgerBloc>(context).add(SummarizeLedgerModel(
      url: "",
      type: selectedIndex == 0 ? "default" : "datewise",
      context: context,
      startDate: formatDate(
        date: context.read<SelectDateBloc>().fromDate,
        inputFormat: Format.dateFormat9,
        outputFormat: Format.apiDateFormat3,
      ),
      endDate: formatDate(
        date: context.read<SelectDateBloc>().toDate,
        inputFormat: Format.dateFormat9,
        outputFormat: Format.apiDateFormat3,
      ),
    ));
  }
}
