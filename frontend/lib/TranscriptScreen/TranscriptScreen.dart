import 'dart:developer';

import 'package:flutter/material.dart';
import '../OutgoingCallScreen/CallingScreen.dart';
import 'TranscriptEntry.dart';
import '../globals.dart' as globals;

class TranscriptScreen extends StatefulWidget {
  static const routeName = '/transcript-page';

  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  dynamic transcript = [];

  @override
  void initState() {
    super.initState();
    globals.globalsocket.on('${globals.userID} Transcript', (data) {
      globals.globalsocket.off('${globals.userID} Transcript');
      setState(() {
        transcript = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments;
    final call = (routeArgs as Map<String, dynamic>)['call'];
    String contactName = routeArgs['name'];
    Function selectPage = routeArgs['tabChange'];


    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top - kBottomNavigationBarHeight;
    final width = mediaQuery.size.width;

    globals.globalsocket.emit('${globals.userID} GetTranscript', {
      'id': globals.userID,
      'callID': call['_id']
    });

    void pageSelect(index) {
      globals.globalsocket.off('${globals.userID} IncomingCall');
      selectPage(index);
      Navigator.of(context).pop();
    }

    var icon;
    var color;
    var start;
    var duration;
    String callInfo = '';
    String otherNumber = '';
    start = DateTime.fromMillisecondsSinceEpoch(call['StartTime']);
    start = '${start.day.toString().padLeft(2,'0')}/${start.month.toString().padLeft(2,'0')}/${start.year} - ${start.hour.toString().padLeft(2,'0')}:${start.minute.toString().padLeft(2,'0')}';
    duration = (call['Duration'] / 60000).floor();
    if(call['CallerID'] == globals.userID) {
      if(call['Status'] == 'ended') {
        icon = Icons.call_made;
        color = const Color.fromRGBO(0, 255, 0, 1);
        callInfo = 'Lasted $duration min';
      }
      if(call['Status'] == 'declined') {
        icon = Icons.call_made;
        color = Colors.red;
        callInfo = 'Declined';
      }
      if(call['Status'] == 'missed') {
        icon = Icons.call_missed_outgoing;
        color = Colors.red;
        callInfo = 'Missed';
      }
      otherNumber = call['CalleeNumber'];
    } else if(call['CalleeID'] == globals.userID) {
      if(call['Status'] == 'ended') {
        icon = Icons.call_received;
        color = const Color.fromRGBO(0, 255, 0, 1);
        callInfo = 'Lasted $duration min';
      }
      if(call['Status'] == 'declined') {
        icon = Icons.call_received;
        color = Colors.red;
        callInfo = 'Declined';
      }
      if(call['Status'] == 'missed') {
        icon = Icons.call_missed;
        color = Colors.red;
        callInfo = 'Missed';
      }
      otherNumber = call['CallerNumber'];
    }
    final appBar = AppBar(
      backgroundColor: const Color.fromRGBO(44, 111, 255, 1),
      leading: Icon(
        icon,
        color: color
      ),
      title: ListTile(
        title: SizedBox(
          width: width / 3,
          child: Text(
            contactName,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: height / 40
            ),
          )
        ),
        trailing: Column(
          children: [
            SizedBox(height: height / 40,),
            Text(
              '$start',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color)
            ),
            Text(
              callInfo,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color)
            ),
          ],
        )
      ),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(height: height / 20),
          SizedBox(
            height: (3 * height) / 4,
            child: ListView.builder(
              itemBuilder: (ctx, i) {
                return Entry(transcript[i], height);
              },
              itemCount: transcript.length,
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          globals.globalsocket.emit('${globals.userID} CallNumber', {
            'id': globals.userID,
            'caller': globals.phoneNumber,
            'callee': otherNumber
          });
          globals.globalsocket.off('${globals.userID} IncomingCall');
          Navigator.of(context).pushReplacementNamed(
            CallingScreen.routeName,
            arguments: {
              'name': contactName,
            }
          );
        },
        backgroundColor: const Color.fromRGBO(0, 255, 0, 1),
        child: const Icon(
          Icons.call,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: pageSelect,
          backgroundColor: const Color.fromRGBO(44, 111, 255, 1),
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ]),
    );
  }
}
