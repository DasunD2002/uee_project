import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
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
    final lower = path.toLowerCase();
    final isVid = lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.3gp');
    if (isVid) {
      return Image.asset('assets/images/gal_vihara.png', height: 260, width: double.infinity, fit: BoxFit.cover);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, o, s) => Image.asset('assets/images/gal_vihara.png', height: 260, width: double.infinity, fit: BoxFit.cover),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, o, s) => Image.asset('assets/images/gal_vihara.png', height: 260, width: double.infinity, fit: BoxFit.cover),
      );
    } else {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, o, s) => Image.asset('assets/images/gal_vihara.png', height: 260, width: double.infinity, fit: BoxFit.cover),
          );
        }
      } catch (_) {}
      return Image.asset('assets/images/gal_vihara.png', height: 260, width: double.infinity, fit: BoxFit.cover);
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
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isLoading = true;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 30);
  String _currentSource = '';
  Timer? _simTimer;

  @override
  void initState() {
    super.initState();
    _currentSource = widget.memory.content.isNotEmpty
        ? widget.memory.content
        : 'assets/videos/family_temple_video.mp4';
    _setupController(_currentSource);
  }

  Future<void> _setupController(String source) async {
    setState(() {
      _isLoading = true;
      _currentSource = source;
    });

    _simTimer?.cancel();
    final prev = _controller;
    _controller = null;
    await prev?.dispose();

    try {
      VideoPlayerController c;
      if (source.startsWith('http://') || source.startsWith('https://')) {
        c = VideoPlayerController.networkUrl(Uri.parse(source));
      } else if (source.startsWith('assets/')) {
        c = VideoPlayerController.asset(source);
      } else {
        final f = File(source);
        if (await f.exists()) {
          c = VideoPlayerController.file(f);
        } else {
          c = VideoPlayerController.asset('assets/videos/family_temple_video.mp4');
        }
      }

      await c.initialize().timeout(const Duration(seconds: 3));
      c.setLooping(false);
      c.addListener(_onVideoUpdate);
      if (mounted) {
        setState(() {
          _controller = c;
          _isLoading = false;
          _duration = c.value.duration;
        });
      }
    } catch (_) {
      // If primary source failed and wasn't default asset, try default asset
      if (source != 'assets/videos/family_temple_video.mp4') {
        _setupController('assets/videos/family_temple_video.mp4');
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _duration = widget.memory.durationSeconds != null
                ? Duration(seconds: widget.memory.durationSeconds!)
                : const Duration(seconds: 30);
          });
        }
      }
    }
  }

  void _onVideoUpdate() {
    if (!mounted || _controller == null) return;
    final val = _controller!.value;
    setState(() {
      _isPlaying = val.isPlaying;
      _position = val.position;
      if (val.duration.inSeconds > 0) {
        _duration = val.duration;
      }
    });
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        if (_controller!.value.position >= _controller!.value.duration) {
          _controller!.seekTo(Duration.zero);
        }
        _controller!.play();
      }
      return;
    }

    // Fallback simulated playback (for desktop or when native decoder is unavailable)
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      if (_position >= _duration) {
        _position = Duration.zero;
      }
      _simTimer?.cancel();
      _simTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          final nextMs = _position.inMilliseconds + 250;
          if (nextMs >= _duration.inMilliseconds) {
            _position = _duration;
            _isPlaying = false;
            timer.cancel();
          } else {
            _position = Duration(milliseconds: nextMs);
          }
        });
      });
    } else {
      _simTimer?.cancel();
    }
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  Future<void> _pickNewVideo(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(source: source);
      if (picked != null) {
        await _setupController(picked.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: _kBrownDeep,
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Video posted successfully! ✦', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not load video: $e'),
          ),
        );
      }
    }
  }

  void _showEnterUrlDialog() {
    final textCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Post Video from URL', style: TextStyle(color: _kBrownDeep, fontSize: 16)),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://example.com/video.mp4',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kBrown),
            onPressed: () {
              final url = textCtrl.text.trim();
              Navigator.pop(ctx);
              if (url.isNotEmpty) {
                _setupController(url);
              }
            },
            child: const Text('Post Video'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = _controller?.value.isInitialized ?? false;
    final progressVal = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final isEnded = isInitialized && _position >= _duration && _duration > Duration.zero;

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AppBar
          AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(widget.memory.title ?? 'Watch Family Video', style: const TextStyle(fontSize: 15)),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                tooltip: _isMuted ? 'Unmute' : 'Mute',
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white70,
                ),
                onPressed: _toggleMute,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                tooltip: 'Post Video Options',
                onSelected: (val) {
                  if (val == 'gallery') {
                    _pickNewVideo(ImageSource.gallery);
                  } else if (val == 'camera') {
                    _pickNewVideo(ImageSource.camera);
                  } else if (val == 'url') {
                    _showEnterUrlDialog();
                  } else if (val == 'default') {
                    _setupController('assets/videos/family_temple_video.mp4');
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.video_library_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Post from Gallery'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'camera',
                    child: Row(
                      children: [
                        Icon(Icons.videocam_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Record New Video'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'url',
                    child: Row(
                      children: [
                        Icon(Icons.link_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Post from Video URL'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.refresh_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Gal Vihara Heritage Video'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Video View Area
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: isInitialized && _controller!.value.aspectRatio > 0
                  ? _controller!.value.aspectRatio
                  : 16 / 9,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    if (isInitialized)
                      VideoPlayer(_controller!)
                    else
                      MemoryViewer._buildImageWidget(
                        'assets/images/gal_vihara.png',
                      ),

                    // Loading indicator
                    if (_isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),

                    // Center Play/Pause/Replay overlay
                    if (!_isLoading)
                      Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: !_isPlaying || isEnded ? 1.0 : 0.0,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              isEnded
                                  ? Icons.replay_rounded
                                  : _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Timeline scrubber & caption controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: progressVal,
                    activeColor: _kBrown,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      final targetMs = (v * _duration.inMilliseconds).toInt();
                      if (_controller != null && isInitialized) {
                        _controller!.seekTo(Duration(milliseconds: targetMs));
                      } else {
                        setState(() {
                          _position = Duration(milliseconds: targetMs);
                        });
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      widget.memory.caption != null && widget.memory.caption!.isNotEmpty
                          ? widget.memory.caption!
                          : 'Added by ${widget.memory.addedBy}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quick Post/Change Video Button
                InkWell(
                  onTap: () => _pickNewVideo(ImageSource.gallery),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: Colors.white60, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Post or change video',
                          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
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

  Timer? _simAudioTimer;

  @override
  void dispose() {
    _simAudioTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      _simAudioTimer?.cancel();
      try {
        await _audioPlayer.pause();
      } catch (_) {}
      if (mounted) setState(() => _isPlaying = false);
    } else {
      bool playedNatively = false;
      if (widget.memory.content.isNotEmpty && File(widget.memory.content).existsSync()) {
        try {
          await _audioPlayer.play(DeviceFileSource(widget.memory.content));
          playedNatively = true;
        } catch (_) {}
      }
      if (!playedNatively) {
        // Fallback simulation toggle
        setState(() => _isPlaying = true);
        if (_position >= _duration) {
          _position = Duration.zero;
        }
        _simAudioTimer?.cancel();
        _simAudioTimer = Timer.periodic(const Duration(milliseconds: 250), (t) {
          if (!mounted) {
            t.cancel();
            return;
          }
          setState(() {
            final nextMs = _position.inMilliseconds + 250;
            if (nextMs >= _duration.inMilliseconds) {
              _position = _duration;
              _isPlaying = false;
              t.cancel();
            } else {
              _position = Duration(milliseconds: nextMs);
            }
          });
        });
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
