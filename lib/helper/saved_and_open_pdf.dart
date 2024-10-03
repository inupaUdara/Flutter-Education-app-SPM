import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;

class SavedAndOpenPdf {
  static Future<File> savePdf({
    required String name,
    required pw.Document pdf,
  }) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$name");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> openPdf(File pdfFile) async {
    await OpenFile.open(pdfFile.path);
  }
}
