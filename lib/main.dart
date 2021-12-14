import 'package:flutter/material.dart';
import 'screens/ble_find.dart';
import 'era_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: EraTheme.light(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        title: Text(
          "Era Companion App",
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Era Watch Companion",
                style: EraTheme.textTheme.headline2),
          ),
          Image.asset('assets/watchy.png'),
          TextButton(
            style: TextButton.styleFrom(primary: Colors.blueGrey),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return BleFind();
                },
              ));
            },
            child: const Text("Get Started"),
          )
        ],
      ),
    );
  }
}
