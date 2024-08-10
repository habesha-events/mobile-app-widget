import 'package:events_app/event_list_widget.dart';
import 'package:flutter/material.dart';

class CitySelectorWidget extends StatefulWidget {
  final provider;

  CitySelectorWidget({required this.provider});

  @override
  _CitySelectorWidgetState createState() => _CitySelectorWidgetState();
}

class _CitySelectorWidgetState extends State<CitySelectorWidget> {
  String? selectedCity; // Holds the selected city

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text('City: '),
          DropdownButton<String>(
            value: selectedCity,
            hint: Text('Select City'), // Initial hint when no city is selected
            items: SUPPORTED_CITIES // Add more cities here
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCity = newValue; // Update selected city
              });
              if (newValue != null) {
                widget.provider.fetchEvents(city: newValue);
              }
            },
            icon: Icon(Icons.arrow_downward), // Arrow down icon
          ),
        ],
      ),
      subtitle: selectedCity != null ? Text('Selected City: $selectedCity') : null,
    );
  }
}
