import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_management_app/pages/add_project_page.dart';
import 'package:project_management_app/providers/project_provider.dart';
import 'package:provider/provider.dart';
import '../model/project_model.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    final project = context
        .watch<ProjectProvider>()
        .filteredProjects
        .firstWhere(
          (p) => p.id == widget.project.id,
          orElse: () => widget.project,
        );

    Color priorityColor = project.priority == 1
        ? Colors.red
        : project.priority == 2
        ? Colors.orange
        : Colors.green;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 183, 208, 250),
      appBar: AppBar(
        title: const Text("Project Overview"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    // print(project.id);
                    return AddProjectPage(project: project);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          project.priority == 1 ? "High Priority" : "Normal",
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(project.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Progress: ${project.progress.toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: project.progress / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.deepPurple,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Project Tasks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            project.tasks.isEmpty
                ? const Center(child: Text("No tasks added yet"))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: project.tasks.length,
                    itemBuilder: (context, index) {
                      final task = project.tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) async {
                              task.isCompleted = value ?? false;
                              try {
                                await context
                                    .read<ProjectProvider>()
                                    .updateProject(project);
                              } catch (e) {
                                setState(() {
                                  task.isCompleted = !task.isCompleted;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to sync: $e")),
                                );
                              }
                            },
                          ),
                          title: Text(
                            task.task,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "Created: ${DateFormat('hh:mm a').format(task.createdAt)}",
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
