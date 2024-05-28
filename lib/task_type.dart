import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';

var uuid = const Uuid();

enum TaskType { 
  Technical(type: "Technical"), 
  Labor(type: "Labor"), 
  Deliver(type: "Delivery"), 
  Other(type: "Other"); 

  const TaskType({required this.type});

  final String type;

  @override
  String toString() {
    return type;
  }
}

class Task {
  final String requester;
  final String title;
  final TaskType taskType;
  final double price;
  final String location;
  final DateTime deadline;
  String? taskId;
  DateTime? published;
  String? supplier;
  bool isCompleted; // Ensure this is initialized before the constructor body

  // Corrected constructor
  Task({
    required this.requester,
    required this.title,
    required this.taskType,
    required this.price,
    required this.location,
    required this.deadline,
    String? taskId,
    DateTime? published,
    String? supplier,
    bool isCompleted = false, // This correctly initializes the field
  })  : this.taskId = taskId ?? uuid.v4(), // Use ': this' for initializing fields
        this.published = published ?? DateTime.now(),
        this.isCompleted = isCompleted,
        this.supplier = supplier ?? "None"; // Include isCompleted in initializer list

  Map<String, dynamic> toJSON() {
    return {
      'requester': requester,
      'taskId': taskId,
      'date': published?.toIso8601String(), // Ensure date is formatted for JSON.
      'title': title,
      'task_type': taskType.toString(),
      'price': price,
      'location': location,
      'deadline': deadline.toIso8601String(), // Ensure date is formatted for JSON.
      'isCompleted': isCompleted,
      'supplier': supplier,
    };
  }

  static Task fromJSON(Map<String, dynamic> json) {
    return Task(
      requester: json['requester'] as String,
      title: json['title'] as String,
      taskType: TaskType.values.firstWhere(
        (type) => type.type == json['task_type'] as String,
        orElse: () => TaskType.Other
      ),
      price: json['price'] as double,
      location: json['location'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      taskId: json['taskId'] as String?,
      published: json['published'] != null ? DateTime.parse(json['published'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,  // Ensuring default to false if null
      supplier: json['supplier'] as String
    );
  }

}
