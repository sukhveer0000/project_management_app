import 'package:flutter/material.dart';
import 'package:project_management_app/model/project_model.dart';
import 'package:project_management_app/repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final _repository = ProjectsRepository();
  List<ProjectModel> _projects = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<ProjectModel> get filteredProjects {
    if (_searchQuery.isEmpty) {
      return _projects;
    }
    return _projects.where((project) {
      return project.title.toLowerCase().contains(_searchQuery) ||
          project.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await _repository.fetchProjects();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      // print(projects.length);
    }
  }

  Future<void> addProject(ProjectModel project) async {
    _isLoading = true;
    notifyListeners();
    try {
      final addedProject = await _repository.addProject(project);
      _projects.insert(0, addedProject);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(ProjectModel updateProject) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProject(updateProject);
      int index = _projects.indexWhere(
        (project) => project.id == updateProject.id,
      );
      if (index != -1) {
        _projects[index] = updateProject;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);

      _projects.removeWhere((project) => project.id == projectId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed deleting project: $e');
    }
  }

  void sortProjects(SortType type) {
    switch (type) {
      case SortType.date:
        _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.priority:
        _projects.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case SortType.progress:
        _projects.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }
    notifyListeners();
  }
}

enum SortType { date, priority, progress }
