import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../bloc/schedule/schedule_bloc.dart';
import '../bloc/schedule/schedule_event.dart';
import '../bloc/schedule/schedule_state.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car Pickup Schedule')),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            return ListView.builder(
              itemCount: state.vendors.length,
              itemBuilder: (context, index) {
                final vendor = state.vendors[index];
                return ExpansionTile(
                  title: Text(vendor.vendorName),
                  children: vendor.vehicles.map((vehicle) {
                    return ListTile(
                      title: Text(
                          '${vehicle.vehicleName} (${vehicle.driverName})'),
                      subtitle: Text('Pickup Time: ${vehicle.pickupTime}'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          BlocProvider.of<ScheduleBloc>(context).add(
                            UpdateVehicleSchedule(
                              vendorId: vendor.vendorId,
                              vehicleId: vehicle.vehicleId,
                              newPickupTime: '2:00 PM',
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            );
          } else if (state is ScheduleError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: Text('Unknown State'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<ScheduleBloc>(context).add(LoadCurrentLocations());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationScreen()),
          );
        },
        child: Icon(Icons.map),
      ),
    );
  }
}

class LocationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Locations')),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is LocationsLoaded) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state.vehicleLocations[0],
                zoom: 14.0,
              ),
              markers: state.vehicleLocations.map((location) {
                return Marker(
                  markerId: MarkerId(location.toString()),
                  position: location,
                );
              }).toSet(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
