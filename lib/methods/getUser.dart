import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crowdfarm/models/UserModel.dart';

Future<UserModel> getCurrentUser() async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user = _auth.currentUser;

  final x = await FirebaseFirestore.instance
      .collection('users')
      .where('uid', isEqualTo: _user.uid)
      .get();

  return UserModel.fromDocument(x.docs[0]);
}
