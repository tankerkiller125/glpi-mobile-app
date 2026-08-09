/// A reminder (`/Tools/Reminder`). GLPI names the planning window
/// `date_begin`/`date_end` on the wire (columns `begin`/`end`).
class ReminderDto {
  const ReminderDto({
    required this.id,
    required this.name,
    required this.text,
    required this.dateBegin,
    required this.dateEnd,
    required this.isPlanned,
    required this.state,
    required this.dateViewBegin,
    required this.dateViewEnd,
    required this.userId,
  });

  final int id;
  final String name;
  final String text;
  final String? dateBegin;
  final String? dateEnd;
  final bool isPlanned;
  final int state;
  final String? dateViewBegin;
  final String? dateViewEnd;
  final int? userId;

  factory ReminderDto.fromJson(Map<String, Object?> json) {
    final user = json['user'];
    return ReminderDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      text: (json['text'] ?? '') as String? ?? '',
      dateBegin: json['date_begin'] as String?,
      dateEnd: json['date_end'] as String?,
      isPlanned: json['is_planned'] == true,
      state: (json['state'] as num?)?.toInt() ?? 0,
      dateViewBegin: json['date_view_begin'] as String?,
      dateViewEnd: json['date_view_end'] as String?,
      userId: user is Map ? (user['id'] as num?)?.toInt() : null,
    );
  }
}

/// A knowledge base article (`/Knowledgebase/Article`).
class KbArticleDto {
  const KbArticleDto({
    required this.id,
    required this.name,
    required this.content,
    required this.isFaq,
    required this.views,
    required this.dateMod,
    required this.categoryId,
    required this.categoryName,
  });

  final int id;
  final String name;
  final String content;
  final bool isFaq;
  final int views;
  final String? dateMod;
  final int? categoryId;
  final String? categoryName;

  factory KbArticleDto.fromJson(Map<String, Object?> json) {
    // Articles carry a `categories` array; the app shows the first.
    int? catId;
    String? catName;
    final cats = json['categories'];
    if (cats is List && cats.isNotEmpty && cats.first is Map) {
      final c = cats.first as Map;
      catId = (c['id'] as num?)?.toInt();
      catName = (c['completename'] ?? c['name']) as String?;
    }
    return KbArticleDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      content: (json['content'] ?? '') as String? ?? '',
      isFaq: json['is_faq'] == true,
      views: (json['views'] as num?)?.toInt() ?? 0,
      dateMod: json['date_mod'] as String?,
      categoryId: catId,
      categoryName: catName,
    );
  }
}

/// A knowledge base category (`/Knowledgebase/Category`).
class KbCategoryDto {
  const KbCategoryDto({
    required this.id,
    required this.name,
    required this.completename,
  });

  final int id;
  final String name;
  final String completename;

  factory KbCategoryDto.fromJson(Map<String, Object?> json) => KbCategoryDto(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '') as String,
    completename: (json['completename'] ?? json['name'] ?? '') as String,
  );
}

/// A comment on a KB article.
class KbCommentDto {
  const KbCommentDto({
    required this.id,
    required this.comment,
    required this.authorName,
    required this.dateCreation,
  });

  final int id;
  final String comment;
  final String authorName;
  final String? dateCreation;

  factory KbCommentDto.fromJson(Map<String, Object?> json) {
    final user = json['user'];
    return KbCommentDto(
      id: (json['id'] as num).toInt(),
      comment: (json['comment'] ?? '') as String? ?? '',
      authorName: user is Map ? '${user['name'] ?? ''}' : '',
      dateCreation: json['date_creation'] as String?,
    );
  }
}

/// An RSS feed (`/Tools/RSSFeed`).
class RssFeedDto {
  const RssFeedDto({
    required this.id,
    required this.name,
    required this.url,
    required this.refreshRate,
  });

  final int id;
  final String name;
  final String url;
  final int refreshRate;

  factory RssFeedDto.fromJson(Map<String, Object?> json) => RssFeedDto(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '') as String,
    url: (json['url'] ?? '') as String? ?? '',
    refreshRate: (json['refresh_rate'] as num?)?.toInt() ?? 0,
  );
}

/// A reservable item (`/Tools/ReservationItem`).
class ReservationItemDto {
  const ReservationItemDto({
    required this.id,
    required this.itemtype,
    required this.itemsId,
    required this.name,
    required this.isActive,
  });

  final int id;
  final String itemtype;
  final int itemsId;
  final String name;
  final bool isActive;

  factory ReservationItemDto.fromJson(Map<String, Object?> json) {
    // The linked asset may arrive nested or flat depending on the schema depth.
    final item = json['item'];
    return ReservationItemDto(
      id: (json['id'] as num).toInt(),
      itemtype:
          '${json['itemtype'] ?? (item is Map ? item['itemtype'] : '') ?? ''}',
      itemsId:
          (json['items_id'] as num?)?.toInt() ??
          (item is Map ? (item['id'] as num?)?.toInt() ?? 0 : 0),
      name: item is Map ? '${item['name'] ?? ''}' : '${json['name'] ?? ''}',
      isActive: json['is_active'] != false,
    );
  }
}

/// A booking (`/Tools/Reservation`).
class ReservationDto {
  const ReservationDto({
    required this.id,
    required this.reservationItemId,
    required this.begin,
    required this.end,
    required this.comment,
    required this.userName,
    required this.userId,
  });

  final int id;
  final int reservationItemId;
  final String begin;
  final String end;
  final String comment;
  final String userName;
  final int? userId;

  factory ReservationDto.fromJson(Map<String, Object?> json) {
    final user = json['user'];
    final item = json['reservationitem'] ?? json['item'];
    return ReservationDto(
      id: (json['id'] as num).toInt(),
      reservationItemId:
          (json['reservationitems_id'] as num?)?.toInt() ??
          (item is Map ? (item['id'] as num?)?.toInt() ?? 0 : 0),
      begin: '${json['begin'] ?? json['date_begin'] ?? ''}',
      end: '${json['end'] ?? json['date_end'] ?? ''}',
      comment: (json['comment'] ?? '') as String? ?? '',
      userName: user is Map ? '${user['name'] ?? ''}' : '',
      userId: user is Map ? (user['id'] as num?)?.toInt() : null,
    );
  }
}
