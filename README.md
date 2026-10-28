# 🍣 Zake Tracker

**¿Le ganamos hoy al buffet?** Una app para apuntar todo lo que coméis en el buffet libre del restaurante **Zake** (San Juan de Alicante) y descubrir si, al final de la comida, el restaurante sale perdiendo con vosotros.

Hecha con **Flutter**, así que funciona en **Android, iPhone y navegador web** con el mismo código.

---

## ✨ Qué hace

- **Comida en grupo**: elige cuántos adultos, niños y peques coméis; la app calcula lo que pagáis entre todos.
- **Toda la carta de Zake**: más de 90 platos por categorías, cada uno con su dibujo y su coste estimado para el restaurante.
- **Rondas**: apunta los platos ronda a ronda, como se pide de verdad en la mesa.
- **Buscador y filtros**: encuentra cualquier plato por nombre o número (sin preocuparte por las tildes) y filtra por muy pedidos 🔥, picantes 🌶️, limitados o ya pedidos.
- **Platos limitados**: los "no puede repetir" se controlan solos (uno por persona en toda la comida).
- **Marcador en directo**: un medidor muestra qué porcentaje del dinero de Zake os habéis comido.
- **Objetivos misteriosos**: seis metas ocultas (25 %, 50 %, 75 %, 100 %, 125 % y 150 %), cada una con su animación al desbloquearla.
- **Bebidas y postres**: cuentan a favor de Zake, porque son casi todo beneficio para él.
- **Ranking del grupo**: quién le ha costado más al restaurante (el MVP de la noche).
- **Historial**: victorias, rachas, mejor comida y plato favorito.
- **Funciona sin cuenta ni servidor**: todo se guarda en el propio móvil.

## 🚀 Empezar rápido

```bash
# 1. Generar las carpetas de cada plataforma (solo la primera vez)
flutter create --org com.sandra --project-name zake_tracker --platforms=android,ios,web .

# 2. Descargar dependencias
flutter pub get

# 3. Comprobar que todo está bien
flutter analyze
flutter test

# 4. Ejecutar (en Chrome, en el emulador o en tu móvil Android)
flutter run -d chrome
flutter run
```

La guía completa paso a paso (instalar Flutter en Windows, emulador, móvil real, iPhone y subir a GitHub) está en **[docs/GUIA_COMPILACION.md](docs/GUIA_COMPILACION.md)**.

## 📚 Documentación

| Documento | Contenido |
|---|---|
| [docs/MEMORIA.md](docs/MEMORIA.md) | Memoria técnica: cómo funciona cada parte, por qué se hizo así, el modelo económico, la arquitectura y cómo ampliar la app. |
| [docs/GUIA_COMPILACION.md](docs/GUIA_COMPILACION.md) | Qué instalar, cómo compilar y probar en cada plataforma, y cómo publicar en GitHub. |

## 🗂️ Estructura

```
lib/
├── main.dart              Arranque de la app
├── data/menu_data.dart    La carta completa con costes estimados
├── models/                Datos: plato, comida, objetivo, historial
├── logic/                 Cálculos, controladores y guardado
├── screens/               Las pantallas
├── widgets/               Piezas reutilizables, dibujos y animaciones
├── theme/                 Colores y tipografías
└── utils/                 Formato de euros, fechas…
test/                      Tests automáticos
docs/                      Memoria y guía
```

## ⚠️ Aviso

Proyecto personal y sin ánimo de lucro, **no afiliado al restaurante Zake**. Los costes de cada plato son **estimaciones aproximadas** hechas para el juego, no datos reales del restaurante. Y recuerda: ganarle al buffet no vale si se tira comida. 🙂
