import 'dart:developer';

import 'package:flutter/material.dart';

import 'model/TodoItem.dart';

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
  _triggerAddNewTodoItem(TodoItem newTodoItem) {
    setState(() {
      this.todoList.add(newTodoItem);
    });
  }

  _triggerDeleteTodoItem() {}

  _triggerModifyTodoItem(int index, TodoItem newTodoItem) {}

  final todoList = <TodoItem>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: TodoList(
            todoList: todoList,
          ),
        ),
        Container(
          height: 64,
          child: NewTodoInput(
            triggerAddNew: this._triggerAddNewTodoItem,
          ),
        ),
      ],
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();

  final todoList;

//  final triggerModify;
//  final triggerDelete;

  TodoList({
    @required this.todoList,
//    @required this.triggerModify,
//    @required this.triggerDelete,
  });
}

class TodoListState extends State<TodoList> {
  Widget _buildList() {
    final todoList = widget.todoList;
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        if (index >= todoList.length) {
          return null;
        }
        return TodoListItem(
          key: UniqueKey(),
          todoItem: todoList[index],
//          triggerDelete: widget.triggerDelete,
//          triggerModify: widget.triggerModify,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }
}

class TodoListItem extends StatefulWidget {
  final TodoItem todoItem;

//  final triggerModify;
//  final triggerDelete;

  @override
  State<StatefulWidget> createState() => TodoListItemState();

  TodoListItem({
    @required Key key,
    @required this.todoItem,
//    @required this.triggerModify,
//    @required this.triggerDelete,
  }) : super(key: key);
}

class TodoListItemState extends State<TodoListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        this.widget.todoItem.content,
      ),
    );
  }
}

class NewTodoInput extends StatefulWidget {
  final triggerAddNew;

  @override
  State<StatefulWidget> createState() => NewTodoInputState();

  NewTodoInput({
    @required this.triggerAddNew,
  });
}

class NewTodoInputState extends State<NewTodoInput> {
  final inputController = TextEditingController();

  void _submitNewTodo() {
    log(inputController.text);
    if (inputController.text.isNotEmpty) {
      final newTodo = TodoItem(inputController.text);
      widget.triggerAddNew(newTodo);
      inputController.clear();
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
