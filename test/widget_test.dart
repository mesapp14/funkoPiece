import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:funko_catalog/main.dart';

void main() {
  testWidgets('Funko Catalog loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FunkoApp());

    // Verifica che ci sia la barra di ricerca
    expect(find.byType(TextField), findsOneWidget);

    // Verifica che la griglia sia presente (può essere vuota se il JSON non è caricato)
    expect(find.byType(GridView), findsOneWidget);
  });
}