// Test básico para Micro-Ritualist
//
// Para realizar interacciones con widgets en tests, usa WidgetTester
// del paquete flutter_test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_ritualist/main.dart';

void main() {
  testWidgets('App se inicia correctamente', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(
      const ProviderScope(
        child: MicroRitualistApp(),
      ),
    );

    // Verificar que la app se carga
    expect(find.byType(MicroRitualistApp), findsOneWidget);
  });
}
