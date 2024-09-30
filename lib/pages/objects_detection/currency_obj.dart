import 'package:flutter/material.dart';

class CurrancyObj extends StatefulWidget {
  const CurrancyObj({super.key});

  @override
  State<CurrancyObj> createState() => _CurrancyObjState();
}

class _CurrancyObjState extends State<CurrancyObj> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currancy Object Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Currancy Object Detection',
            ),
          ],
        ),
      ),
    );
  }
}
