import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'city_selector_widget.dart';
import 'providers/event_provider.dart';

List<String> SUPPORTED_CITIES = ['Washington, D.C.', 'Minneapolis', 'Los Angeles', 'New York City', 'Seattle', 'Dallas', 'Atlanta', 'Denver', 'San Francisco', 'Boston', 'Houston', 'Chicago', 'San Diego', 'Philadelphia', 'Phoenix', 'Portland', 'Austin', 'Miami', 'Detroit', 'Baltimore', 'Toronto', 'Calgary', 'Edmonton', 'Vancouver', 'Montreal', 'Ottawa', 'Winnipeg', 'Hamilton', 'Kitchener', 'London', 'Halifax', 'Victoria', 'Quebec City', 'Surrey', 'Mississauga', 'Burnaby', 'Regina', 'Saskatoon', 'Windsor', 'Oshawa', 'London', 'Frankfurt', 'Stockholm', 'Rome', 'Amsterdam', 'Paris', 'Berlin', 'Oslo', 'Brussels', 'Copenhagen', 'Madrid', 'Vienna', 'Zurich', 'Munich', 'Lisbon', 'Helsinki', 'Dublin', 'Athens', 'Prague', 'Warsaw'];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if(provider.isError){
            return Center(child: Text('Api Error'));
          }
          return Column(
            children: [
            Padding(padding: EdgeInsets.all(20.0)),
              CitySelectorWidget(provider :provider,),
              Expanded(child: _listViewWidget(provider))
            ],
          );
        },
      ),
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
