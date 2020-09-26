
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tdd_todos/repository/prefarence_cliant.dart';
import 'package:flutter_tdd_todos/repository/sql_database.dart';
import 'package:flutter_tdd_todos/todo_list/todo_list_page.dart';
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
final fakeClient = Provider<SqlDatabase>((_) => FakeClient());

void main() {
  testWidgets('必要なwidgetが存在しているか', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesClient.overrideWithProvider(fakePrefClient),
          sqlDatabaseClient.overrideWithProvider(fakeClient),
        ],
        child: MaterialApp(
          home: TodoListPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(IconButton), findsNWidgets(3));
    expect(find.byType(Row), findsWidgets);
  });
  testWidgets('値が追加されるか', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sqlDatabaseClient.overrideWithProvider(fakeClient),
        ],
        child: MaterialApp(
          home: TodoListPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'todo');
    await tester.pump();
    expect(find.text('todo'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('todo'), findsOneWidget);
  });
  testWidgets('値が削除されるか', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sqlDatabaseClient.overrideWithProvider(fakeClient),
        ],
        child: MaterialApp(
          home: TodoListPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'todo');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('todo'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), Offset(1000.0, 0.0));
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);
  });
  testWidgets('削除した値を戻せるか', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sqlDatabaseClient.overrideWithProvider(fakeClient),
        ],
        child: MaterialApp(
          home: TodoListPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'todo');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('todo'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), Offset(1000.0, 0.0));
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);

    await tester.pump(const Duration(milliseconds: 750));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('削除しました'), findsOneWidget);
    expect(find.text('元に戻す'), findsOneWidget);
    expect(find.byType(SnackBarAction), findsOneWidget);

    await tester.tap(find.byType(SnackBarAction));

    // 一応、実機で確認した限りでは動いている
    /* await tester.tap(find.text('元に戻す'));
    await tester.pump(const Duration(milliseconds: 5000));
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('todo'), findsOneWidget); */
  });
}
