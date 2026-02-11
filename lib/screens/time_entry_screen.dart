import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_entry_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../provider/time_entry_provider.dart';
import 'package:intl/intl.dart';

class AddTimeEntryScreen extends StatefulWidget {
  final TimeEntry? entryToEdit;

  const AddTimeEntryScreen({super.key, this.entryToEdit});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      projectId = widget.entryToEdit!.projectId;
      taskId = widget.entryToEdit!.taskId;
      totalTime = widget.entryToEdit!.totalTime;
      date = widget.entryToEdit!.date;
      notes = widget.entryToEdit!.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryToEdit == null ? 'Add Time Entry' : 'Edit Time Entry',
        ),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: projectId,
                    onChanged: (String? newValue) {
                      if (newValue == '__create_new_project__') {
                        _showAddProjectDialog(context);
                      } else {
                        setState(() {
                          projectId = newValue;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Project'),
                    items: [
                      ...provider.projects.map<DropdownMenuItem<String>>((
                        project,
                      ) {
                        return DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }),
                      const DropdownMenuItem<String>(
                        value: '__create_new_project__',
                        child: Text('Create new Project'),
                      ),
                    ],
                    validator: (value) =>
                        value == null ? 'Please select a project' : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: taskId,
                    onChanged: (String? newValue) {
                      if (newValue == '__create_new_task__') {
                        _showAddTaskDialog(context);
                      } else {
                        setState(() {
                          taskId = newValue;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Task'),
                    items: [
                      ...provider.tasks.map<DropdownMenuItem<String>>((task) {
                        return DropdownMenuItem<String>(
                          value: task.id,
                          child: Text(task.name),
                        );
                      }),
                      const DropdownMenuItem<String>(
                        value: '__create_new_task__',
                        child: Text('Create new Task'),
                      ),
                    ],
                    validator: (value) =>
                        value == null ? 'Please select a task' : null,
                  ),
                  TextFormField(
                    initialValue: widget.entryToEdit?.totalTime.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Total Time (hours)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter total time';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => totalTime = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(date)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: widget.entryToEdit?.notes,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some notes';
                      }
                      return null;
                    },
                    onSaved: (value) => notes = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final entry = TimeEntry(
                          id:
                              widget.entryToEdit?.id ??
                              DateTime.now().toString(),
                          projectId: projectId!,
                          taskId: taskId!,
                          totalTime: totalTime,
                          date: date,
                          notes: notes,
                        );

                        if (widget.entryToEdit == null) {
                          Provider.of<TimeEntryProvider>(
                            context,
                            listen: false,
                          ).addTimeEntry(entry);
                        } else {
                          Provider.of<TimeEntryProvider>(
                            context,
                            listen: false,
                          ).updateTimeEntry(entry);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    String newProjectName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Project Name'),
            onChanged: (value) {
              newProjectName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newProjectName.isNotEmpty) {
                  final newProject = Project(
                    id: DateTime.now().toString(),
                    name: newProjectName,
                  );
                  Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  ).addProject(newProject);
                  setState(() {
                    projectId = newProject.id;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    String newTaskName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Task Name'),
            onChanged: (value) {
              newTaskName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTaskName.isNotEmpty) {
                  final newTask = Task(
                    id: DateTime.now().toString(),
                    name: newTaskName,
                  );
                  Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  ).addTask(newTask);
                  setState(() {
                    taskId = newTask.id;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
