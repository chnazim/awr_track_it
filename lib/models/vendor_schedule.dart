import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../enums/vehicle_status.dart';

class Vendor {
  final String vendorId;
  final String vendorName;
  final List<Vehicle> vehicles;

  Vendor({required this.vendorId,
    required this.vendorName,
    required this.vehicles});
}

class Vehicle {
  final String vehicleId;
  final String vehicleName;
  final String driverName;
  final String pickupTime;
  final String droppedTime;
  final LatLng location;
  final VehicleStatus status;

  Vehicle({
    required this.vehicleId,
    required this.vehicleName,
    required this.driverName,
    required this.pickupTime,
    required this.droppedTime,
    required this.location,
    required this.status,
  });

}
