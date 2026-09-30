import '../edit_profile_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../domain/profile_photo_service.dart';
import '../../data/user_service.dart';

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
  final UserService _userService = UserService();
  String? avatarUrl, coverUrl;
  int followers = 0;
  int following = 0;

  Map<String, dynamic> details = {
    'name': '',
    'handle': '',
    'bio': '',
    'location': '',
  };

  bool loading = true, picking = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await _userService.getUserProfile();
      if (data == null) return;
      if (!mounted) return;
      setState(() {
        details['name'] = data['name'] ?? '';
        details['handle'] = data['handle'] ?? '';
        details['bio'] = data['bio'] ?? '';
        details['location'] = data['district'] ?? '';
        avatarUrl = data['photoUrl'];
        coverUrl = data['coverUrl'];
        followers = data['followerCount'] ?? 0;
        following = data['followingCount'] ?? 0;
      });
    } catch (_) {
      if (mounted) {
        message('Failed to load profile data.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> editDetails() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(details: Map<String, String>.from(details))),
    );
    if (result != null && mounted) {
      setState(() => loading = true);
      final success = await _userService.updateUserProfile({
        'name': result['name'],
        'handle': result['handle'],
        'bio': result['bio'],
        'district': result['location'],
      });
      if (success) {
        await loadData();
      } else {
        setState(() => loading = false);
        message('Failed to update profile.');
      }
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
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) throw StateError('Not logged in');

      final url = await uploadProfilePhoto(bytes, userId, isCover: isCover);
      
      final success = await _userService.updateUserProfile(
        isCover ? {'coverUrl': url} : {'photoUrl': url},
      );
      
      if (!success) throw StateError('Could not save photo URL');

      if (!mounted) return;
      setState(() {
        if (isCover) {
          coverUrl = url;
        } else {
          avatarUrl = url;
        }
      });
      message(isCover ? 'Cover photo updated.' : 'Profile photo updated.');
    } catch (_) {
      if (mounted) {
        message(
          'Could not update the photo. Please try again.',
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
            child: coverUrl == null
                ? Image.asset(
                    'assets/images/login_image.jpg',
                    key: const ValueKey('profile-cover-placeholder'),
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    coverUrl!,
                    key: const ValueKey('profile-cover-network'),
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
                          backgroundImage: avatarUrl == null
                              ? null
                              : NetworkImage(avatarUrl!),
                          child: avatarUrl == null
                              ? const Icon(Icons.person, size: 52, color: Colors.grey)
                              : null,
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
                    details['name'] ?? '',
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    details['handle'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details['bio'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.brown,
                        size: 17,
                      ),
                      Text(
                        details['location'] ?? '',
                        style: const TextStyle(
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
              _Stat('$followers', 'Followers'),
              const VerticalDivider(width: 1, color: Color(0xFFF3E8E2)),
              _Stat('$following', 'Following'),
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
