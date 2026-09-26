import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/capsule_model.dart';
import '../../data/capsule_service.dart';

const _kBrown = Color(0xFF84321F);
const _kBrownDeep = Color(0xFF5A1E0E);
const _kMuted = Color(0xFFA07060);
const _kBorder = Color(0xFFEEDFD9);

class ContributorSheet extends StatefulWidget {
  const ContributorSheet({super.key, required this.capsule, required this.onCapsuleUpdated});
  final CapsuleModel capsule;
  final ValueChanged<CapsuleModel> onCapsuleUpdated;

  static void show(BuildContext context, {required CapsuleModel capsule, required ValueChanged<CapsuleModel> onCapsuleUpdated}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContributorSheet(
        capsule: capsule,
        onCapsuleUpdated: onCapsuleUpdated,
      ),
    );
  }

  @override
  State<ContributorSheet> createState() => _ContributorSheetState();
}

class _ContributorSheetState extends State<ContributorSheet> {
  final CapsuleService _capsuleService = CapsuleService();
  late CapsuleModel _currentCapsule;
  final TextEditingController _nameCtrl = TextEditingController();

  static const _avatarColors = [
    Color(0xFFD4A89A),
    Color(0xFF9BC4B2),
    Color(0xFFA8BDD4),
    Color(0xFFE2B084),
    Color(0xFFB8A2CD),
  ];

  @override
  void initState() {
    super.initState();
    _currentCapsule = widget.capsule;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _shareInviteLink() {
    final link = 'https://rootly.app/capsule/${_currentCapsule.id ?? "family"}';
    final text = "Join my Time Capsule '${_currentCapsule.title}' on Rootly! We are preserving memories together until it unlocks on ${_currentCapsule.formattedUnlockDate}.\n\nJoin here: $link";
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: "Join '${_currentCapsule.title}' Time Capsule",
      ),
    );
  }

  Future<void> _addManualContributor() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final updated = await _capsuleService.addContributor(_currentCapsule.id ?? '', name);
    if (updated != null && mounted) {
      setState(() => _currentCapsule = updated);
      widget.onCapsuleUpdated(updated);
      _nameCtrl.clear();
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name as contributor!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final contributors = _currentCapsule.contributors.isNotEmpty
        ? _currentCapsule.contributors
        : ['Grandma', 'Uncle', 'You'];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 28 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9C4BC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Capsule Contributors',
                  style: TextStyle(
                    color: _kBrownDeep,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'serif',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECDB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${contributors.length} Members',
                    style: const TextStyle(color: _kBrown, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Anyone invited can add memories before unlock day',
              style: TextStyle(color: _kMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),

            // Contributor list
            ...List.generate(contributors.length, (i) {
              final name = contributors[i];
              final color = _avatarColors[i % _avatarColors.length];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: color,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(color: _kBrownDeep, fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                    if (name.toLowerCase() == 'you')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Creator', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 14),

            // Quick add by name
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add member by name…',
                      hintStyle: const TextStyle(color: _kMuted, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBrown)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: _kBrown, foregroundColor: Colors.white),
                  onPressed: _addManualContributor,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Native Share invite link button
            SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: _shareInviteLink,
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Share Invite Link', style: TextStyle(fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
