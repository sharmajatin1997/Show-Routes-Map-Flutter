import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

import 'package:location/location.dart';

class MapController extends RxController {
  late GoogleMapController mapController;
  final RxSet<Marker> markers = RxSet();
  final RxSet<Polyline> polyline = RxSet();
  Rx<LatLng> sourceLoc = Rx(const LatLng(0, 0));
  late PolylinePoints polylinePoints;
  RxList<LatLng> polylineCoordinates = RxList();
  LocationData? currentLocation;

  @override
  void onInit() {
    addMarker();
    super.onInit();
  }

  createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "API KEY OF MAP", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      polylineCoordinates.refresh();
    }

    polyline.add(Polyline(
      polylineId: PolylineId('1'),
      width: 6,
      points: polylineCoordinates,
      color: Colors.red,
    ));
  }

  onmapCreate(GoogleMapController controller) {
    mapController = controller;
    getCurrentPosition(controller);
     /**uncomment when you dont remove your current location*/
    // getCurrentLocation(controller);
  }

  addMarker() async {
    final Uint8List? markerIcon =
        await getBytesFromAsset('assets/hotel.png', 100);
    markers.add(Marker(
      markerId: MarkerId("1"),
      anchor: const Offset(0.5, 0.9),
      position: LatLng(30.7068, 76.7081),
      infoWindow: const InfoWindow(
        title: 'HOSPITAL',
        snippet: 'IVY HOSPITAL',
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon!),
    ));
  }

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  Future<void> getCurrentPosition(GoogleMapController map) async {
    polyline.clear();
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition().then((Position position) async {
      sourceLoc.value = LatLng(position.latitude, position.longitude);
      map.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 0,
        target: sourceLoc.value,
        zoom: 18.0,
      )));
      await createPolylines(
          position.latitude, position.longitude, 30.7068, 76.7081);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void getCurrentLocation(GoogleMapController map) async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    location.onLocationChanged.listen(
      (newLoc) async {
        currentLocation = newLoc;
        map.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 18,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        markers.add(Marker(
          markerId: MarkerId("2"),
          anchor: const Offset(0.5, 0.9),
          position: LatLng(
            newLoc.latitude!,
            newLoc.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));

        /**comment this code  if your cannot remove current location 137 to 139*/
        await createPolylines(
            newLoc.latitude!,
            newLoc.longitude!, 30.7068, 76.7081);
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
}
