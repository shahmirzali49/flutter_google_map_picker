import 'dart:async';
import 'dart:developer';

// import 'package:app_settings/app_settings.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:system_settings/system_settings.dart';
import '../src/models/pick_result.dart';
import '../src/place_picker.dart';
import 'package:google_maps_webservice_ex/geocoding.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class PlaceProvider extends ChangeNotifier {
  PlaceProvider(
    String apiKey,
    String? proxyBaseUrl,
    Client? httpClient,
    Map<String, dynamic> apiHeaders,
  ) {
    places = GoogleMapsPlaces(
      apiKey: apiKey,
      baseUrl: proxyBaseUrl,
      httpClient: httpClient,
      apiHeaders: apiHeaders as Map<String, String>?,
    );

    geocoding = GoogleMapsGeocoding(
      apiKey: apiKey,
      baseUrl: proxyBaseUrl,
      httpClient: httpClient,
      apiHeaders: apiHeaders as Map<String, String>?,
    );
  }

  static PlaceProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<PlaceProvider>(context, listen: listen);

  late GoogleMapsPlaces places;
  late GoogleMapsGeocoding geocoding;
  String? sessionToken;
  bool isOnUpdateLocationCooldown = false;
  LocationAccuracy? desiredAccuracy;
  bool isAutoCompleteSearching = false;

  Future<void> updateCurrentLocation(bool forceAndroidLocationManager) async {
    try {
      await Geolocator.requestPermission();
      LocationPermission permission = await Geolocator.checkPermission();
      log("updateCurrentLocation ${permission.name}");
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever &&
          permission != LocationPermission.unableToDetermine) {
        currentPosition =
            await Geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy ?? LocationAccuracy.best);
        // await Future.delayed(const Duration(seconds: 3));
        final GeocodingResponse response = await geocoding.searchByLocation(
          Location(lat: currentPosition!.latitude, lng: currentPosition!.longitude),
          language: 'tr',
        );
        selectedPlace = PickResult.fromGeocodingResult(response.results[0]);
        log("Geolocator.getCurrentPosition currentPosition $currentPosition");
      } else {
        currentPosition = null;
        await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          await AppSettings.openLocationSettings(
            asAnotherTask: true,
          );
        }

        print("ELSE PROBLEM ");
      }
    } catch (e) {
      print("CATCH PROBLEM $e");
      currentPosition = null;
    }

    notifyListeners();
  }

  Position? _currentPoisition;
  Position? get currentPosition => _currentPoisition;

  set currentPosition(Position? newPosition) {
    _currentPoisition = newPosition;
    notifyListeners();
  }

  Timer? _debounceTimer;
  Timer? get debounceTimer => _debounceTimer;
  set debounceTimer(Timer? timer) {
    _debounceTimer = timer;
    notifyListeners();
  }

  CameraPosition? _previousCameraPosition;
  CameraPosition? get prevCameraPosition => _previousCameraPosition;
  setPrevCameraPosition(CameraPosition? prePosition) {
    _previousCameraPosition = prePosition;
  }

  CameraPosition? _currentCameraPosition;
  CameraPosition? get cameraPosition => _currentCameraPosition;
  setCameraPosition(CameraPosition? newPosition) {
    _currentCameraPosition = newPosition;
  }

  PickResult? _selectedPlace;
  PickResult? get selectedPlace => _selectedPlace;
  set selectedPlace(PickResult? result) {
    _selectedPlace = result;
    notifyListeners();
  }

  SearchingState _placeSearchingState = SearchingState.Idle;
  SearchingState get placeSearchingState => _placeSearchingState;
  set placeSearchingState(SearchingState newState) {
    _placeSearchingState = newState;
    notifyListeners();
  }

  // ButtonState _buttonState = ButtonState.UseThisAddress;
  // ButtonState get buttonState => _buttonState;
  // set buttonState(ButtonState newState) {
  //   _buttonState = newState;
  //   notifyListeners();
  // }

  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

    

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;
  set mapController(GoogleMapController? controller) {
    _mapController = controller;
  
    notifyListeners();
  }

  PinState _pinState = PinState.Preparing;
  PinState get pinState => _pinState;
  set pinState(PinState newState) {
    _pinState = newState;
    notifyListeners();
  }

  bool _isSeachBarFocused = false;
  bool get isSearchBarFocused => _isSeachBarFocused;
  set isSearchBarFocused(bool focused) {
    _isSeachBarFocused = focused;
    notifyListeners();
  }

  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;
  setMapType(MapType mapType, {bool notify = false}) {
    _mapType = mapType;
    if (notify) notifyListeners();
  }

  switchMapType() {
    _mapType = MapType.values[(_mapType.index + 1) % MapType.values.length];
    if (_mapType == MapType.none) _mapType = MapType.normal;

    notifyListeners();
  }
}
