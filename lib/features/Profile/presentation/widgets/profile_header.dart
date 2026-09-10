import '../edit_profile_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../domain/profile_photo_service.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key, required this.postCount});
  final int postCount;
  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  Uint8List? avatar, cover;
  Map<String, String> details = {
    'name': 'Amaya Wickrama',
    'handle': '@amaya.heritage',
    'bio':
        'Archivist documenting the temples, textiles\nand oral histories of the central highlands.',
    'location': 'Kandy, Sri Lanka',
  };
  Future<void> editDetails() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(details: details)),
    );
    if (result != null && mounted) {
      setState(() => details = result);
      await loadPhotos();
    }
  }

  bool loading = true, picking = false;

  @override
  void initState() {
    super.initState();
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedDetails = prefs.getString('profile.details');
      final loadedDetails = storedDetails == null
          ? null
          : Map<String, String>.from(jsonDecode(storedDetails) as Map);
      final storedAvatar = prefs.getString('profile.avatar');
      final storedCover = prefs.getString('profile.cover');
      if (!mounted) return;
      setState(() {
        if (loadedDetails != null) details = {...details, ...loadedDetails};
        avatar = storedAvatar == null ? null : base64Decode(storedAvatar);
        cover = storedCover == null ? null : base64Decode(storedCover);
      });
    } catch (_) {
      if (mounted) {
        message('Saved photos could not be loaded. You can choose them again.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> changePhoto({required bool isCover}) async {
    if (loading || picking) return;
    setState(() => picking = true);
    try {
      final bytes = await pickProfilePhoto(isCover: isCover);
      if (bytes == null) return;
      final encoded = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(
        isCover ? 'profile.cover' : 'profile.avatar',
        encoded,
      );
      if (!saved) throw StateError('Could not save photo');
      if (!mounted) return;
      setState(() {
        if (isCover) {
          cover = bytes;
        } else {
          avatar = bytes;
        }
      });
      message(isCover ? 'Cover photo updated.' : 'Profile photo updated.');
    } catch (_) {
      if (mounted) {
        message(
          'Could not update the photo. Please choose a valid JPG or PNG and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        children: [
          Positioned.fill(
            child: cover == null
                ? Image.asset(
                    'assets/images/login_image.jpg',
                    key: const ValueKey('profile-cover'),
                    fit: BoxFit.cover,
                  )
                : Image.memory(
                    cover!,
                    key: const ValueKey('profile-cover'),
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: .1),
                    const Color(0xFFFFF7E8).withValues(alpha: .96),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 62, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundImage: avatar == null
                              ? const AssetImage(
                                  'assets/images/profile_avatar.png',
                                )
                              : MemoryImage(avatar!),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton.filled(
                          tooltip: 'Change profile photo',
                          onPressed: loading || picking
                              ? null
                              : () => changePhoto(isCover: false),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.brown,
                          ),
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    details['name']!,
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    details['handle']!,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details['bio']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.brown,
                        size: 17,
                      ),
                      Text(
                        details['location']!,
                        style: TextStyle(
                          color: AppColors.brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 56,
            child: IconButton.filledTonal(
              tooltip: 'Change cover photo',
              onPressed: loading || picking
                  ? null
                  : () => changePhoto(isCover: true),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.brown,
              ),
              icon: const Icon(Icons.edit_outlined, size: 21),
            ),
          ),
          Positioned(
            left: 12,
            top: 8,
            child: FilledButton.tonalIcon(
              onPressed: loading ? null : editDetails,
              icon: const Icon(Icons.manage_accounts_outlined, size: 18),
              label: const Text('Edit Profile Data'),
            ),
          ),
          Positioned(
            right: 12,
            top: 8,
            child: IconButton.filledTonal(
              tooltip: 'Profile settings',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
          if (picking)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3E8E2))),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _Stat('${widget.postCount}', 'Posts'),
              const VerticalDivider(width: 1, color: Color(0xFFF3E8E2)),
              const _Stat('12.4k', 'Followers'),
              const VerticalDivider(width: 1, color: Color(0xFFF3E8E2)),
              const _Stat('286', 'Following'),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF95857F), fontSize: 12),
        ),
      ],
    ),
  );
}
