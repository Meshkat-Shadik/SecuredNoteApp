import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:google_sign_in/google_sign_in.dart';

final List<Map<String, dynamic>> selectedColors = [
  {
    "heading": 0xff3f51b5,
    "body": 0xff7986cb,
  },
  {
    "heading": 0xff607d8b,
    "body": 0xff90a4ae,
  },
  {
    "heading": 0xff009688,
    "body": 0xff4db6ac,
  },
  {
    "heading": 0xff795548,
    "body": 0xffa1887f,
  },
  {
    "heading": 0xffF44336,
    "body": 0xffE57373,
  },
];

const Color redColor = Color(0xffA70923);
const Color greenColor = Color(0xffA4DD04);
final googleSignIn = GoogleSignIn();
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
