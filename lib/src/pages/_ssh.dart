import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter_local_notifications_extended/flutter_local_notifications_extended.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'dart:async';

bool _get = true;
var _context;

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  static String MQS = ""; //int.parse(MQS);
  static String LW = ""; //int.parse(LW);
  static String MRL = ""; //int.parse(MRL);
  static String GEOID = "";
  static String RadioValue = "";
  static String Value1 = "";
  static String Value2 = "";
  static int ENDPOINT = 2;
  bool _validateError = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  initState() {
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text(
            "Complete!!",
            style: TextStyle(color: Colors.blue),
          ),
          content: Text("Your task has been completed."),
        );
      },
    );
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Complete',
      'Your task has been completed.',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      backgroundColor: Color.fromRGBO(3, 9, 23, 1),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "SSH",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _hostController,
                          decoration: InputDecoration(
                            errorText:
                                _validateError ? 'Host is mandatory' : null,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(width: 3),
                            ),
                            hintText: 'Address',
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: _portController,
                            decoration: InputDecoration(
                              errorText:
                                  _validateError ? 'Port is mandatory' : null,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                              hintText: 'Port eg : 22',
                            ),
                          ))),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: _usernameController,
                            decoration: InputDecoration(
                              errorText: _validateError
                                  ? 'Username is mandatory'
                                  : null,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                              hintText: 'Username',
                            ),
                          ))),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              errorText: _validateError
                                  ? 'Password is mandatory'
                                  : null,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                              hintText: 'Password',
                            ),
                          ))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.blue,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                          ),
                          onPressed: () {
                            Future<bool> test = execute(
                                _usernameController,
                                _passwordController,
                                _portController,
                                _hostController);
                            // print(test);
                            // if (test == true) {
                            //   _showNotificationWithDefaultSound();
                            // }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              RaisedButton(
                // shape: StadiumBorder(),
                color: Colors.blue,
                child: Text(
                  "Download",
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () async {
                  Directory tempDir = await getTemporaryDirectory();
                  String tempPath = tempDir.path;
                  print(tempPath);
                  print(_get);
                  if (_get == true) {
                    getSSH.onClickSFTP(_usernameController, _passwordController,
                        _portController, _hostController);
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => new AlertDialog(
                              title: new Text(
                                "Alert!!!",
                                style: TextStyle(color: Colors.red),
                              ),
                              content: new Text("Process Not Completed"),
                              elevation: 24,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)),
                            ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> execute(
    TextEditingController username,
    TextEditingController password,
    TextEditingController port,
    TextEditingController address,
  ) async {
    var client = new SSHClient(
      host: address.text,
      port: int.parse(port.text),
      username: username.text,
      passwordOrKey: password.text,
    );
//    Do Not Change Anything Here
    await client.connect();
//    Enter Command To Execute on HPC
    sleep(Duration(seconds: 45));
    sleep(Duration(seconds:2));
    //print(IndexState.RadioValue);
    //print(IndexState.Value1);
    String _commandnohup = "";
    if(int.parse(IndexState.Value1)==1 && int.parse(IndexState.RadioValue)==1){
      _commandnohup = "nohup /home/saad18409/saad-env/bin/python mainScript.py -b ${IndexState.Value2} -r ${IndexState.RadioValue} -g ${IndexState.GEOID}>stdout.txt 2>report.txt &"; //comand here
    } else if(int.parse(IndexState.Value1)==2 && int.parse(IndexState.RadioValue)==1){
      _commandnohup = "nohup /home/saad18409/saad-env/bin/python mainScript.py -b ${IndexState.Value2} -t ${IndexState.Value1} -r ${IndexState.RadioValue} -g ${IndexState.GEOID} -q ${IndexState.MQS} -w ${IndexState.LW} -l ${IndexState.MRL} >stdout.txt 2>report.txt &"; //comand here
    } else if(int.parse(IndexState.Value1)==2 && int.parse(IndexState.RadioValue)==2){
      _commandnohup = "nohup /home/saad18409/saad-env/bin/python mainScript.py -b ${IndexState.Value2} -t ${IndexState.Value1} -g ${IndexState.GEOID} -q ${IndexState.MQS} -w ${IndexState.LW} -l ${IndexState.MRL} >stdout.txt 2>report.txt &"; //comand here   
    } else{
      _commandnohup = "nohup /home/saad18409/saad-env/bin/python mainScript.py -b ${IndexState.Value2} -g ${IndexState.GEOID}>stdout.txt 2>report.txt &"; //comand here
    }
    print(_commandnohup);
    print(await client.execute(_commandnohup));
    address.clear();
    port.clear();
    username.clear();
    password.clear();
    _showNotificationWithDefaultSound();
    //_command = "nohup python3 nvbi.py ${IndexState.ENDPOINT} ${IndexState.GEOID}>~/${IndexState.GEOID}/stdout.txt 2>~/${IndexState.GEOID}/stderr.txt &";
    //print(await client.execute(_command));
    //print(client.disconnect());
    //address.clear();
    //port.clear();
    //username.clear();
    //password.clear();
    _get = true;
    return true;
  }
}

// class executeSSH {
//   static Future<bool> execute(
//     TextEditingController username,
//     TextEditingController password,
//     TextEditingController port,
//     TextEditingController address,
//   ) async {
//     var client = new SSHClient(
//       host: address.text,
//       port: int.parse(port.text),
//       username: username.text,
//       passwordOrKey: password.text,
//     );
// //    Do Not Change Anything Here
//     await client.connect();
// //    Enter Command To Execute on HPC
//     sleep(Duration(seconds:45));
//     print("${IndexState.GEOID}");
//     String _command = "mkdir /home/aditya18378/bitchassnigga"; //comand here
//     print(_command);
//     print(await client.execute(_command));
//     address.clear();
//     port.clear();
//     username.clear();
//     password.clear();
//     //_command = "nohup python3 nvbi.py ${IndexState.ENDPOINT} ${IndexState.GEOID}>~/${IndexState.GEOID}/stdout.txt 2>~/${IndexState.GEOID}/stderr.txt &";
//     //print(await client.execute(_command));
//     //print(client.disconnect());
//     //address.clear();
//     //port.clear();
//     //username.clear();
//     //password.clear();
//     _get = true;
//     return true;
//   }
// }

class getSSH {
  static Future<void> onClickSFTP(
    TextEditingController username,
    TextEditingController password,
    TextEditingController port,
    TextEditingController address,
  ) async {
    // var address;
    var client = new SSHClient(
      host: address.text,
      port: int.parse(port.text),
      username: username.text,
      passwordOrKey: password.text,
    );
    Map<ph.PermissionGroup, ph.PermissionStatus> permissions =
        await ph.PermissionHandler()
            .requestPermissions([ph.PermissionGroup.storage]);
    if (permissions[ph.PermissionGroup.storage] ==
        ph.PermissionStatus.granted) {
      try {
        String result = await client.connect();
        sleep(Duration(seconds: 45));
        if (result == "session_connected") {
          result = await client.connectSFTP();
          sleep(Duration(seconds: 45)); // Remove if not required
          if (result == "sftp_connected") {
            Directory tempDir = await getExternalStorageDirectory();
            String tempPath = tempDir.path;

            var filePath = await client.sftpDownload(
              path: "/home/saad18409/${IndexState.GEOID}/qcReports/multiqc_report.html", //file path
              toPath: "$tempPath/multiqc_report.html", //place where u want it
              callback: (progress) async {
                print(progress);
                print(tempPath);
                print("Am here");
                showDialog(
                    context: _context,
                    builder: (BuildContext context) => new AlertDialog(
                          title: new Text(
                            "Alert!!!",
                            style: TextStyle(color: Colors.green),
                          ),
                          content: new Text("Process Completed"),
                          elevation: 24,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                        ));
                // if (progress == 20) await client.sftpCancelDownload();
              },
            );
            print(await client.disconnectSFTP());

            client.disconnect();
            address.clear();
            port.clear();
            username.clear();
            password.clear();
            showDialog(
                context: _context,
                builder: (BuildContext context) => new AlertDialog(
                      title: new Text(
                        "Alert!!!",
                        style: TextStyle(color: Colors.green),
                      ),
                      content: new Text("Process Completed"),
                      elevation: 24,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                    ));
          }
        }
      } on PlatformException catch (e) {
        print('Error: ${e.code}\nError Message: ${e.message}');
        print("Not Completed");
        showDialog(
            context: _context,
            builder: (BuildContext context) => new AlertDialog(
                  title: new Text(
                    "Alert!!!",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: new Text("Process Not Completed"),
                  elevation: 24,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                ));
      }
    }
  }
}

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/db.txt');
  }
}
