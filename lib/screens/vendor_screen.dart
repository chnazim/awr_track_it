import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/schedule/schedule_bloc.dart';
import '../bloc/schedule/schedule_state.dart';
import '../models/vendor_schedule.dart';
import 'all_vehicles_screen.dart';
import 'vehicle_screen.dart';

class VendorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendors'),
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: state.vendors.length,
                itemBuilder: (context, index) {
                  final vendor = state.vendors[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.business, color: Colors.white),
                      ),
                      title: Text(vendor.vendorName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          Text('Number of Vehicles: ${vendor.vehicles.length}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: BlocProvider.of<ScheduleBloc>(context),
                              child: VehicleScreen(vendor: vendor),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllVehiclesScreen(),
            ),
          );
        },
        child: Icon(Icons.directions_car),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
