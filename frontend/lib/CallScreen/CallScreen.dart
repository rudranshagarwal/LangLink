import 'dart:developer';

import 'package:flutter/material.dart';
import './CallTranscriptScreen.dart';
import './CallWithoutTranscriptScreen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_audio_output/flutter_audio_output.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart' show Level;
import '../globals.dart' as globals;
import 'dart:io';
import 'dart:convert';
import 'dart:collection';


class CallScreen extends StatefulWidget {
  static const routeName = '/call-screen';

  const CallScreen({super.key});
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with RouteAware {
  int speaker = 0;
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "English", child: Text("English", style: TextStyle(color: Colors.black))),
      const DropdownMenuItem(value: "Telugu", child: Text("Telugu", style: TextStyle(color: Colors.black))),
      const DropdownMenuItem(value: "Hindi", child: Text("Hindi", style: TextStyle(color: Colors.black)))
    ];
    return menuItems;
  }

  List<Map<String, Object>>? _pages;
  int _selectedPageIndex = 0;

  void getpages()
  {
    _pages = [
      {'page': CallWithoutTranscriptScreen(toggleSpeaker, toggleTranscript, toggleBot, cutCall, speaker, dropdownItems)},
      {'page': CallTranscriptScreen(toggleSpeaker, toggleTranscript, toggleBot, cutCall, speaker, dropdownItems)},
    ];
  }

  void toggleSpeaker() async {
    setState(() {
      speaker = 1 - speaker;
    });
  }

  void toggleTranscript() {
    setState(() {
      _selectedPageIndex = 1 - _selectedPageIndex;
    });
  }

  void toggleBot () {
    globals.botMode = !globals.botMode;
    if(globals.botMode == true) {
      stopRecording(globals.callID);
    } else {
      startRecording();
    }
    var data = {
      'id': globals.userID,
      'callID': globals.callID,
      'newBotMode': globals.botMode
    };
    globals.globalsocket.emit('${globals.userID} ChangeBotMode', data);
  }

  void cutCall() async {
    await stopRecording(globals.callID);
    globals.globalsocket.emit(
      '${globals.userID} CallCut',
      {
        'id': globals.userID,
        'callID': globals.callID
      }
    );
  }

  FlutterSoundRecorder? _recordingSession;
  late String pathToAudio;
  late int fileNo;
  late String ext;
  final dbQueue = Queue();
  bool endCall = false;

  FlutterSoundPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    globals.selectedValue = "English";
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
  void didPush() async {
    initSockets();
    initializeaudio();
  }

  void initSockets() {
    log('callScreen SocketInit');

    endCall = false;

    globals.globalsocket.on('${globals.userID} CallEnd', (data) async {
      log(data['Status']);
      if(data['Status'] == 'ended') {
        if (_recordingSession != null) {
          await _recordingSession!.closeRecorder();
          _recordingSession = null;
        }
        if (_audioPlayer != null) {
          await _audioPlayer!.closePlayer();
          _audioPlayer = null;
        }
      }
      if(data['Status'] == 'declined' || data['Status'] == 'ended' || data['Status'] == 'missed') {
        globals.messages.clear();
        globals.callID = "";
        globals.botMode = false;
        globals.globalsocket.off('${globals.userID} IncomingText');
        globals.globalsocket.off('${globals.userID} TextSent');
        globals.globalsocket.off('${globals.userID} CallEnd');
        setState(() {
          endCall = true;
        });
      }
    });

    globals.globalsocket.on('${globals.userID} IncomingText', (data) async {
      log('Receive : ' + data['_id'] + ' : ' + data['TranslatedText']);
      if(data['TranslatedText'] != '__NO_TEXT_RECEIVED__' || data['TranslatedText'] != '__NO_TEXT_SENT__') {
        await ttsAPI(data['TranslatedText'], data['ReceiverLang']);
      }
      var message = {
        'send': 1,
        'message': data['TranslatedText'],
        'chatgpt': false
      };
      if(mounted) {
        setState(() {
          globals.messages.add(message);
          // if(globals.messages.length > 5) {
          //   globals.messages.removeAt(0);
          // }
        });
      }
    });

    globals.globalsocket.on('${globals.userID} TextSent', (data) async {
      var message = {
        'send': 0,
        'message': data['SentText'],
        'chatgpt': data['SentByChatBot']
      };
      if(mounted) {
        setState(() {
          globals.messages.add(message);
          // if(globals.messages.length > 5) {
          //   globals.messages.removeAt(0);
          // }
        });
      }
    });
  }

  void initializeaudio() async {
    pathToAudio = '/storage/emulated/0/langlink/temp';
    fileNo = 0;
    ext = '.wav';
    dbQueue.addAll([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    _recordingSession = FlutterSoundRecorder(logLevel: Level.nothing);
    await _recordingSession!.openRecorder();
    await _recordingSession!.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recordingSession!.onProgress?.listen((event) {
      double? dB = event.decibels;
      dbQueue.addLast(dB);
      dbQueue.removeFirst();
      var ind = 0;
      num dBOld = 0;
      num dBNew = 0;
      for (var element in dbQueue) {
        if(ind < 5) {
          dBOld += element;
          ind++;
        }
        else {
          dBNew += element;
        }
      }
      var diff = (dBNew - dBOld) / 5;

      if(diff < -10) {
        dbQueue.clear();
        dbQueue.addAll([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
        continueRecording();
      }
    });
    await FlutterAudioOutput.changeToReceiver();
    _audioPlayer = FlutterSoundPlayer(logLevel: Level.nothing);
    await _audioPlayer!.openPlayer();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    await Permission.accessMediaLocation.request();
    startRecording();
  }

  Future<void> asrAPI(fileNum, callID, language) async {
    String fnum = fileNum.toString();
    var client = http.Client();
    try {
      var request = http.MultipartRequest(
        "POST", Uri.parse("https://asr.iitm.ac.in/asr/v2/decode"),
      );
      Map<String,String> headers={
        "Content-type": "application/json"
      };
      request.headers.addAll(headers);
      request.fields.addAll({
        "vtt": "false",
        "language": language.toLowerCase(),
      });
      request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            pathToAudio + fnum + ext,  
            filename: "temp.wav",
            contentType: MediaType('application', 'octet-stream')
          ),
      );
      var response = await request.send();

      var resp  = await http.Response.fromStream(response);
      final respData = json.decode(resp.body);

      if(respData['transcript'] != null && respData['transcript'] != '') {
        sendMessage(respData['transcript'], callID, language);
      }
    } finally {
      client.close();
      File? tmpAudio = File(pathToAudio + fnum + ext);
      if(tmpAudio.existsSync()) {
        tmpAudio.delete();
      }
    }
}

  Future<void> startRecording() async {
    fileNo++;
    String fnum = fileNo.toString();
    Directory directory = Directory(path.dirname(pathToAudio + fnum + ext));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession!.startRecorder(
      toFile: pathToAudio + fnum + ext,
      codec: Codec.pcm16WAV,
    );
  }


  Future<void> stopRecording(callID) async {
    await _recordingSession!.stopRecorder();
    asrAPI(fileNo, callID, globals.selectedValue);
  }

  Future<void> continueRecording() async {
    await _recordingSession!.stopRecorder();
    asrAPI(fileNo, globals.callID, globals.selectedValue);
    startRecording();
  }



  void sendMessage(msg, callID, language) {
    log('Sent : ' + callID + ' : ' + msg);
    var data = {
      "id": globals.userID,
      "callID": callID,
      "text": msg,
      "language": language,
      "botMode": false
    };
    globals.globalsocket.emit('${globals.userID} SendText', data);
  }

  Future<void> ttsAPI(String message, String language) async {
    var client = http.Client();
    log(language + ' - ' + message);
    try {
      var response = await http.post(
        Uri.parse("https://asr.iitm.ac.in/ttsv2/tts"),
        headers: <String, String>{
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, String>{
          "input": message,
          "lang": language,
          "gender": "female",
          "alpha": "1",
          "segmentwise": "False"
        }),
      );

      final respData = json.decode(response.body);
      if(respData['audio'] != null && respData['audio'].isNotEmpty) {
        log('tts');
        final decodedAudio = base64.decode(respData['audio']);
        AudioInput currentOutput = await FlutterAudioOutput.getCurrentOutput();
        if(speaker == 0 && currentOutput.port != AudioPort.receiver) {
          await FlutterAudioOutput.changeToReceiver();
        }
        if(speaker == 1 && currentOutput.port != AudioPort.speaker) {
          await FlutterAudioOutput.changeToSpeaker();
        }
        await _audioPlayer?.startPlayer(
          fromDataBuffer: decodedAudio,
          codec: Codec.pcm16WAV,
          sampleRate: 16000,
        );
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {

    if(endCall == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      endCall = false;
    }
    final mediaQuery = MediaQuery.of(context);

    getpages();
    return Scaffold(
      body: (_pages as List<Map<String, Object>>)[_selectedPageIndex]['page']
          as Widget
    );
  }
}
