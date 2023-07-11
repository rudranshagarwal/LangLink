import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:project4/CallScreen/CallScreen.dart';
import '../ContactScreen/Contacts.dart';
import '../HistoryScreen/History.dart';
import '../IncomingCallScreen/ReceiveCall.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../globals.dart' as globals;

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';

  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with RouteAware {
  List<Map<String, Object>>? _pages;

  void getpages()
  {
    _pages = [
      {'page': Contacts(controller, fnode, searchContacts, _selectPage)},
      {'page': History(controller, _contacts, fnode, _selectPage)},
    ];
  }

  final List<Contact> _contacts = [];
  List<Contact> searchContacts = [];

  final controller = TextEditingController();
  final fnode = FocusNode();

  bool outCall = false;
  bool inCall = false;
  String? contactName = '';

  @override
  void initState() {
    super.initState();
    permissionandcontact();
    controller.addListener(onSearch);
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

  @override
  void didPopNext() {
    initSockets();
  }

  void initSockets() {
    log('contactScreen SocketInit');
    outCall = false;
    inCall = false;
    contactName = '';
    globals.globalsocket.on('${globals.userID} IncomingCall', (data) async {
      fnode.unfocus();
      globals.callID = data['callID'];
      contactName = findContact(data['phoneNumber']);
      contactName ??= data['phoneNumber'];
      globals.globalsocket.off('${globals.userID} IncomingCall');
      setState(() {
        inCall = true;
      });
    });
  }

  int _selectedPageIndex = 0;

  void _selectPage(index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  String? findContact(String phoneNumber) {
    for(var i = 0; i < _contacts.length; i++) {
      if(phoneNumber == '+91' + (_contacts[i].phones?.elementAt(0).value?.replaceAll(' ', '').replaceAll('+91', '')?? 'null')) {
        return _contacts[i].displayName;
      }
    }
    return null;
  }

  void permissionandcontact() async{
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      await getContacts();
    }
  }
  Future<PermissionStatus> _getPermission() async {
    await Permission.contacts.request();
    return Permission.contacts.status;
  }


  Future<void> getContacts() async {
    final List<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      for(var i = 0; i < contacts.length; i++) {
        if(contacts[i].phones!.isNotEmpty) {
          _contacts.add(contacts[i]);
        }
      }
      searchContacts = _contacts;
    });
  }

  bool cmpStr(String str1, String? str2) {
    if(str1.length > str2!.length) {
      return false;
    }
    
    str1 = str1.toLowerCase();
    str2 = str2.toLowerCase();

    for (var i = 0; i < str1.length; i++) {
      if(str1[i] != str2[i]) {
        return false;
      }
    }

    return true;
  }

  void onSearch() {
    setState(() {
      searchContacts = [];
      if(controller.text.isEmpty) {
        searchContacts = _contacts;
      } else {
        _selectedPageIndex = 0;
        fnode.requestFocus();
        for(var i = 0; i < _contacts.length; i++) {
          if(cmpStr(controller.text, _contacts[i].displayName)) {
            searchContacts.add(_contacts[i]);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if(inCall == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed(
          ReceiveCall.routeName,
          arguments: {
            'name': contactName,
          }
        );
      });
      inCall = false;
    }

    getpages();
    return Scaffold(
      body: (_pages as List<Map<String, Object>>)[_selectedPageIndex]['page']
          as Widget,
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          backgroundColor: const Color.fromRGBO(222, 234, 255, 1),
          unselectedItemColor: Colors.black,
          selectedItemColor: const Color.fromRGBO(44, 111, 255, 1),
          currentIndex: _selectedPageIndex,
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
