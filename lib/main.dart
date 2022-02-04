import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String messageTitle = "Empty";
  String notificationAlert = "alert";

  @override
  void initState() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification?.body);
        print(message.notification?.title);
      }
    });
  }

  var task;
  var _selected;
  var _selected2;
  var val;
  var scheduledTime;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          backgroundColor: Colors.tealAccent,
          title: Text("Water Notification"),
        ),
        body: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(children: [
            const SizedBox(
              height: 120,
            ),
            Center(

              child: Text("My first notification app"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (_val) {
                task = _val;
              },
            ),
            Row(
            //  mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButton(
                      value: _selected,
                      items: [
                        DropdownMenuItem(child: Text("Seconds"),
                        value: "Seconds"),
                        DropdownMenuItem(child: Text("Minutes"),
                            value: "Minutes" ),
                        DropdownMenuItem(child: Text("Hour"),
                            value: "Hour")
                      ],
                      hint: Text("Select period"),
                      onChanged: (_val){
                        setState(() {
                           _selected=_val;
                        });
                      }),
                ),
                Expanded(
                  child: DropdownButton(
                      value: _selected2,
                      items: [
                        DropdownMenuItem(child: Text("one"),
                            value: 1),
                        DropdownMenuItem(child: Text("two"),
                            value:2),
                        DropdownMenuItem(child: Text("three"),
                            value: 3)
                      ],
                      hint: Text("Select  time"),
                      onChanged: (_val){
                        setState(() {
                          _selected2=_val;
                        });
                      }),
                ),
              ],

            ),

            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.pink),
              child: Text("Simple Notification"),
              onPressed: () {
                NotificationApi.showNotification(
                    title: "simple notification",
                    body: "hey, this notification should  work",
                    payload: 'bu ne ');
              },
            ),
            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
style: ElevatedButton.styleFrom(primary: Colors.pink),
                onPressed: () {
                  if(_selected=="Hour"){
                    scheduledTime=  DateTime.now().add(Duration(hours: _selected2));
                    }
                  else if(_selected=="Minutes"){
                      scheduledTime=  DateTime.now().add(Duration(minutes: _selected2));  }
                  else{
                  scheduledTime=  DateTime.now().add(Duration(seconds: _selected2));
                  }
                  NotificationApi.showScheduledNotification(

                  scheduleDate: scheduledTime,
                      title: 'This is Scheduled Notification',
                      body: task,
                      payload: 'nothing but an payload');

                },
                child: Text("Scheduled Notification")),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: ()async{

              await NotificationApi._notifications.cancelAll();

            }, child: Text("Remove Notification"),style: ElevatedButton.styleFrom(primary: Colors.pink),),
          ],),
        ),
      ),
    );
  }
}

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  //static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        importance: Importance.max,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.show(id, title, body, await _notificationDetails(),
        payload: payload);
  }

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>

      _notifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduleDate, tz.local),
          await _notificationDetails(),
          payload: payload,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true);

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: android);
    await _notifications.initialize(settings,
        onSelectNotification: (payload) async {
      // onNotifications.add(payload);
    });
  }
}
