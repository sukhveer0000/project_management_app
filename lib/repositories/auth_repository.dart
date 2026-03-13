import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String userName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(userName);
      await credential.user!.reload();
      return credential;
    } catch (e) {
      throw Exception('Failed to Signup: $e');
    }
  }

  Future<UserCredential> loginAccount(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Fialed to login: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
