class WorkoutConfig {
  final String name;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final int warmupSeconds;
  final int cooldownSeconds;

  const WorkoutConfig({
    this.name = 'Rutina Default',
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    this.warmupSeconds = 0,
    this.cooldownSeconds = 0,
  });

  int get totalSeconds =>
      warmupSeconds +
      (rounds * workSeconds) +
      ((rounds - 1) * restSeconds) +
      cooldownSeconds;

  String get totalFormatted {
    final min = totalSeconds ~/ 60;
    final sec = totalSeconds % 60;
    if (sec == 0) return '$min min';
    return '$min min $sec seg';
  }

  static String formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory WorkoutConfig.boxing() => const WorkoutConfig(
    name: 'Boxeo Clásico',
    rounds: 12,
    workSeconds: 180,
    restSeconds: 60,
    warmupSeconds: 30,
  );

  factory WorkoutConfig.hiit() => const WorkoutConfig(
    name: 'HIIT',
    rounds: 8,
    workSeconds: 40,
    restSeconds: 20,
  );

  factory WorkoutConfig.tabata() => const WorkoutConfig(
    name: 'Tabata',
    rounds: 8,
    workSeconds: 20,
    restSeconds: 10,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'rounds': rounds,
    'workSeconds': workSeconds,
    'restSeconds': restSeconds,
    'warmupSeconds': warmupSeconds,
    'cooldownSeconds': cooldownSeconds,
  };

  factory WorkoutConfig.fromJson(Map<String, dynamic> json) => WorkoutConfig(
    name: (json['name'] as String?) ?? 'Rutina Default',
    rounds: json['rounds'] as int,
    workSeconds: json['workSeconds'] as int,
    restSeconds: json['restSeconds'] as int,
    warmupSeconds: (json['warmupSeconds'] as int?) ?? 0,
    cooldownSeconds: (json['cooldownSeconds'] as int?) ?? 0,
  );

  WorkoutConfig copyWith({
    String? name,
    int? rounds,
    int? workSeconds,
    int? restSeconds,
    int? warmupSeconds,
    int? cooldownSeconds,
  }) {
    return WorkoutConfig(
      name: name ?? this.name,
      rounds: rounds ?? this.rounds,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      warmupSeconds: warmupSeconds ?? this.warmupSeconds,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
    );
  }

  @override
  String toString() =>
      'WorkoutConfig(name: $name, rounds: $rounds, work: ${workSeconds}s, '
      'rest: ${restSeconds}s, warmup: ${warmupSeconds}s, '
      'cooldown: ${cooldownSeconds}s, total: $totalFormatted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutConfig &&
          name == other.name &&
          rounds == other.rounds &&
          workSeconds == other.workSeconds &&
          restSeconds == other.restSeconds &&
          warmupSeconds == other.warmupSeconds &&
          cooldownSeconds == other.cooldownSeconds;

  @override
  int get hashCode => Object.hash(
    name,
    rounds,
    workSeconds,
    restSeconds,
    warmupSeconds,
    cooldownSeconds,
  );
}
