import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/screen/home_screen.dart';

Future<void> main() async {
    await Hive.initFlutter(); // <1> initilize hive in the main
await Hive.openBox('shopping_box'); // <2> to store data in hive we will open box (box equal the table in sql database but without structure)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
