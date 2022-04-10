import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowdfarm/pages/dashboard.dart';
import 'package:crowdfarm/pages/userInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
String name;
String email;
String imageUrl;
String phoneNumber;

Future<String> signInWithGoogle(BuildContext context) async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final User currentUser = _auth.currentUser;
  assert(user.uid == currentUser.uid);
  assert(user.email != null);
  assert(user.displayName != null);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('login', true);
  final x = await FirebaseFirestore.instance
      .collection('users')
      .where('uid', isEqualTo: user.uid)
      .get();
  if (x.docs.isNotEmpty) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoardPage()));
  } else {
    name = user.displayName;
    email = user.email;
    phoneNumber = user.phoneNumber;
    imageUrl = user.photoURL;
    //FirebaseAdd().addUser(name, email, phoneNumber, user.uid, imageUrl);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return DetailsForm(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        image: imageUrl,
        uid: user.uid,
      );
    }));
  }
  return 'signInWithGoogle succeeded: $user';
}

void signOut() async {
  await googleSignIn.signOut();
  await FirebaseAuth.instance.signOut();
  print("User Sign Out");
}
