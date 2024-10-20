import 'package:events_app/event_list_widget.dart';
import 'package:events_app/providers/event_provider.dart';
import 'package:events_app/services/location_service.dart';
import 'package:flutter/material.dart';

import 'models/supported_city.dart';


// List<String> SUPPORTED_CITIES_DEFAULT = ['Washington, DC',
//   'Addis Ababa',
//   'Nairobi', 'Dubai',
//   'Johannesburg', 'Minneapolis', 'Los Angeles', 'New York City', 'Seattle', 'Dallas', 'Atlanta', 'Denver', 'San Francisco', 'Boston', 'Houston', 'Chicago', 'San Diego', 'Philadelphia', 'Phoenix', 'Portland', 'Austin', 'Miami', 'Detroit', 'Baltimore', 'Toronto', 'Calgary', 'Edmonton', 'Vancouver', 'Montreal', 'Ottawa', 'Winnipeg', 'Hamilton', 'Kitchener', 'London', 'Halifax', 'Victoria', 'Quebec City', 'Surrey', 'Mississauga', 'Burnaby', 'Regina', 'Saskatoon', 'Windsor', 'Oshawa', 'London', 'Frankfurt', 'Stockholm', 'Rome', 'Amsterdam', 'Paris', 'Berlin', 'Oslo', 'Brussels', 'Copenhagen', 'Madrid', 'Vienna', 'Zurich', 'Munich', 'Lisbon', 'Helsinki', 'Dublin', 'Athens', 'Prague', 'Warsaw'];

List<SupportedCity> SUPPORTED_CITIES = [];

class CitySelectorWidget extends StatefulWidget {
  final EventProvider provider;
  final Function(String) onChanged;

  CitySelectorWidget({required this.provider, required this.onChanged});

  @override
  _CitySelectorWidgetState createState() => _CitySelectorWidgetState();
}

class _CitySelectorWidgetState extends State<CitySelectorWidget> {
  String? _selectedCity = SUPPORTED_CITIES[0].city;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Select City: '),
          DropdownButton<String>(
            value: _selectedCity,
            // hint: Text('Select City'), // Initial hint when no city is selected
            items: SUPPORTED_CITIES
            .map((supportedCity) => supportedCity.city)
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                if (newValue != null) {
                  widget.onChanged(newValue);
                }
                _selectedCity = newValue; // Update selected city
              });

            },
            icon: Icon(Icons.keyboard_arrow_down), // Arrow down icon
          ),
        ],
      ),
      // subtitle: _selectedCity != null ? Text('Selected City: $_selectedCity') : null,
    );
  }
}
