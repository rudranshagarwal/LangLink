import 'package:flutter/material.dart';
import '../Wallpaper.dart';
import './CallScreen.dart';
import './message.dart';
import '../globals.dart' as globals;

class CallWithoutTranscriptScreen extends StatefulWidget {

  Function toggleSpeaker;
  Function toggleTranscript;
  Function toggleBot;
  Function cutCall;
  int speaker;
  List<DropdownMenuItem<String>> dropdownItems;

  CallWithoutTranscriptScreen(this.toggleSpeaker, this.toggleTranscript, this.toggleBot, this.cutCall, this.speaker, this.dropdownItems, {super.key});
  @override
  State<CallWithoutTranscriptScreen> createState() => _CallWithoutTranscriptScreenState();
}

class _CallWithoutTranscriptScreenState extends State<CallWithoutTranscriptScreen> {

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;
    final width = mediaQuery.size.width;
    final padding = mediaQuery.padding.top;
    final routeArgs = (ModalRoute.of(context)!.settings.arguments ?? <String, dynamic>{}) as Map;
    String contactName = routeArgs['name'];

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
            ]),
            SizedBox(
              height: height / 20,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            widget.toggleSpeaker();
                          },
                          icon: Icon(widget.speaker == 0
                              ? Icons.volume_up_outlined
                              : Icons.volume_up)),
                      const Text('Speaker')
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            widget.toggleTranscript();
                          },
                          icon: const Icon(Icons.list_alt)),
                      const Text('Transcript'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(onPressed: () {
                        widget.toggleBot();
                      }, icon: const Icon(Icons.chat)),
                      const Text('ChatGPT')
                    ],
                  ),
                ]),
            SizedBox(
              height: height / 20,
            ),
            Container(
              alignment: Alignment.center,
              width: width / 2,
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 2)
              ),
              child: DropdownButton(
                underline: Container(),
                isExpanded: true,
                alignment: Alignment.center,
                hint: const Text('Language'),
                value: globals.selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    globals.selectedValue = newValue!;
                  });
                  globals.globalsocket.emit(
                    '${globals.userID} ChangeLanguage',
                    {
                      'id': globals.userID,
                      'callID': globals.callID,
                      'language': newValue
                    }
                  );
                },
                items: widget.dropdownItems
              ),
            ),
            SizedBox(
              height: height / 5,
            ),
            FloatingActionButton(
              heroTag: 'endCall',
              onPressed: () {
                widget.cutCall();
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