import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_management_app/model/project_model.dart';
import 'package:project_management_app/pages/add_project_page.dart';
import 'package:project_management_app/pages/project_details_page.dart';
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 10,

        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.purple.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  onChanged: (value) =>
                      context.read<ProjectProvider>().setSearchQuery(value),
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              PopupMenuButton<SortType>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.filter_list,
                  //  color: Colors.deepPurple
                ),
                onSelected: (result) =>
                    context.read<ProjectProvider>().sortProjects(result),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: SortType.date,
                    child: Text('Date'),
                  ),
                  const PopupMenuItem(
                    value: SortType.progress,
                    child: Text('Progress'),
                  ),
                  const PopupMenuItem(
                    value: SortType.priority,
                    child: Text('Priority'),
                  ),
                ],
              ),

              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.logout,
                  // color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => authProvider.logout(),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
        
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
            : projectProvider.filteredProjects.isEmpty
            ? const Center(child: Text('You do not have any project...'))
            : Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 10,
                  right: 10,
                ),

                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: projectProvider.filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project =
                              projectProvider.filteredProjects[index];
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
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
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
                                    color: projectPriority.withValues(
                                      alpha: 0.5,
                                    ),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                        color: const Color.fromARGB(
                                          221,
                                          45,
                                          44,
                                          44,
                                        ),
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
                  ],
                ),
              ),
      ),
    );
  }
}
