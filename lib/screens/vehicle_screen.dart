import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/schedule/schedule_bloc.dart';
import '../bloc/schedule/schedule_state.dart';
import '../enums/vehicle_status.dart';
import '../models/vendor_schedule.dart';

class VehicleScreen extends StatefulWidget {
  final Vendor vendor;

  VehicleScreen({required this.vendor});

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.vendor.vendorName} - Vehicles'),
          backgroundColor: Colors.blueAccent,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Picked Up'),
              Tab(text: 'Ready to Pick Up'),
              Tab(text: 'Dropped'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: VehicleSearchDelegate(
                    vehicles: widget.vendor.vehicles,
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
            return Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            final filteredVehicles = widget.vendor.vehicles
                .where((vehicle) => vehicle.status == status)
                .where((vehicle) => vehicle.vehicleName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

            if (filteredVehicles.isEmpty) {
              return Center(child: Text('No vehicles found for this status.'));
            }

            return ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = filteredVehicles[index];
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
                        leading: CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child:
                              Icon(Icons.directions_car, color: Colors.white),
                        ),
                        title: Text(
                          '${vehicle.vehicleName} (${vehicle.driverName})',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(timeText),
                      ),
                      if (status ==
                          VehicleStatus
                              .pickedUp) // Show map button only for picked up status
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _launchMap(vehicle),
                            child: Text('Show Map'),
                          ),
                        ),
                      SizedBox(height: 10),
                    ],
                  ),
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
    );
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

  Future<LatLng> _getVehicleLocation(Vehicle vehicle) async {
    // Replace this with your actual logic to fetch vehicle's location
    return LatLng(25.2788, 55.3309); // Example coordinates (San Francisco)
  }
}

class VehicleSearchDelegate extends SearchDelegate<String> {
  final List<Vehicle> vehicles;
  final ValueChanged<String> onSearch;

  VehicleSearchDelegate({
    required this.vehicles,
    required this.onSearch,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = vehicles
        .where((vehicle) =>
            vehicle.vehicleName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final vehicle = results[index];

        return ListTile(
          title: Text(vehicle.vehicleName),
          subtitle: Text(
              '${vehicle.driverName} - Pickup Time: ${vehicle.pickupTime}'),
          onTap: () {
            Navigator.pop(
                context, vehicle.vehicleId); // Handle the selection if needed
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = vehicles
        .where((vehicle) =>
            vehicle.vehicleName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final vehicle = suggestions[index];

        return ListTile(
          title: Text(vehicle.vehicleName),
          subtitle: Text(
              '${vehicle.driverName} - Pickup Time: ${vehicle.pickupTime}'),
          onTap: () {
            query = vehicle.vehicleName;
            showResults(context);
          },
        );
      },
    );
  }
}
