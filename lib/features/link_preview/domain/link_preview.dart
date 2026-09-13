import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_preview.freezed.dart';
part 'link_preview.g.dart';

/// Cached OG metadata for a pasted product link (G-211; maps
/// `public.link_previews`). The image lives in the public `link-previews`
/// storage bucket — clients never touch the original site.
@freezed
class LinkPreview with _$LinkPreview {
  const factory LinkPreview({
    required String id,
    String? url,
    String? title,
    @JsonKey(name: 'image_path') String? imagePath,
    String? price,
    String? site,
  }) = _LinkPreview;

  factory LinkPreview.fromJson(Map<String, dynamic> json) =>
      _$LinkPreviewFromJson(json);
}
