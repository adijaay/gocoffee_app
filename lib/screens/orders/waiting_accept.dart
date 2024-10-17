import 'package:coffeonline/screens/home/widgets/button_order.dart';
import 'package:coffeonline/screens/orders/map_screen.dart';
import 'package:coffeonline/screens/orders/models/ongoing_model.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/socket/socket_service.dart';
import '../home/provider/order_service.dart';
import '../login/provider/auth_service.dart';

class WaitingAccept extends StatefulWidget {
  const WaitingAccept({super.key, this.id});

  final String? id;

  @override
  State<WaitingAccept> createState() => _WaitingAcceptState();
}

class _WaitingAcceptState extends State<WaitingAccept> {
  bool isAcceptedOrder = false;
  OngoingResponse? order;

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketServices>(context, listen: false);
    final userProv = Provider.of<AuthService>(context, listen: false);
    final orderProv = Provider.of<OrderService>(context, listen: false);

    printLog('ini id ${widget.id}');

    if (widget.id != null) {
      final response = orderProv.getOrderById(
        token: userProv.token,
        orderId: widget.id!,
      );
      response.then((value) {
        if (mounted) {
          setState(() {
            isAcceptedOrder = false;
          });
        }
      });
    } else {
      socketService.socket.connect();
      socketService.socket.on('${userProv.userId}-ongoing-order', _handleOrder);
    }
  }

  void _handleOrder(dynamic data) async {
    final userProv = Provider.of<AuthService>(context, listen: false);
    final orderProv = Provider.of<OrderService>(context, listen: false);
    printLog('Socket mencari penjual acc');
    final response = orderProv.getOrderById(
      token: userProv.token,
      orderId: data['id'].toString(),
    );
    response.then((value) {
      if (mounted) {
        setState(() {
          isAcceptedOrder = true;
        });
      }
    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketServices>(context, listen: false);
    final userProv = Provider.of<AuthService>(context, listen: false);

    socketService.socket.off('${userProv.userId}-ongoing-order', _handleOrder);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = context.watch<OrderService>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isAcceptedOrder) ...[
              SvgPicture.asset(
                'assets/waiting.svg',
                height: 200,
                width: 200,
              ),
              Text(
                'Mencari Penjual yang siap melayani',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Card(
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         MenuTextDetail(
              //           text:
              //               '- Jumlah Gelas: ${orderData.ongoingResponse != null ? orderData.ongoingResponse!.amount : 0}',
              //         ),
              //         MenuTextDetail(
              //           text:
              //               '- Harga Maksimal: ${orderData.ongoingResponse != null ? orderData.ongoingResponse!.totalPrice : 0}',
              //         ),
              //         MenuTextDetail(
              //           text:
              //               '- Alamat Kamu: ${orderData.ongoingResponse != null ? orderData.ongoingResponse!.address : ''}',
              //         ),
              //         MenuTextDetail(
              //           text:
              //               '- Catatan: ${orderData.ongoingResponse != null ? orderData.ongoingResponse!.addressDetail : ''}',
              //         ),
              //         MenuTextDetail(
              //           text:
              //               '- Order ID: ${orderData.ongoingResponse != null ? orderData.ongoingResponse!.id : ''}',
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
            if (isAcceptedOrder) ...[
              SvgPicture.asset(
                'assets/accept.svg',
                height: 200,
                width: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Penjual Berhasil Menerima Pesanan Anda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              MyButton(
                child: Text('Cek Lokasi',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return MapScreen(
                        ongoingData: orderData.ongoingResponse!,
                      );
                    },
                  ));
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
