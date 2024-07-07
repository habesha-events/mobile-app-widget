import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          primarySwatch: Colors.blue,
        ),
        home: EventListScreen(),
      ),
    );
  }
}

class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              Provider.of<EventProvider>(context, listen: false).fetchEvents();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selectedCity = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Choose City'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('New York'),
                          onTap: () => Navigator.pop(context, 'New York'),
                        ),
                        ListTile(
                          title: Text('San Francisco'),
                          onTap: () => Navigator.pop(context, 'San Francisco'),
                        ),
                        // Add more cities as needed
                      ],
                    ),
                  );
                },
              );

              if (selectedCity != null) {
                Provider.of<EventProvider>(context, listen: false).fetchEvents(city: selectedCity);
              }
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return ListTile(
                leading: Image.network(event.imageUrl),
                title: Text(event.title),
                subtitle: Text('${event.startTime}\n${event.price}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
