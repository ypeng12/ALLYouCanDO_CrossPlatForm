import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'navigation.dart';
import 'userInfo.dart';
import 'mongo_db.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserInfo>(create: (_) => UserInfo()),
        ChangeNotifierProvider<MongoDB>(create: (_) => MongoDB()),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MongoDB>(
      builder: (context, value, child) => Consumer<UserInfo>(
        builder: (context, value, child) => MaterialApp(
          title: 'All You Can Do',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const NavigationWidget(),
        )
      )
    );
  }
}