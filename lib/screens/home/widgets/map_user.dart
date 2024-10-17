import 'package:coffeonline/screens/home-merchant/models/merchant_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMap extends StatefulWidget {
  UserMap({
    Key? key,
    required this.latitudeBuyer,
    required this.longitudeBuyer,
    required this.coordinates,
  }) : super(key: key);

  final double latitudeBuyer, longitudeBuyer;
  final List<Merchant> coordinates;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<UserMap> {
  late GoogleMapController mapController;
  LatLng? buyerLoc;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(covariant UserMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinates != widget.coordinates) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    buyerLoc = LatLng(widget.latitudeBuyer, widget.longitudeBuyer);
    _markers.clear();
    for (int i = 0; i < widget.coordinates.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(
            double.parse(widget.coordinates[i].latitude),
            double.parse(widget.coordinates[i].longitude),
          ),
          infoWindow: InfoWindow(title: "Lokasi Merchant"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    setState(() {}); // Trigger a rebuild after updating markers
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationEnabled: true,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: buyerLoc ?? LatLng(0, 0), // Ensure buyerLoc is not null
        zoom: 13.0,
      ),
      markers: _markers,
    );
  }
}
