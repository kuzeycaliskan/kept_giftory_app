import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kept/shared/widgets/image_edit_screen.dart';

/// Avatar flavour of the shared editor: circle mask, 1:1 locked. Pops with
/// the cropped square bytes, or null when cancelled.
class AvatarCropScreen extends StatelessWidget {
  const AvatarCropScreen({required this.imageBytes, super.key});

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) =>
      ImageEditScreen(imageBytes: imageBytes, aspectRatio: 1, circle: true);
}
