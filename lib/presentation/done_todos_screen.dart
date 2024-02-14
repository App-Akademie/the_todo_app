import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_todo_app/presentation/todo_list_item.dart';
import 'package:the_todo_app/presentation/todo_model.dart';

class DoneTodosScreen extends StatelessWidget {
  const DoneTodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final provider = context.watch<TodoProvider>();
    final TodoModel model = Provider.of<TodoModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Open Todos",
          style: TextStyle(fontSize: 32),
        ),
        backgroundColor: Colors.lightBlue[500],
      ),
      body: ListView.builder(
        itemCount: model.doneTodos.length,
        itemBuilder: (context, index) {
          return TodoListItem(todo: model.doneTodos[index]);
        },
      ),
    );
  }
}