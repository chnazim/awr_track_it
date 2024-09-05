import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/vendor_schedule.dart';

abstract class ScheduleState {
  get vendors => null;
}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Vendor> vendors;

  ScheduleLoaded({required this.vendors});
}

class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError({required this.message});
}

class LocationsLoaded extends ScheduleState {
  final List<LatLng> vehicleLocations;

  LocationsLoaded({required this.vehicleLocations});
}
