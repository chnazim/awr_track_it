import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vehicle {
  final String id;
  final String vendor;
  final LatLng location;

  Vehicle({required this.id, required this.vendor, required this.location});

  Vehicle copyWith({LatLng? location}) {
    return Vehicle(
      id: id,
      vendor: vendor,
      location: location ?? this.location,
    );
  }
}
