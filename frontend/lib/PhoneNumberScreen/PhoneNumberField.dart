import 'package:flutter/material.dart';

class PhoneNumberField extends StatefulWidget {

  final numberController;

  const PhoneNumberField(this.numberController, {super.key});
  @override
  State<PhoneNumberField> createState() => PhoneNumberFieldState();
}

class PhoneNumberFieldState extends State<PhoneNumberField> {



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: const Color.fromRGBO(121, 116, 126, 1),
          width: 1,
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
          height: 45,
          width: 210,
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          child: TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter phone number'
            ),
            controller: widget.numberController,
            keyboardType: TextInputType.number,
          ),
        ),
      ]),
    );
  }
}
