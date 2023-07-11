import 'package:flutter/material.dart';
import 'PhoneNumberScreen/EnterphonenumberWidget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'OTPScreen/EnterotpWidget.dart';
import 'IncomingCallScreen/ReceiveCall.dart';
import 'TabsScreen/TabsScreen.dart';
import 'CallScreen/CallScreen.dart';
import 'OutgoingCallScreen/CallingScreen.dart';
import 'TranscriptScreen/TranscriptScreen.dart';
import 'globals.dart' as globals;

void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState(){
    globals.globalsocket = IO.io(
        globals.url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    globals.globalsocket.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [globals.routeObserver],
      routes: {
        '/': (ctx) => const EnterphonenumberWidget(),
        EnterotpWidget.routeName: (ctx) => const EnterotpWidget(),
        ReceiveCall.routeName: (ctx) => const ReceiveCall(),
        TabsScreen.routeName: (ctx) => const TabsScreen(),
        CallScreen.routeName: (ctx) => const CallScreen(),
        CallingScreen.routeName: (ctx) => const CallingScreen(),
        TranscriptScreen.routeName:(ctx) => const TranscriptScreen()
      },
    );
  }
}