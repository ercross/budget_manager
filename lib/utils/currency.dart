import 'package:flutter/material.dart';

class Currency {

  
  static String format(double value) {
    String fValue = "";
    final String textValue = value.toStringAsFixed(0);
    final int length = value.toStringAsFixed(0).length;
    if(value > 9999) {
      
      for(int i = length-4; i !=-1 ; i-3) {
        if (i<3) fValue = textValue.substring(0, i) + fValue;
        else {
          String temp = ",${textValue.substring(length-3, length)}";
          print(temp);
          fValue = temp + fValue;
        }
      }
    }
    else return value.toStringAsFixed(0);
    return fValue;
  }

  static List<DropdownMenuItem<String>> currencies =[
      DropdownMenuItem(child: Text(String.fromCharCodes([0x0024])), value: String.fromCharCodes([0x0024]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x00A2])), value: String.fromCharCodes([0x00A2]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x00A3])), value: String.fromCharCodes([0x00A3]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x00A4])), value: String.fromCharCodes([0x00A4]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x00A5])), value: String.fromCharCodes([0x00A5]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x058F])), value: String.fromCharCodes([0x058F]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x060B])), value: String.fromCharCodes([0x060B]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x07FE])), value: String.fromCharCodes([0x07FE]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x07FF])), value: String.fromCharCodes([0x07FF]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x09F2])), value: String.fromCharCodes([0x09F2]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x09F3])), value: String.fromCharCodes([0x09F3]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x09FB])), value: String.fromCharCodes([0x09FB]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x0AF1])), value: String.fromCharCodes([0x0AF1]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x0BF9])), value: String.fromCharCodes([0x0BF9]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x0E3F])), value: String.fromCharCodes([0x0E3F]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x17DB])), value: String.fromCharCodes([0x17DB]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A0])), value: String.fromCharCodes([0x20A0]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A1])), value: String.fromCharCodes([0x20A1]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A2])), value: String.fromCharCodes([0x20A2]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A3])), value: String.fromCharCodes([0x20A3]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A4])), value: String.fromCharCodes([0x20A4]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A5])), value: String.fromCharCodes([0x20A5]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A6])), value: String.fromCharCodes([0x20A6]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A7])), value: String.fromCharCodes([0x20A7]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A8])), value: String.fromCharCodes([0x20A8]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20A9])), value: String.fromCharCodes([0x20A9]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20AA])), value: String.fromCharCodes([0x20AA]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20AB])), value: String.fromCharCodes([0x20AB]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20AC])), value: String.fromCharCodes([0x20AC]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20AD])), value: String.fromCharCodes([0x20AD]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20AE])), value: String.fromCharCodes([0x20AE]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20AF])), value: String.fromCharCodes([0x20AF]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B0])), value: String.fromCharCodes([0x20B0]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B1])), value: String.fromCharCodes([0x20B1]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B2])), value: String.fromCharCodes([0x20B2]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B3])), value: String.fromCharCodes([0x20B3]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B4])), value: String.fromCharCodes([0x20B4]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B5])), value: String.fromCharCodes([0x20B5]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B6])), value: String.fromCharCodes([0x20B6]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B7])), value: String.fromCharCodes([0x20B7]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B8])), value: String.fromCharCodes([0x20B8]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20B9])), value: String.fromCharCodes([0x20B9]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20BA])), value: String.fromCharCodes([0x20BA]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20BB])), value: String.fromCharCodes([0x20BB]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20BC])), value: String.fromCharCodes([0x20BC]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20BD])), value: String.fromCharCodes([0x20BD]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20BE])), value: String.fromCharCodes([0x20BE]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0x20BF])), value: String.fromCharCodes([0x20BF]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0xA838])), value: String.fromCharCodes([0xA838]),),
      DropdownMenuItem(child: Text(String.fromCharCodes([0xFDFC])), value: String.fromCharCodes([0xFDFC]),),
    ];
}