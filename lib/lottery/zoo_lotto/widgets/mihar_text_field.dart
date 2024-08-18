import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class MiharTextField extends StatefulWidget {
  List<TextEditingController> controller;
  List<FocusNode> focusNode;
  int maxLength;
  TextInputType keyboardType;
  Function(String) onChange;
  int index;

  MiharTextField({Key? key, required this.controller, required this.focusNode, required this.maxLength, required this.keyboardType, required this.onChange, required this.index}) : super(key: key);

  @override
  _MiharTextFieldState createState() => _MiharTextFieldState();
}

class _MiharTextFieldState extends State<MiharTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      cursorColor: WlsPosColor.black,
      controller: widget.controller[widget.index],
      focusNode: widget.focusNode[widget.index],
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      style: TextStyle(
          color: WlsPosColor.black
      ),
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(
              color: WlsPosColor.light_grey
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: WlsPosColor.light_grey),
          borderRadius: BorderRadius.circular(10.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: WlsPosColor.black_four),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onChanged: (value){
          widget.onChange(value);
      },
      validator: (inputValue){
        if(inputValue!.isEmpty){
          return "Please enter number";
        }
        return null;
      },
    );
  }
}
