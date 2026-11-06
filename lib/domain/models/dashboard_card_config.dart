import '../enums/card_type.dart';
import '../enums/card_size.dart';

/// Configuration for a card displayed on the dashboard.
class DashboardCardConfig {
  final String id;
  final CardType cardType;
  final CardSize size;
  final int position;
  final Map<String, dynamic> settings;

  const DashboardCardConfig({
    required this.id,
    required this.cardType,
    this.size = CardSize.medium,
    required this.position,
    this.settings = const {},
  });

  factory DashboardCardConfig.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    final typeName = json['card_type'] as String? ?? 'totalPlaytime';
    final cardType = CardType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => CardType.totalPlaytime,
    );

    final sizeName = json['size'] as String? ?? 'medium';
    final size = CardSize.values.firstWhere(
      (e) => e.name == sizeName,
      orElse: () => CardSize.medium,
    );

    return DashboardCardConfig(
      id: json['id'] as String? ?? fallbackId ?? '${typeName}_${json['position'] ?? 0}',
      cardType: cardType,
      size: size,
      position: json['position'] as int? ?? 0,
      settings: (json['settings'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_type': cardType.name,
      'size': size.name,
      'position': position,
      'settings': settings,
    };
  }

  DashboardCardConfig copyWith({
    String? id,
    CardType? cardType,
    CardSize? size,
    int? position,
    Map<String, dynamic>? settings,
  }) {
    return DashboardCardConfig(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      size: size ?? this.size,
      position: position ?? this.position,
      settings: settings ?? this.settings,
    );
  }
}
