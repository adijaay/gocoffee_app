import 'package:coffeonline/screens/home/widgets/button_order.dart';
import 'package:coffeonline/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home/provider/order_service.dart';
import 'screens/login/provider/auth_service.dart';
import 'utils/print_log.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthService>();
    final orderProv = context.read<OrderService>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SELAMAT DATANG DI\n GO-COFFE',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            MyButton(
              child: Text(
                'KUY NGOPI',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                    ),
              ),
              onPressed: () {
                orderProv.historyOrder.clear();
                setDataUser().then(
                  (value) {
                    printLog('data user: ${authProv.userData}');
                    if (authProv.token.isNotEmpty ||
                        authProv.typeUser != null) {
                      printLog(
                          "data user: ${authProv.userData!.id.toString()}");
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      authProv.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setDataUser() async {
    final authProv = context.read<AuthService>();
    LoadingDialog.show(context, message: 'Mendapatkan data user');
    try {
      await authProv.getUserData(
        authProv.userId!,
      );
    } catch (e) {
      printLog(e);
    }
    LoadingDialog.hide(context);
  }
}
