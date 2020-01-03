import 'dart:developer';

import 'package:flutter/material.dart';

import './TodoItem.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To-Do List",
      home: Scaffold(
        appBar: AppBar(
          title: Text('To-Do List'),
        ),
        body: TodoManager(),
      ),
    );
  }
}

class TodoManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoManagerState();

}

class TodoManagerState extends State<TodoManager> {

  void _triggerAddNewTodoItem() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: TodoList(),
        ),
        Container(
          height: 64,
          child: NewTodoInput(),
        ),
      ],
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final todoList = <TodoItem>[
    TodoItem("hello"),
  ];

  void addTodoItem(String newTodoContent) {
    final newTodo = new TodoItem(newTodoContent);
    todoList.add(newTodo);
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        if (index >= todoList.length) {
          return null;
        }
        return _buildRow(todoList[index]);
      },
    );
  }

  Widget _buildRow(TodoItem item) {
    return ListTile(
      title: Text(
        item.content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }
}

class NewTodoInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewTodoInputState();
}

class NewTodoInputState extends State<NewTodoInput> {
  final inputController = TextEditingController();

  void _submitNewTodo() {
    log(inputController.text);
    if (inputController.text.isNotEmpty) {
      // todo: submit new todo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: TextField(
              controller: inputController,
              decoration: const InputDecoration(
                hintText: 'Create a new To-Do item',
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: RaisedButton(
              child: Text('Submit'),
              onPressed: _submitNewTodo,
            ),
          )
        ],
      ),
    );
  }
}
