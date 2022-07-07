// To parse this JSON data, do
//
//      noteModel = noteModelFromJson(jsonString);

import 'package:equatable/equatable.dart';

class Note extends Equatable {
  const Note({
    this.bodyColor,
    this.color,
    this.description,
    this.title,
    this.isFav,
    this.modifiedAt,
  });

  final int? bodyColor;
  final int? color;
  final String? description;
  final String? title;
  final bool? isFav;
  final int? modifiedAt;

  Note copyWith({
    int? bodyColor,
    int? color,
    String? description,
    String? title,
    bool? isFav,
    int? modifiedAt,
  }) =>
      Note(
        bodyColor: bodyColor ?? this.bodyColor,
        color: color ?? this.color,
        description: description ?? this.description,
        title: title ?? this.title,
        isFav: isFav ?? this.isFav,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        bodyColor: json["bodyColor"],
        color: json["color"],
        description: json["description"],
        title: json["title"],
        isFav: json["isFav"],
        modifiedAt: json["modifiedAt"],
      );

  Map<String, dynamic> toJson() => {
        "bodyColor": bodyColor,
        "color": color,
        "description": description,
        "title": title,
        "isFav": isFav,
        "modifiedAt": modifiedAt,
      };

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props =>
      [bodyColor, color, description, title, isFav, modifiedAt];
}
