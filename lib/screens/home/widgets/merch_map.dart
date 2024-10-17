import 'package:coffeonline/screens/home-merchant/provider/merchant_service.dart';
import 'package:coffeonline/screens/login/provider/auth_service.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:coffeonline/utils/socket/socket_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';


// ignore: must_be_immutable
class MerchMap extends StatefulWidget {
  MerchMap({
    super.key,
    required this.latitudeBuyer,
    required this.longitudeBuyer,
    required this.latitudeMerchant,
    required this.longitudeMerchant,
    required this.orderID,
    required this.merchantID,
  });

  double latitudeBuyer, longitudeBuyer, latitudeMerchant, longitudeMerchant;
  int orderID;
  int? merchantID;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MerchMap> {
  late GoogleMapController mapController;

  LatLng? buyerLoc; // lokasi mu
  LatLng? merchLoc; // Lokasi Penjual
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    buyerLoc = LatLng(
      widget.latitudeBuyer,
      widget.longitudeBuyer,
    );

    merchLoc = LatLng(
      widget.latitudeMerchant,
      widget.longitudeMerchant,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("Lokasi Pembeli"),
        position: buyerLoc!,
        infoWindow: const InfoWindow(title: "Lokasi Pembeli"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    // _markers.add(
    //   Marker(
    //     markerId: const MarkerId("Lokasi Saya"),
    //     position: merchLoc!,
    //     infoWindow: InfoWindow(title: "Lokasi Saya"),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    //   ),
    // );
    _updateRoute();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _updateRoute() async {
    final authProv = Provider.of<AuthService>(context, listen: false);
    final socketProv = Provider.of<SocketServices>(context, listen: false);
    final merchProv = Provider.of<MerchantService>(context, listen: false);
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100, // in meters
  );

  Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
    if(authProv.userData?.merchId == widget.merchantID){
      printLog("check loc");
      merchProv.updateLocation(latitude: position.latitude.toString(), longitude: position.longitude.toString(), token: authProv.token, id: widget.orderID.toString());
      socketProv.socket.emit('update-location-' + widget.orderID.toString(), {
        'userId': authProv.userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'orderId': widget.orderID.toString()
      });
      printLog("sent location update-location-" + widget.orderID.toString());
    }
  });

  _getRoute();
}

  Future<void> _getRoute() async {
    String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";
    String apiKey = "AIzaSyB_q3Y7dnCikWdwmEFs6tR-jnypbJ5AJSE";

    Dio dio = Dio();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double currentLatitude = position.latitude;
    double currentLongitude = position.longitude;
    Response response = await dio.get(baseUrl, queryParameters: {
      "origin": "${currentLatitude},${currentLongitude}",
      "destination": "${buyerLoc!.latitude},${buyerLoc!.longitude}",
      "key": apiKey,
    });

    if (response.statusCode == 200) {
      var body = response.data;
      List<LatLng> routeCoords = [];
      if (body['routes'].length > 0) {
        body['routes'][0]['legs'][0]['steps'].forEach((step) {
          routeCoords.add(LatLng(
              step['start_location']['lat'], step['start_location']['lng']));
          routeCoords.add(
              LatLng(step['end_location']['lat'], step['end_location']['lng']));
        });
      }
      _drawRoute(routeCoords);
    } else {
      throw Exception('Failed to load route');
    }
  }

  void _drawRoute(List<LatLng> routeCoords) {
    setState(() {
      _polyLines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: routeCoords,
          color: Colors.blue,
          width: 3,
        ),
      );
    });
  }

  final Set<Polyline> _polyLines = {};

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: buyerLoc!,
        zoom: 13.0,
      ),
      markers: _markers,
      polylines: _polyLines,
      myLocationEnabled: true,
    );
  }
}
