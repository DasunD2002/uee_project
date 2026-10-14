class ExploreCategory {
  const ExploreCategory({required this.id, required this.label});

  factory ExploreCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final label = json['label'];
    if (id is! String || id.isEmpty || label is! String || label.isEmpty) {
      throw const FormatException('Explore category payload is invalid.');
    }
    return ExploreCategory(id: id, label: label);
  }

  final String id;
  final String label;
}
