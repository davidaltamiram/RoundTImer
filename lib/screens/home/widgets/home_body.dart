import 'package:flutter/material.dart';
import 'package:round_timer_app/models/workout_config.dart';
import 'package:round_timer_app/repositories/workout_repository.dart';
import 'package:round_timer_app/screens/timer/timer_screen.dart';
import 'package:round_timer_app/theme/app_theme.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _repository = WorkoutRepository();
  WorkoutConfig? _defaultConfig;
  WorkoutConfig? _lastSession;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final defaultConfig = await _repository.getDefaultSession();
    final lastSession = await _repository.getLastSession();
    setState(() {
      _defaultConfig = defaultConfig;
      _lastSession = lastSession;
      _loading = false;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}min' : '${m}min ${s}seg';
  }

  void _iniciar(WorkoutConfig config) async {
    await _repository.saveLastSession(config);
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TimerScreen(config: config)),
      );
      _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card superior — última sesión
        Card(
          margin: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _lastSession == null
                  ? const Text(
                      'No hay sesiones recientes',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _lastSession!.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${_lastSession!.rounds} rondas',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_formatTime(_lastSession!.workSeconds)} trabajo  •  ${_formatTime(_lastSession!.restSeconds)} descanso',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _iniciar(_lastSession!),
                            child: const Text(
                              'REPETIR SESIÓN →',
                              style: TextStyle(
                                color: AppColors.work,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        // Sesión default — centro de pantalla
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _defaultConfig!.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_defaultConfig!.rounds} rondas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_formatTime(_defaultConfig!.workSeconds)} trabajo  •  ${_formatTime(_defaultConfig!.restSeconds)} descanso',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: ElevatedButton(
                        onPressed: () => _iniciar(_defaultConfig!),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text('INICIAR'),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
