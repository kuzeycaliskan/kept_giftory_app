import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/media/camera/camera_backend.dart';
import 'package:kept/core/media/camera/camera_screen.dart';
import 'package:kept/core/media/media_providers.dart';

import '../../features/feed/feed_test_support.dart';

void main() {
  Uint8List? returned;

  Future<void> pump(WidgetTester tester, FakeCameraBackend camera) async {
    returned = null;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cameraBackendProvider.overrideWithValue(camera)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () async => returned = await takePhoto(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shutter → review → use returns the shot', (tester) async {
    final camera = FakeCameraBackend(tinyPng);
    await pump(tester, camera);

    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(camera.openedLenses, [CameraLens.back]);
    // Flash starts off and is applied to the session.
    expect(camera.flashes, [CameraFlash.off]);

    await tester.tap(find.byKey(const Key('camera-shutter')));
    await tester.pumpAndSettle();
    expect(find.text('Retake'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Use photo'));
    await tester.pumpAndSettle();
    expect(returned, tinyPng);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('flash cycles off → auto → on; flip opens the front lens', (
    tester,
  ) async {
    final camera = FakeCameraBackend(tinyPng);
    await pump(tester, camera);

    await tester.tap(find.byKey(const Key('camera-flash')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('camera-flash')));
    await tester.pumpAndSettle();
    expect(camera.flashes, [CameraFlash.off, CameraFlash.auto, CameraFlash.on]);

    await tester.tap(find.byKey(const Key('camera-flip')));
    await tester.pumpAndSettle();
    expect(camera.openedLenses, [CameraLens.back, CameraLens.front]);
    // The chosen flash follows the new lens.
    expect(camera.flashes.last, CameraFlash.on);
  });

  testWidgets('retake goes back to the viewfinder; close returns nothing', (
    tester,
  ) async {
    final camera = FakeCameraBackend(tinyPng);
    await pump(tester, camera);

    await tester.tap(find.byKey(const Key('camera-shutter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retake'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('camera-shutter')), findsOneWidget);
    expect(camera.opened, 2);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(returned, isNull);
  });

  testWidgets('one lens means no flip', (tester) async {
    await pump(tester, FakeCameraBackend(tinyPng, lenses: [CameraLens.back]));
    expect(find.byKey(const Key('camera-shutter')), findsOneWidget);
    expect(find.byKey(const Key('camera-flip')), findsNothing);
  });

  testWidgets('denied access explains and offers a retry', (tester) async {
    await pump(tester, FakeCameraBackend(tinyPng, denied: true));
    expect(
      find.textContaining('Allow it in your device settings'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byKey(const Key('fake-camera-preview')), findsNothing);
  });
}
