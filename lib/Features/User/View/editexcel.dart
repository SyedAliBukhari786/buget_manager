import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class ExcelTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Excel Test"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _createSampleExcel(context), // Fixing the onPressed callback
          child: Text("Create Sample Excel File"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
        ),
      ),
    );
  }

  Future<void> _createSampleExcel(BuildContext context) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add header row
    sheet.appendRow([
      TextCellValue("Name"),
      TextCellValue("Age"),
    ]);

    // Add sample data
    sheet.appendRow([
      TextCellValue("Ali"),
      DoubleCellValue(12),
    ]);

    // File saving logic
    Directory? directory;
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final customDir = Directory("${directory.path}/SampleExcel");
      if (!(await customDir.exists())) {
        await customDir.create(recursive: true);
        print('Custom directory created: ${customDir.path}');
      } else {
        print('Custom directory already exists: ${customDir.path}');
      }

      String path =
          "${customDir.path}/sample_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx";
      print('Saving file to: $path');

      File file = File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.save()!);

      if (file.existsSync()) {
        print('File successfully saved: $path, Size: ${file.lengthSync()} bytes');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File saved: $path")));
      } else {
        print('Failed to save file.');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to save file.")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Could not save file.")));
      print("Directory is null, file could not be saved.");
    }
  }
}


