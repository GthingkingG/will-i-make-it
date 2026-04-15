import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/home/view/widgets/probability_ring.dart';

void main() {
  group('ProbabilityRing', () {
    testWidgets('displays percentage text after animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ProbabilityRing(value: 0.87, size: 200)),
          ),
        ),
      );
      // Allow the 600ms tween to finish.
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('87%'), findsOneWidget);
    });

    testWidgets('clamps value > 1 to 100%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ProbabilityRing(value: 1.5, size: 200)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('clamps value < 0 to 0%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ProbabilityRing(value: -0.5, size: 200)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('renders at mid value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ProbabilityRing(value: 0.5, size: 200)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
