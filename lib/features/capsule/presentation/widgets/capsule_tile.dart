import 'package:flutter/material.dart';
import '../../../capsules/data/capsule_store.dart';

class CapsuleTile extends StatelessWidget {
  const CapsuleTile({super.key, required this.capsule});
  final Map<String, dynamic> capsule;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(13),
      leading: SizedBox(
        width: 66,
        height: 66,
        child:
            capsule['coverPhotoUrl'] is String &&
                (capsule['coverPhotoUrl'] as String).isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  capsule['coverPhotoUrl'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.inventory_2_outlined),
                ),
              )
            : const Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: Color(0xFF84321F),
              ),
      ),
      title: Text(
        capsule['title'] as String? ?? 'Untitled capsule',
        style: const TextStyle(
          color: Color(0xFF493027),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        '${capsule['type'] ?? 'personal'} · ${capsule['status'] ?? 'open'}',
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF84321F)),
      onTap: () {
        CapsuleStore.instance.select(capsule);
        Navigator.pushNamed(context, '/family-receipt');
      },
    ),
  );
}
