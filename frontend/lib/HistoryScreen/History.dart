import 'package:flutter/material.dart';
import './HistoryTile.dart';
import 'package:contacts_service/contacts_service.dart';
import '../globals.dart' as globals;

class History extends StatefulWidget {
  TextEditingController controller;
  List<Contact> contacts;
  FocusNode fnode;
  final Function _selectPage;

  History(this.controller, this.contacts, this.fnode, this._selectPage, {super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  final ScrollController _scrollController = ScrollController();

  late List<dynamic> historyList = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(onScroll);
    globals.globalsocket.emit('${globals.userID} GetCallHistory',{
      'id': globals.userID,
      'numCalls': 50,
      'offset': 0
    });
    globals.globalsocket.on('${globals.userID} CallHistory', (data) {
      setState(() {
        historyList.addAll(data);
      });
      globals.globalsocket.off('${globals.userID} CallHistory');
    });
  }

  void onScroll() {
    // if(_scrollController.offset > historyList.length * height / 8) {}
  }

  void reset() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height - mediaQuery.padding.top - kBottomNavigationBarHeight;
    final width = mediaQuery.size.width;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: <Widget>[
              SizedBox(height: height / 15),
              Container(
                padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
                alignment: Alignment.center,
                width: width / 1.1,
                height: height / 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 30),
                  color: const Color.fromRGBO(222, 234, 255, 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search contacts',
                          border: InputBorder.none,
                        ),
                        controller: widget.controller,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (height) / 100,
              ),
              SizedBox(
                height: height,
                child: ListView.builder(
                  itemBuilder: (ctx, i) {
                    return HistoryTile(widget.contacts, historyList[i], height, width, reset, widget.fnode, widget._selectPage);
                  },
                  itemCount: historyList.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
