import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return " ";
    } on FirebaseAuthException catch(e) {
      switch(e.code) {
        case 'wrong-password':
          return 'Invalid Username or Password';
          break;
        case 'user-not-found':
          return 'Invalid Username or Password';
          break;
        case 'network-request-failed':
          return 'Please connect to a internet';
          break;
        default:
          return 'Server error, please try again later';
      }
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return " ";
    } on FirebaseAuthException catch(e) {
      switch(e.code) {
        case 'email-already-in-use':
          return 'Email already in use. Go to Sign In Page';
          break;
        default:
          return 'Server error, please try again later';
      }
    }
  }

  Future<String> signOut() async {
    await _firebaseAuth.signOut();
    return "Sign Out";
  }

  Future<String> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return " ";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Server error, please try again later';
    }
  }

  Future<String> confirmNewPassword(String code, String newPassword) async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(code: code, newPassword: newPassword);
      return " ";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Server error, please try again later';
    }
  }
}