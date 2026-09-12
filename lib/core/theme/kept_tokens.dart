import 'package:flutter/material.dart';

/// Spacing scale (design.md §2). Every padding/gap comes from here.
abstract final class KeptSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii (design.md §2).
abstract final class KeptRadius {
  static const double control = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static final BorderRadius controlAll = BorderRadius.circular(control);
  static final BorderRadius cardAll = BorderRadius.circular(card);
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static final BorderRadius pillAll = BorderRadius.circular(pill);
}
