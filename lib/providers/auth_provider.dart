import 'package:flutter/cupertino.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> signUp(String email, String password) async {
    
  }
}
