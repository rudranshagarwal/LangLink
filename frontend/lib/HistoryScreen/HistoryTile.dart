import 'dart:developer';

import 'package:flutter/material.dart';
import '../OutgoingCallScreen/CallingScreen.dart';
import '../TranscriptScreen/TranscriptScreen.dart';
import 'package:contacts_service/contacts_service.dart';
import '../globals.dart' as globals;

class HistoryTile extends StatefulWidget {
  List<Contact> contacts;
  Map call;
  double height;
  double width;
  Function reset;
  FocusNode fnode;
  final Function _selectPage;

  HistoryTile(this.contacts, this.call, this.height, this.width, this.reset, this.fnode, this._selectPage, {super.key});

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  int showoptions = 0;

  var icon;
  var color;
  var start;
  var duration;
  String callInfo = '';
  String? contactName;
  String otherNumber = '';

  @override
  void initState() {
    super.initState();
    start = DateTime.fromMillisecondsSinceEpoch(widget.call['StartTime']);
    start = '${start.day.toString().padLeft(2,'0')}/${start.month.toString().padLeft(2,'0')}/${start.year} - ${start.hour.toString().padLeft(2,'0')}:${start.minute.toString().padLeft(2,'0')}';
    duration = (widget.call['Duration'] / 60000).floor();
    if(widget.call['CallerID'] == globals.userID) {
      if(widget.call['Status'] == 'ended') {
        icon = Icons.call_made;
        color = const Color.fromRGBO(0, 255, 0, 1);
        callInfo = '$start - Lasted $duration min';
      }
      if(widget.call['Status'] == 'declined') {
        icon = Icons.call_made;
        color = Colors.red;
        callInfo = '$start - Declined';
      }
      if(widget.call['Status'] == 'missed') {
        icon = Icons.call_missed_outgoing;
        color = Colors.red;
        callInfo = '$start - Missed';
      }
      otherNumber = widget.call['CalleeNumber'];
      contactName = findContact(widget.call['CalleeNumber']);
      contactName ??= widget.call['CalleeNumber'];
    } else if(widget.call['CalleeID'] == globals.userID) {
      if(widget.call['Status'] == 'ended') {
        icon = Icons.call_received;
        color = const Color.fromRGBO(0, 255, 0, 1);
        callInfo = '$start - Lasted $duration min';
      }
      if(widget.call['Status'] == 'declined') {
        icon = Icons.call_received;
        color = Colors.red;
        callInfo = '$start - Declined';
      }
      if(widget.call['Status'] == 'missed') {
        icon = Icons.call_missed;
        color = Colors.red;
        callInfo = '$start - Missed';
      }
      otherNumber = widget.call['CallerNumber'];
      contactName = findContact(widget.call['CallerNumber']);
      contactName ??= widget.call['CallerNumber'];
    }
  }

  String? findContact(phoneNumber) {
    for(var i = 0; i < widget.contacts.length; i++) {
      if(phoneNumber == '+91' + (widget.contacts[i].phones?.elementAt(0).value?.replaceAll(' ', '').replaceAll('+91', '')?? 'null')) {
        return widget.contacts[i].displayName;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        if (showoptions == 0) widget.reset;
        setState(() {
          showoptions = 1 - showoptions;
        });
      },
      child: Container(
        color:
            showoptions == 0 ? Colors.white : const Color.fromRGBO(222, 234, 255, 1),
        width: widget.width,
        height: showoptions == 0 ? widget.height / 8 : widget.height / 4.3,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: widget.height / 50
            ),
            Row(children: <Widget>[
              SizedBox(
                width: widget.width / 25,
              ),
              Icon(
                icon,
                color: color,
                size: widget.height / 25,
              ),
              SizedBox(width: widget.width / 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: widget.width / 1.5,
                    child: Text(
                      contactName!,
                      style: TextStyle(fontSize: widget.height / 30.0),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: widget.width / 1.5,
                    child: Text(
                      callInfo,
                      style: TextStyle(
                        fontSize: widget.height / 60.0,
                        color: color
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ]),
            showoptions == 0
                ? Container()
                : Column(
                    children: <Widget>[
                      const Divider(
                        thickness: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            height: widget.height / 10,
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    widget.fnode.unfocus();
                                    globals.globalsocket.emit('${globals.userID} CallNumber', {
                                      'id': globals.userID,
                                      'caller': globals.phoneNumber,
                                      'callee': otherNumber
                                    });
                                    globals.globalsocket.off('${globals.userID} IncomingCall');
                                    Navigator.of(context).pushNamed(
                                      CallingScreen.routeName,
                                      arguments: {
                                        'name': contactName,
                                      }
                                    );
                                  },
                                  icon: const Icon(Icons.call),
                                  iconSize: widget.height / 30,
                                ),
                                SizedBox(
                                  height: widget.height / 50,
                                  child: Text(
                                    'Call',
                                    style: TextStyle(
                                        fontSize: widget.height / 60),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: widget.height / 10,
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    widget.fnode.unfocus();
                                    Navigator.of(context).pushNamed(
                                      TranscriptScreen.routeName,
                                      arguments: {
                                        'call': widget.call,
                                        'name': contactName,
                                        'tabChange': widget._selectPage
                                      }
                                    );
                                  },
                                  icon: const Icon(Icons.list_alt),
                                  iconSize: widget.height / 40,
                                ),
                                SizedBox(
                                  height: widget.height / 50,
                                  child: Text(
                                    'Transcript',
                                    style: TextStyle(
                                      fontSize: widget.height / 60
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ]
                      ),
                    ],
                  ),
            SizedBox(
              height: widget.height / 50.0,
            )
          ],
        ),
      ),
    );
  }
}
