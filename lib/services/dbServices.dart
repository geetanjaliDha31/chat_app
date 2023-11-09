// ignore_for_file: dead_code

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  //reference for our collections
  final CollectionReference userCollections =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //updating user data
  Future saveUserData(String fullName, String email) async {
    return await userCollections.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "userid": uid,
    });
  }

  //getting user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollections.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //getting user groups
  getUserGroups() async {
    return userCollections.doc(uid).snapshots(); // snapshot: list of document
  }

  //creating a group
  Future createGroup(String userName, String id, String groupName1) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      //document reference is an object to store document
      "groupName": groupName1,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${id}_$userName"]),
      "groupId": groupDocumentReference.id
    });

    //adding group in admin document
    DocumentReference userDocumentReference = userCollections.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName1"])
    });
  }

  //getting chats
  getChat(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("message")
        .orderBy("time")
        .snapshots();
  }

  //getting admin
  Future getAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot[
        "admin"]; //A DocumentSnapshot contains data from a document.The data can be extracted with data() or get(<field>) to get a specific field.
  }

  //getting group members
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //searching groups
  searchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  //function to check if user joined a group
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollections.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = documentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userdocumentReference = userCollections.doc(uid);
    DocumentReference groupdocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot userSnapshot = await userdocumentReference.get();
    List<dynamic> groups = userSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      await userdocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupdocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userdocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupdocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendMessage2(String groupId, Map<String, dynamic> chatMap) {
    groupCollection.doc(groupId).collection("message").add(chatMap);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMap["message"],
      "recentMessageSender": chatMap["sender"],
      "recentMessageTime": chatMap["time"].toString(),
    });
  }

  Future getRecentMessage(String groupId) async {
    QuerySnapshot snapshot =
        await groupCollection.where("groupId", isEqualTo: groupId).get();
    return snapshot;
  }
}
