import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/balance_invoice_report/bloc/balance_invoice_report_bloc.dart';
import 'package:wls_pos/balance_invoice_report/bloc/balance_invoice_report_event.dart';
import 'package:wls_pos/balance_invoice_report/bloc/balance_invoice_report_state.dart';
import 'package:wls_pos/balance_invoice_report/models/response/balance_invoice_report_response.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import '../utility/date_format.dart';
import '../utility/utils.dart';
import '../utility/widgets/selectdate/bloc/select_date_bloc.dart';
import '../utility/widgets/selectdate/forward.dart';
import '../utility/widgets/selectdate/select_date.dart';


class BalanceInvoiceReportScreen extends StatefulWidget {
  const BalanceInvoiceReportScreen({Key? key}) : super(key: key);

  @override
  State<BalanceInvoiceReportScreen> createState() => _BalanceInvoiceReportState();
}

class _BalanceInvoiceReportState extends State<BalanceInvoiceReportScreen> {
  @override
  void initState() {
    BlocProvider.of<BalanceInvoiceReportBloc>(context).add(GetBalanceInvoiceReportApiData(
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
    var body = Column(
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
        BlocConsumer<BalanceInvoiceReportBloc, BalanceInvoiceReportState>(
          listener: (context, state) {
              if (state is BalanceInvoiceReportError) {
                ShowToast.showToast(context, state.errorMessage, type: ToastType.ERROR);
              }
          },
          builder: (context, state) {
          if (state is BalanceInvoiceReportLoading) {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ).p(10);
          }
          else if (state is BalanceInvoiceReportSuccess) {
            Data?  balanceInvoiceData = state.balanceInvoiceReportApiResponse.responseData?.data;
            String? closingBalance = balanceInvoiceData?.closingBalance ?? "-";
            String? openingBalance = balanceInvoiceData?.openingBalance ?? "-";
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
                            "Opening Balance",
                            style: TextStyle(
                                color: WlsPosColor.black_four
                                    .withOpacity(0.5)),
                          ).p(10),
                          Text(openingBalance,
                                  style: const TextStyle(
                                      color: WlsPosColor.shamrock_green))
                              .pOnly(bottom: 10)
                        ],
                      ),
                      Column(
                        children: [
                          Text("Closing Balance",
                                  style: TextStyle(
                                      color: WlsPosColor.black_four
                                          .withOpacity(0.5)))
                              .p(10),
                          Text(closingBalance,
                                  style: const TextStyle(
                                      color: WlsPosColor.shamrock_green))
                              .pOnly(bottom: 10)
                        ],
                      ),
                    ],
                  ).pOnly(left: 25, right: 25),
                ),

                balanceInvoiceData != null
                    ? Expanded(
                      child: ListView(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Sales
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: WlsPosColor.light_grey
                                    ),
                                    child: const Text(
                                      "Sales",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.sales ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Row(
                              children: [
                                // Claims
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .light_grey),
                                    child: const Text(
                                      "Claims",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.claims ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Row(
                              children: [
                                // Claim Tax
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .light_grey),
                                    child: const Text(
                                      "Claim Tax",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.claimTax ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Row(
                              children: [
                                // Commission Sales
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .light_grey),
                                    child: const Text(
                                      "Commission Sales",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.salesCommission ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Row(
                              children: [
                                // Commission Winnings
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .light_grey),
                                    child: const Text(
                                      "Winnings Commission",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.winningsCommission ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Row(
                              children: [
                                // payments
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .light_grey),
                                    child: const Text(
                                      "Payments",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.payments ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Row(
                              children: [
                                // payments
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .light_grey),
                                    child: const Text(
                                      "Debit/Credit txn",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        WlsPosColor
                                            .black,
                                      ),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        WlsPosColor
                                            .white),
                                    child: Text(
                                      balanceInvoiceData.creditDebitTxn ?? "-",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color:
                                          WlsPosColor
                                              .black),
                                      textAlign:
                                      TextAlign.center,
                                    ).p(15),
                                  ),
                                ),
                              ],
                            ).pSymmetric(h: 16, v: 4),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextButton(
                                  style: ButtonStyle(
                                      padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.only(
                                              left: 40,
                                              right: 40,
                                              top: 12,
                                              bottom: 12)),
                                      foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                      backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(50.0),
                                              side: const BorderSide(color: Colors.red)))),

                                  onPressed: () {
                                    if (androidInfo?.model == "V2" || androidInfo?.model == "M1" || androidInfo?.model == "T2mini") {

                                      Map<String, dynamic> printingDataArgs = {};
                                      printingDataArgs["orgId"] = UserInfo.organisationID;
                                      printingDataArgs["orgName"] = UserInfo.organisation;
                                      printingDataArgs["toAndFromDate"] = "${context.read<SelectDateBloc>().fromDate} to ${context.read<SelectDateBloc>().toDate}"/*"08-02-2023 to 08-02-2024"*/;
                                      printingDataArgs["balanceInvoiceData"] = jsonEncode(balanceInvoiceData);
                                      printingDataArgs["reportHeaderName"] = "Balance/Invoice Report";

                                      PrintingDialog().show(
                                          context: context,
                                          title: "Printing started",
                                          buttonText: 'Retry',
                                          isBalanceInvoiceReport:true,
                                          printingDataArgs: printingDataArgs,
                                          onPrintingDone: () {
                                            Navigator.pop(context);
                                          },
                                          onPrintingFailed: () {

                                          },
                                          isPrintingForSale: false);
                                    }

                                  },
                                  child: const Text("PRINT", style: TextStyle(fontSize: 16, color: WlsPosColor.white))),
                            ),
                          ],
                      ),
                    )
                    : Expanded(
                        child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "No Data Available",
                          style: TextStyle(
                              color: WlsPosColor.black_four
                                  .withOpacity(0.5)),
                        ).p(10),
                      )),
              ],
            ));
          }
          else if (state is BalanceInvoiceReportError) {
            return Container();
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
    );
    return WlsPosScaffold(
      showAppBar: true,
      appBarTitle: const Text("Balance/Invoice Report"),
      body:  body,
    );
  }

  String getDate(String? createdAt) {
    String fromDate = formatDate(
      date: createdAt.toString(),
      inputFormat: Format.apiDateFormat,
      outputFormat: Format.dateFormat,
    );
    List<String> splitag = fromDate.split(",");
    String? splitag1 = splitag[0];
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
    BlocProvider.of<BalanceInvoiceReportBloc>(context).add(GetBalanceInvoiceReportApiData(
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
