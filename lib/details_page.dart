import 'package:flutter/material.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/extensions/toast_x.dart';
import 'package:secured_note_app/model/note_model.dart';
import 'extensions/firestore_x.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    Key? key,
    required this.isEditing,
    this.id,
    this.note,
  }) : super(key: key);
  final bool isEditing;
  final Note? note;
  final String? id;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Color? selectedHeadingColor;
  Color? selectedDescriptionColor;
  Color? selectedButtonColor;

  TextEditingController? titleController;
  TextEditingController? descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.isEditing && widget.note != null ? widget.note!.title : null,
    );
    descriptionController = TextEditingController(
      text: widget.isEditing && widget.note != null
          ? widget.note!.description
          : null,
    );

    selectedHeadingColor = widget.isEditing && widget.note != null
        ? Color(widget.note!.color!)
        : Colors.transparent;
    selectedDescriptionColor = widget.isEditing && widget.note != null
        ? Color(widget.note!.bodyColor!)
        : Colors.transparent;
    selectedButtonColor = widget.isEditing && widget.note != null
        ? Color(widget.note!.color!)
        : Colors.black;
    // print(firebaseAuth.currentUser);
  }

  void updateNote(BuildContext context) {
    final prevNote = widget.note;
    final newNote = Note(
      title: titleController!.text,
      description: descriptionController!.text,
      color: selectedHeadingColor!.value,
      bodyColor: selectedDescriptionColor!.value,
      isFav: prevNote!.isFav,
    );
    if (prevNote != newNote) {
      firestore.updateNote(widget.id!, newNote).whenComplete(
        () {
          '${prevNote.title} is updated!'.showToast(context);
          Navigator.pop(context);
        },
      );
    } else {
      "No changes made".showToast(context);
    }
  }

  void addNote() {
    final note = Note(
      title: titleController?.text,
      description: descriptionController?.text,
      color: selectedHeadingColor!.value,
      bodyColor: selectedDescriptionColor!.value,
      isFav: false,
    );
    firestore.addNote(note).whenComplete(() => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Note' : 'Add Note'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      minLines: 2,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        filled: true,
                        fillColor: selectedHeadingColor ?? Colors.transparent,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      controller: titleController,
                    ),
                    TextFormField(
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor:
                            selectedDescriptionColor ?? Colors.transparent,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      controller: descriptionController,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedColors.length,
                        itemBuilder: (context, index) {
                          return RawMaterialButton(
                            onPressed: () {
                              setState(() {
                                selectedHeadingColor =
                                    Color(selectedColors[index]["heading"]);
                                selectedDescriptionColor =
                                    Color(selectedColors[index]["body"]);
                                selectedButtonColor =
                                    Color(selectedColors[index]["heading"]);
                              });
                            },
                            elevation: 6,
                            fillColor: Color(selectedColors[index]["heading"]),
                            constraints: const BoxConstraints.tightFor(
                              width: 60,
                              height: 60,
                            ),
                            shape: const CircleBorder(),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 12);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    widget.isEditing ? updateNote(context) : addNote();
                  },
                  child: Text(
                    widget.isEditing ? 'Update' : 'Add',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButtonColor,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    titleController?.dispose();
    descriptionController?.dispose();
  }
}
