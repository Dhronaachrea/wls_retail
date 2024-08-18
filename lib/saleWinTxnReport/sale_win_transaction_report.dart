import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/saleWinTxnReport/bloc/sale_win_bloc.dart';
import 'package:wls_pos/saleWinTxnReport/bloc/sale_win_event.dart';
import 'package:wls_pos/saleWinTxnReport/bloc/sale_win_state.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import '../utility/date_format.dart';
import '../utility/utils.dart';
import '../utility/widgets/selectdate/bloc/select_date_bloc.dart';
import '../utility/widgets/selectdate/forward.dart';
import '../utility/widgets/selectdate/select_date.dart';
import '../utility/widgets/show_snackbar.dart';
import '../utility/widgets/wls_pos_scaffold.dart';
import 'model/get_sale_report_response.dart';
import 'model/get_service_list_response.dart';

class SaleWinTransactionReport extends StatefulWidget {
  const SaleWinTransactionReport({Key? key}) : super(key: key);

  @override
  State<SaleWinTransactionReport> createState() =>
      _SaleWinTransactionReportState();
}

bool loading = false;
List<Data> data = [];

class _SaleWinTransactionReportState extends State<SaleWinTransactionReport> {
  String _selectedItem = "";
  String serviceCode = "";

  final List<String> _picGroup = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SaleWinBloc>(context)
        .add(SaleList(context: context, url: ""));
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
      showAppBar: true,
      centerTitle: false,
      appBarTitle: const Text('Sale Win Txn. Report', style: TextStyle(fontSize: 18)),
      body: Column(
        children: <Widget>[
          BlocBuilder<SaleWinBloc, SaleWinState>(builder: (context, state) {
            if (state is SaleListLoading) {
            } else if (state is SaleListError) {
              loading = false;
              ShowToast.showToast(context, state.errorMessage.toString(),
                  type: ToastType.ERROR);
            } else if (state is SaleListSuccess) {
              data = state.response.responseData!.data!;

              for (var element in data) {
                _picGroup.add(element.serviceDisplayName!);
              }

              _selectedItem = data[0].serviceDisplayName!;

              initData();
            }

            return Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.grey,
                width: 1,
              )),
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                height: 48,
                child: DropdownButtonFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                    ),
                    isExpanded: true,
                    isDense: true,
                    value: _selectedItem,
                    selectedItemBuilder: (BuildContext context) {
                      return _picGroup.map<Widget>((String item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList();
                    },
                    items: _picGroup.map((item) {
                      if (item == _selectedItem) {
                        return DropdownMenuItem(
                          value: item,
                          child: Container(
                              height: 48.0,
                              width: double.infinity,
                              color: WlsPosColor.light_dark_white,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item,
                                ),
                              )),
                        );
                      } else {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }
                    }).toList(),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Cannot Empty' : null,
                    onChanged: (item) => {_selectedItem = item!}),
              ),
            ).pSymmetric(v: 5, h: 5);
          }),
          Row(
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
          ),
          BlocBuilder<SaleWinBloc, SaleWinState>(builder: (context, state) {
            if (state is SaleWinTaxListLoading) {
              return const Expanded(
                  child: Center(child: CircularProgressIndicator()));
            }
            else if (state is SaleWinTaxListError) {
              var errorMsg = state.errorMessage;
              return Expanded(
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(errorMsg),
                  ).p(10),
                ),
              );
            }
            else if (state is SaleWinTaxListSuccess) {
              DataValue? _saleWinTax = state.response.responseData?.data;
              return Expanded(
                  child: Column(
                children: [
                  Container(
                    color: WlsPosColor.warm_grey,
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Total Sale',
                                style: TextStyle(color: WlsPosColor.black_four),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    _saleWinTax?.total?.sumOfSale?.toString() ??
                                        "",
                                    style: const TextStyle(
                                        color: WlsPosColor.shamrock_green)),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Total Winning',
                                style: TextStyle(color: WlsPosColor.black_four),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    _saleWinTax?.total?.sumOfWinning
                                            ?.toString() ??
                                        "",
                                    style: const TextStyle(
                                        color: WlsPosColor.shamrock_green)),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Net Amount',
                                style: TextStyle(color: WlsPosColor.black_four),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    _saleWinTax?.total?.netSale?.toString() ??
                                        "",
                                    style: TextStyle(
                                      color: double.parse(_saleWinTax
                                                      ?.total?.rawNetSale ??
                                                  "0.0") >
                                              0.0
                                          ? WlsPosColor.shamrock_green
                                          : WlsPosColor.tomato,
                                    )),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Total Comm.',
                                style: TextStyle(color: WlsPosColor.black_four),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    _saleWinTax?.total?.rawNetCommission
                                            ?.toString() ??
                                        "",
                                    style: const TextStyle(
                                        color: WlsPosColor.shamrock_green)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ).pOnly(left: 15, right: 15),
                  ),
                  if (_saleWinTax?.transactionData!.isNotEmpty ?? false)
                    Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _saleWinTax?.transactionData!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 100,
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                    getDate(_saleWinTax
                                                        ?.transactionData![
                                                            index]
                                                        .createdAt),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: WlsPosColor.black
                                                            .withOpacity(0.5),
                                                        fontSize: 14))
                                                .pOnly(bottom: 2),
                                            Text(
                                              getTime(_saleWinTax
                                                  ?.transactionData![index]
                                                  .createdAt),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: WlsPosColor.black_four
                                                      .withOpacity(0.5)),
                                            ),
                                          ],
                                        ).pOnly(left: 15, right: 15),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("${_saleWinTax?.transactionData![index].txnTypeCode ?? ""} : ${_saleWinTax?.transactionData![index].gameName ?? ""}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            WlsPosColor.black))
                                                .pOnly(bottom: 10),
                                            Text(
                                              "${"User id"} : ${_saleWinTax?.transactionData![index].userId ?? ""}",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: WlsPosColor.black_four
                                                      .withOpacity(0.5),
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "${"Transaction id"} : ${_saleWinTax?.transactionData![index].txnId ?? ""}",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: WlsPosColor.black_four
                                                      .withOpacity(0.5),
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "${"Comm Amt"} : ${_saleWinTax?.transactionData![index].orgCommValue ?? ""}",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: WlsPosColor.black_four
                                                      .withOpacity(0.5),
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ).pOnly(left: 5, right: 5),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                    _saleWinTax
                                                            ?.transactionData![
                                                                index]
                                                            .txnValue ??
                                                        "",
                                                    style: TextStyle(
                                                        color: (_saleWinTax
                                                                        ?.transactionData![
                                                                            index]
                                                                        .txnTypeCode ??
                                                                    "") ==
                                                                "Sale"
                                                            ? WlsPosColor.tomato
                                                            : WlsPosColor
                                                                .shamrock_green,
                                                        fontWeight:
                                                            FontWeight.bold))
                                                .pOnly(bottom: 10),
                                            Text('Bal Amt',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: WlsPosColor
                                                        .black_four
                                                        .withOpacity(0.4))),
                                            FittedBox(
                                              child: Text(
                                                  _saleWinTax
                                                          ?.transactionData![
                                                              index]
                                                          .orgNetAmount ??
                                                      "",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: WlsPosColor
                                                          .black_four
                                                          .withOpacity(0.6))),
                                            ),
                                          ],
                                        ).pOnly(right: 15),
                                      )
                                    ],
                                  ),
                                  Container(
                                      child: const Divider(
                                    height: 2,
                                    // color: Colors.blue,
                                  ))
                                ],
                              );
                            }))
                  else
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'No Data Available!',
                        style: TextStyle(
                            color: WlsPosColor.black_four.withOpacity(0.5)),
                      ).p(10),
                    )),
                ],
              ));
            }
            return Container();
          })
        ],
      ),
    );
  }

  initData() {
    for (var element in data) {
      if (element.serviceDisplayName == _selectedItem) {
        serviceCode = element.serviceCode!;
      }
    }
    BlocProvider.of<SaleWinBloc>(context).add(SaleWinTxnReport(
      context: context,
      serviceCode: serviceCode,
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

  String getDate(String? createdAt) {
    String fromDate = formatDate(
      date: createdAt!,
      inputFormat: Format.apiDateFormat,
      outputFormat: Format.dateFormat,
    );
    List<String> splitag = fromDate.split(",");
    String? splitag1 = splitag[0];
    return splitag1;
  }

  String getTime(String? createdAt) {
    String fromDate = formatDate(
      date: createdAt!,
      inputFormat: Format.apiDateFormat,
      outputFormat: Format.dateFormat,
    );
    List<String> splitag = fromDate.split(",");
    String? splitag2 = splitag[1];
    return splitag2;
  }
}
