import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_management_app/model/task_model.dart';

class ProjectModel {
  final String? id;
  final String title;
  final String description;
  List<TaskModel> tasks;
  final int priority;
  int status;
  final String createdBy;
  final DateTime createdAt;

  ProjectModel({
    this.id,
    required this.title,
    required this.description,
    required this.tasks,
    required this.priority,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  double get progress {
    if (tasks.isEmpty) return 0.0;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    return (completedTasks / tasks.length) * 100;
  }

  ProjectModel copyWith({String? id}) {
    return ProjectModel(
      id: id ?? this.id,
      title: title,
      description: description,
      tasks: tasks,
      priority: priority,
      status: status,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Title": title,
      "CreatedBy": createdBy,
      "Description": description,
      'Tasks': tasks.map((task) => task.toJson()).toList(),
      "Priority": priority,
      'Status': status,
      "CreatedAt": Timestamp.fromDate(createdAt),
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      title: map['Title']?.toString() ?? 'Untitled',
      description: map['Description']?.toString() ?? '',
      tasks:
          (map['Tasks'] as List<dynamic>?)
              ?.map(
                (item) => TaskModel.fromJson(item as Map<String, dynamic>, id),
              )
              .toList() ??
          [],
      priority: map['Priority'] is int ? map['Priority'] : 3,
      status: map['Status'] is int ? map['Status'] : 0,
      createdBy: map['CreatedBy'],
      createdAt: (map['CreatedAt'] as Timestamp).toDate(),
    );
  }
}
