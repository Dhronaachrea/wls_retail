import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/ledger_report/bloc/ledger_report_bloc.dart';
import 'package:wls_pos/ledger_report/bloc/ledger_report_event.dart';
import 'package:wls_pos/ledger_report/bloc/ledger_report_state.dart';
import 'package:wls_pos/ledger_report/models/response/ledgerReportApiResponse.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/selectdate/bloc/select_date_bloc.dart';
import 'package:wls_pos/utility/widgets/selectdate/forward.dart';
import 'package:wls_pos/utility/widgets/selectdate/select_date.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class LedgerReportScreen extends StatefulWidget {
  const LedgerReportScreen({Key? key}) : super(key: key);

  @override
  _LedgerReportState createState() => _LedgerReportState();
}

class _LedgerReportState extends State<LedgerReportScreen> {
  @override
  void initState() {
    BlocProvider.of<LedgerReportBloc>(context).add(GetLedgerReportApiData(
      context: context,
      fromDate: formatDate(
        date: context.read<SelectDateBloc>().fromDate,
        inputFormat: Format.dateFormat9,
        outputFormat: Format.apiDateFormat3,
      ),
      toDate: formatDate(
        date: context.read<SelectDateBloc>().toDate,
        inputFormat: Format.dateFormat9,
        outputFormat: Format.apiDateFormat3,
      ),
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        appBarTitle: Text('Ledger Report'),
        body: Column(
          children: [
            Container(
              color: WlsPosColor.white,
              // constraints: BoxConstraints(
              //   minHeight: context.screenHeight / 7,
              // ),
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
                      // context.read<DepWithBloc>().add(
                      //       GetDepWith(
                      //         context: context,
                      //         fromDate: context.watch<SelectDateBloc>().fromDate,
                      //         toDate: context.watch<SelectDateBloc>().toDate,
                      //       ),
                      //     );
                      initData();
                    },
                  ),
                ],
              ).pSymmetric(v: 16, h: 10),
            ),

            BlocBuilder<LedgerReportBloc, LedgerReportState>(
                builder: (context, state) {
              if (state is LedgerReportLoading) {
                return Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ).p(10);
              }
              else if (state is LedgerReportSuccess) {
                LedgerReportApiResponse ledgerReportApiResponse =
                    state.ledgerReportApiResponse;
                List<Transaction>? transList =
                    ledgerReportApiResponse.responseData!.data!.transaction;
                String? closingBalance = state.ledgerReportApiResponse
                    .responseData!.data!.balance!.closingBalance;
                String? openingBalance = state.ledgerReportApiResponse
                    .responseData!.data!.balance!.openingBalance;
                return Expanded(
                    child: Column(
                  children: [
                    Container(
                      color: WlsPosColor.pale_grey_four,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Opening Balance',
                                style: TextStyle(
                                    color: WlsPosColor.black_four
                                        .withOpacity(0.5)),
                              ).p(10),
                              Text(openingBalance!,
                                      style: TextStyle(
                                          color: WlsPosColor.shamrock_green))
                                  .pOnly(bottom: 10)
                            ],
                          ),
                          Column(
                            children: [
                              Text('Closing Balance',
                                      style: TextStyle(
                                          color: WlsPosColor.black_four
                                              .withOpacity(0.5)))
                                  .p(10),
                              Text(closingBalance!,
                                      style: TextStyle(
                                          color: WlsPosColor.shamrock_green))
                                  .pOnly(bottom: 10)
                            ],
                          ),
                        ],
                      ).pOnly(left: 25, right: 25),
                    ),
                    transList!.length > 0
                        ? Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: transList!.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 70,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            alignment: Alignment.center,
                                            color: WlsPosColor.light_grey
                                                .withOpacity(0.5),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                        getDate(
                                                            transList[index]
                                                                .createdAt),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: WlsPosColor
                                                                .black
                                                                .withOpacity(
                                                                    0.5),
                                                            fontSize: 14))
                                                    .pOnly(bottom: 2),
                                                Text(
                                                  getTime(transList[index]
                                                      .createdAt),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: WlsPosColor
                                                          .black_four
                                                          .withOpacity(0.5)),
                                                ),
                                              ],
                                            ).pOnly(left: 15, right: 15),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                        transList[index]
                                                                    .serviceDisplayName !=
                                                                null
                                                            ? transList[index]
                                                                .serviceDisplayName!
                                                            : '',
                                                        style: const TextStyle(
                                                            color: WlsPosColor
                                                                .black))
                                                    .pOnly(bottom: 10),
                                                Text(
                                                  transList[index].particular!,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: WlsPosColor
                                                          .black_four
                                                          .withOpacity(0.5),
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ).pOnly(left: 5, right: 5),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(transList[index].amount!,
                                                        style: TextStyle(
                                                            color: transList[
                                                                            index]
                                                                        .serviceDisplayName ==
                                                                    'Dr.'
                                                                ? WlsPosColor
                                                                    .tomato
                                                                : WlsPosColor
                                                                    .shamrock_green,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    .pOnly(bottom: 10),
                                                Text('Bal Amt',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: WlsPosColor
                                                            .black_four
                                                            .withOpacity(0.4))),
                                                FittedBox(
                                                  child: Text(
                                                      transList[index]
                                                          .availableBalance!,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: WlsPosColor
                                                              .black_four
                                                              .withOpacity(
                                                                  0.6))),
                                                ),
                                              ],
                                            ).pOnly(right: 15),
                                          )
                                        ],
                                      ),
                                      Container(
                                          child: Divider(
                                        height: 2,
                                        // color: Colors.blue,
                                      ))
                                    ],
                                  );
                                }))
                        : Expanded(
                            child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'No Data Available!',
                              style: TextStyle(
                                  color:
                                      WlsPosColor.black_four.withOpacity(0.5)),
                            ).p(10),
                          )),
                  ],
                ));
              }
              else if (state is LedgerReportError) {
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
                            // context.read<DepWithBloc>().add(
                            //       GetDepWith(
                            //         context: context,
                            //         fromDate: context.watch<SelectDateBloc>().fromDate,
                            //         toDate: context.watch<SelectDateBloc>().toDate,
                            //       ),
                            //     );
                            initData();
                          },
                        ),
                      ],
                    ).pSymmetric(v: 16, h: 10),
                  ),
                ],
              );
            })
          ],
        ));
  }

  String getDate(String? createdAt) {
    String fromDate = formatDate(
      date: createdAt.toString(),
      inputFormat: Format.apiDateFormat,
      outputFormat: Format.dateFormat,
    );
    List<String> splitag = fromDate.split(",");
    String? splitag1 = splitag![0];
    return splitag1;
  }

  String getTime(String? createdAt) {
    String fromDate = formatDate(
      date: createdAt.toString(),
      inputFormat: Format.apiDateFormat,
      outputFormat: Format.dateFormat,
    );
    List<String> splitag = fromDate.split(",");
    String? splitag2 = splitag[1];
    return splitag2;
  }


  initData() {
    BlocProvider.of<LedgerReportBloc>(context).add(GetLedgerReportApiData(
      context: context,
      fromDate: formatDate(
        date: context.read<SelectDateBloc>().fromDate,
        inputFormat: Format.dateFormat9,
        outputFormat: Format.apiDateFormat3,
      ),
      toDate: formatDate(
        date: context.read<SelectDateBloc>().toDate,
        inputFormat: Format.dateFormat9,
        outputFormat: Format.apiDateFormat3,
      ),
    ));
  }
}
