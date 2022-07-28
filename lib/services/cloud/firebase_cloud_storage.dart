import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_excepsions.dart';
import 'package:notes/services/cloud/cloud_store_constant.dart';

class FirebaseCloudStorage {
  static final _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<CloudNote> createNewNote({
    required String ownerUserId,
  }) async {
    final docRef = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final doc = await docRef.get();
    return CloudNote(
      documentId: doc.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  Future<Iterable<CloudNote>> getNotes({
    required String ownerUserId,
  }) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then((querySnapshot) => querySnapshot.docs.map(
              (queryDocumentSnapshot) =>
                  CloudNote.formSnapshot(queryDocumentSnapshot)));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map((event) => event.docs
        .map((doc) => CloudNote.formSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));
  }
}
