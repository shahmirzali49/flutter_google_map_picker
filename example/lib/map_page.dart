// import 'dart:developer';

// import 'package:example/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_maps_places_picker_refractored/google_maps_places_picker_refractored.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';

// final _heightProvider = StateProvider<double>((ref) => 0.0);

// class MapPage extends ConsumerStatefulWidget {
//   const MapPage({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _MapPageState();
// }

// class _MapPageState extends ConsumerState<MapPage> with AutomaticKeepAliveClientMixin {
//   // double _height = 0;
//   PickResult? selectedPlace;
//   DraggableScrollableController controller = DraggableScrollableController();
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       // key: scaffoldState,
//       body: SlidingUpPanel(
//         panel: Container(
//           color: Colors.lightBlue,
//         ),
//         body: PlacePicker(
//           apiKey: "AIzaSyCp0zCDL940M2F_NhLzs_frvm8cAZqV41U",
//           initialPosition: HomePage.kInitialPosition,
//           useCurrentLocation: true,
//           selectInitialPosition: true,
//           hintText: "Mahallle, sokak veya cadde ara",
//           // forceAndroidLocationManager: true,

//           // border: OutlineInputBorder(),
//           // enabledBorder: OutlineInputBorder(),
//           height: 38.0,
//           // borderRadius: BorderRadius.circular(5.0),
//           // usePlaceDetailSearch: true,
//           onPlacePicked: (result) {
//             selectedPlace = result;
//             log("${result.addressComponents![0].longName}-");
//             // Navigator.of(context).pop();
//             // setState(() {
//             ref.read(_heightProvider.state).state = 0.3;

//             // _height = 0.3;
//             // });
//           },
//           forceSearchOnZoomChanged: true,
//           isInScaffoldBodyAndHasAppBar: false,
//           automaticallyImplyAppBarLeading: false,
//           //selectInitialPosition: true,
//           // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
//           //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
//           //   return isSearchBarFocused
//           //       ? Container()
//           //       : FloatingCard(
//           //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
//           //           leftPosition: 0.0,
//           //           rightPosition: 0.0,
//           //           width: 500,
//           //           borderRadius: BorderRadius.circular(12.0),
//           //           child: state == SearchingState.Searching
//           //               ? Center(child: CircularProgressIndicator())
//           //               : RaisedButton(
//           //                   child: Text("Pick Here"),
//           //                   onPressed: () {
//           //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
//           //                     //            this will override default 'Select here' Button.
//           //                     print("do something with [selectedPlace] data");
//           //                     Navigator.of(context).pop();
//           //                   },
//           //                 ),
//           //         );
//           // },
//           // pinBuilder: (context, state) {
//           //   if (state == PinState.Idle) {
//           //     return Icon(Icons.favorite_border);
//           //   } else {
//           //     return Icon(Icons.favorite);
//           //   }
//           // },
//         ),
//       ),
//     );
//   }

//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }
