import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tdd_todos/repository/sql_database.dart';

import '../entity/todo.dart';

final todoRepository =
    Provider<TodoRepository>((ref) => TodoRepositoryImpl(ref.read));

abstract class TodoRepository {
  Future<List<Todo>> getAll();
  Future<int> insert(Todo todo);
  Future<int> delete(Todo todo);
}

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this.reader);
  final Reader reader;

  @override
  Future<int> delete(Todo todo) =>
      reader(sqlDatabaseClient).delete(todo.toJson());

  @override
  Future<int> insert(Todo todo) =>
      reader(sqlDatabaseClient).insert(todo.toJson());

  @override
  Future<List<Todo>> getAll() async {
    final jsonList = await reader(sqlDatabaseClient).fetchAll();
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }
}
