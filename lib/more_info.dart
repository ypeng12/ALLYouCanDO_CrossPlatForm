import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'task_type.dart';
import 'mongo_db.dart';

class MoreInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Task taskInfo = ModalRoute.of(context)!.settings.arguments as Task;
    String? requester; 
    Provider.of<MongoDB>(context, listen: false).getUser(taskInfo.requester).then((value) {
      requester = value;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          taskInfo.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder(
            future: Provider.of<MongoDB>(context, listen: false).getUser(taskInfo.requester),
            initialData: "???",
            builder:(context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: double.infinity),
                    Icon(
                      Icons.task,
                      size: constraints.biggest.shortestSide / 1.5,
                      color: Colors.blue,
                    ),
                    Text(
                      'Requested by: ${snapshot.data}',
                      style: const TextStyle(
                        fontSize: 24
                      )
                    ),
                    Text(
                      'Requested on: ${taskInfo.published!.month}/${taskInfo.published!.day}/${taskInfo.published!.year} at ${taskInfo.published!.hour}:${taskInfo.published!.minute}',
                      style: const TextStyle(
                        fontSize: 24
                      )
                    ),
                    Text(
                      'Task type: ${taskInfo.taskType}',
                      style: const TextStyle(
                        fontSize: 24
                      )
                    ),
                    Text(
                      'Price: ${taskInfo.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24
                      )
                    ),
                    Text(
                      'Complete by: ${taskInfo.deadline.month}/${taskInfo.deadline.day}/${taskInfo.deadline.year}',
                      style: const TextStyle(
                        fontSize: 24
                      )
                    ),
                    Text(
                      'Job Completed: ${taskInfo.isCompleted}',
                      style: const TextStyle(
                        fontSize: 24
                      )
                    ),
                    Text(
                      taskInfo.supplier != "None" 
                      ? "Taken by: ${taskInfo.supplier}"
                      : "",
                      style: const TextStyle(
                        fontSize: 24
                      )
                    )
                  ]
                );
              }
              else {
                return const Center(
                  child: Text("Loading..."),
                );
              }
            }
          );
        }
      )
    );
  }
}