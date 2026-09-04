import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.birthdays);

  final List<UpcomingBirthday> birthdays;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async =>
      Success(birthdays);
}

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    required List<UpcomingBirthday> birthdays,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider
              .overrideWithValue(_FakeHomeRepository(birthdays)),
        ],
        child: const KeptApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty upcoming section drives friend discovery',
      (tester) async {
    await pumpHome(tester, birthdays: const []);

    expect(find.text('No upcoming birthdays yet'), findsOneWidget);
    expect(find.text('Find friends'), findsOneWidget);
    // Mock activity panel renders with its sample badge.
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('sample'), findsOneWidget);
  });

  testWidgets('shows birthday cards sorted with countdown', (tester) async {
    await pumpHome(
      tester,
      birthdays: [
        UpcomingBirthday(
          friendId: 'a',
          username: 'ali',
          displayName: 'Ali',
          birthday: DateTime(1995, 9, 6),
          daysUntil: 0,
        ),
        UpcomingBirthday(
          friendId: 'z',
          username: 'zeynep',
          displayName: 'Zeynep',
          birthday: DateTime(1997, 9, 12),
          daysUntil: 3,
        ),
      ],
    );

    expect(find.text('Ali'), findsOneWidget);
    expect(find.textContaining('Today!'), findsOneWidget);
    expect(find.text('Zeynep'), findsOneWidget);
    expect(find.textContaining('In 3 days'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Gift'), findsNWidgets(2));
  });

  testWidgets('tapping Find friends opens the Friends screen',
      (tester) async {
    await pumpHome(tester, birthdays: const []);

    await tester.tap(find.text('Find friends'));
    await tester.pumpAndSettle();

    expect(find.text('No friends yet'), findsOneWidget);
  });
}
