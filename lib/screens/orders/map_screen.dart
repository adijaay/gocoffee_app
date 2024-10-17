import 'package:coffeonline/screens/orders/models/ongoing_model.dart';
import 'package:coffeonline/utils/print_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:coffeonline/utils/socket/socket_service.dart';

import 'widgets/check_order.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen({
    super.key,
    required this.ongoingData,
  });

  OngoingResponse ongoingData;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  LatLng? buyerLoc; // lokasi mu
  LatLng? merchLoc; // Lokasi Penjual
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    buyerLoc = LatLng(
      widget.ongoingData.latitudeBuyer,
      widget.ongoingData.longitudeBuyer,
    );

    merchLoc = LatLng(
      widget.ongoingData.merchant.latitude,
      widget.ongoingData.merchant.longitude,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("Lokasi Saya"),
        position: buyerLoc!,
        infoWindow: const InfoWindow(title: "Lokasi Saya"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId("Lokasi Penjual"),
        position: merchLoc!,
        infoWindow: InfoWindow(title: widget.ongoingData.merchant.user.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    _getRoute();
  }

  
  void acceptMerchUpdate() {
    final socketProv = Provider.of<SocketServices>(context, listen: false);
  
    socketProv.socket.on('update-location-${widget.ongoingData.id}', (data) {
      printLog(data);
      if (mounted) {
        setState(() {
          merchLoc = LatLng(
            data['latitude'],
            data['longitude'],
          );
          _markers.removeWhere((marker) => marker.markerId == const MarkerId("Lokasi Penjual"));
          _markers.add(
            Marker(
              markerId: const MarkerId("Lokasi Penjual"),
              position: merchLoc!,
              infoWindow: InfoWindow(title: widget.ongoingData.merchant.user.name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        });
        _getRoute();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getRoute() async {
    String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";
    String apiKey = "AIzaSyB_q3Y7dnCikWdwmEFs6tR-jnypbJ5AJSE";

    Dio dio = Dio();
    Response response = await dio.get(baseUrl, queryParameters: {
      "origin": "${buyerLoc!.latitude},${buyerLoc!.longitude}",
      "destination": "${merchLoc!.latitude},${merchLoc!.longitude}",
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
    acceptMerchUpdate();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesananmu',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: buyerLoc!,
              zoom: 13.0,
            ),
            markers: _markers,
            polylines: _polyLines,
          ),
          CheckOrderButton(
            dataOngoing: widget.ongoingData,
          )
        ],
      ),
    );
  }
}
