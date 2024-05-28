import "dart:async";

import "package:flutter/material.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:provider/provider.dart';

import 'userInfo.dart';
import 'task_type.dart';

class MongoDB extends ChangeNotifier {
  List<Task> tasks = [];
  late StreamSubscription<Map<String, dynamic>> subscription;
  late Db db;

  MongoDB() {
    print("Hi");
    Db.create("mongodb+srv://${dotenv.env["MONGO_DB_USERNAME"]}:${dotenv.env["MONGO_DB_PASSWORD"]}@${dotenv.env["MONGO_DB_NAME"]}.kc4wdjk.mongodb.net/AllYouCanDo?retryWrites=true&w=majority&appName=AllYouCanDo").then((value) {
      db = value;
      print("test db creation");
      init();
    });
  }

  Future<void> init() async {
    if (!db.isConnected) {
      await db.open();
    }
    List<Task> tasksReplacement = [];
    subscription = db.collection(dotenv.env["MONGO_TASK_COLLECTION"]!).find(where.sortBy("deadline")).listen((onData) {
      print("newTask added!");
      TaskType type;
      switch (onData["task_type"]) {
        case "technical":
          type = TaskType.Technical;
          break;
        case "delivery":
          type = TaskType.Deliver;
          break;
        case "labor":
          type = TaskType.Labor;
          break;
        default:
          type = TaskType.Other;
      }
      Task newTask = Task(requester: onData["requester"],
                          title: onData["title"], 
                          taskType: type, 
                          price: onData["price"], 
                          location: onData["location"], 
                          deadline: DateTime.parse(onData["deadline"]),
                          taskId: onData["taskId"],
                          published: DateTime.parse(onData["date"]),
                          isCompleted: onData["isCompleted"],
                          supplier: onData["supplier"]);
      if (!newTask.isCompleted) {
        tasksReplacement.add(newTask); 
      }
    }, onDone: () {
      tasks = tasksReplacement;
      notifyListeners();
    });
  }
  // void openConnection() async {
  //   print("mongodb+srv://${dotenv.env["MONGO_DB_USERNAME"]}:${dotenv.env["MONGO_DB_PASSWORD"]}@${dotenv.env["MONGO_DB_NAME"]}.kc4wdjk.mongodb.net/AllYouCanDo?retryWrites=true&w=majority&appName=AllYouCanDo");
  //   await db.open();
  //   print(db.isConnected);
  //   var collection = db.collection(dotenv.env["MONGO_TASK_COLLECTION"]!);
  //   var result = await collection.insertOne({'login':'doug', 'name':'Dimmadome', 'email':'Doug@Dimmadome.com'});
  //   print(result.isSuccess);
  //   await db.close();
  // }

  Future<bool> insertTask(String title, TaskType task, double price, String location, DateTime deadline, BuildContext context) async {
    if(db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_TASK_COLLECTION"]!);
      String requester = Provider.of<UserInfo>(context, listen: false).uuid;
      Task newTask = Task(requester: requester, 
                          title: title, 
                          taskType: task, 
                          price: price, 
                          location: location, 
                          deadline: deadline, 
                          isCompleted: false,
                          supplier: "None");
      WriteResult result = await collection.insertOne(newTask.toJSON());
      await init();
      return result.isSuccess;
    }
    return false;
  }

  void completeTask(String taskId) {
    int taskIndex = tasks.indexWhere((task) => task.taskId == taskId);
    if (taskIndex != -1) {
      tasks[taskIndex].isCompleted = true;
      notifyListeners();  // Notify listeners about state change
    }
  }

  List<Task> getCompletedTasks() {
    return tasks.where((task) => task.isCompleted).toList();
  }

  // Run this to clear documents in collection (After db.open())
  void developmentReset(String collection) {
    if (!db.isConnected) {
      db.open();
    }
    db.removeFromCollection(collection!);
  }

  // Email and usernames must be unique (not (email, username) unique but separately unique)
  Future<bool?> userExist(String email, String username) async {
    if (db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_USER_COLLECTION"]!);
      Map<String,dynamic>? emailTaken = await collection.findOne({'email': email});
      Map<String,dynamic>? usernameTaken = await collection.findOne({'username': username});
      return !(emailTaken == null && usernameTaken == null);
    }
    return null;
  }

  Future<bool> userNameAvailable(String username) async {
    if (db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_USER_COLLECTION"]!);
      Map<String,dynamic>? usernameTaken = await collection.findOne({'username': username});
      return (usernameTaken == null);
    }
    return false;
  }

  // THERE IS NO ENCRYPTION
  void newUser(String uuid, String email, String username, String password) {
    if (db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_USER_COLLECTION"]!);
      collection.insertOne({"UID_user": uuid, 
                            "username": username,
                            "email": email,
                            "password": password});
    }
  }

  Future<Map<String,dynamic>?> logIn(String email, String password) async {
    if (db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_USER_COLLECTION"]!);
      Map<String,dynamic>? user = await collection.findOne({'email': email,
                                                            'password': password});
      return user;
    }
    return null;
  }

  Future<bool> changeUsername(String email, String username) async {
    if (db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_USER_COLLECTION"]!);
      WriteResult result = await collection.updateOne(where.eq("email", email), modify.set('username', username));
      return result.isSuccess;
    }
    return false;
  }

  Future<String?> getUser(String userId) async {
    Map<String,dynamic>? result;
    if (db.isConnected) {
      var collection = db.collection(dotenv.env["MONGO_USER_COLLECTION"]!);
      result = await collection.findOne(where.eq("UID_user", userId));
    }
    if (result != null) {
      return result["username"];
    }
    return null;
  }

  @override 
  void dispose() {
    subscription.cancel();
    db.close();
    super.dispose();
  }

  updateTaskCompletion(String? taskId, bool value) {}
}