import 'package:coffeonline/screens/home-merchant/provider/merchant_service.dart';
import 'package:coffeonline/utils/socket/socket_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/print_log.dart';
import '../login/provider/auth_service.dart';
import 'widgets/button_order.dart';
import 'widgets/header_user.dart';
import 'widgets/main_search_coffe.dart';
import 'widgets/menu_container.dart';
import 'widgets/merch_menu.dart';
import 'widgets/admin_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SocketServices socketService = SocketServices();
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    socketService.connected();

    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permissions for iOS
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure message handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null &&
          message.notification!.title != 'New Order') {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'No Title'),
              content: Text(message.notification!.body ?? 'No Body'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printLog('Message clicked!');
      if (message.notification != null) {
        printLog('Notification: ${message.notification}');
      }
    });

    // Handle when the app is launched by a notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        printLog('App launched by notification: ${message.notification}');
        if (message.notification != null) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(message.notification!.title ?? 'No Title'),
                content: Text(message.notification!.body ?? 'No Body'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchantService>();
    final authProv = context.watch<AuthService>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            const HeaderUserAccount(),
            if (authProv.userData != null &&
                authProv.userData!.type == 'merchant') ...[MerchMenu()],
            if (authProv.userData != null &&
                authProv.userData!.type == 'admin') ...[
                  AdminMenu()
                ],
            if (authProv.userData != null &&
                authProv.userData!.type == 'user') ...[
              const MenuContainer(),
              const SearchCoffe(),
              Visibility(
                visible: provider.listMerchant.isNotEmpty,
                child: const OrderButton(),
              )
            ],
          ],
        ),
      ),
    );
  }
}
