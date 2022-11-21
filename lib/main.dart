import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_distance/map_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Google Map Route'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final control = Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Obx(
        () => GoogleMap(
          onMapCreated: control.onmapCreate,
          markers: control.markers.value,
          polylines: control.polyline.value,
          initialCameraPosition:
              const CameraPosition(target: LatLng(0.0, 0.0), zoom: 18),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          /**uncomment when you dont remove your current location*/
          // control.getCurrentPosition(control.mapController);
          control.getCurrentLocation(control.mapController);
        },
        label: const Text('start Navigation'),
        icon: const Icon(Icons.location_on),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
