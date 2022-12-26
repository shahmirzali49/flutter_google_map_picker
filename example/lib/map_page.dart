import 'dart:developer';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_places_picker/google_maps_places_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// final _heightProvider = StateProvider<double>((ref) => 0.0);
// final latLngProvider = StateProvider<LatLng?>((ref) => null);

class MapPage extends ConsumerStatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  // double _height = 0;
  PickResult? selectedPlace;
  PanelController panelController = PanelController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      maxHeight: 550,
      minHeight: 0,
      parallaxEnabled: true,
      isDraggable: false,
      parallaxOffset: 0.45,
      controller: panelController,
      panel: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 100,
                  color: Colors.lightBlue,
                ),
                TextFormField(),
                TextFormField(),
                TextFormField(
                  // key: _formKey,
                  controller: emailController,
                ),
              ],
            ),
          ),
        ),
      ),
      body: PlacePicker(
        apiKey: "AIzaSyCp0zCDL940M2F_NhLzs_frvm8cAZqV41U",
        initialCameraPosition: CameraPosition(target: LatLng(-33.8567844, 151.213108), zoom: 13),
        pinIcon: Icon(Icons.location_on, color: Colors.orange.shade900, size: 40),
        appBarBackButtonButton: Icon(Icons.arrow_back, color: Colors.white),
        useCurrentLocation: false,
        selectInitialPosition: true,

        hintText: "Mahallle, sokak veya cadde ara",
        myLocationButtonCooldown: 2,
        autoCompleteContentPadding: EdgeInsets.zero,
        // fillColor: ,
        fillColor: Colors.white,
        selectPlaceButtonWidget: (pickResult, searchingState) {
          return const SizedBox.shrink();
        },
        googleMapOntap: (p0) {
          panelController.close();
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
