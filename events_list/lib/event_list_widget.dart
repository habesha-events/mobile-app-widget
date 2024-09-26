import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'city_selector_widget.dart';
import 'providers/event_provider.dart';

class EventListWidget extends StatefulWidget {
  Function(String) onErrorCallback;

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
      _fetchEvents();
    });
  }


  _fetchEvents({String? city  = null}) {
    Provider.of<EventProvider>(context, listen: false).fetchEvents(inputCity: city);
  }

  @override
  Widget build(BuildContext context) {
    return  Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.isError) {
            widget.onErrorCallback(provider.errorMessage);
          }
          return Column(
            children: [
              Padding(padding: EdgeInsets.all(20.0)),
              CitySelectorWidget(provider: provider, onChanged: (city) {
                _fetchEvents(city: city);
              }),
              provider.localResponse.response_type == "neighboring_cities"
                  ? Text('Showing events from ${provider.localResponse.city
                  .replaceAll("[", "")
                  .replaceAll("]", "")
                  .replaceAll("'", "")
              }')
                  : Container(),
              provider.isError
                  ? Center(child: Text(provider.errorMessage))
                  : Expanded(child: _listViewWidget(provider)),
            ],
          );
        },
      );
  }

  Widget _listViewWidget(provider) => ListView.builder(
        itemCount: provider.localResponse.events.length,
        itemBuilder: (context, index) {
          final event = provider.localResponse.events[index];
          return ListTile(
            leading: Image.network(event.imageUrl??'imageUrl', ),
            title: Text(event.title??'Event',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${event.startTime}\n${event.price}'
              ),
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
