import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  Todo({required this.id, required this.topic, this.isDone = false});

  /// Damit kann ein Todo eindeutig identifiziert werden.
  /// Wird der ID aus Firestore zugewiesen.
  final String id;

  /// Was erledigt werden soll.
  final String topic;

  /// Ob das Todo gemacht wurde.
  bool isDone;

  /// Takes a data structure from firestore and creates a Todo object.
  factory Todo.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) throw ArgumentError("Document has no content");

    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      topic: data['topic'] as String,
      isDone: data['isDone'] as bool,
    );
  }

  /// Gibt NICHT die ID mit zurück. Diese soll automatisch generiert werden.
  Map<String, dynamic> toMap() {
    return {
      "topic": topic,
      "isDone": isDone,
    };
  }
}
