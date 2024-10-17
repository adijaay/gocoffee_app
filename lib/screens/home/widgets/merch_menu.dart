import 'package:coffeonline/screens/home/UI/user_riwayat.dart';
import 'package:coffeonline/screens/home/provider/coffee_service.dart';
import 'package:coffeonline/screens/home/widgets/button_order.dart';
import 'package:coffeonline/screens/home/widgets/merch_map.dart';
import 'package:coffeonline/screens/home/widgets/merch_order.dart';
import 'package:coffeonline/screens/login/provider/auth_service.dart';
import 'package:coffeonline/screens/orders/models/order_model.dart';
import 'package:coffeonline/utils/loading.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../utils/socket/socket_service.dart';
import '../../home-merchant/provider/merchant_service.dart';
import '../provider/order_service.dart';

class MerchMenu extends StatefulWidget {
  const MerchMenu({super.key});

  @override
  State<MerchMenu> createState() => _MerchMenuState();
}

class _MerchMenuState extends State<MerchMenu> {
  TextEditingController stockController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<String> selectedCoffeeNames = [];
  List<int> selectedCoffeeIds = [];
  bool isRequestedOrder = false;
  OrderResponse? order;
  OrderResponse? orderPrev;
  bool isFetched = false;
  late Future<void> fetchOrderHistoryFuture;

  bool _serviceEnabled = false;
  LocationPermission _permission = LocationPermission.denied;

  @override
  void dispose() {
    printLog('Widget disposed');
    stockController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderHistory() async {
    final authService = context.read<AuthService>();
    final orderService = context.read<OrderService>();
    printLog("function order merchant called ${authService.token}");
    await orderService.getOrderByMerchant(
      token: authService.token,
      merchantId: authService.userData!.merchId,
    );
  }

  void _fetchOrderRequest() async {
    final authService = context.read<AuthService>();
    final orderService = context.read<OrderService>();
    printLog("function order merchant called ${authService.token}");
    await orderService.getOrderRequested(
      token: authService.token,
    );
  }

  void _fetchCoffeeList() async {
    printLog('fetch coffee list called');
    final orderService = context.read<CoffeeService>();
    await orderService.getCoffee();
    printLog(orderService.coffeeData);
  }

  @override
  void initState() {
    super.initState();
    printLog("check state");
    _fetchCoffeeList();
    _fetchOrderHistory();
    _fetchOrderRequest();
    printLog('merch menu init');
  }

  @override
  Widget build(BuildContext context) {
    print('MerchMenu build called');
    final merchProv = context.watch<MerchantService>();
    final userProv = Provider.of<AuthService>(context, listen: true);
    final _orderService = context.watch<OrderService>();
    final _coffeeService = context.watch<CoffeeService>();
    final socketService = Provider.of<SocketServices>(context, listen: true);

    socketService.socket.connect();
    merchProv.decrementCount();
    socketService.socket.on('${userProv.userId}-request-order', (data) {
      printLog('Socket mencari penjual..., $data');
      order = OrderResponse.fromJson(data);
      printLog("order ${order!.id}, count ${merchProv.count}");
      if (merchProv.count < 1) {
        _orderService.setListOrderRequested(
          token: userProv.token,
          idOrder: order!.id,
        );
        _showOrderDialog(context, order!, userProv);
        merchProv.incrementCount();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
      child: RefreshIndicator(
        onRefresh: () async {
          await _fetchOrderHistory();
        },
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runAlignment: WrapAlignment.spaceEvenly,
                    direction: Axis.vertical,
                    children: [
                      MyButton(
                        child: const Text('Riwayat',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return UserHistoryScreen();
                            },
                          ));
                        },
                      ),
                      MyButton(
                        child: const Text('Perbarui Informasi',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          // printLog("update token: ${userProv.token}");
                          showDialogMerch();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  height: 120.0, // Set the height of the carousel
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _coffeeService.coffeeData.length,
                    itemBuilder: (context, index) {
                      final coffee = _coffeeService.coffeeData[index];
                      return Container(
                        width: 180.0, // Set the width of each item
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            coffee["image_link"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_orderService.listOrderRequest.length > 0) ...[
                  Text('Request Order :',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: _orderService.listOrderRequest.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              '${_orderService.listOrderRequest[index].id}'),
                          subtitle: Text(
                              'Alamat: ${_orderService.listOrderRequest[index].address}'),
                          onTap: () {
                            _showOrderDialog(
                                context,
                                _orderService.listOrderRequest[index],
                                userProv);
                            _orderService.resetOrderRequest();
                            merchProv.decrementCount();
                          },
                        );
                      },
                    )
                  )
                  // Container(
                  //     width: double.infinity,
                  //     height: 100,
                  //     child: Column(
                  //       children: [
                  //         ListTile(
                  //           title: Text(
                  //               '${_orderService.orderRequestResponse!.id}'),
                  //           subtitle: Text(
                  //               'Alamat: ${_orderService.orderRequestResponse!.address}'),
                  //           onTap: () {
                  //             _showOrderDialog(
                  //                 context,
                  //                 _orderService.orderRequestResponse!,
                  //                 userProv);
                  //             _orderService.resetOrderRequest();
                  //             merchProv.decrementCount();
                  //           },
                  //         ),
                  //       ],
                  //     )),
                ],
                Text('Ongoing Order :',
                    style: Theme.of(context).textTheme.titleLarge),
                Container(
                  width: double.infinity,
                  height: 150,
                  child: ListView.builder(
                    itemCount: _orderService.historyOrder.length,
                    itemBuilder: (context, index) {
                      final order = _orderService.historyOrder[index];
                      if (order.status == 'ongoing') {
                        return Column(
                          children: [
                            ListTile(
                              title: Text('Order ID ${order.id}'),
                              subtitle: Text('Alamat: ${order.address}'),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return MerchOrder(
                                      orderId: order.id.toString(),
                                    );
                                  },
                                ));
                              },
                            ),
                            const Divider(),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCoffeeSelectionDialog(BuildContext context, StateSetter setState) {
    final coffeeService = context.read<CoffeeService>();
    final coffeeItems = coffeeService.coffeeData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Kopi'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: coffeeItems.map((coffee) {
                  final coffeeName = coffee["name"].toString();
                  final coffeeId = coffee["id"] as int;
                  final isSelected = selectedCoffeeIds.contains(coffeeId);

                  return CheckboxListTile(
                    title: Text(coffeeName),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedCoffeeIds.add(coffeeId);
                          selectedCoffeeNames.add(coffeeName);
                        } else {
                          selectedCoffeeIds.remove(coffeeId);
                          selectedCoffeeNames.remove(coffeeName);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Notify parent widget of the change
                setState(() {
                  // Refresh parent state if needed
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDialog(
    BuildContext context,
    OrderResponse order,
    AuthService userProv,
  ) {
    // if (!mounted) return;
    final _orderService = context.read<OrderService>();
    final merchProv = context.read<MerchantService>();

    double lat = 0.0;
    double long = 0.0;
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

    Future<void> getLocation() async {
      try {
        LoadingDialog.show(context, message: 'Mendapatkan lokasi...');
        bool _serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await Geolocator.openLocationSettings();
          if (!_serviceEnabled) return;
        }

        LocationPermission _permission = await Geolocator.checkPermission();
        if (_permission == LocationPermission.denied) {
          _permission = await Geolocator.requestPermission();
          if (_permission == LocationPermission.denied) return;
        }

        if (_permission == LocationPermission.deniedForever) return;

        if (_permission == LocationPermission.whileInUse ||
            _permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          if (!mounted) return; // Check if widget is still mounted
          setState(() {
            lat = position.latitude;
            long = position.longitude;
          });
          LoadingDialog.hide(context);
        }
      } catch (e) {
        if (mounted) LoadingDialog.hide(context);
      }
    }

    getLocation().then((_) => showDialog(
          context: context,
          builder: (BuildContext context) {
            if (!mounted) return SizedBox.shrink();
            return Dialog(
                insetPadding: EdgeInsets.all(0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      AppBar(
                        title: Text('Request Order'),
                        automaticallyImplyLeading: false,
                        actions: [
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              merchProv.decrementCount();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text("Jumlah Kopi"),
                                      Text(
                                        order.amount.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("Estimasi Biaya"),
                                      Text(
                                          formatPrice(
                                              double.parse(order.totalPrice)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                    ],
                                  ),
                                ],
                              ),
                              ListTile(
                                title: Text(
                                  order.user.name.toUpperCase(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                    "Alamat: ${order.address} \nCatatan: ${order.addressDetail}"),
                              ),
                              Container(
                                  padding: EdgeInsets.all(18),
                                  margin: EdgeInsets.only(bottom: 20),
                                  height: 400,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: MerchMap(
                                    latitudeBuyer: order.latitudeBuyer,
                                    longitudeBuyer: order.longitudeBuyer,
                                    latitudeMerchant: lat,
                                    longitudeMerchant: long,
                                    orderID: order.id,
                                    merchantID: order.merchantId,
                                  )),
                              MyButton(
                                child: Text(
                                  'Terima Order',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: Colors.white),
                                ),
                                onPressed: () async {
                                  await _orderService.ongoingOrder(
                                    token: userProv.token,
                                    merchantId:
                                        userProv.userData!.merchId.toString(),
                                    orderId: order.id.toString(),
                                  );
                                  merchProv.decrementCount();
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  if(_orderService.ongoingFeedback){
                                    printLog('order feedback: ${_orderService.ongoingFeedback}');
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) {
                                        return MerchOrder(
                                          orderId: order.id.toString(),
                                        );
                                      },
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                        content: Text('Order sudah diambil!'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ));
          },
        ).then((value) => {
              if (mounted) {merchProv.decrementCount()}
            }));
  }

  void showDialogMerch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perbarui Merchant Info'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Satuan',
                  ),
                ),
                const SizedBox(height: 10),
                MyButton(
                  child: const Text('Pilih Kopi',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _showCoffeeSelectionDialog(context, setState);
                  },
                ),
                const SizedBox(height: 10),
                Text('Kopi Terpilih: ${selectedCoffeeNames.join(', ')}'),
                const SizedBox(height: 10),
                MyButton(
                  child: const Text('Perbarui Data & Lokasi',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    updateMerchInfo().then((value) => Navigator.pop(context));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> updateMerchInfo() async {
    final provider = context.read<MerchantService>();
    final authProv = context.read<AuthService>();
    LoadingDialog.show(context, message: 'Memuat Data...');

    try {
      if (!mounted) return;

      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await Geolocator.openLocationSettings();
        if (!_serviceEnabled) return;
      }

      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) return;
      }

      if (_permission == LocationPermission.deniedForever) return;

      if (_permission == LocationPermission.whileInUse ||
          _permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (!mounted) return;

        await provider.updateMerchInfo(
          id: authProv.userData!.merchId.toString(),
          token: authProv.token,
          latitude: position.latitude.toString(),
          longitude: position.longitude.toString(),
          stock: stockController.text,
          price: priceController.text,
          coffeeID: selectedCoffeeIds,
        );

        if (mounted) {
          LoadingDialog.hide(context);
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
      }
    }
  }
}
