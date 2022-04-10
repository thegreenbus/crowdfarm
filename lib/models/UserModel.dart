import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web3dart/credentials.dart';

class UserModel {
  final String name;
  final String email;
  final String phone;
  final int balance;
  final String address;
  final String uid;
  final int score;

  UserModel(
      {this.email,
      this.name,
      this.address,
      this.balance,
      this.phone,
      this.uid,
      this.score});

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
        name: doc['name'],
        email: doc['email'],
        phone: doc['phoneNumber'],
        address: doc['ethAddress'],
        balance: doc['balance'],
        uid: doc['uid'],
        score: doc['score']);
  }

  EthereumAddress getEthaddress(address) {
    return EthereumAddress.fromHex(address);
  }
}
