import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item.freezed.dart';
part 'wishlist_item.g.dart';

/// Domain model for a wishlist entry (maps `public.wishlist_items`).
@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String title,
    String? note,
    String? url,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default(0) int priority,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WishlistItem;

  factory WishlistItem.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemFromJson(json);
}
