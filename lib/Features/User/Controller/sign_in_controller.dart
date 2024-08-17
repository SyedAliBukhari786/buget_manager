import 'package:firebase_auth/firebase_auth.dart';

class SignInController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e); // Handle error appropriately
      return false;
    }
  }


}
