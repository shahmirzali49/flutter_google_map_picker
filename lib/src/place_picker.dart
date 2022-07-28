import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import '../google_maps_places_picker.dart';
import '../providers/place_provider.dart';
import '../src/autocomplete_search.dart';
import '../src/controllers/autocomplete_search_controller.dart';
import '../src/google_map_place_picker.dart';
import '../src/utils/uuid.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

enum PinState { Preparing, Idle, Dragging }

enum SearchingState { Idle, Searching, FirstTime }

// enum ButtonState { Idle, Searching, FirstTime, UseThisAddress, VerifyAddress }

class PlacePicker extends StatefulWidget {
  PlacePicker({
    Key? key,
    required this.apiKey,
    this.onPlacePicked,
    required this.initialPosition,
    this.useCurrentLocation,
    this.desiredLocationAccuracy = LocationAccuracy.high,
    this.onMapCreated,
    this.hintText,
    this.searchingText,
    // this.searchBarHeight,
    this.resizeToAvoidBottomInset,
    // this.contentPadding,
    this.onAutoCompleteFailed,
    this.onGeocodingSearchFailed,
    this.proxyBaseUrl,
    this.httpClient,
    this.selectedPlaceWidgetBuilder,
    this.pinBuilder,
    this.autoCompleteDebounceInMilliseconds = 500,
    this.cameraMoveDebounceInMilliseconds = 750,
    this.initialMapType = MapType.normal,
    this.enableMapTypeButton = true,
    this.enableMyLocationButton = true,
    this.myLocationButtonCooldown = 10,
    this.usePinPointingSearch = true,
    this.usePlaceDetailSearch = false,
    required this.appBarBackgroundColor,
    this.autocompleteOffset,
    this.autocompleteRadius,
    this.autocompleteLanguage,
    this.autocompleteComponents,
    this.autocompleteTypes,
    this.strictbounds,
    this.region,
    this.selectInitialPosition = false,
    this.initialSearchString,
    this.searchForInitialValue = false,
    this.forceAndroidLocationManager = false,
    this.forceSearchOnZoomChanged = false,
    this.automaticallyImplyAppBarLeading = true,
    this.autocompleteOnTrailingWhitespace = false,
    this.hidePlaceDetailsWhenDraggingPin = true,
    this.icon,
    this.iconColor,
    this.label,
    required this.textFieldTopSize,
    this.labelText,
    this.labelStyle,
    this.floatingLabelStyle,
    this.helperText,
    this.helperStyle,
    this.helperMaxLines,
    this.hintStyle,
    this.hintTextDirection,
    this.hintMaxLines,
    this.errorText,
    this.errorStyle,
    this.errorMaxLines,
    this.googleMapOntap,
    this.floatingLabelBehavior,
    this.floatingLabelAlignment,
    this.isCollapsed = false,
    this.isDense,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.prefix,
    this.prefixText,
    this.prefixStyle,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffix,
    this.suffixText,
    this.suffixStyle,
    this.suffixIconColor,
    this.suffixIconConstraints,
    this.counter,
    this.counterText,
    this.counterStyle,
    this.filled,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.errorBorder,
    this.focusedBorder,
    this.focusedErrorBorder,
    this.disabledBorder,
    this.enabledBorder,
    this.border,
    this.enabled = true,
    this.semanticCounterText,
    this.alignLabelWithHint,
    this.constraints,
    this.height,
    this.borderRadius,
    this.isInScaffoldBodyAndHasAppBar = true,
  }) : super(key: key);

  final bool isInScaffoldBodyAndHasAppBar;
  final String apiKey;
  final BorderRadiusGeometry? borderRadius;
  final LatLng initialPosition;
  final bool? useCurrentLocation;
  final LocationAccuracy desiredLocationAccuracy;
  final Color appBarBackgroundColor;
  final MapCreatedCallback? onMapCreated;

  final String? hintText;
  final String? searchingText;
  // final double searchBarHeight;
  // final EdgeInsetsGeometry contentPadding;
  final void Function(LatLng)? googleMapOntap;
  final ValueChanged<String>? onAutoCompleteFailed;
  final ValueChanged<String>? onGeocodingSearchFailed;
  final int autoCompleteDebounceInMilliseconds;
  final int cameraMoveDebounceInMilliseconds;
  final double textFieldTopSize;

  final MapType initialMapType;
  final bool enableMapTypeButton;
  final bool enableMyLocationButton;
  final int myLocationButtonCooldown;

  final bool usePinPointingSearch;
  final bool usePlaceDetailSearch;

  final num? autocompleteOffset;
  final num? autocompleteRadius;
  final String? autocompleteLanguage;
  final List<String>? autocompleteTypes;
  final List<Component>? autocompleteComponents;
  final bool? strictbounds;
  final String? region;

  /// If true the [body] and the scaffold's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///

  final bool selectInitialPosition;

  /// By using default setting of Place Picker, it will result result when user hits the select here button.
  ///
  /// If you managed to use your own [selectedPlaceWidgetBuilder], then this WILL NOT be invoked, and you need use data which is
  /// being sent with [selectedPlaceWidgetBuilder].
  final ValueChanged<PickResult?>? onPlacePicked;

  /// optional - builds selected place's UI
  ///
  /// It is provided by default if you leave it as a null.
  /// INPORTANT: If this is non-null, [onPlacePicked] will not be invoked, as there will be no default 'Select here' button.
  final SelectedPlaceWidgetBuilder? selectedPlaceWidgetBuilder;

  /// optional - builds customized pin widget which indicates current pointing position.
  ///
  /// It is provided by default if you leave it as a null.
  final PinBuilder? pinBuilder;

  /// optional - sets 'proxy' value in google_maps_webservice
  ///
  /// In case of using a proxy the baseUrl can be set.
  /// The apiKey is not required in case the proxy sets it.
  /// (Not storing the apiKey in the app is good practice)
  final String? proxyBaseUrl;

  /// optional - set 'client' value in google_maps_webservice
  ///
  /// In case of using a proxy url that requires authentication
  /// or custom configuration
  final BaseClient? httpClient;

  /// Initial value of autocomplete search
  final String? initialSearchString;

  /// Whether to search for the initial value or not
  final bool searchForInitialValue;

  /// On Android devices you can set [forceAndroidLocationManager]
  /// to true to force the plugin to use the [LocationManager] to determine the
  /// position instead of the [FusedLocationProviderClient]. On iOS this is ignored.
  final bool forceAndroidLocationManager;

  /// Allow searching place when zoom has changed. By default searching is disabled when zoom has changed in order to prevent unwilling API usage.
  final bool forceSearchOnZoomChanged;

  /// Whether to display appbar backbutton. Defaults to true.
  final bool automaticallyImplyAppBarLeading;

  /// Will perform an autocomplete search, if set to true. Note that setting
  /// this to true, while providing a smoother UX experience, may cause
  /// additional unnecessary queries to the Places API.
  ///
  /// Defaults to false.
  final bool autocompleteOnTrailingWhitespace;

  final bool hidePlaceDetailsWhenDraggingPin;
  final Widget? icon;

  final Color? iconColor;

  final Widget? label;

  final bool? resizeToAvoidBottomInset;

  final String? labelText;

  final TextStyle? labelStyle;

  final TextStyle? floatingLabelStyle;

  final String? helperText;

  final TextStyle? helperStyle;

  final int? helperMaxLines;

  final TextStyle? hintStyle;

  final TextDirection? hintTextDirection;

  final int? hintMaxLines;

  final String? errorText;

  final TextStyle? errorStyle;

  final int? errorMaxLines;

  final FloatingLabelBehavior? floatingLabelBehavior;

  final FloatingLabelAlignment? floatingLabelAlignment;

  final bool? isDense;

  final bool isCollapsed;

  final Widget? prefixIcon;

  final BoxConstraints? prefixIconConstraints;

  final Widget? prefix;

  final String? prefixText;

  final TextStyle? prefixStyle;

  final Color? prefixIconColor;

  final Widget? suffixIcon;

  final Widget? suffix;

  final String? suffixText;

  final TextStyle? suffixStyle;

  final Color? suffixIconColor;

  final BoxConstraints? suffixIconConstraints;

  final String? counterText;

  final Widget? counter;

  final TextStyle? counterStyle;

  final bool? filled;

  final Color? fillColor;

  final Color? focusColor;

  final Color? hoverColor;

  final InputBorder? errorBorder;

  final InputBorder? focusedBorder;

  final InputBorder? focusedErrorBorder;

  final InputBorder? disabledBorder;

  final InputBorder? enabledBorder;

  final InputBorder? border;

  final bool enabled;

  final String? semanticCounterText;

  final bool? alignLabelWithHint;

  final BoxConstraints? constraints;
  final double? height;

  @override
  _PlacePickerState createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  GlobalKey appBarKey = GlobalKey();
  Future<PlaceProvider>? _futureProvider;
  PlaceProvider? provider;
  SearchBarController searchBarController = SearchBarController();

  late final double bottomPadding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) {
        bottomPadding = MediaQuery.of(context).padding.bottom;
      },
    );

    _futureProvider = _initPlaceProvider();
  }

  @override
  void dispose() {
    searchBarController.dispose();

    super.dispose();
  }

  Future<PlaceProvider> _initPlaceProvider() async {
    final headers = await GoogleApiHeaders().getHeaders();
    final provider = PlaceProvider(
      widget.apiKey,
      widget.proxyBaseUrl,
      widget.httpClient,
      headers,
    );
    provider.sessionToken = Uuid().generateV4();
    provider.desiredAccuracy = widget.desiredLocationAccuracy;
    provider.setMapType(widget.initialMapType);

    return provider;
  }

  @override
  Widget build(BuildContext context) {
    // final myProviderPlaceSearchingState = context.watch<PlaceProvider>().placeSearchingState;
    return WillPopScope(
      onWillPop: () {
        searchBarController.clearOverlay();
        return Future.value(true);
      },
      child: FutureBuilder<PlaceProvider>(
        future: _futureProvider,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            provider = snapshot.data;

            return MultiProvider(
              providers: [
                ChangeNotifierProvider<PlaceProvider>.value(value: provider!),
              ],
              child: Scaffold(
                key: ValueKey<int>(provider.hashCode),
                // resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                // extendBodyBehindAppBar: true,
                // backgroundColor: Colors.red,
                appBar: AppBar(
                  key: appBarKey,
                  automaticallyImplyLeading: false,
                  iconTheme: Theme.of(context).iconTheme,
                  elevation: 0,
                  backgroundColor: widget.appBarBackgroundColor,
                  titleSpacing: 0.0,
                  title: _buildSearchBar(context),
                ),
                body: _buildMapWithLocation(),

                bottomNavigationBar: Container(
                  padding: EdgeInsets.only(
                    bottom: 20 +
                        (bottomPadding != 0.0
                            ? MediaQuery.of(context).padding.bottom / 3
                            : MediaQuery.of(context).padding.bottom),
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    // color: appColorScheme?.white50,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Consumer<PlaceProvider>(builder: (context, placeProvider, _) {
                    return ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),

                        // fixedSize: MaterialStateProperty.all(
                        //   Size(100, 100),
                        // ),
                        // minimumSize: MaterialStateProperty.all(
                        //   Size(100, 100),
                        // ),
                        // maximumSize: MaterialStateProperty.all(
                        //   Size(100, 100),
                        // ),
                        backgroundColor: placeProvider.placeSearchingState == SearchingState.Searching
                            ? null
                            : MaterialStateProperty.all(const Color(0xffEE724B)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                        ),
                      ),
                      child: Text(
                     "Bu Adresi Kullan"  ,
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: placeProvider.placeSearchingState == SearchingState.Searching
                          ? null
                          : () {
                                  // searchByCameraLocationPLACEPICKER(provider!);
                                  print("CLICKED onPressed Bu Adresi Kullan");
                                  widget.onPlacePicked!(provider?.selectedPlace);
                                 
                                },
                      
                    );
                  }),
                ),

                //  SafeArea(
                //   bottom: false,
                //   child: Stack(children: [
                //     _buildMapWithLocation(),
                //     _buildSearchBar(context),
                //   ]),
                // ),
                // _buildSearchBar(context)
              ),
            );
          }

          final children = <Widget>[];
          if (snapshot.hasError) {
            children.addAll([
              Icon(
                Icons.error_outline,
                color: Theme.of(context).errorColor,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ]);
          } else {
            children.add(CircularProgressIndicator());
          }

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: 5),
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(
            Icons.clear_rounded,
            size: 35,
            color: Colors.white,
          ),
          padding: EdgeInsets.zero,
        ),
        SizedBox(width: 5),
        Expanded(
          child: AutoCompleteSearch(
              appBarKey: appBarKey,
              textFieldTopSize: widget.textFieldTopSize,
              isInScaffoldBodyAndHasAppBar: widget.isInScaffoldBodyAndHasAppBar,
              borderRadius: widget.borderRadius,
              searchBarController: searchBarController,
              sessionToken: provider!.sessionToken,
              hintText: widget.hintText,
              searchingText: widget.searchingText,
              debounceMilliseconds: widget.autoCompleteDebounceInMilliseconds,
              alignLabelWithHint: widget.alignLabelWithHint,
              constraints: widget.constraints,
              hintStyle: widget.hintStyle,
              hintTextDirection: widget.hintTextDirection,
              hintMaxLines: widget.hintMaxLines,
              errorText: widget.errorText,
              errorStyle: widget.errorStyle,
              errorMaxLines: widget.errorMaxLines,
              floatingLabelBehavior: widget.floatingLabelBehavior,
              floatingLabelAlignment: widget.floatingLabelAlignment,
              floatingLabelStyle: widget.floatingLabelStyle,
              labelText: widget.labelText,
              labelStyle: widget.labelStyle,
              helperText: widget.helperText,
              helperStyle: widget.helperStyle,
              helperMaxLines: widget.helperMaxLines,
              suffixIcon: widget.suffixIcon,
              suffixText: widget.suffixText,
              suffixStyle: widget.suffixStyle,
              suffixIconColor: widget.suffixIconColor,
              suffixIconConstraints: widget.suffixIconConstraints,
              prefixIcon: widget.prefixIcon,
              prefixText: widget.prefixText,
              prefixStyle: widget.prefixStyle,
              prefixIconColor: widget.prefixIconColor,
              prefixIconConstraints: widget.prefixIconConstraints,
              counterText: widget.counterText,
              counterStyle: widget.counterStyle,
              filled: widget.filled,
              fillColor: widget.fillColor,
              focusColor: widget.focusColor,
              hoverColor: widget.hoverColor,
              errorBorder: widget.errorBorder,
              focusedBorder: widget.focusedBorder,
              focusedErrorBorder: widget.focusedErrorBorder,
              disabledBorder: widget.disabledBorder,
              enabledBorder: widget.enabledBorder,
              counter: widget.counter,
              enabled: widget.enabled,
              icon: widget.icon,
              iconColor: widget.iconColor,
              label: widget.label,
              prefix: widget.prefix,
              suffix: widget.suffix,
              isCollapsed: widget.isCollapsed,
              semanticCounterText: widget.semanticCounterText,
              border: widget.border,
              isDense: widget.isDense,
              inputHeight: widget.height,
              onPicked: (prediction) {
                _pickPrediction(prediction);
              },
              onSearchFailed: (status) {
                if (widget.onAutoCompleteFailed != null) {
                  widget.onAutoCompleteFailed!(status);
                }
              },
              autocompleteOffset: widget.autocompleteOffset,
              autocompleteRadius: widget.autocompleteRadius,
              autocompleteLanguage: widget.autocompleteLanguage,
              autocompleteComponents: widget.autocompleteComponents,
              autocompleteTypes: widget.autocompleteTypes,
              strictbounds: widget.strictbounds,
              region: widget.region,
              initialSearchString: widget.initialSearchString,
              searchForInitialValue: widget.searchForInitialValue,
              autocompleteOnTrailingWhitespace: widget.autocompleteOnTrailingWhitespace),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  _pickPrediction(Prediction prediction) async {
    provider!.placeSearchingState = SearchingState.Searching;

    final PlacesDetailsResponse response = await provider!.places.getDetailsByPlaceId(
      prediction.placeId!,
      sessionToken: provider!.sessionToken,
      language: widget.autocompleteLanguage,
    );

    if (response.errorMessage?.isNotEmpty == true || response.status == "REQUEST_DENIED") {
      if (widget.onAutoCompleteFailed != null) {
        widget.onAutoCompleteFailed!(response.status);
      }
      return;
    }

    provider!.selectedPlace = PickResult.fromPlaceDetailResult(response.result);

    // Prevents searching again by camera movement.
    provider!.isAutoCompleteSearching = true;

    await _moveTo(provider!.selectedPlace!.geometry!.location.lat, provider!.selectedPlace!.geometry!.location.lng);

    provider!.placeSearchingState = SearchingState.Idle;
  }

  _moveTo(double latitude, double longitude) async {
    GoogleMapController? controller = provider!.mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 16,
        ),
      ),
    );
  }

  _moveToCurrentPosition() async {
    if (provider!.currentPosition != null) {
      await _moveTo(provider!.currentPosition!.latitude, provider!.currentPosition!.longitude);
    }
  }

  Widget _buildMapWithLocation() {
    log("widget.useCurrentLocation ${widget.useCurrentLocation} widget.useCurrentLocation! ${widget.useCurrentLocation!}");
    if (widget.useCurrentLocation != null && widget.useCurrentLocation!) {
      return FutureBuilder(
          future: provider!.updateCurrentLocation(widget.forceAndroidLocationManager),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.indigo,
              ));
            } else {
              if (provider!.currentPosition == null) {
                return _buildMap(widget.initialPosition);
              } else {
                return _buildMap(LatLng(provider!.currentPosition!.latitude, provider!.currentPosition!.longitude));
              }
            }
          });
    } else {
      return FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 1)),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return _buildMap(widget.initialPosition);
          }
        },
      );
    }
  }

  Widget _buildMap(LatLng initialTarget) {
    return GoogleMapPlacePicker(
      initialTarget: initialTarget,
      appBarKey: appBarKey,
      height: widget.height,
      selectedPlaceWidgetBuilder: widget.selectedPlaceWidgetBuilder,
      pinBuilder: widget.pinBuilder,
      onSearchFailed: widget.onGeocodingSearchFailed,
      debounceMilliseconds: widget.cameraMoveDebounceInMilliseconds,
      enableMapTypeButton: widget.enableMapTypeButton,
      enableMyLocationButton: widget.enableMyLocationButton,
      googleMapOntap: widget.googleMapOntap,
      usePinPointingSearch: widget.usePinPointingSearch,
      usePlaceDetailSearch: widget.usePlaceDetailSearch,
      onMapCreated: widget.onMapCreated,
      selectInitialPosition: widget.selectInitialPosition,
      language: widget.autocompleteLanguage,
      forceSearchOnZoomChanged: widget.forceSearchOnZoomChanged,
      hidePlaceDetailsWhenDraggingPin: widget.hidePlaceDetailsWhenDraggingPin,
      onToggleMapType: () {
        provider!.switchMapType();
      },
      onMyLocation: () async {
        // Prevent to click many times in short period.
        log("isOnUpdateLocationCooldown ${provider!.isOnUpdateLocationCooldown}");
        if (provider!.isOnUpdateLocationCooldown == false) {
          provider!.isOnUpdateLocationCooldown = true;
          Timer(Duration(seconds: widget.myLocationButtonCooldown), () {
            provider!.isOnUpdateLocationCooldown = false;
          });
          await provider!.updateCurrentLocation(widget.forceAndroidLocationManager);
          await _moveToCurrentPosition();
        }
      },
      onMoveStart: () {
        searchBarController.reset();
        print(" on Move Start ${provider!.placeSearchingState}");
      },
      onPlacePicked: widget.onPlacePicked,
    );
  }
}
