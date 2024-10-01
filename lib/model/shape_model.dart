import 'package:cloud_firestore/cloud_firestore.dart';

class ShapeModel {
  final String shapeId;
  final String shapeName;
  final String imageUrl;
  final bool completed;
  final Timestamp timestamp;

  ShapeModel({
    required this.shapeId,
    required this.shapeName,
    required this.imageUrl,
    required this.completed,
    required this.timestamp,
  });
}
