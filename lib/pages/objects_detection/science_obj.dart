import 'package:flutter/material.dart';

class ScienceObj extends StatefulWidget {
  const ScienceObj({super.key});

  @override
  State<ScienceObj> createState() => _ScienceObjState();
}

class _ScienceObjState extends State<ScienceObj> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Science Object Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Science Object Detection',
            ),
          ],
        ),
      ),
    );
  }
}
