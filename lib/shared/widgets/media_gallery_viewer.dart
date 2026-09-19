import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/private_media_image.dart';

/// One item of a [showMediaGallery] session.
class GalleryItem {
  const GalleryItem({required this.bucket, required this.path, this.onRemove});

  final String bucket;
  final String path;

  /// When set, the viewer offers "remove" for this item (owner only).
  final Future<void> Function()? onRemove;
}

/// Full-screen swipeable gallery for private media (gift photos): black
/// stage, pinch-zoom per page, page counter, optional remove for items the
/// viewer owns. Same deliberate dark-chrome exception as the avatar preview.
Future<void> showMediaGallery(
  BuildContext context, {
  required List<GalleryItem> items,
  required String removeLabel,
  int initialIndex = 0,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).closeButtonLabel,
    barrierColor: Colors.black,
    pageBuilder: (context, _, __) => _GalleryPage(
      items: items,
      initialIndex: initialIndex,
      removeLabel: removeLabel,
    ),
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _GalleryPage extends StatefulWidget {
  const _GalleryPage({
    required this.items,
    required this.initialIndex,
    required this.removeLabel,
  });

  final List<GalleryItem> items;
  final int initialIndex;
  final String removeLabel;

  @override
  State<_GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<_GalleryPage> {
  late int _index = widget.initialIndex.clamp(0, widget.items.length - 1);

  Future<void> _actions() async {
    final onRemove = widget.items[_index].onRemove;
    if (onRemove == null) return;
    final navigator = Navigator.of(context);
    await showKeptActionSheet(
      context,
      actions: [
        KeptSheetAction(
          icon: Icons.delete_outline,
          label: widget.removeLabel,
          destructive: true,
          onTap: () async {
            await onRemove();
            // The gallery's item list is a snapshot; leave it to the owner
            // screen to re-render with the photo gone.
            if (navigator.canPop()) navigator.pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final canRemove = items[_index].onRemove != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
        title: Text('${_index + 1} / ${items.length}'),
        centerTitle: true,
        actions: [
          if (canRemove)
            IconButton(
              tooltip: context.l10n.storyMoreActions,
              icon: const Icon(Icons.more_horiz),
              onPressed: _actions,
            ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: _index),
        itemCount: items.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: KeptSpacing.xs),
          child: InteractiveViewer(
            maxScale: 4,
            child: PrivateMediaImage(
              bucket: items[i].bucket,
              path: items[i].path,
            ),
          ),
        ),
      ),
    );
  }
}
