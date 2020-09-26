import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tdd_todos/entity/todo.dart';
import 'package:flutter_tdd_todos/todo_list/todo_list.dart';

class TodoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read(todoListController).initState();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo LIST'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: context.read(todoListController).sortOrderChange,
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: context.read(todoListController).onlyCompleteChange,
          )
        ],
      ),
      body: TodoList(),
    );
  }
}

final _currentTodo = ScopedProvider<Todo>((_) => null);

class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context,
      T Function<T>(ProviderBase<Object, T> provider) watch) {
    final list = watch(todoList).state;
    final textEditor = TextEditingController();

    if (list == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0)
          return Row(
            children: [
              Flexible(
                flex: 8,
                child: TextField(
                  controller: textEditor,
                ),
              ),
              Flexible(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    context
                        .read(todoListController)
                        .add(Todo(label: textEditor.text));
                    textEditor.text = '';
                  },
                ),
              )
            ],
          );
        else
          return ProviderScope(
            overrides: [
              _currentTodo.overrideWithValue(list[index - 1]),
            ],
            child: Dismissible(
              key: ObjectKey(list[index - 1]),
              child: TodoListTile(),
              onDismissed: (_) {
                final todo = list[index - 1];
                context.read(todoListController).delete(todo);
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('削除しました'),
                    action: SnackBarAction(
                      label: '元に戻す',
                      onPressed: () {
                        context.read(todoListController).add(todo);
                      },
                    ),
                  ),
                );
              },
            ),
          );
      },
      separatorBuilder: (_, __) => Divider(),
      itemCount: list.length + 1,
    );
  }
}

class TodoListTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context,
      T Function<T>(ProviderBase<Object, T> provider) watch) {
    final todo = watch(_currentTodo);
    return CheckboxListTile(
      title: Text(todo.label),
      value: todo.completed,
      onChanged: (val) => context.read(todoListController).update(
            todo.copyWith(completed: val),
          ),
    );
  }
}
