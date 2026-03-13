import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_management_app/model/project_model.dart';
import 'package:project_management_app/pages/add_project_page.dart';
import 'package:project_management_app/pages/task_details_page.dart';
import 'package:project_management_app/providers/auth_provider.dart';
import 'package:project_management_app/providers/project_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You've been logged out...")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong...")));
    }
  }

  void onTapProject(ProjectModel project) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProjectDetailPage(project: project),
          ),
        )
        .then((_) {
          if (!mounted) return;
          context.read<ProjectProvider>().fetchProjects();
        });
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final authProvider = Provider.of<ProjectAuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 183, 208, 250),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        shape: CircleBorder(),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddProjectPage()));
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: projectProvider.isLoading
            ? Center(child: const CircularProgressIndicator())
            : projectProvider.projects.isEmpty
            ? const Center(child: Text('You do not have any project...'))
            : Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 10,
                  right: 10,
                ),

                child: ListView.builder(
                  itemCount: projectProvider.projects.length,
                  itemBuilder: (context, index) {
                    final project = projectProvider.projects[index];
                    String projectId = project.id ?? "";

                    Color projectPriority = project.priority == 1
                        ? Colors.red
                        : project.priority == 2
                        ? Colors.yellow
                        : Colors.green;

                    return Dismissible(
                      key: Key(projectId),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        projectProvider.deleteProject(projectId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Project deleted...")),
                        );
                      },
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Project'),
                            content: Text(
                              "Are you sure to delete this project...",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      background: Container(color: Colors.transparent),
                      secondaryBackground: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () => onTapProject(project),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: projectPriority.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: projectPriority.withValues(alpha: 0.5),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    project.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 22,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      project.progress == 0
                                          ? 'TODO'
                                          : project.progress == 100
                                          ? "Completed"
                                          : "Pending",
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                project.description,
                                style: TextStyle(
                                  color: const Color.fromARGB(221, 45, 44, 44),
                                  fontSize: 18,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Auther: ${project.createdBy}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy, hh:mm a',
                                    ).format(project.createdAt),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
