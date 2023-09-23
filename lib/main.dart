import 'package:flutter/material.dart';
import 'package:weather/pages/locationpage.dart';

void  main () => runApp(Home());


class Home extends StatelessWidget {
   Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        'locationPage' : (context) => LocationPage(),
      },
      initialRoute: 'locationPage',
    );

  }
}
