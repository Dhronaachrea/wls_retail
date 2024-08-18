import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/bloc/inv_flow_bloc.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/inv_flow_widget/inv_flow_widget.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/model/response/inv_flow_response.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/primary_button.dart';
import 'package:wls_pos/utility/widgets/selectdate/bloc/select_date_bloc.dart';
import 'package:wls_pos/utility/widgets/selectdate/forward.dart';
import 'package:wls_pos/utility/widgets/selectdate/select_date.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import 'inv_flow_widget/inv_flow_print.dart';

class InventoryFlowScreen extends StatefulWidget {
  final MenuBeanList? menuBeanList;

  const InventoryFlowScreen({Key? key, required this.menuBeanList})
      : super(key: key);

  @override
  State<InventoryFlowScreen> createState() => _InventoryFlowScreenState();
}

class _InventoryFlowScreenState extends State<InventoryFlowScreen> {
  bool mIsShimmerLoading = false;

  InvFlowResponse? invFlowResponse;
  List<GameWiseClosingBalanceData>? gameWiseClosingBalanceData;
  bool showGameWiseClosingBalanceData = false;
  List<GameWiseClosingBalanceData>? gameWiseOpeningBalanceData;
  List<GameWiseData>? gameWiseData;
  bool showGameWiseOpeningBalanceData = false;
  bool showReceivedData = false;
  bool showReturnedData = false;
  bool showSoldData = false;
  double bottomViewHeight = 80;

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        appBarTitle: Text(widget.menuBeanList?.caption ?? '', style: const TextStyle(fontSize: 18)),
        body: BlocListener<InvFlowBloc, InvFlowState>(
          listener: (context, state) {
            if (state is GettingInvFlowReport) {
              setState(() {
                invFlowResponse = null;
                mIsShimmerLoading = true;
                showGameWiseOpeningBalanceData = false;
                showGameWiseClosingBalanceData = false;
                showReceivedData = false;
                showReturnedData = false;
                showSoldData = false;
              });
            } else if (state is GotInvFlowReport) {
              setState(() {
                invFlowResponse = state.response;
                if (invFlowResponse != null) {
                  gameWiseClosingBalanceData =
                      invFlowResponse!.gameWiseClosingBalanceData;
                  gameWiseOpeningBalanceData =
                      invFlowResponse!.gameWiseOpeningBalanceData;
                  gameWiseData = invFlowResponse!.gameWiseData;
                }
                mIsShimmerLoading = false;
              });
            } else if (state is InvFlowReportError) {
              setState(() {
                mIsShimmerLoading = false;
              });
              Alert.show(
                  context: context,
                  title: 'REPORT ERROR',
                  subtitle: state.errorMessage,
                  type: AlertType.error,
                  buttonText: 'OK',
                  isDarkThemeOn: false,
                  buttonClick: () {});
            }
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
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
                    const HeightBox(20),
                    mIsShimmerLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[300]!,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Text(''),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 30,
                                        margin: const EdgeInsets.all(2),
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                            color: WlsPosColor.warm_grey_eight),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 30,
                                        margin: const EdgeInsets.all(2),
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                            color: WlsPosColor
                                                .brownish_grey_seven),
                                      ),
                                    ),
                                  ],
                                ).pSymmetric(h: 8, v: 2),
                                const ShimmerRow(),
                                const ShimmerRow(),
                                const ShimmerRow(),
                                const ShimmerRow(),
                                const ShimmerRow(),
                              ],
                            ),
                          )
                        : invFlowResponse != null
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 3,
                                        child: Text(''),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                            margin: const EdgeInsets.all(2),
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                                color: WlsPosColor
                                                    .warm_grey_eight),
                                            child: const Text("Books",
                                                style: TextStyle(
                                                    color: WlsPosColor.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Roboto",
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 12.0),
                                                textAlign: TextAlign.center)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                            margin: const EdgeInsets.all(2),
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                                color: WlsPosColor
                                                    .brownish_grey_seven),
                                            child: const Text("Tickets",
                                                style: TextStyle(
                                                    color: WlsPosColor.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Roboto",
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 12.0),
                                                textAlign: TextAlign.center)),
                                      ),
                                    ],
                                  ).pSymmetric(h: 8, v: 2),
                                  FlowTableRow(
                                    typeName: "Open Balance",
                                    booksOfType:
                                        "${invFlowResponse!.booksOpeningBalance ?? 0}",
                                    ticketsOfType:
                                        "${invFlowResponse!.ticketsOpeningBalance ?? 0}",
                                    onTap: () {
                                      if (gameWiseOpeningBalanceData == null ||
                                          gameWiseOpeningBalanceData!.isEmpty) {
                                        Alert.show(
                                            context: context,
                                            title: 'Inventory Flow REPORT',
                                            subtitle: "No Data Found",
                                            type: AlertType.warning,
                                            buttonText: 'OK',
                                            isDarkThemeOn: false,
                                            buttonClick: () {});
                                      } else {
                                        setState(() {
                                          showGameWiseOpeningBalanceData = true;
                                        });
                                      }
                                    },
                                  ),
                                  FlowTableRow(
                                    typeName: "Received",
                                    booksOfType:
                                        "${invFlowResponse!.receivedBooks ?? 0}",
                                    ticketsOfType:
                                        "${invFlowResponse!.receivedTickets ?? 0}",
                                    onTap: () {
                                      if (gameWiseData == null ||
                                          gameWiseData!.isEmpty) {
                                        Alert.show(
                                            context: context,
                                            title: 'Inventory Flow REPORT',
                                            subtitle: "No Data Found",
                                            type: AlertType.warning,
                                            buttonText: 'OK',
                                            isDarkThemeOn: false,
                                            buttonClick: () {});
                                      } else {
                                        setState(() {
                                          showReceivedData = true;
                                        });
                                      }
                                    },
                                  ),
                                  FlowTableRow(
                                    typeName: "Returned",
                                    booksOfType:
                                        "${invFlowResponse!.returnedBooks ?? 0}",
                                    ticketsOfType:
                                        "${invFlowResponse!.returnedTickets ?? 0}",
                                    onTap: () {
                                      if (gameWiseData == null ||
                                          gameWiseData!.isEmpty) {
                                        Alert.show(
                                            context: context,
                                            title: 'Inventory Flow REPORT',
                                            subtitle: "No Data Found",
                                            type: AlertType.warning,
                                            buttonText: 'OK',
                                            isDarkThemeOn: false,
                                            buttonClick: () {});
                                      } else {
                                        setState(() {
                                          showReturnedData = true;
                                        });
                                      }
                                    },
                                  ),
                                  FlowTableRow(
                                    typeName: "Sales",
                                    booksOfType:
                                        "${invFlowResponse!.soldBooks ?? 0}",
                                    ticketsOfType:
                                        "${invFlowResponse!.soldTickets ?? 0}",
                                    onTap: () {
                                      if (gameWiseData == null ||
                                          gameWiseData!.isEmpty) {
                                        Alert.show(
                                            context: context,
                                            title: 'Inventory Flow REPORT',
                                            subtitle: "No Data Found",
                                            type: AlertType.warning,
                                            buttonText: 'OK',
                                            isDarkThemeOn: false,
                                            buttonClick: () {});
                                      } else {
                                        setState(() {
                                          showSoldData = true;
                                        });
                                      }
                                    },
                                  ),
                                  FlowTableRow(
                                    typeName: "Close Balance, Total Balance",
                                    booksOfType:
                                        "${invFlowResponse!.booksClosingBalance ?? 0}",
                                    ticketsOfType:
                                        "${invFlowResponse!.ticketsClosingBalance ?? 0}",
                                    onTap: () {
                                      if (gameWiseClosingBalanceData == null ||
                                          gameWiseClosingBalanceData!.isEmpty) {
                                        Alert.show(
                                            context: context,
                                            title: 'Inventory Flow REPORT',
                                            subtitle: "No Data Found",
                                            type: AlertType.warning,
                                            buttonText: 'OK',
                                            isDarkThemeOn: false,
                                            buttonClick: () {});
                                      } else {
                                        setState(() {
                                          showGameWiseClosingBalanceData = true;
                                        });
                                      }
                                    },
                                  ),
                                  //Open Balance Details
                                  showGameWiseOpeningBalanceData &&
                                          gameWiseOpeningBalanceData != null
                                      ? Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text(
                                                      "Open Balance",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                      color: WlsPosColor
                                                          .brownish_grey_seven),
                                                  child: const Text("Books",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Tickets",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                        ).pOnly(
                                          left: 8,
                                          right: 8,
                                          top: 20,
                                          bottom: 2,
                                        )
                                      : Container(),
                                  showGameWiseOpeningBalanceData &&
                                          gameWiseOpeningBalanceData != null
                                      ? Column(
                                          children: gameWiseOpeningBalanceData!
                                              .map((element) {
                                          return FlowTableRow(
                                            detailTypeName: true,
                                            typeName: element.gameName ?? "",
                                            booksOfType:
                                                "${element.totalBooks ?? ""}",
                                            ticketsOfType:
                                                "${element.totalTickets ?? ""}",
                                            onTap: () {},
                                          );
                                        }).toList()
                                          // ],
                                          )
                                      : Container(),
                                  //Open Balance Details End

                                  //Received Details
                                  const HeightBox(20),
                                  showReceivedData && gameWiseData != null
                                      ? Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Received",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                      color: WlsPosColor
                                                          .brownish_grey_seven),
                                                  child: const Text("Books",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Tickets",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                        ).pOnly(
                                          left: 8,
                                          right: 8,
                                          top: 20,
                                          bottom: 2,
                                        )
                                      : Container(),
                                  showReceivedData && gameWiseData != null
                                      ? Column(
                                          children:
                                              gameWiseData!.map((element) {
                                          return FlowTableRow(
                                            detailTypeName: true,
                                            typeName: element.gameName ?? "",
                                            booksOfType:
                                                "${element.receivedBooks ?? ""}",
                                            ticketsOfType:
                                                "${element.receivedTickets ?? ""}",
                                            onTap: () {},
                                          );
                                        }).toList()
                                          // ],
                                          )
                                      : Container(),
                                  //Received Details End

                                  //Returned Details
                                  showReturnedData && gameWiseData != null
                                      ? Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Returned",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                      color: WlsPosColor
                                                          .brownish_grey_seven),
                                                  child: const Text("Books",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Tickets",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                        ).pOnly(
                                          left: 8,
                                          right: 8,
                                          top: 20,
                                          bottom: 2,
                                        )
                                      : Container(),
                                  showReturnedData && gameWiseData != null
                                      ? Column(
                                          children:
                                              gameWiseData!.map((element) {
                                          return FlowTableRow(
                                            detailTypeName: true,
                                            typeName: element.gameName ?? "",
                                            booksOfType:
                                                "${element.returnedBooks ?? ""}",
                                            ticketsOfType:
                                                "${element.returnedTickets ?? ""}",
                                            onTap: () {},
                                          );
                                        }).toList()
                                          // ],
                                          )
                                      : Container(),
                                  //Returned Details End

                                  //Sold Details
                                  showSoldData && gameWiseData != null
                                      ? Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Sale",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                      color: WlsPosColor
                                                          .brownish_grey_seven),
                                                  child: const Text("Books",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Tickets",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                        ).pOnly(
                                          left: 8,
                                          right: 8,
                                          top: 20,
                                          bottom: 2,
                                        )
                                      : Container(),
                                  showSoldData && gameWiseData != null
                                      ? Column(
                                          children:
                                              gameWiseData!.map((element) {
                                          return FlowTableRow(
                                            detailTypeName: true,
                                            typeName: element.gameName ?? "",
                                            booksOfType:
                                                "${element.soldBooks ?? ""}",
                                            ticketsOfType:
                                                "${element.soldTickets ?? ""}",
                                            onTap: () {},
                                          );
                                        }).toList()
                                          // ],
                                          )
                                      : Container(),
                                  //Sold Details End

                                  //Close Balance Details
                                  showGameWiseClosingBalanceData &&
                                          gameWiseClosingBalanceData != null
                                      ? Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text(
                                                      "Closing Balance",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: const BoxDecoration(
                                                      color: WlsPosColor
                                                          .brownish_grey_seven),
                                                  child: const Text("Books",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: WlsPosColor
                                                              .warm_grey_eight),
                                                  child: const Text("Tickets",
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12.0),
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                        ).pOnly(
                                          left: 8,
                                          right: 8,
                                          top: 20,
                                          bottom: 2,
                                        )
                                      : Container(),
                                  showGameWiseClosingBalanceData &&
                                          gameWiseClosingBalanceData != null
                                      ? Column(
                                          children: gameWiseClosingBalanceData!
                                              .map((element) {
                                          return FlowTableRow(
                                            detailTypeName: true,
                                            typeName: element.gameName ?? "",
                                            booksOfType:
                                                "${element.totalBooks ?? ""}",
                                            ticketsOfType:
                                                "${element.totalTickets ?? ""}",
                                            onTap: () {},
                                          );
                                        }).toList()
                                          // ],
                                          )
                                      : Container()
                                  //Close Balance Details End
                                ],
                              )
                            : Container(),
                    //Bottom view padding
                    invFlowResponse != null
                        ? HeightBox(bottomViewHeight)
                        : const SizedBox(),
                  ],
                ),
              ),
              //bottomView for print
              invFlowResponse != null
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: bottomViewHeight,
                        width: context.screenWidth,
                        color: WlsPosColor.white_two,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: PrimaryButton(
                            btnBgColor1: WlsPosColor.tomato,
                            btnBgColor2: WlsPosColor.tomato,
                            borderRadius: 30,
                            text: "PRINT",
                            width: context.screenWidth / 3,
                            textColor: WlsPosColor.white,
                            onPressed: () {
                              Map<String, dynamic> printingDataArgs = {};
                              printingDataArgs['showGameWiseOpeningBalanceData'] = jsonEncode(showGameWiseOpeningBalanceData);
                              printingDataArgs['showGameWiseClosingBalanceData'] = jsonEncode(showGameWiseClosingBalanceData);
                              printingDataArgs['showReceivedData'] = jsonEncode(showReceivedData);
                              printingDataArgs['showReturnedData'] = jsonEncode(showReturnedData);
                              printingDataArgs['showSoldData'] = jsonEncode(showSoldData);

                              printingDataArgs['invFlowResponse'] = jsonEncode(invFlowResponse);

                              printingDataArgs['startDate'] = formatDate(
                                date: context.read<SelectDateBloc>().fromDate,
                                inputFormat: Format.dateFormat9,
                                outputFormat: Format.apiDateFormat3,
                              );

                              printingDataArgs['endDate'] = formatDate(
                                date: context.read<SelectDateBloc>().toDate,
                                inputFormat: Format.dateFormat9,
                                outputFormat: Format.apiDateFormat3,
                              );
                              printingDataArgs['name'] = UserInfo.userName;

                              InvFlowPrint().show(
                                  context: context,
                                  title: "Printing started",
                                  isCloseButton: true,
                                  printingDataArgs: printingDataArgs,
                                  isPrintingForSale: false);
                            },
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  void initData() {
    BlocProvider.of<InvFlowBloc>(context).add(
      InvFlowReport(
        context: context,
        menuBeanList: widget.menuBeanList,
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
      ),
    );
  }
}
