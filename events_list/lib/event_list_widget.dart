import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/event_provider.dart';

class EventListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EventListWidgetState();
}

class EventListWidgetState extends State<EventListWidget> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 10), () {
      //get current location and fetch:
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
    });

    //fetch by location:
    // builder: (context) {
    //   return AlertDialog(
    //     title: Text('Choose City'),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         ListTile(
    //           title: Text('New York'),
    //           onTap: () => Navigator.pop(context, 'New York'),
    //         ),
    //         ListTile(
    //           title: Text('San Francisco'),
    //           onTap: () => Navigator.pop(context, 'San Francisco'),
    //         ),
    //         // Add more cities as needed
    //       ],
    //     ),
    //   );
    // },
    // );
    //
    // if (selectedCity != null) {
    // Provider.of<EventProvider>(context, listen: false).fetchEvents(city: selectedCity);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
             Spacer(),
              Expanded(child: _citySelectorWidget(provider)),
              Expanded(child: _listViewWidget(provider))
            ],
          );
        },
      ),
    );
  }

  _citySelectorWidget(provider) => ListTile(
        title: Text('City: someTitleCity'),
        onTap: () {
          showDialog(
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
          ).then((selectedCity) {
            if (selectedCity != null) {
              provider.fetchEvents(city: selectedCity);
            }
          });
        },
      );


  Widget _listViewWidget(provider) => ListView.builder(
        itemCount: provider.events.length,
        itemBuilder: (context, index) {
          final event = provider.events[index];
          return ListTile(
            leading: Image.network(event.imageUrl),
            title: Text(event.title),
            subtitle: Text('${event.startTime}\n${event.price}'),
            isThreeLine: true,
            onTap: () {
              _launchURL(event.eventUrl);
            },
          );
        },
      );

  void _launchURL(url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri $url';
    }
  }
}
