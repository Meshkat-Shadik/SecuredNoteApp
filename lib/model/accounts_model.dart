import 'dart:convert';

import 'package:equatable/equatable.dart';

AccountModel accountModelFromJson(String str) =>
    AccountModel.fromJson(json.decode(str));

String accountModelToJson(AccountModel data) => json.encode(data.toJson());

class AccountModel extends Equatable {
  const AccountModel({
    required this.title,
    required this.type,
    required this.amount,
  });

  final String title;
  final String type;
  final int amount;

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        title: json["title"],
        type: json["type"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "type": type,
        "amount": amount,
      };
  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [title, type, amount];
}
