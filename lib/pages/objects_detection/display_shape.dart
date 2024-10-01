import 'package:flutter/material.dart';
import 'package:spm_project/widget/checked_widget.dart';
import 'package:spm_project/widget/unchecked_widget.dart';

class DisplayShapes extends StatefulWidget {
  const DisplayShapes({super.key});

  @override
  State<DisplayShapes> createState() => _DisplayShapesState();
}

class _DisplayShapesState extends State<DisplayShapes> {
  int _buttonIndex = 0;

  final List<Widget> _widgets = [
    //unchecked_widget.dart
    const UncheckedWidget(),
    //checked_widget.dart
    const CheckedWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SAVED OBJECTS"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _buttonIndex = 0;
                    });
                  },
                  child: Container(
                    height: screenHeight * 0.065,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Unchecked",
                        style: TextStyle(
                          fontSize: _buttonIndex == 0
                              ? screenWidth * 0.040
                              : screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                          color: _buttonIndex == 0
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _buttonIndex = 1;
                    });
                  },
                  child: Container(
                    height: screenHeight * 0.065,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Checked",
                        style: TextStyle(
                          fontSize: _buttonIndex == 1
                              ? screenWidth * 0.040
                              : screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                          color: _buttonIndex == 1
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),
            _widgets[_buttonIndex],
          ],
        ),
      ),
    );
  }
}
