import 'package:flutter/material.dart';

class NotificationItemData {
  const NotificationItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.avatarAsset,
    this.avatarUrl,
    this.icon,
    this.isUnread = false,
    this.timestamp,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String? avatarAsset;
  final String? avatarUrl;
  final IconData? icon;
  final bool isUnread;
  final DateTime? timestamp;

  NotificationItemData copyWith({
    bool? isUnread,
    String? timeAgo,
  }) => NotificationItemData(
    id: id,
    title: title,
    subtitle: subtitle,
    timeAgo: timeAgo ?? this.timeAgo,
    avatarAsset: avatarAsset,
    avatarUrl: avatarUrl,
    icon: icon,
    isUnread: isUnread ?? this.isUnread,
    timestamp: timestamp,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'timeAgo': timeAgo,
    'avatarAsset': avatarAsset,
    'avatarUrl': avatarUrl,
    'iconCode': icon?.codePoint,
    'isUnread': isUnread,
    'timestamp': timestamp?.toIso8601String(),
  };

  factory NotificationItemData.fromJson(Map<String, dynamic> json) => NotificationItemData(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    timeAgo: json['timeAgo'] as String? ?? 'Just now',
    avatarAsset: json['avatarAsset'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    icon: _iconFromCode(json['iconCode'] as int?),
    isUnread: json['isUnread'] as bool? ?? false,
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String)
        : null,
  );

  static IconData? _iconFromCode(int? code) {
    if (code == null) return null;
    switch (code) {
      case 0xe25b:
      case 0xf07c:
        return Icons.favorite_rounded;
      case 0xe153:
      case 0xf028:
        return Icons.chat_bubble_outline_rounded;
      case 0xe2a8:
        return Icons.forum_outlined;
      case 0xf62a:
        return Icons.celebration_outlined;
      case 0xe134:
        return Icons.campaign_outlined;
      case 0xf137:
        return Icons.inventory_2_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}

class NotificationItemTile extends StatelessWidget {
  const NotificationItemTile({super.key, required this.data, this.onTap});

  final NotificationItemData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadingAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C1E1A),
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data.timeAgo,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8C7E77),
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (data.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9E4B33),
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(width: 8, height: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF796860),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar() {
    if (data.icon != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF4A352F),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(data.icon, color: const Color(0xFFF5EBE1), size: 22),
        ),
      );
    }

    if (data.avatarUrl != null && data.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          data.avatarUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackAvatar(),
        ),
      );
    }

    if (data.avatarAsset != null && data.avatarAsset!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          data.avatarAsset!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackAvatar(),
        ),
      );
    }

    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    final initials = data.title.isNotEmpty ? data.title.substring(0, 1) : '?';
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFE2D6CC),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF4A352F),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
