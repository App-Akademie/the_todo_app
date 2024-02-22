import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_todo_app/data/todo_repository.dart';
import 'package:the_todo_app/domain/todo.dart';

// // Eine Liste von so genannten Records, einer speziellen Art von Tupeln :)
// final List<({String topic, bool isDone})> _defaultTodos = [
//   (topic: "Frühstücken", isDone: true),
//   (topic: "Clojure lernen", isDone: false),
//   (topic: "Vorlesung vorbereiten", isDone: true),
//   (topic: "Tasksheet vorbereiten", isDone: true),
//   (topic: "Lego bauen", isDone: false),
// ];

/// Todos um den Inhalt von Firestore zu ersetzen.
/// Die IDs werden auch von Firestore gesetzt und sind hier nur Platzhalter.
final List<Todo> _defaultTodos = [
  Todo(id: "UNUSED", topic: "Frühstücken", isDone: true),
  Todo(id: "UNUSED", topic: "Clojure lernen"),
  Todo(id: "UNUSED", topic: "Vorlesung vorbereiten", isDone: true),
  Todo(id: "UNUSED", topic: "Tasksheet vorbereiten", isDone: true),
  Todo(id: "UNUSED", topic: "Lego bauen"),
];

class FirebaseTodoRepository implements TodoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // @override
  // Stream<List<Todo>> get todos =>
  //     _firestore.collection('todos').snapshots().map((snapshot) => snapshot.docs
  //         .map((document) => Todo.fromFirestore(document))
  //         .toList());

  @override
  Stream<List<Todo>> get todos {
    final todoCollectionRef = _firestore.collection('todos');
    final todosSnapshot = todoCollectionRef.snapshots();
    final todosStream = todosSnapshot.map(
        (snapshot) => snapshot.docs.map((e) => Todo.fromFirestore(e)).toList());

    return todosStream;
  }

  // @override
  // Stream<List<Todo>> get todos {
  //   final todoCollectionRef = _firestore.collection('todos');
  //   final todosSnapshotStream = todoCollectionRef.snapshots();
  //   return todosSnapshotStream.map((snapshot) {
  //     final todoDocuments = snapshot.docs;
  //     final List<Todo> retrievedTodos = [];
  //     for (final todoDocument in todoDocuments) {
  //       retrievedTodos.add(Todo.fromFirestore(todoDocument));
  //     }

  //     return retrievedTodos;
  //   });
  // }

  Stream<List<Todo>> get openTodos => _firestore
      .collection('todos')
      .where("isDone", isEqualTo: false)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList());

  Stream<List<Todo>> get completedTodos {
    final todoCollectionRef = _firestore.collection('todos');
    final openTodoSnapshots =
        todoCollectionRef.where("isDone", isEqualTo: true).snapshots();
    final openTodoStream = openTodoSnapshots.map(
        (snapshot) => snapshot.docs.map((e) => Todo.fromFirestore(e)).toList());

    return openTodoStream;
  }

  // Stream<List<Todo>> get completedTodos {
  //   final CollectionReference<Map<String, dynamic>> todoCollectionRef =
  //       _firestore.collection('todos');
  //   final Stream<QuerySnapshot<Map<String, dynamic>>> openTodoSnapshots =
  //       todoCollectionRef.where("isDone", isEqualTo: true).snapshots();
  //   final Stream<List<Todo>> openTodoStream = openTodoSnapshots.map(
  //       (snapshot) => snapshot.docs.map((e) => Todo.fromFirestore(e)).toList());

  //   return openTodoStream;
  // }

  Future<List<Todo>> getThreeTodos() =>
      _firestore.collection('todos').limit(3).get().then((snapshot) =>
          snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList());

  /// Computed property um die Todos einmalig zu holen.
  Future<List<Todo>> get todosOnce => _firestore.collection('todos').get().then(
      (snapshot) => snapshot.docs.map((e) => Todo.fromFirestore(e)).toList());

  /// Funktion um die Todos einmal zu holen.
  Future<List<Todo>> getTodosOnce() async {
    final snapshot = await _firestore.collection('todos').get();
    final todos = snapshot.docs.map((e) => Todo.fromFirestore(e)).toList();

    return todos;
  }

  // @override
  // Stream<List<Todo>> get todos {
  //   final todoCollectionRef = _firestore.collection('todos');
  //   final todosSnapshotStream = todoCollectionRef.snapshots();
  //   return todosSnapshotStream.map((snapshot) {
  //     final todoDocuments = snapshot.docs;
  //     final List<Todo> retrievedTodos = [];
  //     for (final todoDocument in todoDocuments) {
  //       retrievedTodos.add(Todo.fromFirestore(todoDocument));
  //     }

  //     return retrievedTodos;
  //   });
  // }

  // @override
  // Stream<List<Todo>> get todos {
  //   final CollectionReference<Map<String, dynamic>> todoCollectionRef =
  //       _firestore.collection('todos');
  //   final Stream<QuerySnapshot<Map<String, dynamic>>> todosSnapshotStream =
  //       todoCollectionRef.snapshots();

  //   final Stream<List<Todo>> todosStream = todosSnapshotStream.map((snapshot) {
  //     final List<QueryDocumentSnapshot<Map<String, dynamic>>> todoDocuments =
  //         snapshot.docs;
  //     final List<Todo> retrievedTodos = [];
  //     for (final QueryDocumentSnapshot<Map<String, dynamic>> todoDocument
  //         in todoDocuments) {
  //       retrievedTodos.add(Todo.fromFirestore(todoDocument));
  //     }

  //     return retrievedTodos;
  //   });

  //   return todosStream;
  // }

  // Future<Todo> getTodo(String todoId) async {
  //   final todoCollection = _firestore.collection('todos');
  //   final todoDocument = await todoCollection.doc(todoId).get();
  //   final todo = Todo.fromFirestore(todoDocument);

  //   return todo;
  // }

  Future<Todo> getTodo(String todoId) async => Todo.fromFirestore(
      await _firestore.collection('todos').doc(todoId).get());

  @override
  Future<void> setTodoCompletion(Todo todoToChange, bool isDone) async {
    final todoCollectionRef = _firestore.collection('todos');
    await todoCollectionRef.doc(todoToChange.id).update({
      'isDone': isDone,
    });
  }

  @override
  void resetTodos() {
    final todoCollectionRef = _firestore.collection('todos');
    todoCollectionRef.get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    }).then((_) {
      for (final todo in _defaultTodos) {
        todoCollectionRef.add(todo.toMap());
        // todoCollectionRef.add({
        //   'topic': todo.topic,
        //   'isDone': todo.isDone,
        // });
      }
    });
  }

  void setTodosWithId() {
    final todoCollectionRef = _firestore.collection('todos');

    for (int i = 0; i < _defaultTodos.length; i++) {
      // Beispiel:
      // todoCollectionRef.doc("0").set({
      //   "topic": "Gassi gehen",
      //   "isDone": false,
      // });
      todoCollectionRef.doc(i.toString()).set(_defaultTodos[i].toMap());
    }
  }

  @override
  void deleteTodo(Todo todo) {
    final todoCollectionRef = _firestore.collection('todos');
    todoCollectionRef.doc(todo.id).delete();
  }
}
