// To parse this JSON data, do
//
//      noteModel = noteModelFromJson(jsonString);

import 'package:equatable/equatable.dart';
import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel extends Equatable {
  const NoteModel({
    this.datas,
  });

  final List<Note>? datas;

  NoteModel copyWith({
    List<Note>? datas,
    String? uid,
  }) =>
      NoteModel(
        datas: datas ?? this.datas,
      );

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        datas: List<Note>.from(json["datas"].map((x) => Note.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "datas": List<dynamic>.from(datas!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [datas];
}

class Note extends Equatable {
  const Note({
    this.bodyColor,
    this.color,
    this.description,
    this.title,
    this.isFav,
  });

  final int? bodyColor;
  final int? color;
  final String? description;
  final String? title;
  final bool? isFav;

  Note copyWith({
    int? bodyColor,
    int? color,
    String? description,
    String? title,
    bool? isFav,
  }) =>
      Note(
        bodyColor: bodyColor ?? this.bodyColor,
        color: color ?? this.color,
        description: description ?? this.description,
        title: title ?? this.title,
        isFav: isFav ?? this.isFav,
      );

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        bodyColor: json["bodyColor"],
        color: json["color"],
        description: json["description"],
        title: json["title"],
        isFav: json["isFav"],
      );

  Map<String, dynamic> toJson() => {
        "bodyColor": bodyColor,
        "color": color,
        "description": description,
        "title": title,
        "isFav": isFav,
      };

  // @override
  // String toString() {
  //   return "(title: $title, description: $description, color: $color, bodyColor: $bodyColor, isFav: $isFav)";
  // }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [bodyColor, color, description, title, isFav];
}
