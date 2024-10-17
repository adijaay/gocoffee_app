import 'package:coffeonline/screens/home/UI/user_riwayat.dart';
import 'package:coffeonline/screens/home/widgets/button_order.dart';
import 'package:coffeonline/screens/login/provider/auth_service.dart';
import 'package:coffeonline/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/print_log.dart';
import '../provider/order_service.dart';

class AdminMenu extends StatefulWidget {
  const AdminMenu({
    super.key,
  });

  @override
  State<AdminMenu> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  Future<void> _fetchUserHistory() async {
    final _authService = context.read<AuthService>();
    await _authService.getAllUsers(
      token: _authService.token,
      data: {},
      params: {},
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserHistory();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.read<AuthService>();
    final orderProv = context.watch<OrderService>();
    return Container(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
            onRefresh: () async {
              _fetchUserHistory();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runAlignment: WrapAlignment.spaceEvenly,
                    direction: Axis.vertical,
                    children: [
                      MyButton(
                        child: const Text('Cek Seluruh Riwayat Order',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              orderProv.historyOrder.clear();
                              orderProv.getAllOrder(token: authProv.token);
                              return UserHistoryScreen();
                            },
                          ));
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text("Unverified User",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                // Show message when the userDataList is empty
                if (authProv.userDataList.isEmpty) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: const Text('Tidak ada user terdaftar'),
                      ),
                      MyButton(
                        child: Text('Refresh',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          printLog('Dari button tengah');
                          LoadingDialog.show(context,
                              message: 'Mengambil data...');
                          authProv.getAllUsers(
                            token: authProv.token,
                            data: {},
                            params: {}, // Pass necessary data if required
                          ).then((_) {
                            LoadingDialog.hide(context);
                          });
                        },
                      ),
                    ],
                  ),
                ],
                // Display the list of users when userDataList is not empty
                if (authProv.userDataList.isNotEmpty) ...[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(children: [
                      Expanded(
                        child: _buildUnverifiedUser(authProv),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Center(
                          child: Text(
                          "All Users", style: Theme.of(context).textTheme.titleLarge)
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListView.builder(
                          padding: EdgeInsets.all(2),
                            itemCount: authProv.userDataList.length,
                            itemBuilder: (context, index) {
                              final data = authProv.userDataList[index];
                              return Card(
                                elevation: 4.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${data.name}',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        '${data.email}',
                                        style: TextStyle(
                                          fontSize: 8.0,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: data.verified
                                            ? Text(
                                                'Verified' + ' ${data.type}',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[800],
                                                ),
                                              )
                                            : Text(
                                                'Not verified',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ]),
                  ),
                  //unverified
                ],
              ],
            )));
  }
}

Widget _buildUnverifiedUser(AuthService authService) {
  final unverifiedUsers =
      authService.userDataList.where((user) => user.verified == false).toList();

  if (unverifiedUsers.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Tidak ada user yang belum diverifikasi',
      ),
    );
  } else {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: unverifiedUsers.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => verirfyDialog(
              context,
              authService,
              unverifiedUsers[index],
            ),
            child: Card(
              color: Colors.red[200],
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${unverifiedUsers[index].name}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '${unverifiedUsers[index].email}',
                      style: TextStyle(
                        fontSize: 8.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: unverifiedUsers[index].verified
                          ? Text(
                              'Verified' + ' ${unverifiedUsers[index].type}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[800],
                              ),
                            )
                          : Text(
                              'Not verified',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[800],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<dynamic> verirfyDialog(
    BuildContext context, AuthService provider, dynamic data) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Verifikasi Akun',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text('Apakah anda yakin ingin verifikasi?'),
              const SizedBox(height: 10.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 60.0),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.black),
                      )),
                  const SizedBox(width: 10.0),
                  MyButton(
                    child: const Text('Verifikasi',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      printLog(data);
                      provider.verifyUser(
                          token: provider.token,
                          data: {},
                          params: {"id": data.id.toString()});
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
