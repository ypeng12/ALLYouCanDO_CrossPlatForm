import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mongo_db.dart';
import 'task_type.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    List<Task> completedTasks = Provider.of<MongoDB>(context).getCompletedTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks'),
        backgroundColor: Colors.blue[900],
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            Task task = completedTasks[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text('Completed on: ${task.deadline}'),
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

