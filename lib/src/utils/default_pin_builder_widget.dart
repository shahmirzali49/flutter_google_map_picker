// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:google_maps_places_picker/google_maps_places_picker.dart';
import 'package:google_maps_places_picker/src/components/animated_pin.dart';

class DefaultPinBuilderWidget extends StatelessWidget {
  const DefaultPinBuilderWidget({
    Key? key,
    required this.state,
    required this.pinIcon,
  }) : super(key: key);
  final PinState state;
  final Icon pinIcon;

  @override
  Widget build(BuildContext context) {
    return state == PinState.Preparing
        ? const SizedBox.shrink()
        : Stack(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    state == PinState.Idle ? pinIcon : AnimatedPin(child: pinIcon),
                    SizedBox(height: 42),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
  }
}
