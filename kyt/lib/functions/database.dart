import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference usersCollection =
      Firestore.instance.collection('users');

  Future updateUserData(
      String name, String phoneNumber, String aadharCardNumber) async {
    return await usersCollection.document(uid).setData({
      'phoneNumber': phoneNumber,
      'name': name,
      'aadharCardNumber': aadharCardNumber
    });
  }
}
