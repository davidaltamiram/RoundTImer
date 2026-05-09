import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:round_timer_app/models/workout.dart';
import 'package:round_timer_app/models/workout_config.dart';
import 'package:round_timer_app/repositories/workout_repository.dart';
import 'package:round_timer_app/screens/timer/timer_screen.dart';
import 'package:round_timer_app/theme/app_theme.dart';

class RoutinesScreen extends StatefulWidget {
  final VoidCallback? onSessionStarted;
  const RoutinesScreen({super.key, this.onSessionStarted});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final _repository = WorkoutRepository();
  List<Workout> _workouts = [];
  bool _loading = true;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await _repository.getAll();
    setState(() {
      _workouts = workouts;
      _loading = false;
    });
  }

  void _onCardTap(String id) {
    setState(() {
      _selectedId = _selectedId == id ? null : id;
    });
  }

  void _onIniciar(Workout workout) async {
    await _repository.saveLastSession(workout.config);
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TimerScreen(config: workout.config)),
      );
      widget.onSessionStarted?.call();
    }
  }

  void _onEliminar(String id) async {
    await _repository.delete(id);
    setState(() {
      _workouts.removeWhere((w) => w.id == id);
      if (_selectedId == id) _selectedId = null;
    });
  }

  void _onEditar(Workout workout) {
    _showFormDialog(workout: workout);
  }

  void _onNuevaRutina() {
    _showFormDialog();
  }

  void _showFormDialog({Workout? workout}) {
    final isEditing = workout != null;
    final config = workout?.config;

    final nombreController = TextEditingController(text: config?.name ?? '');
    final rondasController = TextEditingController(
      text: config?.rounds.toString() ?? '',
    );
    final trabajoMinController = TextEditingController(
      text: config != null ? (config.workSeconds ~/ 60).toString() : '',
    );
    final trabajoSegController = TextEditingController(
      text: config != null
          ? (config.workSeconds % 60).toString().padLeft(2, '0')
          : '',
    );
    final descansoMinController = TextEditingController(
      text: config != null ? (config.restSeconds ~/ 60).toString() : '',
    );
    final descansoSegController = TextEditingController(
      text: config != null
          ? (config.restSeconds % 60).toString().padLeft(2, '0')
          : '',
    );
    final prepMinController = TextEditingController(
      text: config != null ? (config.warmupSeconds ~/ 60).toString() : '',
    );
    final prepSegController = TextEditingController(
      text: config != null
          ? (config.warmupSeconds % 60).toString().padLeft(2, '0')
          : '',
    );
    final coolMinController = TextEditingController(
      text: config != null ? (config.cooldownSeconds ~/ 60).toString() : '',
    );
    final coolSegController = TextEditingController(
      text: config != null
          ? (config.cooldownSeconds % 60).toString().padLeft(2, '0')
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Rutina' : 'Nueva Rutina',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              _buildLabel('NOMBRE'),
              _buildTextField(
                controller: nombreController,
                hint: 'Ej. Sparring 12 rondas',
                isNumeric: false,
              ),
              const SizedBox(height: 16),

              _buildLabel('RONDAS'),
              _buildTextField(
                controller: rondasController,
                hint: '12',
                maxLength: 2,
              ),
              const SizedBox(height: 16),

              _buildLabel('PREPARACIÓN (solo 1ra ronda)'),
              _buildTimeRow(
                minController: prepMinController,
                segController: prepSegController,
              ),
              const SizedBox(height: 16),

              _buildLabel('TIEMPO POR RONDA'),
              _buildTimeRow(
                minController: trabajoMinController,
                segController: trabajoSegController,
              ),
              const SizedBox(height: 16),

              _buildLabel('DESCANSO ENTRE RONDAS'),
              _buildTimeRow(
                minController: descansoMinController,
                segController: descansoSegController,
              ),
              const SizedBox(height: 16),

              _buildLabel('COOL DOWN'),
              _buildTimeRow(
                minController: coolMinController,
                segController: coolSegController,
              ),
              const SizedBox(height: 32),

              // Botón guardar
              ElevatedButton(
                onPressed: () async {
                  final newConfig = WorkoutConfig(
                    name: nombreController.text.isEmpty
                        ? 'Sin nombre'
                        : nombreController.text,
                    rounds: int.tryParse(rondasController.text) ?? 12,
                    workSeconds: _toSeconds(
                      trabajoMinController.text,
                      trabajoSegController.text,
                    ),
                    restSeconds: _toSeconds(
                      descansoMinController.text,
                      descansoSegController.text,
                    ),
                    warmupSeconds: _toSeconds(
                      prepMinController.text,
                      prepSegController.text,
                    ),
                    cooldownSeconds: _toSeconds(
                      coolMinController.text,
                      coolSegController.text,
                    ),
                  );

                  if (isEditing) {
                    final updated = workout.copyWith(config: newConfig);
                    await _repository.update(updated);
                  } else {
                    final newWorkout = Workout(
                      id: const Uuid().v4(),
                      config: newConfig,
                      createdAt: DateTime.now(),
                    );
                    await _repository.save(newWorkout);
                  }

                  if (context.mounted) Navigator.pop(context);
                  await _loadWorkouts();
                },
                child: Text(isEditing ? 'GUARDAR CAMBIOS' : 'CREAR RUTINA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _toSeconds(String min, String seg) {
    final m = int.tryParse(min) ?? 0;
    final s = int.tryParse(seg) ?? 0;
    return (m * 60) + s;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}min' : '${m}min ${s}seg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay rutinas guardadas',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: ElevatedButton(
                      onPressed: _onNuevaRutina,
                      child: const Text('CREAR PRIMERA RUTINA'),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                final isSelected = _selectedId == workout.id;

                return GestureDetector(
                  onTap: () => _onCardTap(workout.id),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.work : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre y rondas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                workout.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${workout.rounds} rondas',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Info de tiempos
                          Text(
                            '${_formatTime(workout.config.workSeconds)} trabajo  •  ${_formatTime(workout.config.restSeconds)} descanso',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Duración total: ${workout.config.totalFormatted}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),

                          // Botones al seleccionar
                          if (isSelected) ...[
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.divider),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _onIniciar(workout),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('INICIAR'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Editar
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () => _onEditar(workout),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: const CircleBorder(),
                                      side: const BorderSide(
                                        color: AppColors.divider,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Eliminar
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () => _onEliminar(workout.id),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: const CircleBorder(),
                                      side: const BorderSide(
                                        color: AppColors.work,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.work,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _workouts.isNotEmpty
          ? FloatingActionButton(
              onPressed: _onNuevaRutina,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumeric = true,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(hintText: hint),
      maxLength: maxLength,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
    );
  }

  Widget _buildTimeRow({
    required TextEditingController minController,
    required TextEditingController segController,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: minController,
            hint: '00',
            maxLength: 2,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ':',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: _buildTextField(
            controller: segController,
            hint: '00',
            maxLength: 2,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'min  :  seg',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
