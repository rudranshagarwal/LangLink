import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import '../OutgoingCallScreen/CallingScreen.dart';
import '../TranscriptScreen/TranscriptScreen.dart';
import '../globals.dart' as globals;

class ContactTile extends StatefulWidget {
  final Contact contact;
  final double height;
  final double width;
  final Function reset;
  FocusNode fnode;
  final Function _selectPage;

  ContactTile(this.contact, this.height, this.width, this.reset, this.fnode, this._selectPage, {super.key});

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  int showoptions = 0;
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
        color: showoptions == 0 ? Colors.white : const Color.fromRGBO(222, 234, 255, 1),
        width: widget.width,
        height: showoptions == 0 ? widget.height / 10 : widget.height / 5,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: widget.height / 60
            ),
            Row(children: <Widget>[
              SizedBox(
                width: widget.width / 25,
              ),
              CircleAvatar(
                radius: widget.height / 35.0,
                backgroundColor: Colors.orange,
                child: Text(
                  widget.contact.displayName![0],
                  style: TextStyle(
                    fontSize: widget.height / 30.0,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: widget.width / 15),
              Text(
                widget.contact.displayName ?? 'null',
                style: TextStyle(fontSize: widget.height / 30.0),
              ),
            ]),
            showoptions == 0
              ? SizedBox(
                  height: widget.height / 100,
                )
              : Container(
              alignment: Alignment.center,
              height: widget.height / 8,
              width: widget.width,
              color: const Color.fromRGBO(222, 234, 255, 1),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: widget.height / 100,
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
                                  'callee': '+91' + (widget.contact.phones?.elementAt(0).value?.replaceAll(' ', '').replaceAll('+91', '')?? 'null')
                                });
                                globals.globalsocket.off('${globals.userID} IncomingCall');
                                Navigator.of(context).pushNamed(
                                  CallingScreen.routeName,
                                  arguments: {
                                    'name': widget.contact.displayName,
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
                                globals.globalsocket.on('${globals.userID} LastCall', (data) {
                                  widget.fnode.unfocus();
                                  globals.globalsocket.off('${globals.userID} LastCall');
                                  Navigator.of(context).pushNamed(
                                    TranscriptScreen.routeName,
                                    arguments: {
                                      'call': data,
                                      'name': widget.contact.displayName,
                                      'tabChange': widget._selectPage
                                    }
                                  );
                                });
                                globals.globalsocket.emit('${globals.userID} GetLastCall', {
                                  'id': globals.userID,
                                  'phoneNumber': '+91' + (widget.contact.phones?.elementAt(0).value?.replaceAll(' ', '').replaceAll('+91', '')?? 'null')
                                });
                              },
                              icon: const Icon(Icons.list_alt),
                              iconSize: widget.height / 30,
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
            ),
          ],
        ),
      ),
    );
  }
}
