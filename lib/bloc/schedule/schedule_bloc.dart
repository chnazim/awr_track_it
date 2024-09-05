import 'package:awr_track_it/enums/vehicle_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/vendor_schedule.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc() : super(ScheduleLoading()) {
    on<LoadSchedule>((event, emit) async {
      await Future.delayed(Duration(seconds: 2));

      try {
        // Load initial data: Each vendor has multiple vehicles
        final vendors = [
          Vendor(
            vendorId: '1001',
            vendorName: 'Vendor A',
            vehicles: [
              Vehicle(
                  vehicleId: '1001',
                  vehicleName: 'Vehicle 1',
                  driverName: 'Driver A1',
                  pickupTime: '10:00 AM',
                  droppedTime: '',
                  location: LatLng(25.2788, 55.3309),
                  status: VehicleStatus.pickedUp),
              Vehicle(
                  vehicleId: '1002',
                  vehicleName: 'Vehicle 2',
                  driverName: 'Driver A2',
                  pickupTime: '11:00 AM',
                  droppedTime: '12:45 PM',
                  location: LatLng(25.2788, 55.3309),
                  status: VehicleStatus.dropped),
              Vehicle(
                  vehicleId: '1003',
                  vehicleName: 'Vehicle 3',
                  driverName: 'Driver A3',
                  pickupTime: '10:00 AM',
                  droppedTime: '',
                  location: LatLng(25.2788, 55.3309),
                  status: VehicleStatus.pickedUp),
            ],
          ),
          Vendor(
            vendorId: '1002',
            vendorName: 'Vendor B',
            vehicles: [
              Vehicle(
                  vehicleId: '3',
                  vehicleName: 'Vehicle 3',
                  driverName: 'Driver B1',
                  pickupTime: '12:00 PM',
                  droppedTime: '',
                  location: LatLng(25.2788, 55.3309),
                  status: VehicleStatus.pickedUp),
            ],
          ),
        ];

        emit(ScheduleLoaded(vendors: vendors));
      } catch (e) {
        emit(ScheduleError(message: e.toString()));
      }
    });

    on<UpdateVehicleSchedule>((event, emit) async {
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;

        final updatedVendors = currentState.vendors.map((vendor) {
          if (vendor.vendorId == event.vendorId) {
            return Vendor(
              vendorId: vendor.vendorId,
              vendorName: vendor.vendorName,
              vehicles: vendor.vehicles.map((vehicle) {
                if (vehicle.vehicleId == event.vehicleId) {
                  return Vehicle(
                      vehicleId: vehicle.vehicleId,
                      vehicleName: vehicle.vehicleName,
                      driverName: vehicle.driverName,
                      pickupTime: event.newPickupTime,
                      droppedTime: event.newPickupTime,
                      location: vehicle.location,
                      status: VehicleStatus.dropped);
                }
                return vehicle;
              }).toList(),
            );
          }
          return vendor;
        }).toList();

        emit(ScheduleLoaded(vendors: updatedVendors));
      }
    });

    on<LoadCurrentLocations>((event, emit) async {
      if (state is ScheduleLoaded) {
        final currentState = state as ScheduleLoaded;
        List<LatLng> locations = [];

        // Fetch location for each vehicle
        for (var vendor in currentState.vendors) {
          for (var vehicle in vendor.vehicles) {
            locations.add(vehicle.location);
          }
        }

        emit(LocationsLoaded(vehicleLocations: locations));
      }
    });
  }
}
