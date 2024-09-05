import 'package:awr_track_it/screens/schedule_screen.dart';
import 'package:awr_track_it/screens/vendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/schedule/schedule_bloc.dart';
import 'bloc/schedule/schedule_event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleBloc>(
          create: (context) => ScheduleBloc()..add(LoadSchedule()),
        ),
      ],
      child: MaterialApp(
        title: 'AWR TRACK-IT',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: VendorScreen(),
      ),
    );
  }
}
