import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tdd_todos/entity/todo.dart';
import 'package:flutter_tdd_todos/repository/prefarence_cliant.dart';
import 'package:flutter_tdd_todos/repository/todo_repository.dart';

enum SortOrder {
  ASC,
  DES,
}

final todoListController = Provider(
  (ref) => TodoListController(ref.read),
);
final todoList = StateProvider<List<Todo>>((ref) {
  final list = ref.watch(_todoList).state;
  if (list == null) return null;
  final order = ref.watch(_sortOrder).state;
  final onlyNotCompleted = ref.watch(_onlyNotCompleted).state;

  if (order == SortOrder.ASC)
    list.sort((a, b) => (a?.id ?? -1) - (b?.id ?? -1));
  else if (order == SortOrder.DES)
    list.sort((a, b) => (b?.id ?? -1) - (a?.id ?? -1));
  else
    throw ('Sort order is illegal value: $order');

  if (onlyNotCompleted)
    return list;
  else
    return list.where((todo) => !todo.completed).toList();
});

final _todoList = StateProvider<List<Todo>>((_) => null);
final _sortOrder = StateProvider((_) => SortOrder.ASC);
final _onlyNotCompleted = StateProvider((_) => false);

class TodoListController {
  TodoListController(this.read);
  final Reader read;

  Future<void> initState() async {
    read(_todoList).state = await read(todoRepository).getAll();
    read(_sortOrder).state = SortOrder
        .values[await read(sharedPreferencesClient).getSortOrderIndex() ?? 0];
    read(_onlyNotCompleted).state =
        await read(sharedPreferencesClient).getOnlyNotCompleted() ?? false;
  }

  void add(Todo todo) {
    final list = read(_todoList).state;
    final id = read(todoRepository).insert(todo);
    id.then((value) {
      list.add(todo.copyWith(id: value));
      read(_todoList).state = list;
    });
  }

  void update(Todo todo) {
    final list = read(_todoList).state;
    read(todoRepository).insert(todo);
    int index = -1;
    for (int i = 0; i < list.length; i++) {
      if (list[i].id == todo.id) {
        index = i;
        break;
      }
    }
    list[index] = todo;
    read(_todoList).state = list;
  }

  void delete(Todo todo) {
    final list = read(_todoList).state;
    list.remove(todo);
    read(todoRepository).delete(todo);
    read(_todoList).state = list;
  }

  void sortOrderChange() {
    final order = read(_sortOrder).state;
    if (order == SortOrder.ASC)
      read(_sortOrder).state = SortOrder.DES;
    else if (order == SortOrder.DES)
      read(_sortOrder).state = SortOrder.ASC;
    else
      throw ('Sort order is illegal value: $order');

    read(sharedPreferencesClient).saveSortOrderIndex(
      SortOrder.values.indexOf(read(_sortOrder).state),
    );
  }

  void onlyCompleteChange() {
    read(_onlyNotCompleted).state = !read(_onlyNotCompleted).state;
    read(sharedPreferencesClient).saveOnlyNotCompleted(
      read(_onlyNotCompleted).state,
    );
  }
}
