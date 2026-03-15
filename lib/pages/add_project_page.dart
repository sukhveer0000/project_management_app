import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/model/project_model.dart';
import 'package:project_management_app/model/task_model.dart';
import 'package:project_management_app/providers/project_provider.dart';
import 'package:provider/provider.dart';

class AddProjectPage extends StatefulWidget {
  final ProjectModel? project;
  const AddProjectPage({super.key, this.project});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedPriority = "Low";

  final taskController = TextEditingController();
  bool isAddingTask = false;
  List<TaskModel> tempTasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      titleController.text = widget.project!.title;
      descriptionController.text = widget.project!.description;
      selectedPriority = widget.project!.priority == 1
          ? 'High'
          : widget.project!.priority == 2
          ? 'Medium'
          : 'Low';
      tempTasks = widget.project!.tasks;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> onSave(ProjectModel project) async {
    if (widget.project != null) {
      try {
        await context.read<ProjectProvider>().updateProject(project);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating project: $e')));
        }
      }
    } else {
      try {
        await context.read<ProjectProvider>().addProject(project);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Project added...')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error adding project: $e")));
        }
      }
    }
  }

  Widget priorityWidget(String label) {
    bool isSelected = selectedPriority == label;
    Color baseColor = label == 'High'
        ? Colors.red
        : label == 'Medium'
        ? Colors.yellow
        : Colors.green;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriority = label;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : baseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: BoxBorder.all(
            color: isSelected ? baseColor : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    String firstLetterCapital(String value) {
      return value[0].toUpperCase() + value.substring(1);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 183, 208, 250),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: widget.project != null
            ? Text('Update project')
            : Text('Add project'),
        actions: [
          TextButton(
            onPressed: projectProvider.isLoading
                ? null
                : () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();
                    final cratedBy =
                        FirebaseAuth.instance.currentUser?.displayName ??
                        'User';
                    final createdAt = DateTime.now();
                    final project = ProjectModel(
                      id: widget.project?.id ?? '',
                      title: firstLetterCapital(title),
                      description: firstLetterCapital(description),
                      priority: selectedPriority == 'High'
                          ? 1
                          : selectedPriority == 'Medium'
                          ? 2
                          : 3,
                      createdBy: cratedBy,
                      createdAt: createdAt,
                      tasks: tempTasks,
                      status: 3,
                    );

                    await onSave(project);
                  },
            child: Text('Save', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        label: Text("Project title"),
                        hint: Text("Project title"),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            style: BorderStyle.solid,
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      minLines: 5,
                      maxLines: 10,
                      decoration: InputDecoration(
                        label: Text("Description"),
                        hint: Text("Description"),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            priorityWidget('Low'),
                            priorityWidget('Medium'),
                            priorityWidget('High'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Task",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  isAddingTask = !isAddingTask;
                                });
                              },
                              icon: Icon(
                                isAddingTask ? Icons.close : Icons.add,
                              ),
                              label: Text(isAddingTask ? 'Cancel' : 'Add Task'),
                            ),
                          ],
                        ),

                        if (isAddingTask)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: taskController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Task Name...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (taskController.text.isNotEmpty) {
                                    addTaskToList(taskController.text);
                                  }
                                },
                                icon: Icon(Icons.add),
                              ),
                            ],
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: tempTasks.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(tempTasks[index].task),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  tempTasks.removeAt(index);
                                });
                              },
                              icon: Icon(Icons.delete, color: Colors.red[300]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (projectProvider.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Saving Project...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void addTaskToList(String text) {
    final newTask = TaskModel(task: text, createdAt: DateTime.now());
    setState(() {
      tempTasks.add(newTask);
      taskController.clear();
      isAddingTask = false;
    });
  }
}
