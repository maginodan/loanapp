import 'package:file_picker/file_picker.dart';

Future<String?> pickDocument() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg']);

  if (result != null) {
    String? file = result.files.single.path;
    return file!;
  } else {
    return null;
  }
}
