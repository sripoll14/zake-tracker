import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zake_tracker/data/menu_data.dart';
import 'package:zake_tracker/models/goal.dart';
import 'package:zake_tracker/widgets/chili_icon.dart';
import 'package:zake_tracker/widgets/dish_art.dart';
import 'package:zake_tracker/widgets/goal_art.dart';

// Comprueba que los dibujos se pintan sin errores.
// (No se prueba la app entera aquí porque las fuentes se descargan de
// internet y en los tests no hay conexión.)

void main() {
  testWidgets('todos los dibujos de platos se pintan', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Wrap(children: [for (final d in kMenu) DishArtView(dish: d)]),
        ),
      ),
    ));
    expect(find.byType(DishArtView), findsNWidgets(kMenu.length));
  });

  testWidgets('las animaciones de los objetivos se pintan', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Wrap(children: [for (final g in kGoals) GoalArtView(art: g.art, size: 120)]),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GoalArtView), findsNWidgets(kGoals.length));
  });

  testWidgets('la guindilla se pinta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: ChiliIcon(size: 32))));
    expect(find.byType(ChiliIcon), findsOneWidget);
  });
}
