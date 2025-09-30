import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic performance test', (WidgetTester tester) async {
    final stopwatch = Stopwatch()..start();

    // Create a simple widget
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Test')),
      ),
    ));

    stopwatch.stop();
    final startupTime = stopwatch.elapsedMilliseconds;


    // Assert reasonable startup time
    expect(startupTime, lessThan(1000));

    // Test basic widget
    expect(find.text('Test'), findsOneWidget);
  });
}