import 'package:flutter/material.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import 'widgets/notification_item_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItemData> todayNotifications;
  late List<NotificationItemData> yesterdayNotifications;

  @override
  void initState() {
    super.initState();
    todayNotifications = [
      const NotificationItemData(
        id: 'today_1',
        title: 'Kumari Devi added a photo to the Family Capsule',
        subtitle: 'New memory shared in "Sinhala New Year 2024"',
        timeAgo: '2h ago',
        avatarAsset: 'assets/images/profile_avatar.png',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
        isUnread: true,
      ),
      const NotificationItemData(
        id: 'today_2',
        title: 'System: Weekly Digest is ready',
        subtitle:
            "Review your family's archival activity from this past week.",
        timeAgo: '5h ago',
        icon: Icons.article_outlined,
        isUnread: false,
      ),
    ];

    yesterdayNotifications = [
      const NotificationItemData(
        id: 'yesterday_1',
        title:
            "Saman Kumara left an audio note on Grandson's 18th Birthday",
        subtitle: '"Wishing you all the best on your journey ahead..."',
        timeAgo: 'Yesterday',
        avatarAsset: 'assets/images/dinesh_avatar.png',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        isUnread: false,
      ),
      const NotificationItemData(
        id: 'yesterday_2',
        title: 'Vault Update: Security Check Completed',
        subtitle:
            'Your digital heirlooms remain securely sealed and backed up.',
        timeAgo: 'Yesterday',
        icon: Icons.verified_user_outlined,
        isUnread: false,
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      todayNotifications = todayNotifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
      yesterdayNotifications = yesterdayNotifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleItemRead(String id, bool isToday) {
    setState(() {
      if (isToday) {
        todayNotifications = todayNotifications.map((item) {
          if (item.id == id) {
            return item.copyWith(isUnread: false);
          }
          return item;
        }).toList();
      } else {
        yesterdayNotifications = yesterdayNotifications.map((item) {
          if (item.id == id) {
            return item.copyWith(isUnread: false);
          }
          return item;
        }).toList();
      }
    });
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else if (index == 1) {
      Navigator.pushNamed(context, '/explorer');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/capsule');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2C1E1A),
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'serif',
            color: Color(0xFF2C1E1A),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: _markAllAsRead,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: Color(0xFF5E4B43),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Today',
              items: todayNotifications,
              isToday: true,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Yesterday',
              items: yesterdayNotifications,
              isToday: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: null,
        onSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<NotificationItemData> items,
    required bool isToday,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E1E19),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFEFE8E1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                NotificationItemTile(
                  data: items[i],
                  onTap: () => _toggleItemRead(items[i].id, isToday),
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF2ECE5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
