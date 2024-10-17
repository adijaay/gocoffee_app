import 'package:coffeonline/utils/loading.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/widgets/button_order.dart';
import '../provider/auth_service.dart';
import '../register_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     handleLogout();
  //   });
  // }

  // void handleLogout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   printLog("handleLogout token: ${token}");
  //   final authService = Provider.of<AuthService>(context, listen: false);
  //   if (token == null || token!.isEmpty) {
  //     authService.logout();
  //   } else {
  //     await authService.getUserData(authService.userId!);
  //     printLog("userData: ${authService.userData}");
  //     await Navigator.of(context).pushReplacementNamed('/');
  //   }
  // }

  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AuthService>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Email Anda';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: obsecurePass,
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
                suffixIcon: obsecurePass
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            obsecurePass = !obsecurePass;
                          });
                        },
                        icon: const Icon(Icons.visibility_off),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            obsecurePass = !obsecurePass;
                          });
                        },
                        icon: const Icon(Icons.visibility),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Kata Sandi Anda';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                onPressed: () {
                  login().then((value) {
                    getUserData().then((value) {
                      LoadingDialog.hide(context);
                      if (provider.userData != null) {
                        Navigator.of(context).pushNamed('/');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                            content: Text('Login Berhasil'),
                          ),
                        );
                      } else {
                        printLog('Login gagal');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                            content: Text('Login Gagal'),
                          ),
                        );
                      }
                    }).catchError((e) {
                      printLog(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                          content: Text('Login Gagal'),
                        ),
                      );
                    });
                  }).catchError((e) {
                    printLog(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                        content: Text('Login Gagal'),
                      ),
                    );
                  });
                },
                child: Text(
                  'Masuk',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.grey),
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                child: const Text('Registrasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final provider = context.read<AuthService>();
    if (formKey.currentState!.validate()) {
      try {
        await provider.login(
          email: emailController.text,
          password: passwordController.text,
        );
      } catch (e) {
        printLog(e);
      }
    }
  }

  Future<void> getUserData() async {
    final provider = context.read<AuthService>();
    if (provider.userData == null) {
      await provider.getUserData(provider.userId!);
    } else {
      return Future.value();
    }
  }
}
