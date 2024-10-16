import 'package:events_app/event_list_widget.dart';
import 'package:events_app/providers/event_provider.dart';
import 'package:events_app/services/location_service.dart';
import 'package:flutter/material.dart';

class CitySelectorWidget extends StatefulWidget {
  final EventProvider provider;
  final Function(String) onChanged;

  CitySelectorWidget({required this.provider, required this.onChanged});

  @override
  _CitySelectorWidgetState createState() => _CitySelectorWidgetState();
}

class _CitySelectorWidgetState extends State<CitySelectorWidget> {
  String? _selectedCity = SUPPORTED_CITIES[0];


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
