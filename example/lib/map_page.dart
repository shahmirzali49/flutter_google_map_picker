import 'dart:developer';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_places_picker/google_maps_places_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final _heightProvider = StateProvider<double>((ref) => 0.0);
final latLngProvider = StateProvider<LatLng?>((ref) => null);

class MapPage extends ConsumerWidget {
  MapPage({Key? key}) : super(key: key);

  // double _height = 0;
  PickResult? selectedPlace;
  PanelController panelController = PanelController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SlidingUpPanel(
      maxHeight: 500,
      minHeight: 0,
      controller: panelController,
      panel: Scaffold(
        body: InkWell(
          onTap: () {
            panelController.close();
          },
          child: Container(
            color: Colors.lightBlue,
          ),
        ),
      ),
      body: PlacePicker(
        apiKey: "AIzaSyCp0zCDL940M2F_NhLzs_frvm8cAZqV41U",
        initialCameraPosition: CameraPosition(target: LatLng(-33.8567844, 151.213108), zoom: 13),
        useCurrentLocation: false,
        selectInitialPosition: true,
        hintText: "Mahallle, sokak veya cadde ara",
        inputMargin: EdgeInsets.all(5),
        
        onPlacePicked: (result) async {
          selectedPlace = result;
          log("${result?.addressComponents![0].longName}-");

          ref.read(_heightProvider.state).state = 0.3;

          ref
              .refresh(latLngProvider.notifier)
              .update((state) => state = LatLng(result!.geometry!.location.lat, result.geometry!.location.lng));

          await Future.delayed(Duration(seconds: 1));
          panelController.open();

          print("latLngProvider print -- ${ref.read(latLngProvider)?.latitude}");
        },
        resizeToAvoidBottomInset: false,
        forceSearchOnZoomChanged: false,
      
        isInScaffoldBodyAndHasAppBar: false,
        automaticallyImplyAppBarLeading: false,
        appBarBackgroundColor: Colors.indigo,
        textFieldTopSize: 30,
      ),
    );
  }
}
