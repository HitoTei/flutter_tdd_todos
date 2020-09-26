import 'dart:math';

import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tdd_todos/entity/todo.dart';
import 'package:flutter_tdd_todos/repository/prefarence_cliant.dart';
import 'package:flutter_tdd_todos/repository/sql_database.dart';
import 'package:flutter_tdd_todos/repository/todo_repository.dart';
import 'package:flutter_tdd_todos/todo_list/todo_list.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClient implements SqlDatabase {
  final list = <Map<String, dynamic>>[Todo(id: 0).toJson()];

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
final fakeClient = Provider<SqlDatabase>((_) => FakeClient());

void main() {
  group('todo repository test', () {
    ProviderContainer container;
    setUp(() {
      container = ProviderContainer(
        overrides: [
          sharedPreferencesClient.overrideWithProvider(fakePrefClient),
          sqlDatabaseClient.overrideWithProvider(fakeClient),
        ],
      );
    });
    test('初期化ができるかテスト', () async {
      expect(container.read(todoList).state, isNull);
      container.read(todoListController).initState();

      await Future.delayed(Duration(milliseconds: 10));
      expect(container.read(todoList).state, isNotNull);
    });
    test('値を追加できるかテスト', () async {
      container.read(todoListController).initState();
      await Future.delayed(Duration(milliseconds: 10));

      container.read(todoListController).add(Todo());
      expect(container.read(todoList).state.length, 2);
    });
    test('値を削除できるかテスト', () async {
      container.read(todoListController).initState();
      await Future.delayed(Duration(milliseconds: 10));

      container.read(todoListController).delete(Todo(id: 0));
      expect(container.read(todoList).state, isNotNull);
      expect(container.read(todoList).state, isEmpty);
    });
    test('値が昇順にソートされるかテスト', () async {
      container.read(todoListController).initState();
      await Future.delayed(Duration(milliseconds: 10));
      for (int i = 0; i < 100; i++)
        container
            .read(todoListController)
            .add(Todo(id: Random().nextInt(10000)));
      final list = container.read(todoList).state;
      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].id <= list[i + 1].id, isTrue);
      }
    });
    test('値が降順にソートされるかテスト', () async {
      container.read(todoListController).initState();
      await Future.delayed(Duration(milliseconds: 10));
      container.read(todoListController).sortOrderChange();

      for (int i = 0; i < 100; i++)
        container
            .read(todoListController)
            .add(Todo(id: Random().nextInt(10000)));
      final list = container.read(todoList).state;
      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].id >= list[i + 1].id, isTrue);
      }
    });
    test('未完了のみ取得できるかテスト', () async {
      container.read(todoListController).initState();
      await Future.delayed(Duration(milliseconds: 10));

      for (int i = 0; i < 100; i++)
        container
            .read(todoListController)
            .add(Todo(completed: Random().nextBool()));
      final list = container.read(todoList).state;
      for (var value in list) {
        expect(value.completed, isFalse);
      }
    });
    test('データがリポジトリに反映されているかテスト', () async {
      container.read(todoListController).initState();
      await Future.delayed(Duration(milliseconds: 10));

      for (int i = 0; i < 100; i++)
        if (Random().nextBool()) container.read(todoListController).add(Todo());

      await Future.delayed(Duration(milliseconds: 10));
      expect(
        container.read(todoList).state.length ==
            (await container.read(todoRepository).getAll()).length,
        isTrue,
      );
    });
  });
}
