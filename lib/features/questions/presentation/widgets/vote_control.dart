import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class VoteControl extends StatelessWidget {
  const VoteControl({
    super.key,
    required this.count,
    required this.selection,
    required this.onUpvote,
    required this.onDownvote,
    this.compact = true,
  });

  final int count;
  final int selection;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 31 : 38,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8D8CD)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoteButton(
          tooltip: 'Upvote',
          icon: Icons.arrow_upward_rounded,
          selected: selection == 1,
          onPressed: onUpvote,
          compact: compact,
        ),
        Text(
          '$count',
          key: const ValueKey('vote-count'),
          style: TextStyle(
            color: selection == 0 ? const Color(0xFF594943) : AppColors.brown,
            fontSize: compact ? 11 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        _VoteButton(
          tooltip: 'Downvote',
          icon: Icons.arrow_downward_rounded,
          selected: selection == -1,
          onPressed: onDownvote,
          compact: compact,
        ),
      ],
    ),
  );
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
    required this.compact,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    constraints: BoxConstraints.tightFor(
      width: compact ? 28 : 34,
      height: compact ? 30 : 37,
    ),
    icon: Icon(
      icon,
      size: compact ? 17 : 20,
      color: selected ? AppColors.brown : const Color(0xFF8A776D),
    ),
  );
}
