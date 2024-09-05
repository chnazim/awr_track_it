import 'package:awr_track_it/screens/vehicle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/schedule/schedule_bloc.dart';
import '../bloc/schedule/schedule_state.dart';
import '../enums/vehicle_status.dart';
import '../models/vendor_schedule.dart';

class AllVehiclesScreen extends StatefulWidget {
  @override
  _AllVehiclesScreenState createState() => _AllVehiclesScreenState();
}

class _AllVehiclesScreenState extends State<AllVehiclesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Vehicles'),
          backgroundColor: Colors.blueAccent,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Picked Up'),
              Tab(text: 'Ready to Pick Up'),
              Tab(text: 'Dropped'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: VehicleSearchDelegate(
                    vehicles: _getAllVehicles(context),
                    onSearch: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildVehicleList(context, VehicleStatus.pickedUp),
            _buildVehicleList(context, VehicleStatus.readyToPickup),
            _buildVehicleList(context, VehicleStatus.dropped),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context, VehicleStatus status) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            final filteredVehicles = _getAllVehicles(context)
                .where((vehicle) => vehicle.status == status)
                .where((vehicle) => vehicle.vehicleName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

            if (filteredVehicles.isEmpty) {
              return const Center(
                  child: Text('No vehicles found for this status.'));
            }

            return ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = filteredVehicles[index];
                final vendor = _getVendorForVehicle(context, vehicle);
                final timeText = status == VehicleStatus.dropped
                    ? 'Pickup Time: ${vehicle.pickupTime}\nDropped Time: ${vehicle.droppedTime}'
                    : 'Pickup Time: ${vehicle.pickupTime}';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child:
                              Icon(Icons.directions_car, color: Colors.white),
                        ),
                        title: Text(
                          '${vehicle.vehicleName} (${vehicle.driverName})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Vendor: ${vendor.vendorName}\n $timeText',
                        ),
                      ),
                      if (status ==
                          VehicleStatus
                              .pickedUp) // Show map button only for picked up status
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _launchMap(vehicle),
                            child: const Text('Show Map'),
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          } else if (state is ScheduleError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Unknown State'));
          }
        },
      ),
    );
  }

  List<Vehicle> _getAllVehicles(BuildContext context) {
    final state = BlocProvider.of<ScheduleBloc>(context).state;

    if (state is ScheduleLoaded) {
      return state.vendors.expand((vendor) => vendor.vehicles).toList();
    }
    return [];
  }

  Vendor _getVendorForVehicle(BuildContext context, Vehicle vehicle) {
    final state = BlocProvider.of<ScheduleBloc>(context).state;

    if (state is ScheduleLoaded) {
      // Define a default or placeholder vendor
      final placeholderVendor = Vendor(
        vendorName: 'Unknown Vendor',
        vehicles: [], vendorId: '0000', // Placeholder vehicles list
      );

      return state.vendors.firstWhere(
        (vendor) => vendor.vehicles.contains(vehicle),
        orElse: () => placeholderVendor,
      );
    }

    // Return a default vendor if state is not ScheduleLoaded
    return Vendor(
      vendorName: 'No Vendor Data',
      vehicles: [],
      vendorId: '0000',
    );
  }

  Future<LatLng> _getVehicleLocation(Vehicle vehicle) async {
    // Replace this with your actual logic to fetch vehicle's location
    return const LatLng(
        25.2788, 55.3309); // Example coordinates (San Francisco)
  }

  void _launchMap(Vehicle vehicle) async {
    final LatLng vehicleLocation = await _getVehicleLocation(vehicle);

    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${vehicleLocation.latitude},${vehicleLocation.longitude}';
    final appleMapsUrl =
        'https://maps.apple.com/?q=${vehicleLocation.latitude},${vehicleLocation.longitude}';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else if (await canLaunch(appleMapsUrl)) {
      await launch(appleMapsUrl);
    } else {
      throw 'Could not launch map';
    }
  }
}
