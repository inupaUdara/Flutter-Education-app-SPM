import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:spm_project/model/shape_model.dart';

class DatabaseHelper {
  final CollectionReference shapeCollection =
      FirebaseFirestore.instance.collection('shapes');

  User? user = FirebaseAuth.instance.currentUser;

  //add shape
  Future<DocumentReference> saveShape(String shapeName, String imageUrl) async {
    try {
      return await shapeCollection.add({
        'uid': user!.uid,
        'shapeName': shapeName,
        'imageUrl': imageUrl,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      devtools.log("Error saving shape: $e");
      throw Exception("Error saving shape");
    }
  }

  //update shapes

  //update shape status
  Future<void> updateShapeStatus(String shapeId, bool completed) async {
    try {
      await shapeCollection.doc(shapeId).update({'completed': completed});
    } catch (e) {
      devtools.log("Error updating shape status: $e");
      throw Exception("Error updating shape status");
    }
  }

  //delete shape
  Future<void> deleteShape(String shapeId, String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await shapeCollection.doc(shapeId).delete();
    } catch (e) {
      devtools.log("Error deleting shape: $e");
      throw Exception("Error deleting shape");
    }
  }

  //get unchecked shapes
  Stream<List<ShapeModel>> get shapes {
    return shapeCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: false)
        .snapshots()
        .map(_shapeListFromSnapshot);
  }

  //get checked shapes
  Stream<List<ShapeModel>> get completedShapes {
    return shapeCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map(_shapeListFromSnapshot);
  }

  // Get unchecked shapes as a list
  Future<List<ShapeModel>> getUncheckedShapes() async {
    try {
      QuerySnapshot snapshot = await shapeCollection
          .where('uid', isEqualTo: user!.uid)
          .where('completed', isEqualTo: false)
          .get();

      return _shapeListFromSnapshot(snapshot);
    } catch (e) {
      devtools.log("Error fetching unchecked shapes: $e");
      throw Exception("Error fetching unchecked shapes");
    }
  }

  // Get checked shapes as a list
  Future<List<ShapeModel>> getCheckedShapes() async {
    try {
      QuerySnapshot snapshot = await shapeCollection
          .where('uid', isEqualTo: user!.uid)
          .where('completed', isEqualTo: true)
          .get();

      return _shapeListFromSnapshot(snapshot);
    } catch (e) {
      devtools.log("Error fetching checked shapes: $e");
      throw Exception("Error fetching checked shapes");
    }
  }

  List<ShapeModel> _shapeListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ShapeModel(
        shapeId: doc.id,
        shapeName: doc['shapeName'] ?? '',
        imageUrl: doc['imageUrl'] ?? '',
        completed: doc['completed'] ?? false,
        timestamp: doc['createdAt'] ?? '',
      );
    }).toList();
  }

  Future<void> saveDetectedShape(File? filePath, String label) async {
    if (filePath != null && label.isNotEmpty) {
      try {
        // Upload image to Firebase Storage
        final fileName = filePath.path.split('/').last;
        final storageRef =
            FirebaseStorage.instance.ref().child('shapes/$fileName');
        UploadTask uploadTask = storageRef.putFile(filePath);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Save shape with image URL to Firestore
        //_databaseService.saveShape(label, imageUrl);
        await saveShape(label, imageUrl);
        devtools.log("Shape saved with image URL: $imageUrl");
      } catch (e) {
        devtools.log("Error saving shape: $e");
      }
    } else {
      devtools.log("No image or label detected to save");
    }
  }
}
