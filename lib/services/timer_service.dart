import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:round_timer_app/models/timer_phase.dart';
import 'package:round_timer_app/models/workout_config.dart';
import 'package:round_timer_app/services/audio_service.dart';

class TimerService extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  // Estado actual
  WorkoutConfig? _config;
  TimerPhase _currentPhase = TimerPhase.completed;
  int _currentRound = 1;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  Timer? _timer;

  // Getters — la UI los lee para saber qué mostrar
  WorkoutConfig? get config => _config;
  TimerPhase get currentPhase => _currentPhase;
  int get currentRound => _currentRound;
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  // Texto de la siguiente fase para mostrar en pantalla
  String get nextPhaseLabel {
    if (_currentPhase == TimerPhase.warmup) {
      return 'TRABAJO • ${WorkoutConfig.formatSeconds(_config!.workSeconds)}';
    }
    if (_currentPhase == TimerPhase.work) {
      if (_currentRound < (_config?.rounds ?? 0)) {
        return 'DESCANSO • ${WorkoutConfig.formatSeconds(_config!.restSeconds)}';
      } else if ((_config?.cooldownSeconds ?? 0) > 0) {
        return 'COOL DOWN • ${WorkoutConfig.formatSeconds(_config!.cooldownSeconds)}';
      } else {
        return 'FIN DE SESIÓN';
      }
    }
    if (_currentPhase == TimerPhase.rest) {
      return 'TRABAJO • ${WorkoutConfig.formatSeconds(_config!.workSeconds)}';
    }
    if (_currentPhase == TimerPhase.cooldown) {
      return 'FIN DE SESIÓN';
    }
    return '';
  }

  // Tiempo total de la sesión formateado para el AppBar
  String get totalTimeLabel {
    if (_config == null) return '00:00';
    return WorkoutConfig.formatSeconds(_config!.totalSeconds);
  }

  // Métodos públicos
  void start(WorkoutConfig config) {
    _config = config;
    _currentRound = 1;
    _isRunning = true;
    _isPaused = false;

    // Decide por qué fase empezar
    if (config.warmupSeconds > 0) {
      _startPhase(TimerPhase.warmup, config.warmupSeconds);
    } else {
      _startPhase(TimerPhase.work, config.workSeconds);
    }
  }

  void pause() {
    if (!_isRunning || _isPaused) return;
    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    if (!_isRunning || !_isPaused) return;
    _isPaused = false;
    _tick();
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _currentPhase = TimerPhase.completed;
    _currentRound = 1;
    _secondsRemaining = 0;
    notifyListeners();
  }

  void skipPhase() {
    _timer?.cancel();
    _nextPhase();
  }

  // Lógica interna
  void _startPhase(TimerPhase phase, int seconds) {
    _timer?.cancel();
    _currentPhase = phase;
    _secondsRemaining = seconds;

    // Sonido según la fase
    switch (phase) {
      case TimerPhase.work:
        _audioService.playRoundStart();
        break;
      case TimerPhase.rest:
      case TimerPhase.cooldown:
        _audioService.playRest();
        break;
      default:
        break;
    }

    notifyListeners();
    _tick();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        // Beep en 3, 2, 1
        if (_secondsRemaining <= 3 && _secondsRemaining > 0) {
          _audioService.playBeep();
        }
        notifyListeners();
      } else {
        _timer?.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    final config = _config!;

    switch (_currentPhase) {
      case TimerPhase.warmup:
        _startPhase(TimerPhase.work, config.workSeconds);
        break;

      case TimerPhase.work:
        if (_currentRound < config.rounds) {
          _startPhase(TimerPhase.rest, config.restSeconds);
        } else if (config.cooldownSeconds > 0) {
          _startPhase(TimerPhase.cooldown, config.cooldownSeconds);
        } else {
          _finish();
        }
        break;

      case TimerPhase.rest:
        _currentRound++;
        _startPhase(TimerPhase.work, config.workSeconds);
        break;

      case TimerPhase.cooldown:
        _finish();
        break;

      case TimerPhase.completed:
        break;
    }
  }

  void _finish() {
    _isRunning = false;
    _isPaused = false;
    _currentPhase = TimerPhase.completed;
    _secondsRemaining = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
