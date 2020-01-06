import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './config.dart' as GLOBAL_CONFIG;
import './model/TodoItem.dart';

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

  Future<bool> uploadTodoListToGist(List<TodoList> list) async {
    final response = await http
        .patch('https://api.github.com/gists/fbc20c527bea8dbd27702add1d55f8c7');
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<TodoItem>> fetchTodoListFromGist() async {
    final response = await http.get(
        'https://api.github.com/gists/fbc20c527bea8dbd27702add1d55f8c7?client_id=${GLOBAL_CONFIG.CLIENT_ID}&client_secret=${GLOBAL_CONFIG.CLIENT_SECRET}');
    if (response.statusCode == 200) {
      final responseBody = response.body;
      Map<String, dynamic> bodyJson = jsonDecode(responseBody);
      final todoListFile = bodyJson['files']['todolist.json'];
      final fileRawData = todoListFile['content'];
      Map<String, dynamic> todoListFileJson = jsonDecode(fileRawData);

      log(fileRawData);

      if (todoListFileJson['updateTm'] == null ||
          todoListFileJson['list'] == null ||
          !(todoListFileJson['list'] is List)) {
        return [];
      }

      final todoItemClassList = <TodoItem>[];
      todoListFileJson['list'].forEach((item) {
        todoItemClassList.add(new TodoItem.fromMap(item));
      });
      return todoItemClassList;
    } else {
      log("error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TodoItem>>(
      future: fetchTodoListFromGist(),
      builder: (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
        Widget listBody;

        // network related
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            this.todoList.removeRange(0, this.todoList.length);
            this.todoList.addAll(snapshot.data);
          }
          listBody = TodoList();
        } else {
          listBody = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                ),
                child: Text("Fetching Data from Github..."),
              ),
            ],
          );
        }

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
                    child: listBody,
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
      },
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
          item: todoList[index],
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: todoList.length,
    );
  }
}

class TodoListItem extends StatefulWidget {
  final int index;
  final TodoItem item;

  const TodoListItem({Key key, @required this.index, @required this.item})
      : super(key: key);

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
    final todoItem = widget.item;
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
