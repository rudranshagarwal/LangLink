import 'package:flutter/material.dart';
import '../OTPScreen/EnterotpWidget.dart';
import './Prefix.dart';
import './PhoneNumberField.dart';
import '../Logo.dart';
import '../globals.dart' as globals;

class EnterphonenumberWidget extends StatefulWidget {
  const EnterphonenumberWidget({super.key});

  @override
  _EnterphonenumberWidgetState createState() => _EnterphonenumberWidgetState();
}

class _EnterphonenumberWidgetState extends State<EnterphonenumberWidget> {
  final numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;

    sendOTP(phoneNumber) {
      globals.globalsocket.on('${globals.phoneNumber} UserID', (data) {
        globals.userID = data['id'];
      });
      var data = {"phoneNumber": globals.phoneNumber};
      globals.globalsocket.emit('PhoneNumber', data);
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
              height: (height),
              child: Column(children: <Widget>[
                Logo(mediaQuery.size.width, height * 0.5),
                const SizedBox(height: 40),
                Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text('Login/SignUp'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Prefix(),
                      const SizedBox(width: 10),
                      PhoneNumberField(numberController),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            globals.phoneNumber = '+91${numberController.text}';
                            sendOTP(globals.phoneNumber);
                            Navigator.of(context).pushNamed(
                              EnterotpWidget.routeName,
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 44, 111, 255)),
                            minimumSize: MaterialStateProperty.all<Size>(const Size(150, 40)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          child: const Text('Send OTP'),
                        ),
                      ]),
                ]),
              ])),
        ),
      ),
    );
  }
}
