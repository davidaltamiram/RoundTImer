import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:round_timer_app/models/workout_config.dart';
import 'package:round_timer_app/repositories/workout_repository.dart';
import 'package:round_timer_app/theme/app_theme.dart';

class ConfigDrawer extends StatefulWidget {
  final VoidCallback? onGuardado;

  const ConfigDrawer({super.key, this.onGuardado});

  @override
  State<ConfigDrawer> createState() => _ConfigDrawerState();
}

class _ConfigDrawerState extends State<ConfigDrawer> {
  final _repository = WorkoutRepository();

  final _nombreController = TextEditingController();
  final _rondasController = TextEditingController();
  final _prepMinController = TextEditingController();
  final _prepSegController = TextEditingController();
  final _trabajoMinController = TextEditingController();
  final _trabajoSegController = TextEditingController();
  final _descansoMinController = TextEditingController();
  final _descansoSegController = TextEditingController();
  final _coolMinController = TextEditingController();
  final _coolSegController = TextEditingController();

  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _repository.getDefaultSession();
    setState(() {
      _nombreController.text = config.name;
      _rondasController.text = config.rounds.toString();
      _prepMinController.text = (config.warmupSeconds ~/ 60).toString();
      _prepSegController.text = (config.warmupSeconds % 60).toString().padLeft(
        2,
        '0',
      );
      _trabajoMinController.text = (config.workSeconds ~/ 60).toString();
      _trabajoSegController.text = (config.workSeconds % 60).toString().padLeft(
        2,
        '0',
      );
      _descansoMinController.text = (config.restSeconds ~/ 60).toString();
      _descansoSegController.text = (config.restSeconds % 60)
          .toString()
          .padLeft(2, '0');
      _coolMinController.text = (config.cooldownSeconds ~/ 60).toString();
      _coolSegController.text = (config.cooldownSeconds % 60)
          .toString()
          .padLeft(2, '0');
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rondasController.dispose();
    _prepMinController.dispose();
    _prepSegController.dispose();
    _trabajoMinController.dispose();
    _trabajoSegController.dispose();
    _descansoMinController.dispose();
    _descansoSegController.dispose();
    _coolMinController.dispose();
    _coolSegController.dispose();
    super.dispose();
  }

  void _guardar() async {
    final config = WorkoutConfig(
      name: _nombreController.text.isEmpty
          ? 'Rutina Default'
          : _nombreController.text,
      rounds: int.tryParse(_rondasController.text) ?? 12,
      workSeconds: _toSeconds(
        _trabajoMinController.text,
        _trabajoSegController.text,
      ),
      restSeconds: _toSeconds(
        _descansoMinController.text,
        _descansoSegController.text,
      ),
      warmupSeconds: _toSeconds(
        _prepMinController.text,
        _prepSegController.text,
      ),
      cooldownSeconds: _toSeconds(
        _coolMinController.text,
        _coolSegController.text,
      ),
    );

    await _repository.saveDefaultSession(config);
    setState(() => _editando = false);
    widget.onGuardado?.call();
    if (mounted) Navigator.pop(context);
  }

  int _toSeconds(String min, String seg) {
    final m = int.tryParse(min) ?? 0;
    final s = int.tryParse(seg) ?? 0;
    return (m * 60) + s;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesión Default',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        _editando ? 'Editando...' : 'Solo lectura',
                        style: TextStyle(
                          color: _editando
                              ? AppColors.work
                              : AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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

              // Campos
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('NOMBRE DE LA CONFIGURACIÓN'),
                      _buildTextField(
                        controller: _nombreController,
                        hint: 'Ej. Sparring 12 rondas',
                        enabled: _editando,
                        isNumeric: false,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('CANTIDAD DE RONDAS'),
                      _buildTextField(
                        controller: _rondasController,
                        hint: '12',
                        enabled: _editando,
                        maxLength: 2,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('PREPARACIÓN (solo 1ra ronda)'),
                      _buildTimeRow(
                        minController: _prepMinController,
                        segController: _prepSegController,
                        enabled: _editando,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('TIEMPO POR RONDA'),
                      _buildTimeRow(
                        minController: _trabajoMinController,
                        segController: _trabajoSegController,
                        enabled: _editando,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('DESCANSO ENTRE RONDAS'),
                      _buildTimeRow(
                        minController: _descansoMinController,
                        segController: _descansoSegController,
                        enabled: _editando,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('COOL DOWN'),
                      _buildTimeRow(
                        minController: _coolMinController,
                        segController: _coolSegController,
                        enabled: _editando,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Botones
              if (_editando) ...[
                ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('GUARDAR'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    _loadConfig();
                    setState(() => _editando = false);
                  },
                  child: const Text('CANCELAR'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => setState(() => _editando = true),
                  child: const Text('EDITAR'),
                ),
              ],
            ],
          ),
        ),
      ),
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
    required bool enabled,
    bool isNumeric = true,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ]
          : null,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        // Muestra el hint como prefijo cuando está vacío y deshabilitado
        prefixText: (!enabled && controller.text.isEmpty) ? hint : null,
        prefixStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        filled: true,
        fillColor: enabled ? AppColors.surfaceVariant : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        suffixIcon: !enabled
            ? const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildTimeRow({
    required TextEditingController minController,
    required TextEditingController segController,
    required bool enabled,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: minController,
            hint: '00',
            enabled: enabled,
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
            enabled: enabled,
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
