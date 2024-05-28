import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'splash_screen.dart';
import 'task_type.dart';
import 'dialogTitle.dart';
import 'mongo_db.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  TaskType _taskType = TaskType.Technical;
  String _title = '';
  double _price = 0.0;
  // DateTime _deadline = DateTime.now(); Not needed?
  String _location = 'College Park, MD';
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          'Request Page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body:   AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                _title = value;
              },
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<TaskType>(
              value: _taskType,
              onChanged: (TaskType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _taskType = newValue;
                  });
                }
              },
              items: TaskType.values
                  .map<DropdownMenuItem<TaskType>>((TaskType value) {
                return DropdownMenuItem<TaskType>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Task Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                try {
                  _price = double.parse(value);
                }
                catch (err) {
                  _price = 0.0;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: "\$",
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _location,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _location = value;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
              ),
              onPressed: () => _selectDate(context),
              child: const Text('Select date', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Filtering out invalid submissions
                bool bannerExist = ScaffoldMessenger.of(context).mounted;
                bool invalidTitle = _title.isEmpty;
                bool invalidPrice = _price.isNaN || _price == 0;
                bool invalidDate = _selectedDate.isBefore(DateTime.now());
                if (invalidPrice || invalidDate) {
                  List<Text> invalidMessages = [];
                  if (invalidTitle) {
                    invalidMessages.add(const Text("Title cannot be empty"));
                  }
                  if (invalidPrice) {
                    invalidMessages.add(const Text("Input a valid price (ex. 10.00)"));
                  }
                  if (invalidDate) {
                    invalidMessages.add(Text("Input a valid date (input a date after ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year})"));
                  }
                  if (bannerExist) {
                    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                  }
                  ScaffoldMessenger.of(context).showMaterialBanner( // Make this look better
                    MaterialBanner(
                      content: Column(
                        children: invalidMessages,
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                          },
                          child: const Text("Dismiss"),
                        )
                      ]
                    )
                  );
                }
                else {
                  showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      titlePadding: const EdgeInsets.all(0.0),
                      title: const DialogTitle(title: "Confirmation"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Title: $_title"),
                          Text("Task Type: $_taskType"),
                          Text("Price: \$${_price.toStringAsFixed(2)}"),
                          Text("Location: $_location"),
                          Text("Complete by: ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}"),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Provider.of<MongoDB>(context, listen: false).insertTask(_title, _taskType, _price, _location, _selectedDate, context).then((value) {
                              if (value) {
                                if (ScaffoldMessenger.of(context).mounted) {
                                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                }
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your request has been processed!',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )
                                    ),
                                    backgroundColor: Colors.blue,
                                  )
                                );
                              }
                              else {
                                ScaffoldMessenger.of(context).showMaterialBanner(
                                  // Haven't tested
                                  MaterialBanner(
                                    content: const Text(
                                      'There was an error processing your request, please try again later',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
                                        child: const Text('Dismiss'),
                                      )
                                    ]
                                  ),
                                );
                              }
                            });
                          },
                          child: const Text("Confirm"),
                        ),
                      ],
                    ),
                  );
                };
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}