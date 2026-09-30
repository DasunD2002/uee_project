import 'package:flutter/material.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import 'widgets/notification_item_tile.dart';
import '../../Profile/domain/social_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void _markAllAsRead() {
    SocialStore.instance.markAllNotificationsAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleItemRead(String id) {
    SocialStore.instance.markNotificationAsRead(id);
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
      body: ListenableBuilder(
        listenable: SocialStore.instance,
        builder: (context, _) {
          final today = SocialStore.instance.notifications.where((n) => n.timeAgo != 'Yesterday').toList();
          final yesterday = SocialStore.instance.notifications.where((n) => n.timeAgo == 'Yesterday').toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (today.isNotEmpty) ...[
                  _buildSection(
                    title: 'Today',
                    items: today,
                  ),
                  const SizedBox(height: 24),
                ],
                if (yesterday.isNotEmpty)
                  _buildSection(
                    title: 'Yesterday',
                    items: yesterday,
                  ),
              ],
            ),
          );
        },
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
                  onTap: () => _toggleItemRead(items[i].id),
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
