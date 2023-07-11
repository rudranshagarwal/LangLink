import 'package:flutter/material.dart';
import '../Logo.dart';
import '../TabsScreen/TabsScreen.dart';
import '../globals.dart' as globals;


class EnterotpWidget extends StatefulWidget {
  static const routeName = '/enter-otp-widget';

  const EnterotpWidget({super.key});

  @override
  State<EnterotpWidget> createState() => EnterotpWidgetState();
}

class EnterotpWidgetState extends State<EnterotpWidget> {
  String otp = '';
  final List<TextEditingController> otpControllers = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController(),];
  final List<FocusNode> otpFocusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode(),];
  final List<int> otpField = [0, 0, 0, 0];


  final url = globals.url;

  verifyOTP(otp, phonenumber) {
    globals.globalsocket.on('${globals.userID} VerifiedOTP', (data) async {
      if (data['verified'] == 'yes') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          TabsScreen.routeName,
          (Route<dynamic> route) => false
        );
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Verification Code"),
                content: Text('Wrong otp'),
              );
            });
        setState(() {});
      }
    });
    var data = {
      "id": globals.userID,
      "otp": otp
    };
    globals.globalsocket.emit('${globals.userID} VerifyOTP', data);
  }

  void submitotp() {
    if (otp.length < 4) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Verification Code"),
              content: Text('OTP entered is not of sufficient length'),
            );
          });
      setState(() {});
    } else if (otp.length == 4) {
      verifyOTP(otp, globals.phoneNumber);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Verification Code"),
              content: Text('Re-enter the otp'),
            );
          });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;

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
                const SizedBox(
                  height: 20,
                ),
                Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text('OTP sent to'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(globals.phoneNumber),
                      ]),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: otpControllers[0],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                          focusNode: otpFocusNodes[0],
                          onChanged: (value) {
                            if (value.length == 1) {
                              otpFocusNodes[1].requestFocus();
                              otpField[0] = 1;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: otpControllers[1],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          focusNode: otpFocusNodes[1],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                          onChanged: (value) {
                            if (value.length == 1) {
                              otpFocusNodes[2].requestFocus();
                              otpField[1] = 1;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: otpControllers[2],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                          focusNode: otpFocusNodes[2],
                          onChanged: (value) {
                            if (value.length == 1) {
                              otpFocusNodes[3].requestFocus();
                              otpField[2] = 1;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: otpControllers[3],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                          focusNode: otpFocusNodes[3],
                          onChanged: (value) {
                            if (value.length == 1) {
                              otpFocusNodes[3].unfocus();
                              otpField[3] = 1;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            otp = otpControllers[0].text + otpControllers[1].text + otpControllers[2].text + otpControllers[3].text;
                            submitotp();
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
                          child: const Text('LOGIN'),
                        ),
                      ]),
                ]),
              ])),
        ),
      ),
    );
  }
}
