import 'package:events_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'city_selector_widget.dart';
import 'models/event.dart';
import 'providers/event_provider.dart';
import 'dart:convert';

class EventListWidget extends StatefulWidget {
  Function(String) onErrorCallback;

  EventListWidget({
    required this.onErrorCallback,
  });

  @override
  State<StatefulWidget> createState() => EventListWidgetState();
}

class EventListWidgetState extends State<EventListWidget> {
  ScrollController _scrollController = ScrollController();
  var provider;
  @override
  void initState() {
    super.initState();

    provider =  Provider.of<EventProvider>(context, listen: false);

    //fetch supported list if not fetched , with .doThen()

    _fetchEvents();
  }

  _fetchEvents({String? city = null}) {
    provider.fetchEdvents(inputCity: city);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return Center(child: CircularProgressIndicator());
        }
        if (provider.isError) {
          widget.onErrorCallback(provider.errorMessage);
        }
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    CitySelectorWidget(
                        provider: provider,
                        onChanged: (city) {
                          _fetchEvents(city: city);
                        }),
                    // provider.localResponse.response_type == "neighboring_cities"
                    //     ? Text(
                    //         'Showing events from ${provider.localResponse.city.replaceAll("[", "").replaceAll("]", "").replaceAll("'", "")}')
                    //     : Container(),
                    Expanded(
                      child: _mainContentWidget(provider),
                    ),
                  ],
                ),
                // Footer pinned to the bottom using Positioned
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white, // Set the background color to gray
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: _sendEmail,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16.0, right: 16.0),
                              // Add bottom and right padding
                              child: Text(
                                'Contact us',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  // Make the text bold
                                  decoration: TextDecoration.underline,
                                  // Underline the text
                                  fontSize: 20.0, // Increase the text size
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mainContentWidget(provider) {
    return provider.isError
        ? Center(child: Text(provider.errorMessage))
        : _listViewWidget(provider);
  }

  Widget _listViewWidget(provider) => Scrollbar(
      controller: _scrollController,
      // Assign the controller to the Scrollbar
      thumbVisibility: true,
      // Makes the scrollbar always visible
      child: ListView.builder(
        itemCount: provider.localResponse.events.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          final event = provider.localResponse.events[index];
          return _rowWidget(event);
        },
      ));

  Widget _getTitleWidget(String text) {
    if (text.length > 25) {
      return SizedBox(
        height: 20,
        child: Marquee(
          text: text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          scrollAxis: Axis.horizontal,
          blankSpace: 20.0,
          velocity: 30.0,
        ),
      );
    } else {
      return Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
      );
    }
  }

  void _launchURL(url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri $url';
    }
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact.tofu.apps@gmail.com',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      print(e.toString());
    }
  }


  Widget _rowWidget(Event event) {
    // print("_rowWidget ${event.toString()}");
    var subTitleText = '${event.startTime}\n${event.getPriceDisplayText()} | ${event.city ?? ''}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 80,
            child: Image.network(
              event.imageUrl ?? 'imageUrl is null',
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 120,
                  height: 80,
                  child: Icon(Icons.image, size: 50),
                );
              },
            ),
          ),
          const SizedBox(width: 10), // Spacing between image and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _getTitleWidget(event.title ?? 'Event'), // Handle null title
                const SizedBox(height: 4), // Add small spacing between title and subtitle
                Text(
                  ApiService.USE_FAKE_DATA ? subTitleText :  utf8.decode(subTitleText.codeUnits),
                  style: const TextStyle(height: 1.5), // Adjust line height for better spacing
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
