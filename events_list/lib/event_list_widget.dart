import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'city_selector_widget.dart';
import 'providers/event_provider.dart';

class EventListWidget extends StatefulWidget {
  Function onErrorCallback;

  EventListWidget({
    required this.onErrorCallback,
  });

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
  }

  @override
  Widget build(BuildContext context) {
    return  Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.isError) {
            widget.onErrorCallback();
          }
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(20.0)),
              CitySelectorWidget(provider: provider),
              provider.isError
                  ? Center(child: Text(provider.errorMessage))
                  : Expanded(child: _listViewWidget(provider)),
            ],
          );
        },
      );
  }

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
