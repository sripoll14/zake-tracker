/// Ilustración animada de cada objetivo.
enum GoalArt { chopsticks, halfNigiri, sweatingChef, balance, cryingRegister, crown }

/// Un objetivo misterioso del marcador.
class Goal {
  const Goal({
    required this.percent,
    required this.title,
    required this.description,
    required this.art,
  });

  /// Porcentaje del ingreso de Zake que hay que "comerse" para conseguirlo.
  final int percent;
  final String title;
  final String description;
  final GoalArt art;
}

/// Los seis objetivos, de menor a mayor.
const List<Goal> kGoals = [
  Goal(
    percent: 25,
    title: 'Calentando palillos',
    description: 'Ya habéis recuperado una cuarta parte. Esto acaba de empezar.',
    art: GoalArt.chopsticks,
  ),
  Goal(
    percent: 50,
    title: 'Medio menú en la barriga',
    description: 'La mitad de lo pagado ya está dentro. Ni un paso atrás.',
    art: GoalArt.halfNigiri,
  ),
  Goal(
    percent: 75,
    title: 'El chef suda',
    description: 'Tres cuartas partes recuperadas. En la cocina empiezan a preocuparse.',
    art: GoalArt.sweatingChef,
  ),
  Goal(
    percent: 100,
    title: '¡Empate técnico!',
    description: 'Zake ya no gana nada con vosotros. Todo lo que venga ahora es ganancia.',
    art: GoalArt.balance,
  ),
  Goal(
    percent: 125,
    title: 'La caja registradora llora',
    description: 'Zake está perdiendo dinero de verdad. Se oyen sollozos tras la barra.',
    art: GoalArt.cryingRegister,
  ),
  Goal(
    percent: 150,
    title: 'Leyenda del buffet',
    description: 'Habéis hecho historia. Vuestras fotos ya cuelgan en la cocina.',
    art: GoalArt.crown,
  ),
];
