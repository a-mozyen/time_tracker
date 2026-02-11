import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/time_entry_provider.dart';
import 'time_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time Tracker'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Entries'),
              Tab(text: 'Group by Project'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menu',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Manage Projects'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProjectManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.task),
                title: const Text('Manage Tasks'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Consumer<TimeEntryProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                // All Entries Tab
                provider.entries.isEmpty
                    ? const Center(child: Text('No entries found.'))
                    : ListView.builder(
                        itemCount: provider.entries.length,
                        itemBuilder: (context, index) {
                          final entry = provider.entries[index];
                          final projectName = provider.getProjectName(
                            entry.projectId,
                          );
                          final taskName = provider.getTaskName(entry.taskId);
                          return ListTile(
                            title: Text(
                              '$projectName - $taskName (${entry.totalTime} hrs)',
                            ),
                            subtitle: Text(
                              '${entry.date.toString().split(' ')[0]} - ${entry.notes}',
                            ),
                            onTap: () {
                              _showEntryDetails(context, entry, provider);
                            },
                          );
                        },
                      ),

                // Group by Project Tab
                provider.projects.isEmpty
                    ? const Center(child: Text('No projects available.'))
                    : ListView.builder(
                        itemCount: provider.projects.length,
                        itemBuilder: (context, index) {
                          final project = provider.projects[index];
                          final projectEntries = provider.entries
                              .where((e) => e.projectId == project.id)
                              .toList();

                          // Calculate total time for the project
                          double projectTotalTime = projectEntries.fold(
                            0.0,
                            (sum, entry) => sum + entry.totalTime,
                          );

                          return ExpansionTile(
                            title: Text(project.name),
                            subtitle: Text('Total: $projectTotalTime hrs'),
                            children: projectEntries.map((entry) {
                              final taskName = provider.getTaskName(
                                entry.taskId,
                              );
                              return ListTile(
                                title: Text(
                                  '$taskName - ${entry.totalTime} hrs',
                                ),
                                subtitle: Text(entry.notes),
                                onTap: () {
                                  _showEntryDetails(context, entry, provider);
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTimeEntryScreen(),
              ),
            );
          },
          tooltip: 'Add Time Entry',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showEntryDetails(
    BuildContext context,
    dynamic entry,
    dynamic provider,
  ) {
    final projectName = provider.getProjectName(entry.projectId);
    final taskName = provider.getTaskName(entry.taskId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entry Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project: $projectName'),
              Text('Task: $taskName'),
              Text('Date: ${entry.date.toString().split(' ')[0]}'),
              Text('Duration: ${entry.totalTime} hrs'),
              const SizedBox(height: 10),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entry.notes),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTimeEntry(entry.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTimeEntryScreen(entryToEdit: entry),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}
