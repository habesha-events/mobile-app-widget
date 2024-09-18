import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_list_widget.dart';
import 'providers/event_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'Events App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(body: EventListWidget(onErrorCallback: (errorMessage){},)),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

