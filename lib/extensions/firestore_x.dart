import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/model/accounts_model.dart';
import 'package:secured_note_app/model/note_model.dart';

extension FirestoreX on FirebaseFirestore {
  Stream<QuerySnapshot<Object?>> showNotes({required bool isFavList}) async* {
    yield* isFavList
        ? FirebaseFirestore.instance.noteCollection
            .where('isFav', isEqualTo: true)
            .orderBy('modifiedAt', descending: true)
            .snapshots()
        : FirebaseFirestore.instance.noteCollection
            .orderBy('modifiedAt', descending: true)
            .snapshots();
  }

  Stream<QuerySnapshot<Object?>> showAccount(String date) async* {
    yield* FirebaseFirestore.instance.expenseCollection(date).snapshots();
  }

  Future<void> updateFav(String id, bool isFav) async {
    await FirebaseFirestore.instance.noteCollection.doc(id).update({
      'isFav': isFav,
    });
  }

  Future<void> updateNote(String id, Note note) async {
    await FirebaseFirestore.instance.noteCollection
        .doc(id)
        .update(note.toJson());
  }

  Future<void> updateAccount(String id, AccountModel accountModel) async {
    await FirebaseFirestore.instance
        .expenseCollection(
          DateFormat('dd-MM-yyyy').format(
            DateTime.fromMicrosecondsSinceEpoch(
              DateTime.now().microsecondsSinceEpoch,
            ),
          ),
        )
        .doc(id)
        .update(accountModel.toJson());
  }

  Future<void> addNote(Note note) async {
    await FirebaseFirestore.instance.noteCollection.add(note.toJson());
  }

  Future<void> addAccount(AccountModel accountModel) async {
    await FirebaseFirestore.instance
        .expenseCollection(
          DateFormat('dd-MM-yyyy').format(
            DateTime.fromMicrosecondsSinceEpoch(
              DateTime.now().microsecondsSinceEpoch,
            ),
          ),
        )
        .add(accountModel.toJson());
  }

  Future<void> deleteNote(String id) async {
    await FirebaseFirestore.instance.noteCollection.doc(id).delete();
  }

  Future<void> deleteAccount(String id) async {
    await FirebaseFirestore.instance
        .expenseCollection(
          DateFormat('dd-MM-yyyy').format(
            DateTime.fromMicrosecondsSinceEpoch(
              DateTime.now().microsecondsSinceEpoch,
            ),
          ),
        )
        .doc(id)
        .delete();
  }
}

extension DocReferenceX on FirebaseFirestore {
  CollectionReference get noteCollection => collection('notes')
      .doc(firebaseAuth.currentUser!.uid)
      .collection('note-item');

  CollectionReference expenseCollection(String date) => collection('expenses')
      .doc(firebaseAuth.currentUser!.uid)
      .collection(date);
}
