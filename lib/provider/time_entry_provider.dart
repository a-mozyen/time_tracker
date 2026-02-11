import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/time_entry_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  TimeEntryProvider() {
    loadData();
  }

  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Projects
    final projectsString = prefs.getString('projects');
    if (projectsString != null) {
      final List<dynamic> projectsJson = json.decode(projectsString);
      _projects = projectsJson.map((json) => Project.fromJson(json)).toList();
    }

    // Load Tasks
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = json.decode(tasksString);
      _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
    }

    // Load Entries
    final entriesString = prefs.getString('entries');
    if (entriesString != null) {
      final List<dynamic> entriesJson = json.decode(entriesString);
      _entries = entriesJson.map((json) => TimeEntry.fromJson(json)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String projectsString = json.encode(
      _projects.map((p) => p.toJson()).toList(),
    );
    await prefs.setString('projects', projectsString);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = json.encode(
      _tasks.map((t) => t.toJson()).toList(),
    );
    await prefs.setString('tasks', tasksString);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesString = json.encode(
      _entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('entries', entriesString);
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveEntries();
    notifyListeners();
  }

  void updateTimeEntry(TimeEntry updatedEntry) {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      _saveEntries();
      notifyListeners();
    }
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveEntries();
    notifyListeners();
  }

  // Project Management
  void addProject(Project project) {
    _projects.add(project);
    _saveProjects();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    // Optional: Only delete if no entries use it? Or cascade?
    // For now, simple delete.
    _saveProjects();
    notifyListeners();
  }

  String getProjectName(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id).name;
    } catch (e) {
      return 'Unknown Project';
    }
  }

  // Task Management
  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveTasks();
    notifyListeners();
  }

  String getTaskName(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id).name;
    } catch (e) {
      return 'Unknown Task';
    }
  }
}
