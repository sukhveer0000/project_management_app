import 'package:flutter/material.dart';
import 'package:project_management_app/model/project_model.dart';
import 'package:project_management_app/repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final _repository = ProjectsRepository();
  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

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

  Future<void> updateProject(ProjectModel project) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProject(project);
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
}
