import 'package:flutter_tdd_todos/entity/todo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default value test', () {
    final todo = Todo();
    expect(todo.id, isNull);
    expect(todo.label, isEmpty);
    expect(todo.completed, isFalse);
  });
  test('from json test', () {
    final json = {
      'id': 1,
      'label': 'hoge',
      'completed': true,
    };
    final todo = Todo.fromJson(json);
    expect(todo.id, 1);
    expect(todo.label, equals('hoge'));
    expect(todo.completed, isTrue);
  });
  test('to json test', () {
    final todo = Todo(id: 1, label: 'hoge', completed: true);
    final json = todo.toJson();
    expect(todo.id, json['id']);
    expect(todo.label, json['label']);
    expect(todo.completed, json['completed']);
  });
  test('copy method test', () {
    final todo = Todo(id: 10, label: 'TODO', completed: true);
    final todoCopy = todo.copyWith(id: 100);
    expect(todoCopy, [
      isA<Todo>()
        ..having((e) => e.id != todoCopy.id, 'id', isTrue)
        ..having((e) => e.label, 'label', todo.label)
        ..having((e) => e.completed, 'completed', todo.completed),
    ]);
  });
}
