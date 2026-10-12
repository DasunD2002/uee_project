import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import 'widgets/notification_item_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItemData> todayNotifications = [];
  List<NotificationItemData> yesterdayNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final dynamicItems = await NotificationService().getInAppNotifications();

    if (dynamicItems.isNotEmpty) {
      final now = DateTime.now();
      final today = <NotificationItemData>[];
      final earlier = <NotificationItemData>[];

      for (final item in dynamicItems) {
        if (item.timestamp != null) {
          final diff = now.difference(item.timestamp!);
          if (diff.inHours < 24) {
            final timeAgoStr = diff.inMinutes < 1
                ? 'Just now'
                : diff.inMinutes < 60
                    ? '${diff.inMinutes}m ago'
                    : '${diff.inHours}h ago';
            today.add(item.copyWith(timeAgo: timeAgoStr));
          } else {
            earlier.add(item.copyWith(timeAgo: 'Yesterday'));
          }
        } else {
          today.add(item);
        }
      }

      if (mounted) {
        setState(() {
          todayNotifications = today;
          yesterdayNotifications = earlier.isNotEmpty
              ? earlier
              : [
                  const NotificationItemData(
                    id: 'default_vault',
                    title: 'Vault Security: Cloud Sync Active',
                    subtitle: 'Your memories and cultural discoveries are protected.',
                    timeAgo: 'Yesterday',
                    icon: Icons.verified_user_outlined,
                    isUnread: false,
                  ),
                ];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          todayNotifications = [
            const NotificationItemData(
              id: 'welcome_1',
              title: 'Welcome to Rootly!',
              subtitle: 'Create your first time capsule or explore Sri Lankan heritage sites.',
              timeAgo: 'Just now',
              icon: Icons.auto_awesome,
              isUnread: true,
            ),
          ];
          yesterdayNotifications = [
            const NotificationItemData(
              id: 'default_vault',
              title: 'Vault Status: Ready',
              subtitle: 'Your heirloom vault is initialized and ready to preserve moments.',
              timeAgo: 'Yesterday',
              icon: Icons.verified_user_outlined,
              isUnread: false,
            ),
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    await NotificationService().markAllAsRead();
    setState(() {
      todayNotifications = todayNotifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
      yesterdayNotifications = yesterdayNotifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleItemRead(String id, bool isToday) async {
    await NotificationService().markAsRead(id);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF84321F)),
            )
          : SingleChildScrollView(
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
            border: Border.all(color: const Color(0xFFEFE8E1), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
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
