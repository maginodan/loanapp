import 'dart:io';

import 'package:expense_tracker/enums/enums.dart';
import 'package:expense_tracker/model/upload_doc_model.dart';
import 'package:expense_tracker/shared/utils/app_logger.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<UploadDocResultModel> uploadDocumentToServer(String docPath) async {
  UploadTask uploadTask;

  final docName = docPath.split('/').last;

  appLogger("uploading image : $docName");

  try {
    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance.ref().child('loan').child('/$docName.pdf');

    uploadTask = ref.putFile(File(docPath));

    TaskSnapshot snapshot = await uploadTask.whenComplete(() => appLogger("Task completed"));

    final downloadUrl = await snapshot.ref.getDownloadURL();

    appLogger("uploading image uril : $downloadUrl");

    return Future.value(UploadDocResultModel(state: ViewState.Success, fileUrl: downloadUrl));
  } on FirebaseException catch (error) {
    appLogger("F-Error uploading image : $error");

    return Future.value(UploadDocResultModel(state: ViewState.Error, fileUrl: '"F-Error uploading image"'));
  } catch (error) {
    appLogger("Error uploading image : $error");

    return Future.value(UploadDocResultModel(state: ViewState.Error, fileUrl: '"Error uploading image"'));
  }
}
