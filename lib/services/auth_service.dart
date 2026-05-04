import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String get userId => _auth.currentUser?.uid ?? '';

  // ─── Register email & password ────────────────────────────────────────────
  Future<UserCredential?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      // Simpan ke Firestore
      await _firestore
          .collection('users')
          .doc(credential.user?.uid)
          .set({'displayName': name, 'email': email}, SetOptions(merge: true));
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  // ─── Login email & password ───────────────────────────────────────────────
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  // ─── Login dengan Google ──────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      // Sign out dulu agar selalu muncul picker akun
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user batal

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw 'Gagal mendapatkan token. Coba lagi.';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Simpan data ke Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'displayName': userCredential.user?.displayName ?? '',
        'email': userCredential.user?.email ?? '',
        'photoUrl': userCredential.user?.photoURL ?? '',
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('network')) throw 'Tidak ada koneksi internet.';
      if (msg.contains('canceled') || msg.contains('cancelled')) {
        throw 'Login dibatalkan.';
      }
      throw msg.replaceAll('Exception: ', '');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Update nama ──────────────────────────────────────────────────────────
  Future<void> updateName(String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    await _firestore.collection('users').doc(userId).set(
      {'displayName': newName},
      SetOptions(merge: true),
    );
  }

  // ─── Upload foto (Base64 ke Firestore) ───────────────────────────────────
  Future<String?> updatePhoto(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.lengthInBytes > 200000) {
      throw 'Foto terlalu besar. Pilih foto yang lebih kecil (maks 200KB).';
    }
    final base64Str = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Str';
    await _firestore.collection('users').doc(userId).set(
      {'photoBase64': dataUrl},
      SetOptions(merge: true),
    );
    return dataUrl;
  }

  // ─── Ambil profil dari Firestore ─────────────────────────────────────────
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ─── Pesan error ─────────────────────────────────────────────────────────
  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan ($code). Coba lagi.';
    }
  }
}
