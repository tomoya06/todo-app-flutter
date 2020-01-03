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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => {
                // TODO: edit mode
              },
            )
          ],
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

  _triggerDeleteTodoItem(int index) {
    setState(() {
      this.todoList.removeAt(index);
    });
  }

  _triggerModifyTodoItem(int index, TodoItem newTodoItem) {
    setState(() {
      this.todoList.removeAt(index);
      this.todoList.insert(index, newTodoItem);
    });
  }

  final todoList = <TodoItem>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: TodoList(
            todoList: todoList,
            triggerModify: this._triggerModifyTodoItem,
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

  final triggerModify;
//  final triggerDelete;

  TodoList({
    @required this.todoList,
//    @required this.triggerModify,
    @required this.triggerModify,
  });
}

class TodoListState extends State<TodoList> {
  Widget _buildList() {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return TodoListItem(
          key: UniqueKey(),
          todoItem: widget.todoList[index],
          index: index,
          triggerModify: widget.triggerModify,
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: widget.todoList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }
}

class TodoListItem extends StatefulWidget {
  final TodoItem todoItem;
  final int index;
  final triggerModify;

  @override
  State<StatefulWidget> createState() => TodoListItemState();

  _doTriggerModify(TodoItem item) {
    this.triggerModify(this.index, item);
  }

  triggerDone(bool value) {
    TodoItem newTodoItem = TodoItem(todoItem.content);
    newTodoItem.isFinished = value;
    _doTriggerModify(newTodoItem);
  }

  triggerEditContent(String value) {
    TodoItem newTodoItem = TodoItem(value);
    newTodoItem.isFinished = todoItem.isFinished;
    _doTriggerModify(newTodoItem);
  }

  TodoListItem({
    @required Key key,
    @required this.todoItem,
    @required this.index,
    @required this.triggerModify,
  }) : super(key: key);
}

class TodoListItemState extends State<TodoListItem> {
  bool _isEditing = false;
  final _editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoItem = this.widget.todoItem;
    return ListTile(
      leading: Checkbox(
        value: todoItem.isFinished,
        onChanged: this.widget.triggerDone,
      ),
      title: !_isEditing ? Text(
        todoItem.content,
      ) : TextField(
        controller: _editController,
      ),
      trailing: !_isEditing ? null : IconButton(
        icon: Icon(Icons.send),
        onPressed: () {
          this.widget.triggerEditContent(_editController.text);
        },
      ),
      onLongPress: () {
        _editController.text = todoItem.content;
        setState(() {
          this._isEditing = true;
        });
      },
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
