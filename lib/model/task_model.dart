import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String task;
  bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.task,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      task: map['task'] ?? '',
      isCompleted: map['isCompleted'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
