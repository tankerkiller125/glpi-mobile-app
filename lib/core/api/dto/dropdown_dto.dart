/// A GLPI dropdown row (ITILCategory, Location, RequestType, …).
class DropdownDto {
  const DropdownDto({required this.id, required this.name});

  final int id;
  final String name;

  factory DropdownDto.fromJson(Map<String, Object?> json) => DropdownDto(
    id: (json['id'] as num).toInt(),
    name: (json['completename'] ?? json['name'] ?? '') as String,
  );
}

/// GLPI dropdown itemtypes the app caches, keyed by the `kind` used locally.
class DropdownKinds {
  static const category = 'ITILCategory';
  static const location = 'Location';
  static const requestType = 'RequestType';

  /// Asset/management status (GLPI's `State`), for the catalog edits.
  static const state = 'State';

  static const all = [category, location, requestType, state];
}
