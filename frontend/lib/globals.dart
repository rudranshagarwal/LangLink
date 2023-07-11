library project4.globals;

import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket globalsocket;
String phoneNumber = "";
String selectedValue = "";
bool botMode = false;
final messages = [];
const url = 'http://192.168.54.236:4000';
var userID = "";
var callID = "";

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
