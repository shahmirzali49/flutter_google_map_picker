/*
Name: Akshath Jain
Date: 3/18/2019 - 4/26/2021
Purpose: Example app that implements the package: sliding_up_panel
Copyright: © 2021, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_places_picker/google_maps_places_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/services.dart';

void main() => runApp(
      const SlidingUpPanelExample(),
    );

class SlidingUpPanelExample extends StatelessWidget {
  const SlidingUpPanelExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[200],
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.black,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SlidingUpPanel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double _initFabHeight = 0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 0.0;
  PanelController controller = PanelController();
  @override
  void initState() {
    super.initState();

    _fabHeight = _initFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    // _panelHeightOpen = MediaQuery.of(context).size.height * .70;

    return PlacePicker(
      apiKey: "AIzaSyCp0zCDL940M2F_NhLzs_frvm8cAZqV41U",
      initialPosition: LatLng(-33.8567844, 151.213108),
      useCurrentLocation: true,
      textFieldTopSize: MediaQuery.of(context).padding.top,
      selectInitialPosition: true,
      // isInScaffoldBodyAndHasAppBar: false,
      // border: OutlineInputBorder(),
      // enabledBorder: OutlineInputBorder(),
      height: 40.0,
      strictbounds: false,
      // borderRadius: BorderRadius.circular(5.0),
      //usePlaceDetailSearch: true,
      onPlacePicked: (result) {
        Navigator.of(context).pop();
        setState(() {});
      },
      //forceSearchOnZoomChanged: true,
      automaticallyImplyAppBarLeading: false, appBarBackgroundColor: Colors.blue,
    );
  }

  Widget _panel(ScrollController sc) {
    return InkWell(
      onTap: () => controller.close(),
      child: Container(
        color: Colors.amber,
      ),
    );
  }

  Widget _body() {
    return PlacePicker(
      apiKey: "AIzaSyCp0zCDL940M2F_NhLzs_frvm8cAZqV41U",
      initialPosition: LatLng(-33.8567844, 151.213108),
      useCurrentLocation: false, appBarBackgroundColor: Colors.blue,
      selectInitialPosition: true,
      textFieldTopSize: 50,
      hintText: "Mahallle, sokak veya cadde ara",
      // forceAndroidLocationManager: true,

      // border: OutlineInputBorder(),
      // enabledBorder: OutlineInputBorder(),
      height: 38.0,
      // borderRadius: BorderRadius.circular(5.0),
      // usePlaceDetailSearch: true,
      onPlacePicked: (result) {
        // selectedPlace = result;
        log("${result.addressComponents![0].longName}-");
        // Navigator.of(context).pop();
        // setState(() {
        // ref.read(_heightProvider.state).state = 0.3;

        // _height = 0.3;
        // });
      },
      // forceSearchOnZoomChanged: true,
      isInScaffoldBodyAndHasAppBar: false,
      automaticallyImplyAppBarLeading: false,
      //selectInitialPosition: true,
      // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
      //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
      //   return isSearchBarFocused
      //       ? Container()
      //       : FloatingCard(
      //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
      //           leftPosition: 0.0,
      //           rightPosition: 0.0,
      //           width: 500,
      //           borderRadius: BorderRadius.circular(12.0),
      //           child: state == SearchingState.Searching
      //               ? Center(child: CircularProgressIndicator())
      //               : RaisedButton(
      //                   child: Text("Pick Here"),
      //                   onPressed: () {
      //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
      //                     //            this will override default 'Select here' Button.
      //                     print("do something with [selectedPlace] data");
      //                     Navigator.of(context).pop();
      //                   },
      //                 ),
      //         );
      // },
      // pinBuilder: (context, state) {
      //   if (state == PinState.Idle) {
      //     return Icon(Icons.favorite_border);
      //   } else {
      //     return Icon(Icons.favorite);
      //   }
      // },
    );
  }
}
