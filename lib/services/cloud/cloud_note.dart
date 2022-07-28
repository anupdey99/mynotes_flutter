import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloud_store_constant.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote(
      {required this.documentId,
      required this.ownerUserId,
      required this.text});

  CloudNote.formSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        text = snapshot.data()[textFieldName] as String;
}
