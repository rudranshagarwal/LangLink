import 'package:flutter/material.dart';

class Prefix extends StatefulWidget {
  @override
  State<Prefix> createState() => _PrefixState();
}

class _PrefixState extends State<Prefix> {
  var selectedValue = "+91";
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "+91", child: Text("+91")),
      const DropdownMenuItem(value: "+040", child: Text("+040")),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 85,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: const Color.fromRGBO(121, 116, 126, 1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: DropdownButton(
        underline: Container(),
        value: selectedValue,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
          });
        },
        items: dropdownItems),
    );
  }
}
