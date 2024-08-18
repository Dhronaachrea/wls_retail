import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/diposit_withdrawal/bloc/depwith_bloc.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/loading_indicator.dart';
import 'package:wls_pos/utility/widgets/selectdate/forward.dart';
import 'package:wls_pos/utility/widgets/selectdate/select_date.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';

import '../utility/widgets/selectdate/bloc/select_date_bloc.dart';
import '../utility/wls_pos_color.dart';
import 'model/depwith_response.dart';

class DepositWithdrawalScreen extends StatefulWidget {
  const DepositWithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<DepositWithdrawalScreen> createState() =>
      _DepositWithdrawalScreenState();
}

class _DepositWithdrawalScreenState extends State<DepositWithdrawalScreen> {
  DepWithResponse? depWithResponse;

  List<Transaction> transaction = [];
  bool isLoading = false;
  String netCollection = "0";
  String screenMsg = '';

  // String fromDate = formatDate(
  //   date: DateTime.now().subtract(const Duration(days: 30)).toString(),
  //   inputFormat: Format.apiDateFormat2,
  //   outputFormat: Format.rangeDateFormat,
  // );
  //
  // String toDate = formatDate(
  //   date: DateTime.now().toString(),
  //   inputFormat: Format.apiDateFormat2,
  //   outputFormat: Format.rangeDateFormat,
  // );

  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    initData();
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
      showAppBar: true,
      centerTitle: false,
      appBarTitle: const Text(
        "Deposit/Withdrawal",
        style: TextStyle(fontSize: 18, color: WlsPosColor.white),
      ),
      body: BlocListener<DepWithBloc, DepWithState>(
        listener: (context, state) {
          if (state is GetDepWithSuccess) {
            setState(() {
              isLoading = false;
              depWithResponse = state.response;
              transaction = depWithResponse!.responseData.data!.transaction;
              netCollection = depWithResponse!
                  .responseData.data!.total.netCollection
                  .trim();
            });
          } else if (state is GettingDepWith) {
            setState(() {
              isLoading = true;
            });
          } else if (state is GetDepWithError) {
            setState(() {
              isLoading = false;
              depWithResponse = null;
              transaction = [];
              netCollection = '0';
              screenMsg = state.errorMessage;
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Divider(
              height: 2,
              // color: Colors.blue,
            ),
            depWithResponse == null
                ? Container()
                : Container(
                    color: WlsPosColor.pale_grey_four,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Deposit',
                              style: TextStyle(
                                  color:
                                      WlsPosColor.black_four.withOpacity(0.5)),
                            ).p(10),
                            Text(
                                    depWithResponse!
                                            .responseData.data!.total.deposit ??
                                        "0.0",
                                    style: const TextStyle(
                                        color: WlsPosColor.black))
                                .pOnly(bottom: 10)
                          ],
                        ),
                        Column(
                          children: [
                            Text('Withdrawal',
                                    style: TextStyle(
                                        color: WlsPosColor.black_four
                                            .withOpacity(0.5)))
                                .p(10),
                            Text(
                                    depWithResponse!.responseData.data!.total
                                            .withdrawal ??
                                        "0.0",
                                    style: const TextStyle(
                                        color: WlsPosColor.black))
                                .pOnly(bottom: 10)
                          ],
                        ),
                        Column(
                          children: [
                            Text('Net Collection',
                                    style: TextStyle(
                                        color: WlsPosColor.black_four
                                            .withOpacity(0.5)))
                                .p(10),
                            Text(
                                depWithResponse!.responseData.data!.total
                                        .netCollection ??
                                    "0.0",
                                style: TextStyle(
                                  color: depWithResponse!.responseData.data!
                                              .total.rawNetCollection >
                                          0
                                      ? WlsPosColor.shamrock_green
                                      : WlsPosColor.orangey_red,
                                )).pOnly(bottom: 10)
                          ],
                        ),
                      ],
                    ).pOnly(left: 25, right: 25),
                  ),
            transaction.isEmpty
                ? Center(child: Text(screenMsg))
                : Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: transaction.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 70,
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    alignment: Alignment.center,
                                    color:
                                        WlsPosColor.light_grey.withOpacity(0.5),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                                getDate(
                                                    transaction[index].txnDate),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: WlsPosColor.black
                                                        .withOpacity(0.5),
                                                    fontSize: 14))
                                            .pOnly(bottom: 2),
                                        Text(
                                          getTime(transaction[index].txnDate),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: WlsPosColor.black_four
                                                  .withOpacity(0.5)),
                                        ),
                                      ],
                                    ).pOnly(left: 15, right: 15),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(transaction[index].txnTyeCode,
                                                style: const TextStyle(
                                                    color: WlsPosColor.black))
                                            .pOnly(bottom: 10),
                                        Text(
                                          "Player: ${transaction[index].PlayerMobile}",
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: WlsPosColor.black_four
                                                  .withOpacity(0.6),
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "User Id: ${transaction[index].userId} | Txn Id: ${transaction[index].txnId}",
                                          style: TextStyle(
                                            color: WlsPosColor.black_four
                                                .withOpacity(0.5),
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).pOnly(left: 5, right: 5),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(transaction[index].txnValue,
                                                style: TextStyle(
                                                    color: transaction[index]
                                                                .txnTyeCode ==
                                                            'WITHDRAWAL'
                                                        ? WlsPosColor
                                                            .shamrock_green
                                                        : WlsPosColor
                                                            .orangey_red,
                                                    fontWeight:
                                                        FontWeight.bold))
                                            .pOnly(bottom: 10),
                                        Text('Bal Amt',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: WlsPosColor.black_four
                                                    .withOpacity(0.4))),
                                        FittedBox(
                                          child: Text(
                                              transaction[index].balancePostTxn,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: WlsPosColor.black_four
                                                      .withOpacity(0.6))),
                                        ),
                                      ],
                                    ).pOnly(right: 15),
                                  )
                                ],
                              ),
                              const Divider(
                                height: 2,
                                // color: Colors.blue,
                              )
                            ],
                          ),
                          /* Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * 0.25,
                                alignment: Alignment.center,
                                color: WlsPosColor.light_grey.withOpacity(0.5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(getDate(transaction[index].txnDate),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(getTime(transaction[index].txnDate)),
                                  ],
                                ).pOnly(left: 15, right: 15),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction[index].txnTyeCode,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ).pOnly(bottom: 10),
                                    Text(
                                      "Player: ${transaction[index].PlayerMobile}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "User Id: ${transaction[index].userId} | Txn Id: ${transaction[index].txnId}"),
                                  ],
                                ),
                              ).pOnly(left: 5, right: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(transaction[index].txnValue,
                                            style: TextStyle(
                                                color: transaction[index]
                                                            .txnTyeCode ==
                                                        'WITHDRAWAL'
                                                    ? WlsPosColor.shamrock_green
                                                    : WlsPosColor.orangey_red,
                                                fontWeight: FontWeight.bold))
                                        .pOnly(bottom: 10),
                                    const Text('Bal Amt'),
                                    Text(transaction[index].balancePostTxn),
                                  ],
                                ).pOnly(right: 15),
                              )
                            ],
                          ),*/
                          //Text(transaction[index].deposit),
                        ),
                        isLoading
                            ? const Center(child: LoadingIndicator())
                            : const SizedBox(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  initData() {
    BlocProvider.of<DepWithBloc>(context).add(
      GetDepWith(
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
      ),
    );
  }

  String getDate(String? createdAt) {
    String fromDate = formatDate(
      date: DateTime.now().subtract(const Duration(days: 30)).toString(),
      inputFormat: Format.apiDateFormat2,
      outputFormat: Format.dateFormat,
    );
    List<String> splitTag = fromDate.split(",");
    String? splitTag1 = splitTag[0];
    return splitTag1;
  }

  String getTime(String? createdAt) {
    String fromDate = formatDate(
      date: DateTime.now().subtract(const Duration(days: 30)).toString(),
      inputFormat: Format.apiDateFormat2,
      outputFormat: Format.dateFormat,
    );
    List<String> splitTag = fromDate.split(",");
    String? splitTag2 = splitTag[1];
    return splitTag2;
  }
}
