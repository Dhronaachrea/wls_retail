import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

// ignore: must_be_immutable
class ScannerError extends StatefulWidget {
  BuildContext context;
  MobileScannerException error;

  ScannerError({Key? key, required this.context, required this.error})
      : super(key: key);

  @override
  State<ScannerError> createState() => _ScannerErrorState();
}

class _ScannerErrorState extends State<ScannerError> {
  static const Permission cameraPermission = Permission.camera;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: WlsPosColor.game_color_black,
      child: widget.error.errorCode.name == "genericError" ||
          widget.error.errorCode.name == "permissionDenied"
          ? Center(
        child: InkWell(
            onTap: () async {
              showCustomDialog(context);
            },
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/icons/alert.png",
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Reload",
                    style: TextStyle(
                        color: WlsPosColor.white, fontSize: 24),
                  ),
                ],
              ),
            )),
      )
          : Text(widget.error.errorCode.name.toString()),
    );
  }

  Future<void> _requestPermission(context) async {
    var status = await cameraPermission.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Need Camera Permission",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("OK",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _requestPermission(context);
              },
            )
          ],
        );
      },
    );
  }
}
