import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String get userId => _auth.currentUser?.uid ?? '';

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
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _authErrorMessage(e.code);
    }
  }

  Future<void> logout() async => await _auth.signOut();

  // Update nama
  Future<void> updateName(String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    // Simpan juga ke Firestore
    await _firestore.collection('users').doc(userId).set(
      {'displayName': newName},
      SetOptions(merge: true),
    );
  }

  // Upload foto → simpan sebagai Base64 di Firestore
  Future<String?> updatePhoto(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    // Resize: ambil max 200KB
    if (bytes.lengthInBytes > 200000) {
      throw 'Foto terlalu besar. Pilih foto yang lebih kecil.';
    }

    final base64Str = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Str';

    // Simpan ke Firestore
    await _firestore.collection('users').doc(userId).set(
      {'photoBase64': dataUrl},
      SetOptions(merge: true),
    );

    return dataUrl;
  }

  // Ambil data profil dari Firestore
  Future<Map<String, dynamic>?> getProfile() async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
