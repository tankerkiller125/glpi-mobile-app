import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/form_dto.dart';

void main() {
  group('Catalog level', () {
    final page = ServiceCatalogPageDto.fromJson(const {
      'expand_categories': true,
      'sort_strategy': 'popularity',
      'category_id': 0,
      'ancestors': [],
      'items': [
        {
          'kind': 'category',
          'id': 1,
          'name': 'General',
          'description': 'Everyday requests',
          'illustration': 'approve-requests',
          'pinned': false,
          'children': [
            {
              'kind': 'form',
              'id': 1,
              'name': 'Report an issue',
              'description': 'Ask for support.',
              'illustration': 'report-issue',
              'pinned': true,
            },
            {
              'kind': 'category',
              'id': 7,
              'name': 'Access Requests',
              'description': '',
              'illustration': '',
              'pinned': false,
              'children': [],
            },
          ],
        },
        {
          'kind': 'kb',
          'id': 4,
          'name': 'Password self-service',
          'description': 'Reset it yourself.',
          'illustration': '',
          'pinned': false,
        },
      ],
      'total': 2,
    });

    test('carries the entity display settings', () {
      expect(page.expandCategories, isTrue);
      expect(page.sortStrategy, 'popularity');
      expect(page.categoryId, 0);
      expect(page.title, isEmpty);
    });

    test('a category brings the one level of children the server loaded', () {
      final category = page.items.first;
      expect(category.isCategory, isTrue);
      expect(category.children, hasLength(2));
      expect(category.children.first.kind, ServiceCatalogItemKind.form);
      expect(category.children.first.pinned, isTrue);
      // A nested category arrives with no children of its own — it is a tile
      // you open, not a second section.
      expect(category.children.last.isCategory, isTrue);
      expect(category.children.last.children, isEmpty);
    });

    test('knowledge articles are listed beside the forms', () {
      expect(page.items.last.kind, ServiceCatalogItemKind.kb);
      expect(page.items.last.id, 4);
    });

    test('order is left exactly as the server sent it', () {
      // Pinned first, then categories, then the entity's sort strategy — all
      // decided server-side. Re-sorting here would silently disagree with the
      // portal the same technician uses at a desk.
      expect(
        page.items.map((i) => i.kind).toList(),
        [ServiceCatalogItemKind.category, ServiceCatalogItemKind.kb],
      );
    });
  });

  group('Breadcrumb', () {
    test('names the level being looked at, root first', () {
      final page = ServiceCatalogPageDto.fromJson(const {
        'category_id': 7,
        'ancestors': [
          {'id': 5, 'name': 'Accounts'},
          {'id': 7, 'name': 'Access Requests'},
        ],
        'items': [],
        'total': 0,
      });

      expect(page.ancestors.map((a) => a.name).toList(), [
        'Accounts',
        'Access Requests',
      ]);
      expect(page.title, 'Access Requests');
      expect(page.isEmpty, isTrue);
    });
  });

  group('Tolerance', () {
    test('an item type this app has never heard of parses as unknown', () {
      final page = ServiceCatalogPageDto.fromJson(const {
        'items': [
          {'kind': 'chatbot', 'id': 9, 'name': 'Ask the bot'},
        ],
      });
      expect(page.items.single.kind, ServiceCatalogItemKind.unknown);
    });

    test('an empty body is an empty level, not an error', () {
      final page = ServiceCatalogPageDto.fromJson(const {});
      expect(page.items, isEmpty);
      expect(page.expandCategories, isFalse);
      expect(page.categoryId, 0);
    });
  });

  group('Older servers', () {
    test('the flat form list becomes one uncategorised level', () {
      final page = ServiceCatalogPageDto.flat(const [
        FormSummaryDto(
          id: 3,
          name: 'Access Request',
          description: 'Ask for access',
          illustration: 'scim',
        ),
      ]);

      expect(page.expandCategories, isFalse);
      expect(page.ancestors, isEmpty);
      expect(page.items.single.kind, ServiceCatalogItemKind.form);
      expect(page.items.single.id, 3);
      expect(page.total, 1);
    });
  });
}
