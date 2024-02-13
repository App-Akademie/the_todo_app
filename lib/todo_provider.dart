import 'package:flutter/material.dart';
import 'package:the_todo_app/firebase_todo_repository.dart';
import 'package:the_todo_app/todo.dart';
import 'package:the_todo_app/todo_repository.dart';

enum TodoProviderStatus { loading, loaded, error }

// Schritt 1: Provider erstellen
class TodoProvider extends ChangeNotifier {
  final TodoRepository _todoRepository = FirebaseTodoRepository();
  final List<Todo> _todos = [];
  TodoProviderStatus _todoProviderStatus = TodoProviderStatus.loading;

  // /// Das hier ist der State, der in allen Widgets verwendet werden soll.
  // /// Dafür muss er natürlich auch von den Widgets angepasst werden.
  // final List<Todo> _todos = [
  //   Todo(id: 0, topic: "Frühstücken", isDone: true),
  //   Todo(id: 1, topic: "Clojure lernen"),
  //   Todo(id: 2, topic: "Vorlesung vorbereiten", isDone: true),
  //   Todo(id: 3, topic: "Tasksheet vorbereiten", isDone: true),
  //   Todo(id: 4, topic: "Lego bauen"),
  // ];

  TodoProvider() {
    _loadTodos();
  }

  TodoProviderStatus get todoProviderStatus => _todoProviderStatus;
  List<Todo> get todos => _todos;

  Future<void> _loadTodos() async {
    try {
      final todos = await _todoRepository.todos;
      _todos.addAll(todos);
      _todoProviderStatus = TodoProviderStatus.loaded;
      notifyListeners();
    } catch (e) {
      _todoProviderStatus = TodoProviderStatus.error;
      notifyListeners();
    }
  }

  /// Gibt eine Liste von Todos zurück, die offen sind.
  List<Todo> get openTodos {
    final openTodos = <Todo>[];
    for (final todo in todos) {
      if (!todo.isDone) {
        openTodos.add(todo);
      }
    }
    return openTodos;
  }

  /// Gibt eine Liste von Todos zurück, die erledigt wurden.
  List<Todo> get doneTodos {
    final doneTodos = <Todo>[];
    for (final todo in todos) {
      if (todo.isDone) {
        doneTodos.add(todo);
      }
    }
    return doneTodos;
  }

  void toggleTodo(Todo todo) {
    Todo? todoToChange;
    // Todo finden, das angepasst werden muss.
    for (final currentTodo in todos) {
      if (currentTodo.id == todo.id) {
        todoToChange = currentTodo;
      }
    }
    // Todo anpassen :)
    todoToChange?.isDone = !(todoToChange.isDone);
    notifyListeners();
  }
}
