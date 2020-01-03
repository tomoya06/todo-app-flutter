import 'dart:developer';

import 'package:flutter/material.dart';

import 'model/TodoItem.dart';

void main() => runApp(TodoApp());

class TodoAppInheritedWidget extends InheritedWidget {
  final TodoAppState state;

  TodoAppInheritedWidget({this.state, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static TodoAppInheritedWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TodoAppInheritedWidget>();
}

class TodoApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoAppState();
}

class TodoAppState extends State<TodoApp> {
  final todoList = <TodoItem>[];
  bool isEditMode = false;

  editTodo(int index, TodoItem newTodoItem) {
    setState(() {
      this.todoList[index] = newTodoItem;
    });
  }

  deleteTodo(int index) {
    setState(() {
      this.todoList.removeAt(index);
    });
  }

  addNewTodo(TodoItem newTodoItem) {
    setState(() {
      this.todoList.add(newTodoItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TodoAppInheritedWidget(
      state: this,
      child: MaterialApp(
        title: "To-Do List",
        home: Scaffold(
          appBar: AppBar(
            title: Text('To-Do List'),
            actions: <Widget>[
              IconButton(
                icon: !this.isEditMode
                    ? Icon(Icons.delete_outline)
                    : Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    this.isEditMode = !this.isEditMode;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: TodoList(),
              ),
              !isEditMode
                  ? Container(
                      height: 64,
                      child: NewTodoInput(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    final todoList = context
        .dependOnInheritedWidgetOfExactType<TodoAppInheritedWidget>()
        .state
        .todoList;

    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return TodoListItem(
          key: UniqueKey(),
          index: index,
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: todoList.length,
    );
  }
}

class TodoListItem extends StatefulWidget {
  final int index;

  const TodoListItem({Key key, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TodoListItemState();
}

class TodoListItemState extends State<TodoListItem> {
  bool _isEditing = false;
  final _editController = TextEditingController();

  _triggerEditTodo(TodoAppState state, int index, TodoItem old) {
    final newTodoItem = TodoItem(_editController.text);
    newTodoItem.isDone = old.isDone;
    state.editTodo(index, newTodoItem);
  }

  _triggerDone(TodoAppState state, int index, bool value, TodoItem old) {
    final newTodoItem = TodoItem(old.content);
    newTodoItem.isDone = value;
    state.editTodo(index, newTodoItem);
  }

  _triggerDelete(TodoAppState state, int index) {
    state.deleteTodo(index);
  }

  final _doneTextStyle = TextStyle(
    decoration: TextDecoration.lineThrough,
    color: Colors.black38,
  );

  @override
  Widget build(BuildContext context) {
    final todoManagerState = context
        .dependOnInheritedWidgetOfExactType<TodoAppInheritedWidget>()
        .state;
    final todoList = todoManagerState.todoList;
    final todoItem = todoList[widget.index];
    final bool isEditMode = todoManagerState.isEditMode;

    return ListTile(
      leading: !isEditMode
          ? Checkbox(
              value: todoItem.isDone,
              onChanged: (value) {
                _triggerDone(todoManagerState, widget.index, value, todoItem);
              },
            )
          : IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              onPressed: () {
                _triggerDelete(todoManagerState, widget.index);
              },
            ),
      title: !_isEditing
          ? Text(
              todoItem.content,
              style: !todoItem.isDone ? null : _doneTextStyle,
            )
          : TextField(
              controller: _editController,
            ),
      trailing: !_isEditing
          ? null
          : IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _triggerEditTodo(todoManagerState, widget.index, todoItem);
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
  @override
  State<StatefulWidget> createState() => NewTodoInputState();
}

class NewTodoInputState extends State<NewTodoInput> {
  final inputController = TextEditingController();

  void _submitNewTodo(TodoAppState state) {
    log(inputController.text);
    if (inputController.text.isNotEmpty) {
      final newTodo = TodoItem(inputController.text);
      state.addNewTodo(newTodo);
      inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoManagerState = context
        .dependOnInheritedWidgetOfExactType<TodoAppInheritedWidget>()
        .state;

    return Container(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
        ),
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
              child: IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  _submitNewTodo(todoManagerState);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
