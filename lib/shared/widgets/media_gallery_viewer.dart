import 'dart:ui' show ImageFilter;

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

/// Full-screen swipeable gallery for private media (gift photos): the
/// current photo, blurred and dimmed, is the backdrop (frosted stage instead
/// of flat black); pinch-zoom per page; counter on top and a pill indicator
/// at the bottom so it is obvious there is more to swipe; optional remove for
/// items the viewer owns. White chrome is the same deliberate exception as
/// the avatar preview.
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

class _GalleryPageState extends State<_GalleryPage>
    with SingleTickerProviderStateMixin {
  /// Drag distance after which letting go dismisses; also the distance over
  /// which the chrome fades to nothing.
  static const double _dismissDistance = 140;
  static const double _dismissVelocity = 800;

  late int _index = widget.initialIndex.clamp(0, widget.items.length - 1);
  late final PageController _pages = PageController(initialPage: _index);
  final _zoom = TransformationController();
  bool _zoomed = false;

  /// Vertical pull-to-dismiss offset (pixels), animated back on release.
  late final AnimationController _pull = AnimationController(
    vsync: this,
    lowerBound: -600,
    upperBound: 600,
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    _zoom.addListener(_onZoom);
  }

  @override
  void dispose() {
    _zoom
      ..removeListener(_onZoom)
      ..dispose();
    _pages.dispose();
    _pull.dispose();
    super.dispose();
  }

  void _onZoom() {
    final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _onPageChanged(int i) {
    _zoom.value = Matrix4.identity();
    setState(() => _index = i);
  }

  void _onPullUpdate(DragUpdateDetails details) {
    _pull.value = (_pull.value + details.delta.dy).clamp(
      _pull.lowerBound,
      _pull.upperBound,
    );
  }

  void _onPullEnd(DragEndDetails details) {
    final far = _pull.value.abs() > _dismissDistance;
    final fast =
        details.primaryVelocity != null &&
        details.primaryVelocity!.abs() > _dismissVelocity;
    if (far || fast) {
      Navigator.of(context).pop();
      return;
    }
    _pull.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

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
    final current = items[_index];
    final canRemove = current.onRemove != null;
    return AnimatedBuilder(
      animation: _pull,
      builder: (context, _) {
        final progress = (_pull.value.abs() / _dismissDistance).clamp(0.0, 1.0);
        final chromeOpacity = 1 - progress;
        return Scaffold(
          // Opaque base: nothing of the screen underneath may bleed through.
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Opacity(
              opacity: chromeOpacity,
              child: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                leading: CloseButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
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
            ),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Frosted backdrop: the photo itself stretched to cover, then a
              // backdrop blur + light dim over it, so the letterbox bands take
              // the photo's own colour instead of black. Fades as the photo is
              // pulled away so the dismissal reads as "letting go".
              Opacity(
                opacity: chromeOpacity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: SizedBox.expand(
                    key: ValueKey(current.path),
                    child: PrivateMediaImage(
                      bucket: current.bucket,
                      path: current.path,
                      fit: BoxFit.cover,
                      compact: true,
                    ),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: const ColoredBox(color: Colors.black26),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      // Pull-to-dismiss only while not zoomed: zoomed, the
                      // drag belongs to panning the photo.
                      child: GestureDetector(
                        onVerticalDragUpdate: _zoomed ? null : _onPullUpdate,
                        onVerticalDragEnd: _zoomed ? null : _onPullEnd,
                        child: Transform.translate(
                          offset: Offset(0, _pull.value),
                          child: PageView.builder(
                            controller: _pages,
                            physics: _zoomed
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            itemCount: items.length,
                            onPageChanged: _onPageChanged,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: KeptSpacing.xs,
                              ),
                              child: InteractiveViewer(
                                transformationController: i == _index
                                    ? _zoom
                                    : null,
                                maxScale: 4,
                                child: PrivateMediaImage(
                                  bucket: items[i].bucket,
                                  path: items[i].path,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (items.length > 1)
                      Opacity(
                        opacity: chromeOpacity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: KeptSpacing.lg,
                          ),
                          child: _PageIndicator(
                            count: items.length,
                            index: _index,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pill indicator: the active page stretches, the rest are dots — reads as
/// "swipeable" at a glance.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${index + 1} / $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: i == index ? 22 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: KeptRadius.pillAll,
                color: i == index ? Colors.white : Colors.white38,
              ),
            ),
        ],
      ),
    );
  }
}
