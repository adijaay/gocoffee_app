import 'package:coffeonline/screens/home/model/riwayat_model.dart';
import 'package:coffeonline/screens/home/widgets/button_order.dart';
import 'package:coffeonline/screens/orders/waiting_accept.dart';
import 'package:coffeonline/utils/date_convert.dart';
import 'package:coffeonline/utils/loading.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../login/provider/auth_service.dart';
import '../provider/order_service.dart';

class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderService>(context, listen: true);
    final authProv = Provider.of<AuthService>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Pesanan'),
          actions: [
            IconButton(
              onPressed: () {
                LoadingDialog.show(context, message: 'Mengambil data...');
                printLog('Refresh app bar');
                if (authProv.userData!.type == 'user') {
                  setState(() {
                    orderProv.getOrderByUser(
                      token: authProv.token,
                      userId: authProv.userData!.id.toString(),
                    );
                  });
                } else if (authProv.userData!.type == 'merchant') {
                  setState(() {
                    orderProv.getOrderByMerchant(
                      token: authProv.token,
                      merchantId: authProv.userData!.merchId,
                    );
                  });
                } else {
                  printLog(authProv.typeUser);
                  setState(() {
                    orderProv.getAllOrder(
                      token: authProv.token
                    );
                  });
                }
                LoadingDialog.hide(context);
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (authProv.userData!.type == 'user') {
              setState(() {
                orderProv.getOrderByUser(
                  token: authProv.token,
                  userId: authProv.userData!.id.toString(),
                );
              });
            } else if (authProv.userData!.type == 'merchant') {
                  setState(() {
                    orderProv.getOrderByMerchant(
                      token: authProv.token,
                      merchantId: authProv.userData!.merchId,
                    );
                  });
                } else {
                  setState(() {
                    orderProv.getAllOrder(
                      token: authProv.token
                    );
                  });
                }
          },
          child: Column(
            children: [
              if (orderProv.historyOrder.isEmpty) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: const Text('Tidak ada riwayat pesanan'),
                      ),
                      MyButton(
                        child: Text('Refresh',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          printLog('Dari button tengah');
                          LoadingDialog.show(context,
                              message: 'Mengambil data...');
                          if (authProv.typeUser == 'user') {
                            setState(() {
                              orderProv.getOrderByUser(
                                token: authProv.token,
                                userId: authProv.userData!.id.toString(),
                              );
                              LoadingDialog.hide(context);
                            });
                          } else if (authProv.typeUser == 'merchant') {
                                setState(() {
                                  orderProv.getOrderByMerchant(
                                    token: authProv.token,
                                    merchantId: authProv.userData!.merchId,
                                  );
                                LoadingDialog.hide(context);
                                });
                              } else {
                                setState(() {
                                  orderProv.getAllOrder(
                                    token: authProv.token
                                  );
                                });
                              LoadingDialog.hide(context);
                              }
                        },
                      ),
                    ],
                  ),
                ),
              ],
              if (orderProv.historyOrder.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: orderProv.historyOrder.length,
                    itemBuilder: (context, index) {
                      final data = orderProv.historyOrder[index];
                      return InkWell(
                        onTap: () => data.doneAt == null
                          ? (authProv.userData!.type == 'user'  ? Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return WaitingAccept(id: data.id.toString());
                            })
                          ) : null)
                          : _detailOrderDialog(data),
                        child: Card(
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${authProv.userData!.type == 'user' ? data.merchant?.user.name == null ? 'Dalam Pencarian' : 'Penjual: ${data.merchant?.user.name}' : 'Pembeli: ${data.user.name}'}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Alamat Pesanan: ${data.address}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: data.doneAt != null
                                      ? Text(
                                          '${formatDateTime(data.doneAt!)}',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[800],
                                          ),
                                        )
                                      : authProv.userData!.type != 'admin' ? Text(
                                          'Dalam Proses',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[800],
                                          ),
                                        ) : Text(
                                          '${formatDate(data.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[800],
                                          )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ]
            ],
          ),
        ));
  }

  _detailOrderDialog(HistoryModel data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan ID: ${data.id}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                Text(
                  'Penjual : Kopi ${data.merchant?.user.name}',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  'Status pesanan: ${data.doneAt != null ? 'Selesai' : 'Dalam Proses'} pada ${formatDateTime(data.doneAt!)}',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total : ${data.amount} Gelas Kopi',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  'Alamat Pesanan: ${data.address}',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  'Catatan: ${data.addressDetail}',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Harga: Rp.${data.totalPrice}',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: MyButton(
                    child: const Text('Tutup',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
