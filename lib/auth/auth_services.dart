import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class AuthServices {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signIn(String email, String password) async {
    try{
        UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
        User? firebaseUser = result.user;
        // firebaseUser?.updateDisplayName('Staff 3');

        return firebaseUser;
    } catch (e){
        print(e.toString());
        Toast.show("Email/Password yang anda masukan salah.", duration: Toast.lengthLong, gravity: Toast.bottom);
        return null;
    }
  }

  static Future<void> signOut () async {
    _auth.signOut();
  }
  static Stream<User?> get firebaseUserStream => _auth.authStateChanges();
}