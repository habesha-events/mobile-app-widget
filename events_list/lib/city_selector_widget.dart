import 'package:events_app/providers/event_provider.dart';
import 'package:events_app/services/location_service.dart';
import 'package:flutter/material.dart';


class CitySelectorWidget extends StatefulWidget {
  final EventProvider provider;
  final Function(String) onChanged;
  final String inputCity;

  CitySelectorWidget({required this.provider, required this.onChanged, required this.inputCity});

  @override
  _CitySelectorWidgetState createState() => _CitySelectorWidgetState();
}

class _CitySelectorWidgetState extends State<CitySelectorWidget> {
  late String _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.inputCity;
  }

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
                _selectedCity = newValue??  widget.inputCity; // Update selected city
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
