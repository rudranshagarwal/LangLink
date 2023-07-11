import 'package:flutter/material.dart';
import '../CallScreen/CallScreen.dart';
import '../Wallpaper.dart';
import '../globals.dart' as globals;

class ReceiveCall extends StatefulWidget {
  static const routeName = '/ReceiveCall';

  const ReceiveCall({super.key});

  @override
  State<ReceiveCall> createState() => _ReceiveCallState();
}


class _ReceiveCallState extends State<ReceiveCall>{

  @override
  void initState(){
    super.initState();

    globals.globalsocket.on('${globals.userID} MissedCall', (data) async {
      if(data['Status'] == 'missed') {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;
    final width = mediaQuery.size.width;
    final routeArgs = ModalRoute.of(context)!.settings.arguments;
    final contactName = (routeArgs as Map<String, dynamic>)['name'] as String;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          width: width,
          child: Column(children: <Widget>[
            Stack(
              children: <Widget>[
                Wallpaper(width, height / 2),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: height / 4,
                      ),
                      CircleAvatar(
                        radius: height / 20,
                        backgroundColor: const Color.fromRGBO(255, 122, 0, 1),
                        child: Text(
                          contactName[0],
                          style: TextStyle(
                              color: Colors.white, fontSize: height / 20),
                        ),
                      ),
                      SizedBox(
                        height: height / 30,
                      ),
                      Text(
                        contactName,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: height / 20, color: Colors.white
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: height / 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    globals.globalsocket.emit('${globals.userID} CallAccepted', {'id': globals.userID, 'callID': globals.callID});
                    Navigator.of(context).pushReplacementNamed(
                      CallScreen.routeName,
                      arguments: {
                        'name': contactName,
                      }
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(0, 255, 0, 1),
                    radius: height / 30,
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                    )
                  ),
                ),
                SizedBox(
                  width: width / 6,
                ),
                GestureDetector(
                  onTap: () {
                    globals.globalsocket.emit('${globals.userID} CallCut', {'id': globals.userID, 'callID': globals.callID});
                    globals.callID = "";
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    radius: height / 30,
                    backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white
                    )
                  ),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}