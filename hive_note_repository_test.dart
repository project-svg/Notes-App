// test/hive_note_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/hive_note_repository.dart';
import 'package:notes_app/services/note_repository.dart';

void main() {
  late HiveNoteRepository repo;

  setUpAll(() async {
    Hive.init('test/hive_test_db');
    Hive.registerAdapter(NoteAdapter());
  });

  setUp(() async {
    repo = HiveNoteRepository();
    await repo.init();
  });

  tearDown(() async {
    await repo.deleteAll();
    repo.dispose();
  });

  group('create', () {
    test('persists a note and returns it', () async {
      final note = Note(title: 'Hello', body: 'World');
      final created = await repo.create(note);

      expect(created.id, note.id);
      expect(created.title, 'Hello');
    });

    test('multiple notes accumulate', () async {
      await repo.create(Note(title: 'A', body: ''));
      await repo.create(Note(title: 'B', body: ''));
      await repo.create(Note(title: 'C', body: ''));

      final all = await repo.getAll();
      expect(all.length, 3);
    });
  });

  group('getAll', () {
    test('returns pinned notes first', () async {
      final n1 = await repo.create(Note(title: 'Normal', body: ''));
      final n2 = Note(title: 'Pinned', body: '', isPinned: true);
      await repo.create(n2);

      final all = await repo.getAll();
      expect(all.first.isPinned, true);
    });

    test('search filters by title and body', () async {
      await repo.create(Note(title: 'Flutter tips', body: ''));
      await repo.create(Note(title: 'Shopping list', body: 'Buy milk'));
      await repo.create(Note(title: 'Ideas', body: 'Flutter is great'));

      final results = await repo.getAll(searchQuery: 'flutter');
      expect(results.length, 2);
    });

    test('sort by title A-Z', () async {
      await repo.create(Note(title: 'Zebra', body: ''));
      await repo.create(Note(title: 'Apple', body: ''));
      await repo.create(Note(title: 'Mango', body: ''));

      final all = await repo.getAll(sort: SortOption.titleAsc);
      expect(all.map((n) => n.title).toList(), ['Apple', 'Mango', 'Zebra']);
    });
  });

  group('update', () {
    test('updates title and bumps updatedAt', () async {
      final original = await repo.create(Note(title: 'Old', body: 'Body'));
      await Future.delayed(const Duration(milliseconds: 10));

      final updated = original.copyWith(title: 'New');
      final result = await repo.update(updated);

      expect(result.title, 'New');
      expect(result.updatedAt.isAfter(original.createdAt), true);
    });

    test('throws when note does not exist', () async {
      final ghost = Note(title: 'Ghost', body: '');
      expect(() => repo.update(ghost), throwsException);
    });
  });

  group('archive / restore', () {
    test('archived note excluded from getAll', () async {
      final note = await repo.create(Note(title: 'Temp', body: ''));
      await repo.archive(note.id);

      final all = await repo.getAll();
      expect(all.where((n) => n.id == note.id), isEmpty);
    });

    test('restore brings note back', () async {
      final note = await repo.create(Note(title: 'Restore me', body: ''));
      await repo.archive(note.id);
      await repo.restore(note.id);

      final all = await repo.getAll();
      expect(all.where((n) => n.id == note.id).length, 1);
    });
  });

  group('delete', () {
    test('permanently removes a note', () async {
      final note = await repo.create(Note(title: 'Delete me', body: ''));
      await repo.delete(note.id);

      final found = await repo.getById(note.id);
      expect(found, isNull);
    });
  });

  group('togglePin', () {
    test('pins and unpins', () async {
      final note = await repo.create(Note(title: 'Pin me', body: ''));
      expect(note.isPinned, false);

      final pinned = await repo.togglePin(note.id);
      expect(pinned.isPinned, true);

      final unpinned = await repo.togglePin(note.id);
      expect(unpinned.isPinned, false);
    });
  });
}
