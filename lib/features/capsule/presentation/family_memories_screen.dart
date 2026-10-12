import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/capsule_service.dart';
import '../domain/capsule_memory.dart';
import '../domain/capsule_model.dart';
import 'widgets/add_memory_picker_sheet.dart';
import 'widgets/memory_viewer_sheet.dart';

const _kBrown = Color(0xFF84321F);
const _kBrownDeep = Color(0xFF5A1E0E);
const _kMuted = Color(0xFFA07060);
const _kPeach = Color(0xFFFFF3E8);

class FamilyMemoriesScreen extends StatefulWidget {
  const FamilyMemoriesScreen({super.key});

  @override
  State<FamilyMemoriesScreen> createState() => _FamilyMemoriesScreenState();
}

class _FamilyMemoriesScreenState extends State<FamilyMemoriesScreen>
    with SingleTickerProviderStateMixin {
  final CapsuleService _capsuleService = CapsuleService();
  CapsuleModel? _capsule;
  bool _isLoading = false;

  // Reveal animation for unlocked state (Step 8)
  late final AnimationController _revealCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
    CurvedAnimation(parent: _revealCtrl, curve: Curves.elasticOut),
  );
  late final Animation<double> _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _revealCtrl, curve: Curves.easeIn),
  );
  bool _showRevealOverlay = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CapsuleModel && _capsule == null) {
      _capsule = args;
      _checkUnlockReveal();
    } else if (_capsule == null) {
      _loadDefaultCapsule();
    }
  }

  Future<void> _loadDefaultCapsule() async {
    setState(() => _isLoading = true);
    final list = await _capsuleService.getCapsules();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (list.isNotEmpty) {
          _capsule = list.first;
          _checkUnlockReveal();
        }
      });
    }
  }

  void _checkUnlockReveal() {
    if (_capsule?.isUnlocked() == true) {
      setState(() => _showRevealOverlay = true);
      _revealCtrl.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _showRevealOverlay = false);
        });
      });
    }
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  void _handleMemoryTap(CapsuleMemory memory) {
    if (_capsule?.isLocked() == true) {
      MemoryViewer.showSealedSheet(
        context,
        unlockDate: _capsule?.formattedUnlockDate ?? 'Future Date',
        countdownString: _capsule?.countdownString,
      );
    } else {
      MemoryViewer.show(context, memory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final capsule = _capsule;
    final isLocked = capsule?.isLocked() ?? true;
    final memories = capsule?.memories ?? CapsuleService.defaultMemories();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFECEE),
        foregroundColor: AppColors.brown,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Rootly',
          style: TextStyle(
            color: AppColors.brown,
            fontFamily: 'serif',
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Icon(Icons.notifications_none_rounded, size: 23),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _kBrown))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header title row
                        Row(
                          children: [
                            _RoundBackButton(onPressed: () => Navigator.pop(context)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capsule?.title ?? 'Family Recipe',
                                    style: const TextStyle(
                                      color: AppColors.brown,
                                      fontFamily: 'serif',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    isLocked
                                        ? 'Sealed Capsule Memories'
                                        : '✦ Unlocked Time Capsule ✦',
                                    style: TextStyle(
                                      color: isLocked ? _kMuted : Colors.green[800],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFFEEDFD9), height: 1),
                        const SizedBox(height: 16),

                        // Status Banner (Locked vs Unlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isLocked ? const Color(0xFFFFF3E8) : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isLocked ? const Color(0xFFE8C5A8) : Colors.green.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLocked ? Icons.lock_clock_rounded : Icons.lock_open_rounded,
                                color: isLocked ? _kBrown : Colors.green.shade800,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLocked
                                          ? 'These memories are sealed until ${capsule?.formattedUnlockDate ?? "the unlock date"}'
                                          : 'This capsule is now open!',
                                      style: TextStyle(
                                        color: isLocked ? _kBrownDeep : Colors.green.shade900,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isLocked
                                          ? '${capsule?.countdownString ?? "Countdown in progress"}. Tap any card to view seal details.'
                                          : 'All memories are ready to view. Tap any card below to open.',
                                      style: TextStyle(
                                        color: isLocked ? _kMuted : Colors.green.shade800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Memory Grid or Empty State
                        if (memories.isEmpty)
                          _buildEmptyState(context, isLocked)
                        else
                          _buildMemoryGrid(memories, isLocked),

                        const SizedBox(height: 30),
                        const Divider(color: Color(0xFFEEDFD9), height: 1),
                        const SizedBox(height: 18),

                        // Bottom Action CTA
                        SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/response-capsule'),
                            icon: const Icon(Icons.hub_outlined, size: 17),
                            label: const Text(
                              'Create a Response Capsule',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD6B6),
                              foregroundColor: AppColors.brown,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // First-time reveal animation overlay (Step 8)
          if (_showRevealOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Color(0x664D3022), blurRadius: 30, offset: Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_open_rounded, color: Colors.green, size: 42),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Capsule Unlocked! ✦',
                              style: TextStyle(
                                color: _kBrownDeep,
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'The seal has broken. All preserved family memories are revealed!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _kMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemoryGrid(List<CapsuleMemory> memories, bool isLocked) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: memories.length,
      itemBuilder: (ctx, i) {
        final memory = memories[i];
        return _PolaroidTile(
          memory: memory,
          isLocked: isLocked,
          onTap: () => _handleMemoryTap(memory),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isLocked) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: _kPeach, shape: BoxShape.circle),
            child: const Icon(Icons.inbox_rounded, color: _kBrown, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Memories Added Yet',
            style: TextStyle(color: _kBrownDeep, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sealed memories will appear here once added to this capsule.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kMuted, fontSize: 12),
          ),
          if (isLocked) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                final mem = await AddMemoryPickerSheet.show(context);
                if (mem != null && mounted) {
                  final updated = await _capsuleService.addMemory(_capsule?.id ?? '', mem);
                  if (updated != null) {
                    setState(() => _capsule = updated);
                  }
                }
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add First Memory'),
              style: FilledButton.styleFrom(
                backgroundColor: _kBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 32,
        height: 32,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.brown,
            side: const BorderSide(color: Color(0xFFE9D9D3)),
            shape: const CircleBorder(),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 13),
        ),
      );
}

class _PolaroidTile extends StatelessWidget {
  const _PolaroidTile({
    required this.memory,
    required this.isLocked,
    required this.onTap,
  });

  final CapsuleMemory memory;
  final bool isLocked;
  final VoidCallback onTap;

  IconData _getTypeIcon() {
    switch (memory.type) {
      case MemoryType.photo:
        return Icons.photo_camera_rounded;
      case MemoryType.video:
        return Icons.videocam_rounded;
      case MemoryType.letter:
        return Icons.mail_outline_rounded;
      case MemoryType.voice:
        return Icons.mic_rounded;
    }
  }

  Widget _buildContent() {
    if (isLocked) {
      // Frosted/sealed locked state: blur and icon
      return Container(
        color: const Color(0xFFFFF0E6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getTypeIcon(), size: 28, color: _kBrown.withAlpha(160)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8C5A8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, size: 10, color: _kBrown),
                      const SizedBox(width: 4),
                      Text(
                        'Sealed ${memory.type.displayName}',
                        style: const TextStyle(color: _kBrown, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Unlocked state: actual preview content
    switch (memory.type) {
      case MemoryType.photo:
        return _buildPhotoWidget(memory.content);
      case MemoryType.video:
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildPhotoWidget(memory.content),
            Container(color: Colors.black26),
            const Center(
              child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 34),
            ),
            if (memory.durationSeconds != null)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '0:${memory.durationSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      case MemoryType.letter:
        return Container(
          color: const Color(0xFFFFFBF7),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline_rounded, size: 28, color: Color(0xFFC17B4F)),
              const SizedBox(height: 6),
              Text(
                memory.title ?? 'A Letter for you',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _kBrown, fontSize: 10.5, fontFamily: 'serif', fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case MemoryType.voice:
        return Container(
          color: const Color(0xFFFFFAF5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: _kPeach, shape: BoxShape.circle),
                child: const Icon(Icons.mic_rounded, color: _kBrown, size: 22),
              ),
              const SizedBox(height: 6),
              const Text(
                'Voice Blessing',
                style: TextStyle(color: _kBrown, fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              Text(
                '0:${(memory.durationSeconds ?? 30).toString().padLeft(2, '0')}',
                style: const TextStyle(color: _kMuted, fontSize: 9),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildPhotoWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else {
      try {
        final f = File(path);
        if (f.existsSync()) return Image.file(f, fit: BoxFit.cover);
      } catch (_) {}
      return Image.asset('assets/images/gal_vihara.png', fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0E1DB)),
          boxShadow: const [
            BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildContent()),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLocked
                        ? 'Sealed Memory'
                        : (memory.title ?? memory.type.displayName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Added by ${memory.addedBy}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFC2978D), fontSize: 9.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
