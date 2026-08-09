import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/models/entity_node.dart';
import 'package:glpi_mobile/core/models/session_info.dart';

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync());

void main() {
  group('SessionInfo', () {
    test('parses the captured /session fixture', () {
      final session = SessionInfo.fromJson(
        fixture('session.json')! as Map<String, Object?>,
      );
      expect(session.userId, 2);
      expect(session.username, 'glpi');
      expect(session.groupIds, isEmpty);
      expect(session.profiles, hasLength(1));
      final profile = session.profiles.single;
      expect(profile.id, 4);
      expect(profile.name, 'Super-Admin');
      expect(profile.entities.single.id, 0);
      expect(profile.entities.single.isRecursive, isTrue);
      expect(session.activeProfileId, 4);
    });
  });

  group('EntityNode', () {
    test('parses the captured /Session/EntityTree fixture', () {
      final roots = EntityNode.listFromJson(
        fixture('entity_tree.json')! as List<Object?>,
      );
      expect(roots, hasLength(1));
      expect(roots.single.id, 0);
      expect(roots.single.label, 'Root entity');
      expect(roots.single.children, hasLength(5));
      expect(
        roots.single.children.map((e) => e.label),
        containsAll([
          'Acme Corp',
          'Beta Industries',
          'Gamma LLC',
          'Delta Managed',
        ]),
      );
    });

    test('flatten yields depth-first order with depths', () {
      final roots = EntityNode.listFromJson(
        fixture('entity_tree.json')! as List<Object?>,
      );
      final flat = EntityNode.flatten(roots);
      expect(flat.first.$1.id, 0);
      expect(flat.first.$2, 0);
      expect(flat[1].$2, 1); // first child is one level deep
      expect(flat, hasLength(6));
    });
  });
}
