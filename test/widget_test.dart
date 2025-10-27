import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doanflutter/main.dart';

void main() {
  testWidgets('AppEntry loads correctly', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const AppEntry());

    // Kiểm tra xem có tiêu đề đúng không (nếu có)
    expect(find.text('Hotel Booking (Clean Architecture)'), findsOneWidget);
  });
}
