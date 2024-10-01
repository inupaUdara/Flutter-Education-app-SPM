import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spm_project/helper/database_helper.dart';
import 'package:spm_project/helper/saved_and_open_pdf.dart';
import 'package:spm_project/model/shape_model.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportGenerator {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<void> generateReport(BuildContext context) async {
    // Fetch checked and unchecked shapes
    List<ShapeModel> checkedShapes = await _databaseHelper.getCheckedShapes();
    List<ShapeModel> uncheckedShapes =
        await _databaseHelper.getUncheckedShapes();

    // Create a PDF document
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Shapes Report', style: pw.TextStyle(fontSize: 30)),
            pw.SizedBox(height: 20),
            pw.Text('Checked Shapes:', style: pw.TextStyle(fontSize: 20)),
            ...checkedShapes.map((shape) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Name: ${shape.shapeName}'),
                  pw.Text('Date: ${shape.timestamp.toDate()}'),
                  pw.SizedBox(height: 10),
                ],
              );
            }).toList(),
            pw.SizedBox(height: 20),
            pw.Text('Unchecked Shapes:', style: pw.TextStyle(fontSize: 20)),
            ...uncheckedShapes.map((shape) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Name: ${shape.shapeName}'),
                  pw.Text('Date: ${shape.timestamp.toDate()}'),
                  pw.SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        );
      },
    ));

    // Save and open the PDF
    File pdfFile = await SavedAndOpenPdf.savePdf(name: 'report.pdf', pdf: pdf);
    await SavedAndOpenPdf.openPdf(pdfFile);
  }
}
