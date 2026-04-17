import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';

class ActivityService {
  static const _boxName = 'activities';
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Box<Activity> get _box => Hive.box<Activity>(_boxName);

  // ─── Buka box Hive (panggil sekali di main) ───────────────────────────────
  static Future<void> init() async {
    await Hive.openBox<Activity>(_boxName);
  }

  // ─── Ambil semua aktivitas user dari Hive (lokal) ─────────────────────────
  List<Activity> getAll(String userId) {
    return _box.values.where((a) => a.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ─── Simpan aktivitas baru ────────────────────────────────────────────────
  Future<void> add({
    required String userId,
    required String name,
    required int durationMinutes,
    required int calories,
    required int reps,
  }) async {
    final activity = Activity(
      id: _uuid.v4(),
      name: name,
      durationMinutes: durationMinutes,
      calories: calories,
      reps: reps,
      date: DateTime.now(),
      userId: userId,
      synced: false,
    );

    // 1. Simpan lokal dulu (selalu berhasil)
    await _box.put(activity.id, activity);

    // 2. Coba sync ke Firestore jika ada internet
    await _syncOne(activity);
  }

  // ─── Hapus aktivitas ──────────────────────────────────────────────────────
  Future<void> delete(Activity activity) async {
    // Hapus dari Hive
    await activity.delete();

    // Hapus dari Firestore jika ada internet
    final online = await _isOnline();
    if (online) {
      await _firestore
          .collection('users')
          .doc(activity.userId)
          .collection('activities')
          .doc(activity.id)
          .delete();
    }
  }

  // ─── Sync semua data lokal yang belum tersync ke Firestore ────────────────
  Future<void> syncPending(String userId) async {
    final online = await _isOnline();
    if (!online) return;

    final unsynced =
        _box.values.where((a) => a.userId == userId && !a.synced).toList();

    for (final activity in unsynced) {
      await _syncOne(activity);
    }
  }

  // ─── Ambil data terbaru dari Firestore ke Hive ───────────────────────────
  Future<void> fetchFromFirestore(String userId) async {
    final online = await _isOnline();
    if (!online) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .orderBy('date', descending: true)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = data['id'] as String;
      // Simpan ke Hive jika belum ada
      if (!_box.containsKey(id)) {
        final activity = Activity.fromFirestore(data);
        await _box.put(id, activity);
      }
    }
  }

  // ─── Internal: sync satu aktivitas ke Firestore ───────────────────────────
  Future<void> _syncOne(Activity activity) async {
    final online = await _isOnline();
    if (!online) return;

    try {
      await _firestore
          .collection('users')
          .doc(activity.userId)
          .collection('activities')
          .doc(activity.id)
          .set(activity.toFirestore());

      // Tandai sudah tersync
      activity.synced = true;
      await activity.save();
    } catch (_) {
      // Gagal sync — akan dicoba lagi nanti lewat syncPending
    }
  }

  // ─── Cek koneksi internet ────────────────────────────────────────────────
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ─── Stream untuk rebuild UI otomatis saat data Hive berubah ─────────────
  Stream<BoxEvent> get watchBox => _box.watch();
}
