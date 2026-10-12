import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/capsule_memory.dart';

const _kBrown = Color(0xFF84321F);
const _kBrownDeep = Color(0xFF5A1E0E);
const _kMuted = Color(0xFFA07060);
const _kBorder = Color(0xFFEEDFD9);
const _kPeachBd = Color(0xFFD9B49E);

enum _RecordState { idle, recording, paused, recorded }

class VoiceNoteRecorderSheet extends StatefulWidget {
  const VoiceNoteRecorderSheet({super.key});

  static Future<CapsuleMemory?> show(BuildContext context) {
    return showModalBottomSheet<CapsuleMemory?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceNoteRecorderSheet(),
    );
  }

  @override
  State<VoiceNoteRecorderSheet> createState() => _VoiceNoteRecorderSheetState();
}

class _VoiceNoteRecorderSheetState extends State<VoiceNoteRecorderSheet> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  _RecordState _recordState = _RecordState.idle;
  String? _recordedPath;
  int _recordDuration = 0;
  Timer? _timer;

  bool _isPlaying = false;
  Duration _playbackPos = Duration.zero;
  Duration _playbackDur = Duration.zero;

  String? _permissionError;
  final TextEditingController _titleCtrl = TextEditingController(text: 'Voice blessing');

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _playbackPos = pos);
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _playbackDur = dur);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        setState(() {
          _permissionError = 'Microphone permission denied. Please grant microphone access in device settings to record voice memories.';
        });
        return;
      }

      setState(() {
        _permissionError = null;
        _recordDuration = 0;
      });

      final tempDir = Directory.systemTemp.path;
      final filePath = '$tempDir/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      setState(() => _recordState = _RecordState.recording);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordDuration++);
      });
    } catch (e) {
      setState(() => _permissionError = 'Error starting recording: $e');
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    _timer?.cancel();
    setState(() => _recordState = _RecordState.paused);
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration++);
    });
    setState(() => _recordState = _RecordState.recording);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _recordedPath = path;
      _recordState = _RecordState.recorded;
      _playbackDur = Duration(seconds: _recordDuration);
    });
  }

  Future<void> _togglePlayback() async {
    if (_recordedPath == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_recordedPath!));
    }
  }

  void _reRecord() {
    _audioPlayer.stop();
    setState(() {
      _recordState = _RecordState.idle;
      _recordedPath = null;
      _recordDuration = 0;
      _isPlaying = false;
      _playbackPos = Duration.zero;
    });
  }

  void _saveMemory() {
    if (_recordedPath == null) return;
    final memory = CapsuleMemory(
      id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
      type: MemoryType.voice,
      content: _recordedPath!,
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Voice Note',
      caption: 'Audio memory (${_recordDuration}s)',
      addedBy: 'You',
      createdAt: DateTime.now(),
      durationSeconds: _recordDuration > 0 ? _recordDuration : 10,
    );
    Navigator.pop(context, memory);
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(28, 20, 28, 28 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD9C4BC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Record Voice Note',
              style: TextStyle(
                color: _kBrownDeep,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Leave spoken blessings, stories, or thoughts',
              style: TextStyle(color: _kMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),

            if (_permissionError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic_off_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _permissionError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Live Waveform visualizer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(24, (i) {
                final baseHeights = [8, 16, 24, 36, 18, 12, 28, 40, 24, 14, 20, 32, 16, 22, 34, 38, 20, 10, 26, 30, 18, 14, 10, 6];
                final active = _recordState == _RecordState.recording || _isPlaying;
                final h = active ? baseHeights[i % baseHeights.length].toDouble() : 8.0;
                return Container(
                  width: 4,
                  height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: active ? _kBrown : _kPeachBd,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Duration display
            Text(
              _recordState == _RecordState.recorded
                  ? '${_formatTime(_playbackPos.inSeconds)} / ${_formatTime(_playbackDur.inSeconds > 0 ? _playbackDur.inSeconds : _recordDuration)}'
                  : _formatTime(_recordDuration),
              style: const TextStyle(
                color: _kBrownDeep,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),

            // Title input if recorded
            if (_recordState == _RecordState.recorded) ...[
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Note Title / Topic',
                  labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBrown, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Action Buttons
            if (_recordState == _RecordState.idle)
              GestureDetector(
                onTap: _startRecording,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _kBrown,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kBrown.withAlpha(80),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32),
                ),
              )
            else if (_recordState == _RecordState.recording || _recordState == _RecordState.paused)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFECEE), foregroundColor: _kBrown),
                    onPressed: _recordState == _RecordState.recording ? _pauseRecording : _resumeRecording,
                    icon: Icon(_recordState == _RecordState.recording ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 26),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _stopRecording,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stop_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                ],
              )
            else ...[
              // Recorded state: Play/pause, Re-record, Save
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _reRecord,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Re-record', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kBrown,
                      side: const BorderSide(color: _kPeachBd),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: _kBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: _togglePlayback,
                    icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: _saveMemory,
                  icon: const Icon(Icons.lock_outline_rounded, size: 16),
                  label: const Text('Seal Voice Note into Capsule', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
