import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/notice.dart';

class ContentProvider extends ChangeNotifier {
  ContentProvider() {
    _seedInitialContent();
  }

  final _uuid = const Uuid();
  final List<Notice> _notices = [];

  List<Notice> get notices => List.unmodifiable(_notices);

  void _seedInitialContent() {
    if (_notices.isNotEmpty) return;
    _notices
      ..add(
        Notice(
          id: _uuid.v4(),
          title: 'Orientation Week Schedule',
          description:
              'Welcome new students! Check the full list of events happening across campus this week and plan ahead.',
          imageUrl:
              'https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?auto=format&fit=crop&w=600&q=80',
          deviceIds: const ['Lobby Display', 'Auditorium'],
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      )
      ..add(
        Notice(
          id: _uuid.v4(),
          title: 'Maintenance Downtime',
          description:
              'Digital boards in the science block will be offline tonight from 10:00 PM to 11:30 PM for maintenance.',
          imageUrl:
              'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=600&q=80',
          deviceIds: const ['Science Block'],
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        ),
      );
  }

  void addNotice(Notice notice) {
    final newNotice = notice.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    _notices.insert(0, newNotice);
    notifyListeners();
  }

  void updateNotice(Notice notice) {
    final index = _notices.indexWhere((item) => item.id == notice.id);
    if (index == -1) return;
    _notices[index] = notice;
    notifyListeners();
  }

  void deleteNotice(String id) {
    _notices.removeWhere((notice) => notice.id == id);
    notifyListeners();
  }
}
