import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_places_picker/google_maps_places_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  // Light Theme
  final ThemeData lightTheme = ThemeData.light().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.white,
    buttonTheme: const ButtonThemeData(
      // Select here's button color
      buttonColor: Colors.black,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.grey,
    buttonTheme: const ButtonThemeData(
      // Select here's button color
      buttonColor: Colors.yellow,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Map Places Picker Refractored Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const kInitialPosition = LatLng(-33.8567844, 151.213108);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PickResult? selectedPlace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Map Places Picker Refractored Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Text("Load Google Map"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PlacePicker(
                          apiKey: "AIzaSyCp0zCDL940M2F_NhLzs_frvm8cAZqV41U",
                          initialPosition: LatLng(40.596697, 43.1017874),
                          useCurrentLocation: false,
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          selectInitialPosition: true,
                          // isInScaffoldBodyAndHasAppBar: false,
                          // border: OutlineInputBorder(),
                          // enabledBorder: OutlineInputBorder(),
                          // height: 40.0,
                          // borderRadius: BorderRadius.circular(5.0),
                          //usePlaceDetailSearch: true,
                          onPlacePicked: (result) {
                            selectedPlace = result;
                            print(" onPlacePicked ${result?.formattedAddress}");
                            // Navigator.of(context).pop();
                            // setState(() {});
                          },
                          
                          //forceSearchOnZoomChanged: true,
                          automaticallyImplyAppBarLeading: false,
                          appBarBackgroundColor: const Color(0xffEE724B),
                          textFieldTopSize:
                              MediaQuery.of(context).padding.top + (MediaQuery.of(context).padding.bottom) + 20,
                          //autocompleteLanguage: "ko",
                          //region: 'au',
                          //selectInitialPosition: true,
                        );
                      },
                    ),
                  );
                },
              ),
              // selectedPlace == null ? Container() : Text(selectedPlace?.formattedAddress ?? ""),
            ],
          ),
        ));
  }
}
