import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playBeep() async {
    await _player.play(
      BytesSource(_generateBeep(frequency: 880, durationMs: 150)),
    );
  }

  Future<void> playRoundStart() async {
    await _player.play(
      BytesSource(_generateBeep(frequency: 660, durationMs: 600)),
    );
  }

  Future<void> playRest() async {
    await _player.play(
      BytesSource(_generateBeep(frequency: 440, durationMs: 400)),
    );
  }

  Uint8List _generateBeep({
    required int frequency,
    required int durationMs,
    int sampleRate = 44100,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = List<int>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final value = (32767 * 0.5 * _sin(2 * 3.141592653589793 * frequency * t))
          .round();
      return value.clamp(-32768, 32767);
    });

    final dataSize = numSamples * 2;
    final header = [
      0x52,
      0x49,
      0x46,
      0x46,
      ..._int32LE(36 + dataSize),
      0x57,
      0x41,
      0x56,
      0x45,
      0x66,
      0x6D,
      0x74,
      0x20,
      0x10,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x01,
      0x00,
      ..._int32LE(sampleRate),
      ..._int32LE(sampleRate * 2),
      0x02,
      0x00,
      0x10,
      0x00,
      0x64,
      0x61,
      0x74,
      0x61,
      ..._int32LE(dataSize),
    ];

    final bytes = <int>[...header];
    for (final sample in samples) {
      bytes.add(sample & 0xFF);
      bytes.add((sample >> 8) & 0xFF);
    }

    return Uint8List.fromList(bytes);
  }

  List<int> _int32LE(int value) => [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];

  double _sin(double x) {
    x = x % (2 * 3.141592653589793);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  void dispose() {
    _player.dispose();
  }
}
