import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spm_project/helper/database_helper.dart';
import 'package:spm_project/model/shape_model.dart';

class UncheckedWidget extends StatefulWidget {
  final DateTime? selectedDate;
  const UncheckedWidget({super.key, this.selectedDate});

  @override
  State<UncheckedWidget> createState() => _UncheckedWidgetState();
}

class _UncheckedWidgetState extends State<UncheckedWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return StreamBuilder<List<ShapeModel>>(
      stream: _databaseHelper.shapes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ShapeModel> shapes = snapshot.data!;

          // Filter the shapes based on the selected date
          if (widget.selectedDate != null) {
            shapes = shapes.where((shape) {
              final DateTime shapeDate = shape.timestamp.toDate();
              return shapeDate.year == widget.selectedDate!.year &&
                  shapeDate.month == widget.selectedDate!.month &&
                  shapeDate.day == widget.selectedDate!.day;
            }).toList();
          }
          if (shapes.isEmpty) {
            return Center(
              child: Text(
                "No Shape Found",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shapes.length,
            itemBuilder: (context, index) {
              final DateTime dt = shapes[index].timestamp.toDate();
              return Container(
                margin: const EdgeInsets.all(10),
                width: screenWidth * 0.9,
                height:
                    screenHeight * 0.12, // Set the height of the entire tile
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(
                  key: ValueKey(shapes[index].shapeId),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.done,
                        label: "Check",
                        onPressed: (context) {
                          _databaseHelper.updateShapeStatus(
                              shapes[index].shapeId, true);
                        },
                      ),
                    ],
                  ),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: "Delete",
                        onPressed: (context) {
                          _databaseHelper.deleteShape(
                              shapes[index].shapeId, shapes[index].imageUrl);
                        },
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          width: screenWidth * 0.20, // Set desired image width
                          height:
                              screenHeight * 0.10, // Set desired image height
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              shapes[index].imageUrl,
                              fit: BoxFit.cover, // Adjust how the image fits
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                shapes[index].shapeName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.040,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                '${dt.day}/${dt.month}/${dt.year}',
                                style: TextStyle(fontSize: screenWidth * 0.03),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
