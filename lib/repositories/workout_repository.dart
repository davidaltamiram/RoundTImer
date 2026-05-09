import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:round_timer_app/models/workout.dart';
import 'package:round_timer_app/models/workout_config.dart';

class WorkoutRepository {
  static const String _defaultSessionKey = 'default_session';
  static const String _workoutsKey = 'workouts';
  static const String _lastSessionKey = 'last_session';

  // Sesión default
  Future<void> saveDefaultSession(WorkoutConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultSessionKey, jsonEncode(config.toJson()));
  }

  Future<WorkoutConfig> getDefaultSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_defaultSessionKey);
    if (json == null) return WorkoutConfig.boxing();
    return WorkoutConfig.fromJson(jsonDecode(json));
  }

  // Última sesión usada
  Future<void> saveLastSession(WorkoutConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSessionKey, jsonEncode(config.toJson()));
  }

  Future<WorkoutConfig?> getLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_lastSessionKey);
    if (json == null) return null;
    return WorkoutConfig.fromJson(jsonDecode(json));
  }

  // Rutinas guardadas
  Future<List<Workout>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_workoutsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Workout.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getAll();
    workouts.add(workout);
    await prefs.setString(
      _workoutsKey,
      jsonEncode(workouts.map((w) => w.toJson()).toList()),
    );
  }

  Future<void> update(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getAll();
    final index = workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      workouts[index] = workout;
      await prefs.setString(
        _workoutsKey,
        jsonEncode(workouts.map((w) => w.toJson()).toList()),
      );
    }
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getAll();
    workouts.removeWhere((w) => w.id == id);
    await prefs.setString(
      _workoutsKey,
      jsonEncode(workouts.map((w) => w.toJson()).toList()),
    );
  }
}
