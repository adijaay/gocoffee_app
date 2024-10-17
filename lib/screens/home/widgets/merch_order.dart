import 'package:coffeonline/screens/home/widgets/button_order.dart';
import 'package:coffeonline/screens/home/widgets/merch_map.dart';
import 'package:coffeonline/screens/login/provider/auth_service.dart';

import 'package:coffeonline/utils/print_log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/order_service.dart';

class MerchOrder extends StatefulWidget {
  final String orderId;

  MerchOrder({super.key, required this.orderId});

  @override
  State<MerchOrder> createState() => _MerchOrderState();
}

class _MerchOrderState extends State<MerchOrder> {
  Future<void> _fetchOrderHistory() async {
    final _authService = context.read<AuthService>();
    final _orderService = context.read<OrderService>();
    await _orderService.getOrderById(
      token: _authService.token,
      orderId: widget.orderId,
    );
  }

  void _completeOrder() {
    final _authService = context.read<AuthService>();
    final _orderService = context.read<OrderService>();
    _orderService
        .completeOrder(token: _authService.token, orderId: widget.orderId)
        .then((_) {
      Navigator.pop(context);
    });
  }

  @override

  void initState() {
    super.initState();
    _fetchOrderHistory();
    printLog('done fetch');
  }

  @override
  Widget build(BuildContext context) {
    print('MerchOrder build called');

    String formatPrice(double price) {
      String priceString = price.toStringAsFixed(
          2); // Convert price to a string with 2 decimal places
      List<String> parts = priceString
          .split('.'); // Split the string into integer and decimal parts

      String integerPart = parts[0];
      String decimalPart =
          parts.length > 1 ? parts[1] : ''; // Check if there are decimal places

      // Add thousand separators to the integer part
      String formattedInteger = '';
      for (int i = integerPart.length - 1; i >= 0; i--) {
        formattedInteger = integerPart[i] + formattedInteger;
        if ((integerPart.length - i) % 3 == 0 && i != 0) {
          formattedInteger = '.' + formattedInteger; // Add thousand separator
        }
      }

      return 'Rp. $formattedInteger${decimalPart.isNotEmpty ? '.' + decimalPart : ''}'; // Combine integer, decimal, and "Rp." prefix
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Info',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: FutureBuilder(
        future: _fetchOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final _orderService = context.watch<OrderService>();
            printLog(
                "order service: ${_orderService.ongoingResponse?.address}");
            final order = _orderService.ongoingResponse;

            if (order == null) {
              return Center(child: Text('No order data found.'));
            }

            return Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID #${order.id}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${order.user.name.toUpperCase()}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Alamat: ${order.address}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Detail: ${order.addressDetail}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Jumlah Kopi: ${order.amount}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total: ${formatPrice(double.parse(order.totalPrice))}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(18),
                    margin: EdgeInsets.only(bottom: 20),
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: MerchMap(
                      latitudeBuyer: order.latitudeBuyer,
                      longitudeBuyer: order.longitudeBuyer,
                      latitudeMerchant: order.merchant.latitude,
                      longitudeMerchant: order.merchant.longitude,
                      orderID: order.id,
                      merchantID: order.merchant.id,
                    ),
                  ),
                  if (order.doneAt == null) ...[
                    Center(
                      child: MyButton(
                        child: Text('Complete Order',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          _completeOrder();
                        },
                      ),
                    ),
                  ]
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
