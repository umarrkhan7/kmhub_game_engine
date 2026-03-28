import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showLocalNotification(
    title: message.notification?.title ?? 'Arcade Hub',
    body: message.notification?.body ?? '',
  );
}

class NotificationService {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'arcade_hub_channel',
    'Arcade Hub Notifications',
    description: 'Notifications for Arcade Hub',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> init() async {
    await requestPermission();
    await setupLocalNotifications();
    await setupFCMHandlers();
  }

  static Future<void> requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('Notification permission: ${settings.authorizationStatus}');
  }

  static Future<void> setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    await localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> setupFCMHandlers() async {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'Arcade Hub',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'arcade_hub_channel',
      'Arcade Hub Notifications',
      channelDescription: 'Notifications for Arcade Hub',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

   await localNotifications.show(
  id: id,         
  title: title,     
  body: body,     
  notificationDetails: const NotificationDetails(android: androidDetails),  
);
  }

  static Future<String?> getToken() async {
    return await messaging.getToken();
  }
}

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {}