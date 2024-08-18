import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class LanguageBottomSheet extends StatefulWidget {
  String lang;
  Function(String) mCallBack;
  LanguageBottomSheet({Key? key,required  this.lang, required this.mCallBack}) : super(key: key);

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height/2.2,
      child: Column(
        children:  [
          const Text("Choose Language",
            style: TextStyle(
                color: WlsPosColor.black,
                fontSize: 23,
                fontWeight: FontWeight.w500
            ),
          ).pOnly(top: 20),
          Column(
            children: [
              RadioListTile(
                title: const Text("English"),
                value: "eng",
                groupValue: widget.lang,
                onChanged: (value){
                  setState(() {
                    widget.lang = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: const Text("Hindi"),
                value: "hi",
                groupValue: widget.lang,
                onChanged: (value){
                  setState(() {
                    widget.lang = value.toString();
                  });
                },
              )
            ],
          ).pOnly(top: 30, left: 10),
          InkWell(
            onTap: () {
              widget.mCallBack(widget.lang);
              Navigator.of(context).pop();
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: BoxDecoration(
                  color: WlsPosColor.icon_green,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: const Text("Submit",
                style: TextStyle(
                    color: WlsPosColor.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ).p(10),
            ).pOnly(top: 20),
          )
        ],
      ),
    );
  }
}
