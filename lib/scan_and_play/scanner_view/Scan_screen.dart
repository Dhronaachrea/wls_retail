import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/scan_and_play/depositScreen/bloc/deposit_bloc.dart';
import 'package:wls_pos/scan_and_play/depositScreen/bloc/deposit_state.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';

import '../../utility/widgets/scanner_error.dart';
import '../../utility/wls_pos_color.dart';
import '../depositScreen/bloc/deposit_event.dart';

class ScanScreen extends StatefulWidget {

  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanLoginScreenState();
}

class _ScanLoginScreenState extends State<ScanScreen> {
  final MobileScannerController _scanController =
      MobileScannerController(autoStart: true);

  bool flashOn = false;

  bool _pendingWithdrawalLoader = false;
  String mRequestId = "";
  String mDomainId = "";
  String mAliasId = "";
  String mUserId = "";
  String mAmount = "";
  String mTxnId = "";
  String mCurrentData = "";
  bool isLastResultOrRePrintingOrCancelling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    return BlocListener<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is ScanQrCodeSuccess) {

           // widget.onTap(state);
            Navigator.pop(context, state.response.data.toString());
          } else if (state is ScanQrCodeError) {
            ShowToast.showToast(context, state.errorMessage);
            setState(() {
              _scanController.start();
            });
          }
        },
        child: WlsPosScaffold(
          showAppBar: true,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    "Scan QR Code",
                    style: TextStyle(
                        color: WlsPosColor.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width > 700
                      ? MediaQuery.of(context).size.width / 4
                      : MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      MobileScanner(
                        errorBuilder: (context, error, child) {
                          return ScannerError(
                            context: context,
                            error: error,
                          );
                        },
                        controller: _scanController,
                        onDetect: (capture) {
                          _scanController.stop();
                          try {
                            setState(() {
                              List<Barcode> barcodes = capture.barcodes;
                              String? data = barcodes[0].rawValue;
                              if (data != null) {
                                Uri uri = Uri.parse(data);
                                print("URI: $uri");
                                String? dataValue = uri.queryParameters['data'];
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  BlocProvider.of<DepositBloc>(context).add(
                                      ScanQrCodeData(
                                          context: context,
                                          data: dataValue.toString()));
                                });
                              }
                            });
                          } catch (e) {
                            _scanController.start();

                            print("Something Went wrong with bar code: $e");
                          }
                        },
                      ),
                      Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              // on and off splash
                              setState(() {
                                flashOn = !flashOn;
                                _scanController.toggleTorch();
                                // controller?.toggleFlash();

                                // _scanController.toggleTorchMode();
                              });
                            },
                            child: Icon(
                              (flashOn ? Icons.flash_on : Icons.flash_off),
                              color: WlsPosColor.reddish_pink,
                              size: 30,
                            ).p(10),
                          )),
                      _pendingWithdrawalLoader
                          ? const Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator())
                          : Container(),
                      Visibility(
                        visible: isLastResultOrRePrintingOrCancelling,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: WlsPosColor.black.withOpacity(0.7),
                          child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Lottie.asset(
                                      'assets/lottie/gradient_loading.json'))),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
