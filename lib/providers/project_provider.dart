import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../services/hive_service.dart';

final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super(HiveService.getAllProjects());

  Future<void> addProject(String name, String colorHex, String icon) async {
    final project = Project(
      id: const Uuid().v4(),
      name: name,
      colorHex: colorHex,
      icon: icon,
      active: true,
      createdAt: DateTime.now(),
    );
    await HiveService.saveProject(project);
    state = [...state, project];
  }

  Future<void> updateProject(Project project) async {
    await HiveService.saveProject(project);
    state = [
      for (final p in state)
        if (p.id == project.id) project else p
    ];
  }

  Future<void> archiveProject(String id) async {
    final project = state.firstWhere((p) => p.id == id);
    final archived = project.copyWith(
      active: false,
      archivedAt: DateTime.now(),
    );
    await HiveService.saveProject(archived);
    state = [
      for (final p in state)
        if (p.id == id) archived else p
    ];
  }

  Future<void> unarchiveProject(String id) async {
    final project = state.firstWhere((p) => p.id == id);
    final unarchived = project.copyWith(
      active: true,
      archivedAt: null,
    );
    await HiveService.saveProject(unarchived);
    state = [
      for (final p in state)
        if (p.id == id) unarchived else p
    ];
  }

  Future<void> deleteProject(String id) async {
    await HiveService.deleteProject(id);
    state = state.where((p) => p.id != id).toList();
  }

  List<Project> get activeProjects {
    return state.where((p) => p.active).toList();
  }

  List<Project> get archivedProjects {
    return state.where((p) => !p.active).toList();
  }
}
