import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'task_type.dart';
import 'mongo_db.dart';
import 'more_info.dart';
import 'userInfo.dart';

class SuppliersPage extends StatefulWidget {
  @override
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {

  @override
  Widget build(BuildContext context) {
      List<Task> tasks = Provider.of<MongoDB>(context)
          .tasks
          .where((task) => !task.isCompleted) // Only show non-completed tasks
          .toList();

      return Scaffold(
        
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.blue[900],
              title: Text(
                  'Supplier Page',
                  style: TextStyle(
                      color: Colors.white,
                  ),
              ),
          ),
   body: AnimationLimiter(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  color: Colors.grey[200],
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        if (value != null) {
                          if (Provider.of<UserInfo>(context, listen: false).uuid != null) {
                            Provider.of<MongoDB>(context, listen: false)
                                .completeTask(task.taskId!);
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Before taking a task, make sure to sign in!"),
                                backgroundColor: Colors.blue,
                              )
                            );
                          }
                        }
                      },
                    ),
                    title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Type: ${task.taskType}\n'
                        'Price: \$${task.price.toStringAsFixed(2)}\n'
                        'Location: ${task.location}\n'
                        'Deadline: ${task.deadline.month}/${task.deadline.day}/${task.deadline.year}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoreInfo(),
                            settings: RouteSettings(arguments: task),
                          )
                        );
                      },
                      child: const Text("More Info"),
                    )
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
}