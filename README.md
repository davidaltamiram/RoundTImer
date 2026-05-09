# RoundFlow

App de temporizador de intervalos para boxeo y rutinas de ejercicio construida con Flutter. Soporta rondas personalizadas, fases de trabajo, descanso, calentamiento y cool down con señales de audio.

## Características

- Configuración personalizada de sesiones (rondas, tiempo de trabajo, descanso, calentamiento, cool down)
- Temporizador circular visual con cambios de color por fase
- Beeps de audio para cuenta regresiva y transiciones de fase
- Guardar y gestionar múltiples rutinas de entrenamiento
- Seguimiento de la última sesión en la pantalla de inicio
- UI oscura y limpia optimizada para uso en gimnasio

## Tecnologías

- **Flutter** & **Dart**
- `shared_preferences` — persistencia de datos local
- `audioplayers` — generación de audio en memoria
- `uuid` — generación de IDs únicos para rutinas

## Estructura del Proyecto
lib/
├── main.dart
├── app/
├── models/
│   ├── workout.dart
│   ├── workout_config.dart
│   └── timer_phase.dart
├── services/
│   ├── timer_service.dart
│   └── audio_service.dart
├── repositories/
│   └── workout_repository.dart
├── screens/
│   ├── home/
│   ├── config/
│   ├── timer/
│   └── routines/
├── widgets/
│   └── bottom_nav_bar.dart
└── theme/
└── app_theme.dart

## Primeros Pasos

### Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio o VS Code

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/davidaltamiram/RoundTImer.git

# Navegar a la carpeta del proyecto
cd RoundTImer

# Instalar dependencias
flutter pub get

# Correr la app
flutter run
```

### Generar APK

```bash
flutter build apk --release
```

## Cómo Funciona

1. Configura tu sesión default desde el menú lateral
2. Presiona **INICIAR** para comenzar tu entrenamiento
3. El timer te guía a través de las fases: calentamiento → trabajo → descanso → cool down
4. Guarda rutinas personalizadas desde la pestaña **Mis Rutinas**
5. Consulta tu última sesión desde la pantalla de inicio

## Autor

David — [@davidaltamiram](https://github.com/davidaltamiram)

## Licencia

Este proyecto está bajo la Licencia MIT —.