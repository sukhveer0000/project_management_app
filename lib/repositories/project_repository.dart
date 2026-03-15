import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_management_app/model/project_model.dart';

class ProjectsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<List<ProjectModel>> fetchProjects() async {
    if (user == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('projects')
          .orderBy('CreatedAt', descending: true)
          .orderBy('Priority', descending: true)
          .get();
      // print("Total Docs in Firestore: ${snapshot.docs.length}");
      return snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  Future<ProjectModel> addProject(ProjectModel project) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('projects')
          .doc();
      final projectWithId = project.copyWith(id: docRef.id);

      await docRef.set(projectWithId.toJson());
      return projectWithId;
    } catch (e) {
      throw Exception("Failed to create a project: $e");
    }
  }

  Future<void> updateProject(ProjectModel project) async {
    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('projects')
          .doc(project.id)
          .update({
            'Title': project.title,
            'Description': project.description,
            'Priority': project.priority,
            'Status': project.status,
            'Tasks': project.tasks.map((task) => task.toJson()).toList(),
          });
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('projects')
        .doc(projectId)
        .delete();
  }
}
