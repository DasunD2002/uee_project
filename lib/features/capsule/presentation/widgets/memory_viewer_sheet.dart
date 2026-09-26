import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/capsule_memory.dart';

const _kBrown = Color(0xFF84321F);
const _kBrownDeep = Color(0xFF5A1E0E);
const _kMuted = Color(0xFFA07060);
const _kBorder = Color(0xFFEEDFD9);
const _kPeachBd = Color(0xFFD9B49E);

class MemoryViewer {
  /// Opens the detail viewer corresponding to the memory type (when unlocked).
  static void show(BuildContext context, CapsuleMemory memory) {
    switch (memory.type) {
      case MemoryType.photo:
        _showPhotoViewer(context, memory);
        break;
      case MemoryType.video:
        _showVideoViewer(context, memory);
        break;
      case MemoryType.letter:
        _showLetterViewer(context, memory);
        break;
      case MemoryType.voice:
        _showVoiceViewer(context, memory);
        break;
    }
  }

  /// Shows the sealed bottom sheet when user taps a memory in a locked capsule.
  static void showSealedSheet(
    BuildContext context, {
    required String unlockDate,
    String? countdownString,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFDF8F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
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
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECDB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: _kBrown, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Memory is Sealed',
              style: TextStyle(
                color: _kBrownDeep,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This memory is sealed until $unlockDate${countdownString != null && countdownString.isNotEmpty ? ' ($countdownString)' : ''}.\nContent will be revealed when the capsule unlocks.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPhotoViewer(BuildContext context, CapsuleMemory memory) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImageWidget(memory.content),
                  ),
                  const SizedBox(height: 14),
                  if (memory.title != null && memory.title!.isNotEmpty)
                    Text(
                      memory.title!,
                      style: const TextStyle(
                        color: _kBrownDeep,
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (memory.caption != null && memory.caption!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      memory.caption!,
                      style: const TextStyle(color: _kBrown, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: _kMuted),
                      const SizedBox(width: 4),
                      Text('Added by ${memory.addedBy}', style: const TextStyle(color: _kMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, height: 260, width: double.infinity, fit: BoxFit.cover);
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, height: 260, width: double.infinity, fit: BoxFit.cover);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, height: 260, width: double.infinity, fit: BoxFit.cover);
      }
      return Image.asset('assets/images/login_image.jpg', height: 260, width: double.infinity, fit: BoxFit.cover);
    }
  }

  static void _showVideoViewer(BuildContext context, CapsuleMemory memory) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _VideoPlayerModal(memory: memory),
    );
  }

  static void _showLetterViewer(BuildContext context, CapsuleMemory memory) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8C5A8), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x334D3022), blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.mail_outline_rounded, color: Color(0xFFC17B4F), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'A Sealed Letter',
                        style: TextStyle(
                          color: _kBrownDeep,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: _kMuted, size: 20),
                  ),
                ],
              ),
              const Divider(color: _kBorder, height: 20),
              if (memory.title != null && memory.title!.isNotEmpty) ...[
                Text(
                  memory.title!,
                  style: const TextStyle(
                    color: _kBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Text(
                    memory.content.isNotEmpty ? memory.content : 'No letter text recorded.',
                    style: const TextStyle(
                      color: Color(0xFF4A352F),
                      fontSize: 14,
                      height: 1.6,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: _kBorder, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('From: ${memory.addedBy}', style: const TextStyle(color: _kMuted, fontSize: 12, fontStyle: FontStyle.italic)),
                  Text(
                    '${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}',
                    style: const TextStyle(color: _kMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showVoiceViewer(BuildContext context, CapsuleMemory memory) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _VoicePlayerSheet(memory: memory),
    );
  }
}

// ── Video Player Modal ────────────────────────────────────────────────────────

class _VideoPlayerModal extends StatefulWidget {
  const _VideoPlayerModal({required this.memory});
  final CapsuleMemory memory;

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(widget.memory.title ?? 'Video Memory', style: const TextStyle(fontSize: 15)),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MemoryViewer._buildImageWidget(
                  widget.memory.content.isNotEmpty ? widget.memory.content : 'assets/images/gal_vihara.png',
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Slider(
                  value: _progress,
                  activeColor: _kBrown,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _progress = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0:${(_progress * 45).toInt().toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(
                      'Added by ${widget.memory.addedBy}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '0:${(widget.memory.durationSeconds ?? 45).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Voice Player Sheet ────────────────────────────────────────────────────────

class _VoicePlayerSheet extends StatefulWidget {
  const _VoicePlayerSheet({required this.memory});
  final CapsuleMemory memory;

  @override
  State<_VoicePlayerSheet> createState() => _VoicePlayerSheetState();
}

class _VoicePlayerSheetState extends State<_VoicePlayerSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    if (widget.memory.durationSeconds != null) {
      _duration = Duration(seconds: widget.memory.durationSeconds!);
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (widget.memory.content.isNotEmpty && File(widget.memory.content).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(widget.memory.content));
      } else {
        // Fallback simulation toggle
        setState(() => _isPlaying = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
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
          const Icon(Icons.graphic_eq_rounded, color: _kBrown, size: 40),
          const SizedBox(height: 10),
          Text(
            widget.memory.title ?? 'Voice Note Memory',
            style: const TextStyle(
              color: _kBrownDeep,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recorded by ${widget.memory.addedBy}',
            style: const TextStyle(color: _kMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          // Animated Waveform Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(24, (i) {
              final heights = [10, 18, 26, 38, 20, 14, 30, 42, 28, 16, 22, 34, 18, 24, 36, 40, 22, 12, 28, 32, 20, 16, 12, 8];
              final h = heights[i % heights.length].toDouble();
              final active = _isPlaying;
              return Container(
                width: 4,
                height: active ? h : (h * 0.4).clamp(6.0, 40.0),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? _kBrown : _kPeachBd,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: _kMuted, fontSize: 11),
              ),
              Text(
                '${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: _kMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _toggleAudio,
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: _kBrown,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x3384321F), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
