import 'dart:developer';

import 'package:flutter/material.dart';
import './ContactTile.dart';
import 'package:contacts_service/contacts_service.dart';

class Contacts extends StatefulWidget {

  TextEditingController controller;
  FocusNode fnode;
  List<Contact> searchContacts;
  final Function _selectPage;

  Contacts(this.controller, this.fnode, this.searchContacts, this._selectPage, {super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}


class _ContactsState extends State<Contacts> {

  double? height;
  double? width;

  void reset() {
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    log('contactScreen');
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
                        focusNode: widget.fnode,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height / 100,
              ),
              SizedBox(
                height: height,
                child: ListView.builder(
                  itemBuilder: (ctx, i) {
                    return ContactTile(widget.searchContacts[i], height, width, reset, widget.fnode, widget._selectPage);
                  },
                  itemCount: widget.searchContacts.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
