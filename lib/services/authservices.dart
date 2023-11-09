// ignore_for_file: unnecessary_null_comparison

import 'package:chat_app/helper/helperFun.dart';
import 'package:chat_app/services/dbServices.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //login
  Future signinWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.message;
    }
  }

  //register
  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        DatabaseServices(uid: user.uid).saveUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.message;
    }
  }

  //signout
  Future signout() async {
    try {
      await helperFun.saveUserLoggedInStatus(false);
      await helperFun.saveUserNameSp("");
      await helperFun.saveUserEmailSp("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
