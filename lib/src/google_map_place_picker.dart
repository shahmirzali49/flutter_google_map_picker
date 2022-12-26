import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_places_picker/src/utils/default_pin_builder_widget.dart';
import 'package:google_maps_webservice_ex/places.dart';
import '../google_maps_places_picker.dart';
import '../providers/place_provider.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

typedef SelectedPlaceWidgetBuilder = Widget Function(
  BuildContext context,
  PickResult? selectedPlace,
  SearchingState state,
  bool isSearchBarFocused,
);

typedef PinBuilder = Widget Function(
  BuildContext context,
  PinState state,
);

class GoogleMapPlacePicker extends StatefulWidget {
  const GoogleMapPlacePicker({
    Key? key,
    required this.initialCameraPosition,
    required this.appBarKey,
    this.selectedPlaceWidgetBuilder,
    this.pinBuilder,
    this.onSearchFailed,
    this.onMoveStart,
    this.onMapCreated,
    this.debounceMilliseconds,
    this.enableMapTypeButton,
    this.enableMyLocationButton,
    this.onToggleMapType,
    this.googleMapOntap,
    this.onMyLocation,
    this.usePinPointingSearch,
    this.usePlaceDetailSearch,
    this.selectInitialPosition,
    this.language,
    this.forceSearchOnZoomChanged,
    this.hidePlaceDetailsWhenDraggingPin,
    required this.polygons,
    required this.pinIcon,
    this.polygonPoints,
  }) : super(key: key);

  final CameraPosition initialCameraPosition;
  final Set<Polygon>? polygons;
  final GlobalKey appBarKey;

  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;
  final PinBuilder? pinBuilder;

  final ValueChanged<String>? onSearchFailed;
  final VoidCallback? onMoveStart;
  final MapCreatedCallback? onMapCreated;
  final VoidCallback? onToggleMapType;
  final VoidCallback? onMyLocation;
  final void Function(LatLng)? googleMapOntap;

  final int? debounceMilliseconds;
  final bool? enableMapTypeButton;
  final bool? enableMyLocationButton;

  final bool? usePinPointingSearch;
  final bool? usePlaceDetailSearch;

  final bool? selectInitialPosition;

  final String? language;

  final bool? forceSearchOnZoomChanged;
  final bool? hidePlaceDetailsWhenDraggingPin;
  final Icon pinIcon;

  final List<List<maps_toolkit.LatLng>>? polygonPoints;

  @override
  State<GoogleMapPlacePicker> createState() => _GoogleMapPlacePickerState();
}

class _GoogleMapPlacePickerState extends State<GoogleMapPlacePicker> {
  _searchByCameraLocation(PlaceProvider provider, {SearchingState? searchingState}) async {
    // We don't want to search location again if camera location is changed by zooming in/out.
    if (widget.forceSearchOnZoomChanged == false &&
        provider.prevCameraPosition != null &&
        provider.prevCameraPosition!.target.latitude == provider.cameraPosition!.target.latitude &&
        provider.prevCameraPosition!.target.longitude == provider.cameraPosition!.target.longitude) {
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }

    provider.placeSearchingState = SearchingState.Searching;

    final GeocodingResponse response = await provider.geocoding.searchByLocation(
      Location(lat: provider.cameraPosition!.target.latitude, lng: provider.cameraPosition!.target.longitude),
      language: widget.language,
    );

    if (response.errorMessage?.isNotEmpty == true || response.status == "REQUEST_DENIED") {
      print("Camera Location Search Error: " + response.errorMessage!);
      if (widget.onSearchFailed != null) {
        widget.onSearchFailed!(response.status);
      }
      provider.placeSearchingState = SearchingState.Idle;
      return;
    }

    if (widget.usePlaceDetailSearch!) {
      final PlacesDetailsResponse detailResponse = await provider.places.getDetailsByPlaceId(
        response.results[0].placeId,
        language: widget.language,
      );
      if (detailResponse.errorMessage?.isNotEmpty == true || detailResponse.status == "REQUEST_DENIED") {
        print("Fetching details by placeId Error: " + detailResponse.errorMessage!);
        if (widget.onSearchFailed != null) {
          widget.onSearchFailed!(detailResponse.status);
        }
        provider.placeSearchingState = SearchingState.Idle;
        return;
      }

      provider.selectedPlace = PickResult.fromPlaceDetailResult(detailResponse.result!);
      log("message 1 ${provider.selectedPlace?.formattedAddress}");
    } else if (response.results.isEmpty) {
      provider.placeSearchingState = SearchingState.ResultError;
    } else {
      provider.selectedPlace = PickResult.fromGeocodingResult(response.results[0]);

      log("message  2 ${provider.selectedPlace?.formattedAddress}");
    }

    provider.placeSearchingState = searchingState ?? SearchingState.Idle;
  }

  bool _mapInitializing = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildGoogleMap(context),
        _buildPin(),
        _buildFloatingCard(),
        _buildMapIcons(context),
        if (_mapInitializing)
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.grey.withOpacity(0.7),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Selector<PlaceProvider, MapType>(
        selector: (_, provider) => provider.mapType,
        builder: (_, data, __) {
          PlaceProvider provider = PlaceProvider.of(context, listen: false);
          // CameraPosition initialCameraPosition = CameraPosition(target: initialTarget, zoom: initialZoom);

          return GoogleMap(
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: widget.initialCameraPosition,
            mapType: data,

            myLocationEnabled: true,
            onTap: widget.googleMapOntap,
            polygons: widget.polygons ?? {},
            onMapCreated: (GoogleMapController controller) async {
              provider.mapController = controller;
              provider.setCameraPosition(null);
              provider.pinState = PinState.Idle;
              await Future.delayed(Duration(milliseconds: 300));
              setState(() {
                _mapInitializing = false;
              });

              // When select initialPosition set to true.
              if (widget.selectInitialPosition!) {
                provider.setCameraPosition(widget.initialCameraPosition);
                _searchByCameraLocation(provider, searchingState: SearchingState.FirstTime);
              }
            },

            onCameraIdle: () {
              print("CAMERA IDLE - 1 -> ${provider.placeSearchingState} - 2 -> ${provider.pinState} ");

              if (provider.isAutoCompleteSearching) {
                provider.isAutoCompleteSearching = false;
                provider.pinState = PinState.Idle;
                provider.placeSearchingState = SearchingState.Idle;
                return;
              }

              if (widget.polygonPoints != null && widget.polygonPoints!.isNotEmpty && provider.cameraPosition != null) {
                final isValid = widget.polygonPoints!.any(
                  (element) => maps_toolkit.PolygonUtil.containsLocation(
                    maps_toolkit.LatLng(
                      provider.cameraPosition!.target.latitude,
                      provider.cameraPosition!.target.longitude,
                    ),
                    element,
                    true,
                  ),
                );
                if (isValid) {
                  if (widget.usePinPointingSearch!) {
                    // Search current camera location only if camera has moved (dragged) before.
                    if (provider.pinState == PinState.Dragging) {
                      // Cancel previous timer.
                      if (provider.debounceTimer?.isActive ?? false) {
                        provider.debounceTimer!.cancel();
                      }
                      provider.debounceTimer = Timer(Duration(milliseconds: widget.debounceMilliseconds!), () {
                        _searchByCameraLocation(provider);
                      });
                    }
                  }
                  provider.placeSearchingState = SearchingState.Idle;
                  provider.pinState = PinState.Idle;
                } else {
                  provider.placeSearchingState = SearchingState.LocationIsNotInPolygons;
                }
              } else {
                // Perform search only if the setting is to true.
                if (widget.usePinPointingSearch!) {
                  // Search current camera location only if camera has moved (dragged) before.
                  if (provider.pinState == PinState.Dragging) {
                    // Cancel previous timer.
                    if (provider.debounceTimer?.isActive ?? false) {
                      provider.debounceTimer!.cancel();
                    }
                    provider.debounceTimer = Timer(Duration(milliseconds: widget.debounceMilliseconds!), () {
                      _searchByCameraLocation(provider);
                    });
                  }
                }
                provider.placeSearchingState = SearchingState.Idle;
                provider.pinState = PinState.Idle;
              }
            },
            onCameraMoveStarted: () {
              provider.setPrevCameraPosition(provider.cameraPosition);

              // Cancel any other timer.
              provider.debounceTimer?.cancel();

              // Update state, dismiss keyboard and clear text.
              provider.pinState = PinState.Dragging;

              // Begins the search state if the hide details is enabled
              // if (this.hidePlaceDetailsWhenDraggingPin!) {
              provider.placeSearchingState = SearchingState.Searching;
              print("SearchingState ${provider.placeSearchingState}");
              // }

              widget.onMoveStart!();
            },
            onCameraMove: (CameraPosition position) {
              provider.setCameraPosition(position);
              // print("SearchingState ${provider.placeSearchingState}");
            },
            // gestureRecognizers make it possible to navigate the map when it's a
            // child in a scroll view e.g ListView, SingleChildScrollView...
            gestureRecognizers: Set()..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
          );
        });
  }

  Widget _buildPin() {
    return Center(
      child: Selector<PlaceProvider, PinState>(
        selector: (_, provider) => provider.pinState,
        builder: (context, state, __) {
          if (widget.pinBuilder == null) {
            return DefaultPinBuilderWidget(
              state: state,
              pinIcon: widget.pinIcon,
            );
          } else {
            return Builder(builder: (builderContext) => widget.pinBuilder!(builderContext, state));
          }
        },
      ),
    );
  }

  Widget _buildFloatingCard () {
    return Selector<PlaceProvider, Tuple4<PickResult?, SearchingState, bool, PinState>>(
      selector: (_, provider) =>
          Tuple4(provider.selectedPlace, provider.placeSearchingState, provider.isSearchBarFocused, provider.pinState),
      builder: (context, data, __) {
        if ((data.item1 == null) ||
            data.item3 == true ||
            data.item4 == PinState.Dragging && this.widget.hidePlaceDetailsWhenDraggingPin!) {
          log("Container ${data.item1} ${widget.selectedPlaceWidgetBuilder}");
          return SizedBox.shrink();
        } else {
          if (widget.selectedPlaceWidgetBuilder == null) {
            log("selectedPlaceWidgetBuilder ${widget.selectedPlaceWidgetBuilder}");
            return _defaultPlaceWidgetBuilder(context, data.item1, data.item2);
          } else {
            log("else selectedPlaceWidgetBuilder ${widget.selectedPlaceWidgetBuilder}");
            return Builder(
                builder: (builderContext) =>
                    widget.selectedPlaceWidgetBuilder!(builderContext, data.item1, data.item2, data.item3));
          }
        }
      },
    );
  }

  Widget _defaultPlaceWidgetBuilder(BuildContext context, PickResult? data, SearchingState state) {
    return FloatingCard(
      bottomPosition: 10,
      leftPosition: 15,
      rightPosition: 15,
      width: double.maxFinite,
      borderRadius: BorderRadius.circular(12.0),
      // elevation: 4.0,
      color: Theme.of(context).cardColor,
      child: state == SearchingState.FirstTime
          ? SizedBox.shrink()
          : state == SearchingState.Searching
              ? _buildLoadingIndicator()
              : _buildSelectionDetails(context, data!, state),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 48,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionDetails(BuildContext context, PickResult result, SearchingState state) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            state == SearchingState.ResultError
                ? "Şuanda bir hata almaktasınız lutfen internetinizi kontrol edin veya imleçi tekrar haraket etdiriniz"
                : state == SearchingState.LocationIsNotInPolygons
                    ? "Suanda secili adresinize teslimat yapamıyoruz lutfen diger bir adres seciniz"
                    : result.formattedAddress!,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),

          // ElevatedButton(
          //   style: ButtonStyle(
          //     padding: MaterialStateProperty.all(
          //       EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          //     ),
          //     shape: MaterialStateProperty.all(
          //       RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(4.0),
          //       ),
          //     ),
          //   ),
          //   child: Text(
          //     "Select here",
          //     style: TextStyle(fontSize: 16),
          //   ),
          //   onPressed: () {
          //     onPlacePicked!(result);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildMapIcons(BuildContext context) {
    // final RenderBox appBarRenderBox =
    //     appBarKey.currentContext!.findRenderObject() as RenderBox;

    return Positioned(
      // top: appBarRenderBox.size.height,
      top: 26,
      // MediaQuery.of(context).size.height * 0.05,
      right: 17,
      child: Column(
        children: <Widget>[
          if (widget.enableMapTypeButton != null && widget.enableMapTypeButton!)
            Container(
              width: 40,
              height: 40,
              child: RawMaterialButton(
                shape: CircleBorder(),
                fillColor: Colors.white,
                elevation: 8.0,
                onPressed: widget.onToggleMapType,
                child: Icon(Icons.layers),
              ),
            ),
          SizedBox(height: 10),
          if (widget.enableMapTypeButton != null && widget.enableMyLocationButton!)
            Container(
              width: 40,
              height: 40,
              child: RawMaterialButton(
                shape: CircleBorder(),
                fillColor: Colors.white,
                elevation: 8.0,
                onPressed: widget.onMyLocation,
                child: Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }
}
