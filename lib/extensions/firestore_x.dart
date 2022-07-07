import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/model/note_model.dart';

extension FirestoreX on FirebaseFirestore {
  Stream<QuerySnapshot<Map<String, dynamic>>> showNotes(
      {required bool isFavList}) async* {
    final user = firebaseAuth.currentUser;
    yield* isFavList
        ? FirebaseFirestore.instance
            .collection('notes')
            .doc(user!.uid)
            .collection('note-item')
            .where('isFav', isEqualTo: true)
            .orderBy('modifiedAt', descending: true)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('notes')
            .doc(user!.uid)
            .collection('note-item')
            .orderBy('modifiedAt', descending: true)
            .snapshots();
  }

  Future<void> updateFav(String id, bool isFav) async {
    final user = firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(user!.uid)
        .collection('note-item')
        .doc(id)
        .update({
      'isFav': isFav,
    });
  }

  Future<void> updateNote(String id, Note note) async {
    final user = firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(user!.uid)
        .collection('note-item')
        .doc(id)
        .update(note.toJson());
  }

  Future<void> addNote(Note note) async {
    final user = firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(user!.uid)
        .collection('note-item')
        .add(note.toJson());
  }

  Future<void> deleteNote(String id) async {
    final user = firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(user!.uid)
        .collection('note-item')
        .doc(id)
        .delete();
  }
}

extension DocReferenceX on DocumentReference {
  CollectionReference get noteCollection => collection('notes');
}
