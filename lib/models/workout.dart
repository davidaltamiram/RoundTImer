import 'package:round_timer_app/models/workout_config.dart';

class Workout {
  final String id;
  final WorkoutConfig config;
  final DateTime createdAt;

  Workout({required this.id, required this.config, required this.createdAt});

  // Getters de conveniencia para no escribir workout.config.name
  String get name => config.name;
  int get rounds => config.rounds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'config': config.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    config: WorkoutConfig.fromJson(json['config'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Workout copyWith({String? id, WorkoutConfig? config, DateTime? createdAt}) {
    return Workout(
      id: id ?? this.id,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Workout(id: $id, name: $name, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Workout && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
