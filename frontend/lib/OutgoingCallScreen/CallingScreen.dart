import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:project4/Wallpaper.dart';
import '../CallScreen/CallScreen.dart';
import '../globals.dart' as globals;


class CallingScreen extends StatefulWidget {
  static const routeName = '/calling-screen';

  const CallingScreen({super.key});
  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> with RouteAware {

  bool endCall = false;
  bool startCall = false;
  String callStatus = 'Calling';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    globals.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    globals.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    initSockets();
  }

  void initSockets() {
    log('callingScreen SocketInit');

    startCall = false;
    endCall = false;

    globals.globalsocket.on('${globals.userID} Calling', (data) async{
      globals.callID = data['callID'];
      globals.globalsocket.off('${globals.userID} Calling');
      setState(() {
        callStatus = 'Ringing';
      });
    });

    globals.globalsocket.on('${globals.userID} CallStart', (data) async {
      if (data['Status'] == 'ongoing') {
        globals.globalsocket.off('${globals.userID} CallStart');
        globals.globalsocket.off('${globals.userID} CallEnd');
        setState(() {
          startCall = true;
        });
      }
    });

    globals.globalsocket.on('${globals.userID} CallEnd', (data) async {
      log(data['Status']);
      if(data['Status'] == 'declined' || data['Status'] == 'missed') {
        globals.globalsocket.off('${globals.userID} IncomingText');
        globals.globalsocket.off('${globals.userID} TextSent');
        globals.globalsocket.off('${globals.userID} CallEnd');
        setState(() {
          endCall = true;
          startCall = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;
    final width = mediaQuery.size.width;
    final padding = mediaQuery.padding.top;
    final routeArgs = (ModalRoute.of(context)!.settings.arguments ?? <String, dynamic>{}) as Map;
    String contactName = routeArgs['name'];

    if(endCall == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      endCall = false;
    }

    if(startCall == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(
          CallScreen.routeName,
          arguments: {
            'name': contactName,
          }
        );
      });
      startCall = false;
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: padding,
            ),
            Stack(children: <Widget>[
              Wallpaper(width, height / 3),
              Container(
                alignment: Alignment.center,
                height: height / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: height / 20,
                      backgroundColor: Colors.red,
                      child: Text(contactName[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height / 20
                          )
                      ),
                    ),
                    SizedBox(
                      height: height / 20,
                    ),
                    Text(contactName,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height / 25
                      )
                    ),
                  ],
                ),
              )
            ]
            ),
            SizedBox(
              height: height / 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(callStatus),
              ],
            ),
            SizedBox(
              height: height / 3,
            ),
            FloatingActionButton(
              heroTag: 'endCall',
              onPressed: () async {
                globals.globalsocket.emit(
                  '${globals.userID} CallCut',
                  {
                    'id': globals.userID,
                    'callID': globals.callID
                  }
                );
              },
              backgroundColor: Colors.red,
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
