import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/event_provider.dart';

class EventListWidget extends StatelessWidget {
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
                onTap: (){
                  _launchURL(event.eventUrl);
                },
              );
            },
          );
        },
      ),
    );
  }


  void _launchURL(url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri $url';
    }
  }
}
