import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tdd_todos/entity/todo.dart';
import 'package:flutter_tdd_todos/repository/prefarence_cliant.dart';
import 'package:flutter_tdd_todos/repository/sql_database.dart';
import 'package:flutter_tdd_todos/repository/todo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClient implements SqlDatabase {
  final list = <Map<String, dynamic>>[];

  int id = 0;

  @override
  Future<int> delete(Map<String, dynamic> todo) async {
    list.removeAt(0);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll() async {
    return list;
  }

  @override
  Future<int> insert(Map<String, dynamic> todo) async {
    if (todo['id'] == null) todo['id'] = ++id;
    list.add(todo);
    return id;
  }
}

class FakePrefClient implements SharedPreferencesClient {
  @override
  Future<bool> getOnlyNotCompleted() async => false;
  @override
  Future<int> getSortOrderIndex() async => 0;
  @override
  Future<void> saveOnlyNotCompleted(bool val) {}
  @override
  Future<void> saveSortOrderIndex(int index) {}
}

final fakePrefClient =
    Provider<SharedPreferencesClient>((_) => FakePrefClient());
final fakeDbClient = Provider<SqlDatabase>((_) => FakeClient());

void main() {
  group('todo repository test', () {
    ProviderContainer container;
    setUp(() {
      container = ProviderContainer(
        overrides: [
          sharedPreferencesClient.overrideWithProvider(fakePrefClient),
          sqlDatabaseClient.overrideWithProvider(fakeDbClient),
        ],
      );
    });

    test('リストの長さが増えるかテスト', () async {
      for (int i = 0; i < 100; i++)
        await container.read(todoRepository).insert(Todo());
      final list = await container.read(todoRepository).getAll();
      expect(list, isNotNull);
      expect(list.length, equals(100));
    });

    test('情報が落ちていないかテスト', () async {
      final todo1 = Todo(id: 3, label: 'completed', completed: true);
      final todo2 = Todo(id: 100, label: 'HOGE', completed: false);
      final todo3 = Todo(id: 129021, label: 'お疲れ様です❤', completed: true);

      await container.read(todoRepository).insert(todo1);
      await container.read(todoRepository).insert(todo2);
      await container.read(todoRepository).insert(todo3);

      final list = await container.read(todoRepository).getAll();
      expect(list, contains(todo1));
      expect(list, contains(todo2));
      expect(list, contains(todo3));
    });

    test('値が削除されるかテスト', () async {
      expect(await container.read(todoRepository).getAll(), isEmpty);
      for (int i = 0; i < 1000; i++)
        await container.read(todoRepository).insert(Todo());

      expect(
        (await container.read(todoRepository).getAll()).length,
        equals(1000),
      );
      await container.read(todoRepository).delete(Todo());

      final list = await container.read(todoRepository).getAll();
      expect(list.length, equals(999));
    });
  });
}
