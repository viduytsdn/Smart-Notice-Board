import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/notice.dart';

class ContentService {
  ContentService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Stream<List<Notice>> streamNotices() {
    return _firestore
        .collection('notices')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Notice.fromDoc(doc)).toList());
  }

  Future<void> addNotice(Notice notice) async {
    await _firestore.collection('notices').add(notice.toJson());
  }

  Future<void> updateNotice(Notice notice) async {
    await _firestore.collection('notices').doc(notice.id).update(
          notice.toJson(),
        );
  }

  Future<void> deleteNotice(String id) async {
    await _firestore.collection('notices').doc(id).delete();
  }

  Future<String> uploadImage({
    required File file,
    required String adminId,
  }) async {
    final path = 'notices/$adminId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadWebImage({
    required Uint8List data,
    required String adminId,
    required String fileName,
  }) async {
    final path = 'notices/$adminId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(data);
    final snapshot = await uploadTask.whenComplete(() => null);
    return snapshot.ref.getDownloadURL();
  }
}
