import 'dart:io';

Future<void> deleteFile(File file) async {
  try {
    if (await file.exists()) {
      print("deleting file...");
      await file.delete();
    }
  } catch (e) {
    // Error in getting access to the file.
  }
}