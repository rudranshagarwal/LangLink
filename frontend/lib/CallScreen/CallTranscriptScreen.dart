import 'package:flutter/material.dart';
import '../Wallpaper.dart';
import './message.dart';
import '../globals.dart' as globals;

class CallTranscriptScreen extends StatefulWidget {

  Function toggleSpeaker;
  Function toggleTranscript;
  Function toggleBot;
  Function cutCall;
  int speaker;
  List<DropdownMenuItem<String>> dropdownItems;

  CallTranscriptScreen(this.toggleSpeaker, this.toggleTranscript, this.toggleBot, this.cutCall, this.speaker, this.dropdownItems, {super.key});
  @override
  State<CallTranscriptScreen> createState() => _CallTranscriptScreenState();
}

class _CallTranscriptScreenState extends State<CallTranscriptScreen> {
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top;
    final width = mediaQuery.size.width;
    final routeArgs = ModalRoute.of(context)!.settings.arguments;
    final contactName = (routeArgs as Map<String, dynamic>)['name'];
    final padding = mediaQuery.padding.top;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: padding,
            ),
            Stack(
              children: <Widget>[
                Wallpaper(width, height / 3),
                Row(
                  children: [
                    SizedBox(
                      width: width * 3 / 4,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: height / 40,
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: width / 40,
                              ),
                              CircleAvatar(
                                radius: height / 30,
                                backgroundColor: Colors.red,
                                child: Text(contactName[0],
                                    style:
                                        TextStyle(fontSize: height / 20)),
                              ),
                              SizedBox(
                                width: width / 30,
                              ),
                              SizedBox(
                                width: width / 1.8,
                                child: Text(
                                  contactName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height / 25
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis
                                )
                              )
                            ],
                          ),
                          SizedBox(
                            height: height / 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: width / 10,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: width / 2,
                                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.white
                                  )
                                ),
                                child: DropdownButton(
                                  iconEnabledColor: Colors.white,
                                  underline: Container(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
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
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: height / 40,
                        ),
                        Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  widget.toggleSpeaker();
                                },
                                icon: Icon(widget.speaker == 0
                                    ? Icons.volume_up_outlined
                                    : Icons.volume_up,
                                    color: Colors.white,
                                  )
                                ),
                            const Text(
                              'Speaker',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.toggleTranscript();
                              },
                              icon: const Icon(
                                Icons.list_alt,
                                color: Colors.white,
                              )
                            ),
                            const Text(
                              'Transcript',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.toggleBot();
                              },
                              icon: const Icon(
                                Icons.chat,
                                color: Colors.white,
                              )
                            ),
                            const Text(
                              'ChatGPT',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: height / 3,
              width: double.infinity,
              child: ListView.builder(
                itemBuilder: (ctx, i) {
                  return Container(
                      alignment: globals.messages[i]['send'] == 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Message(globals.messages[i]['message'],
                          globals.messages[i]['chatgpt']));
                },
                itemCount: globals.messages.length,
              ),
            ),
            SizedBox(
              height: height / 10,
            ),
            FloatingActionButton(
              onPressed: () {
                widget.cutCall();
              },
              backgroundColor: Colors.red,
              child: const Icon(
                Icons.call_end,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
