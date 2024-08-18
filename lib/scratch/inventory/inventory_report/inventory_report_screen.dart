import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/bloc/inv_rep_bloc.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/inv_widget/inv_widget.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

import 'model/request/inv_rep_details.dart';
import 'model/response/inv_rep_response.dart';

class InventoryReportScreen extends StatefulWidget {
  final MenuBeanList? menuBeanList;

  const InventoryReportScreen({Key? key, required this.menuBeanList})
      : super(key: key);

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  List<GameWiseBookDetailList>? gameWiseBookDetailList;
  bool mIsShimmerLoading = false;

  @override
  void initState() {
    BlocProvider.of<InvRepBloc>(context).add(
      InvRepForRetailer(context: context, menuBeanList: widget.menuBeanList),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WlsPosScaffold(
      showAppBar: true,
      centerTitle: false,
      appBarTitle: Text(widget.menuBeanList?.caption ?? ''),
      body: BlocListener<InvRepBloc, InvRepState>(
        listener: (context, state) {
          log("state : $state");
          if (state is GettingInvRepForRet) {
            setState(() {
              mIsShimmerLoading = true;
            });
          } else if (state is GotInvRepForRet) {
            setState(() {
              gameWiseBookDetailList = state.response.gameWiseBookDetailList;
              mIsShimmerLoading = false;
            });
          } else if (state is InvRepForRetError) {
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
                buttonClick: () {
                  Navigator.of(context).pop();
                });
          }
        },
        child: GridView.builder(
            itemCount: mIsShimmerLoading ? 10 : gameWiseBookDetailList?.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.7),
            itemBuilder: (context, cardIndex) {
              return mIsShimmerLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[300]!,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: WlsPosColor.warm_grey,
                              blurRadius: 1.0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.grey[400]!,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                            ).pOnly(bottom: 10),
                            Container(
                              width: 80,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Colors.grey[400]!,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  )),
                            ),
                          ],
                        ),
                      ).p(6),
                    )
                  : gameWiseBookDetailList != null &&
                          gameWiseBookDetailList!.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            List<InvRepDetailsModel> invRepDetailList = [];
                            if(gameWiseBookDetailList![cardIndex].inTransitPacksList != null){
                              invRepDetailList.add(InvRepDetailsModel(title : "In-Transit" , packList : gameWiseBookDetailList![cardIndex].inTransitPacksList!),);
                            }
                            if(gameWiseBookDetailList![cardIndex].receivedPacksList != null){
                              invRepDetailList.add(InvRepDetailsModel(title : "Received" , packList : gameWiseBookDetailList![cardIndex].receivedPacksList!),);
                            }
                            if(gameWiseBookDetailList![cardIndex].activatedPacksList != null){
                              invRepDetailList.add(InvRepDetailsModel(title : "Activated" , packList : gameWiseBookDetailList![cardIndex].activatedPacksList!),);
                            }
                            if(gameWiseBookDetailList![cardIndex].invoicedPacksList != null){
                              invRepDetailList.add(InvRepDetailsModel(title : "In-Voice" , packList : gameWiseBookDetailList![cardIndex].invoicedPacksList!),);
                            }
                            InvRepDetail().show(
                              context: context,
                              title: "Books",
                              invRepDetailList: invRepDetailList,
                            );
                          },
                          child: InvRepCard(
                            gameWiseBookDetailList: gameWiseBookDetailList,
                            cardIndex: cardIndex,
                          ),
                        )
                      : Container();
            }),
      ),
    );
  }
}
