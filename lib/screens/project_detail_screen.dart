import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailScreen({Key? key, required this.project}) : super(key: key);

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _milestoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.project.description;
  }

  @override
  void dispose() {
    _milestoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addMilestone() {
    if (_milestoneController.text.isEmpty) return;

    final updatedProject = widget.project.copyWith(
      milestones: [...widget.project.milestones, _milestoneController.text],
      milestoneCompleted: [...widget.project.milestoneCompleted, false],
    );

    ref.read(projectsProvider.notifier).updateProject(updatedProject);
    _milestoneController.clear();
    Navigator.pop(context);
  }

  void _toggleMilestone(int index) {
    final updatedCompleted = List<bool>.from(widget.project.milestoneCompleted);
    updatedCompleted[index] = !updatedCompleted[index];

    final updatedProject = widget.project.copyWith(
      milestoneCompleted: updatedCompleted,
    );

    ref.read(projectsProvider.notifier).updateProject(updatedProject);
  }

  void _deleteMilestone(int index) {
    final updatedMilestones = List<String>.from(widget.project.milestones);
    final updatedCompleted = List<bool>.from(widget.project.milestoneCompleted);
    updatedMilestones.removeAt(index);
    updatedCompleted.removeAt(index);

    final updatedProject = widget.project.copyWith(
      milestones: updatedMilestones,
      milestoneCompleted: updatedCompleted,
    );

    ref.read(projectsProvider.notifier).updateProject(updatedProject);
  }

  void _logSession() {
    final updatedProject = widget.project.copyWith(
      sessionDates: [...widget.project.sessionDates, DateTime.now()],
      hoursSpent: widget.project.hoursSpent + 1,
    );

    ref.read(projectsProvider.notifier).updateProject(updatedProject);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Work session logged!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateDescription() {
    final updatedProject = widget.project.copyWith(
      description: _descriptionController.text,
    );
    ref.read(projectsProvider.notifier).updateProject(updatedProject);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Description updated!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final currentProject = projects.firstWhere((p) => p.id == widget.project.id);
    final color = Color(int.parse('0xFF${currentProject.colorHex}'));
    final icon = IconData(int.parse(currentProject.icon), fontFamily: 'MaterialIcons');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          currentProject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              ref.read(projectsProvider.notifier).archiveProject(currentProject.id);
              Navigator.pop(context);
            },
            tooltip: 'Archive Project',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project header card
            _buildHeaderCard(currentProject, color, icon),
            const SizedBox(height: 20),

            // Stats Grid
            _buildStatsGrid(currentProject, color),
            const SizedBox(height: 20),

            // Progress bar
            _buildProgressSection(currentProject, color),
            const SizedBox(height: 20),

            // Description section
            _buildDescriptionSection(color),
            const SizedBox(height: 20),

            // Milestones section
            _buildMilestonesSection(currentProject, color),
            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActions(color),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Project project, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.3), const Color(0xFF1D1E33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.daysActive} days active',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Project project, Color color) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
          '${project.milestones.length}',
          'Milestones',
          Icons.flag,
          color,
        ),
        _buildStatCard(
          '${project.totalSessions}',
          'Sessions',
          Icons.work,
          color,
        ),
        _buildStatCard(
          '${project.hoursSpent}h',
          'Time Spent',
          Icons.access_time,
          color,
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Project project, Color color) {
    final percentage = project.completionPercentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add a description...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0A0E21),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _updateDescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(Project project, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Milestones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: color),
                onPressed: () => _showAddMilestoneDialog(color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (project.milestones.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No milestones yet. Add one to track progress!',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          else
            ...List.generate(project.milestones.length, (index) {
              final milestone = project.milestones[index];
              final isCompleted = project.milestoneCompleted[index];
              return Dismissible(
                key: Key('milestone_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteMilestone(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? color.withValues(alpha: 0.1)
                        : const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? color.withValues(alpha: 0.5)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: (_) => _toggleMilestone(index),
                        activeColor: color,
                      ),
                      Expanded(
                        child: Text(
                          milestone,
                          style: TextStyle(
                            fontSize: 14,
                            color: isCompleted ? Colors.white54 : Colors.white,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Icon(Icons.check_circle, color: color, size: 20),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _logSession,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Log Work Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Add Milestone', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _milestoneController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter milestone...',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _addMilestone,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
