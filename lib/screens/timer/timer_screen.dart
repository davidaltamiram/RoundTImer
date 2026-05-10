import 'dart:math';
import 'package:flutter/material.dart';
import 'package:round_timer_app/models/timer_phase.dart';
import 'package:round_timer_app/models/workout_config.dart';
import 'package:round_timer_app/services/timer_service.dart';
import 'package:round_timer_app/theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  final WorkoutConfig config;

  const TimerScreen({super.key, required this.config});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.start(widget.config);
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  // Color _phaseColor(TimerPhase phase) {
  //   return Color(_timerService.currentPhase.colorValue);
  // }

  void _onExitPressed() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '¿Salir de la sesión?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Se perderá el progreso de la sesión actual.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cierra el diálogo
              _timerService.stop();
              Navigator.pop(context); // regresa al HomeScreen
            },
            child: const Text(
              'SALIR',
              style: TextStyle(
                color: AppColors.work,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _timerService,
      builder: (context, _) {
        final phase = _timerService.currentPhase;
        final color = Color(phase.colorValue);
        final config = widget.config;
        final secondsRemaining = _timerService.secondsRemaining;
        final totalPhaseSeconds = _phaseTotal(phase, config);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: phase == TimerPhase.completed
                ? _buildCompletedView()
                : Column(
                    children: [
                      // Top bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _onExitPressed,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              label: const Text(
                                'SALIR',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              _timerService.totalTimeLabel,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Phase label
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: color, size: 10),
                            const SizedBox(width: 8),
                            Text(
                              phase.label,
                              style: TextStyle(
                                color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Círculo principal
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: 260,
                            height: 260,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Arco de progreso
                                CustomPaint(
                                  size: const Size(260, 260),
                                  painter: _CircularTimerPainter(
                                    progress: totalPhaseSeconds > 0
                                        ? secondsRemaining / totalPhaseSeconds
                                        : 0,
                                    color: color,
                                  ),
                                ),
                                // Tiempo y estado
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      WorkoutConfig.formatSeconds(
                                        secondsRemaining,
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 64,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                    Text(
                                      phase == TimerPhase.completed
                                          ? '¡COMPLETADO!'
                                          : _timerService.isPaused
                                          ? 'PAUSADO'
                                          : 'LISTO',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Indicadores de ronda
                      if (phase != TimerPhase.completed)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(config.rounds, (i) {
                              final isActive =
                                  i + 1 == _timerService.currentRound;
                              final isDone = i + 1 < _timerService.currentRound;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: isActive ? 10 : 7,
                                height: isActive ? 10 : 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? AppColors.textSecondary
                                      : isActive
                                      ? color
                                      : AppColors.surfaceVariant,
                                ),
                              );
                            }),
                          ),
                        ),

                      // Siguiente fase
                      if (phase != TimerPhase.completed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(text: 'A continuación: '),
                                TextSpan(
                                  text: _timerService.nextPhaseLabel,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Controles
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: phase == TimerPhase.completed
                            ? FractionallySizedBox(
                                widthFactor: 0.7,
                                child: ElevatedButton(
                                  onPressed: _onExitPressed,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: const Text('FINALIZAR'),
                                ),
                              )
                            : Row(
                                children: [
                                  // Skip
                                  _ControlButton(
                                    icon: Icons.skip_next,
                                    onPressed: _timerService.skipPhase,
                                  ),
                                  const SizedBox(width: 12),
                                  // Play / Pause
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _timerService.isPaused
                                          ? _timerService.resume
                                          : _timerService.pause,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: color,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            40,
                                          ),
                                        ),
                                        minimumSize: const Size(0, 52),
                                      ),
                                      icon: Icon(
                                        _timerService.isPaused
                                            ? Icons.play_arrow
                                            : Icons.pause,
                                        color: AppColors.textPrimary,
                                      ),
                                      label: Text(
                                        _timerService.isPaused
                                            ? 'CONTINUAR'
                                            : 'PAUSA',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Stop
                                  _ControlButton(
                                    icon: Icons.stop,
                                    onPressed: _onExitPressed,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // Devuelve el total de segundos de la fase actual para calcular el progreso
  int _phaseTotal(TimerPhase phase, WorkoutConfig config) {
    switch (phase) {
      case TimerPhase.warmup:
        return config.warmupSeconds;
      case TimerPhase.work:
        return config.workSeconds;
      case TimerPhase.rest:
        return config.restSeconds;
      case TimerPhase.cooldown:
        return config.cooldownSeconds;
      case TimerPhase.completed:
        return 1;
    }
  }

  Widget _buildCompletedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono de check
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.completed, width: 3),
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.completed,
              size: 56,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '¡SESIÓN COMPLETADA!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.config.name,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.config.rounds} rondas completadas',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            'Duración: ${widget.config.totalFormatted}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: ElevatedButton(
              onPressed: () {
                _timerService.stop();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.completed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text('FINALIZAR'),
            ),
          ),
        ],
      ),
    );
  }
}

// Botón circular de control (skip / stop)
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: const BorderSide(color: AppColors.divider),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}

// Painter del arco de progreso
class _CircularTimerPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final Color color;

  _CircularTimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    // Fondo del arco
    final bgPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Arco de progreso
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // empieza desde arriba
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
