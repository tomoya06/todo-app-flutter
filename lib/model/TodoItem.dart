class TodoItem {
  String content;
  bool isDone;

  TodoItem(String content) {
    this.content = content;
    this.isDone = false;
  }

  TodoItem.fromMap(Map<String, dynamic> map) {
    this.content = map['content'] as String;
    this.isDone = map['isDone'] as bool;
  }
}
