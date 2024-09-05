abstract class ScheduleEvent {}

class LoadSchedule extends ScheduleEvent {}

class UpdateVehicleSchedule extends ScheduleEvent {
  final String vendorId;
  final String vehicleId;
  final String newPickupTime;

  UpdateVehicleSchedule({
    required this.vendorId,
    required this.vehicleId,
    required this.newPickupTime,
  });
}

class LoadCurrentLocations extends ScheduleEvent {}
