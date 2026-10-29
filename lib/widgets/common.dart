import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Caja con fondo y esquinas redondeadas (las "tarjetas" de los diseños).
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Título pequeño en mayúsculas encima de cada sección.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: AppText.label())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Botón − número + (personas, platos...).
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.canIncrement = true,
    this.incrementLabel = 'Añadir uno',
    this.decrementLabel = 'Quitar uno',
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final String incrementLabel;
  final String decrementLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            label: decrementLabel,
            onTap: value > 0 ? onDecrement : null,
            filled: false,
          ),
          SizedBox(
            width: 28,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: AppText.display(18),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: incrementLabel,
            onTap: canIncrement ? onIncrement : null,
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bg = filled
        ? (enabled ? AppColors.salmon : AppColors.surfaceHigh)
        : Colors.transparent;
    final fg = filled
        ? (enabled ? AppColors.bg : AppColors.faint)
        : (enabled ? AppColors.muted : AppColors.surfaceHigh);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 44,
            child: Icon(icon, color: fg, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Botón principal (salmón) o secundario (con borde).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? AppColors.bg : AppColors.salmon;
    return Material(
      color: primary ? AppColors.salmon : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: primary
            ? BorderSide.none
            : const BorderSide(color: AppColors.salmon, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.body(16, weight: FontWeight.w800, color: fg),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: fg, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip seleccionable (categorías, rondas, personas).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.filledWhenSelected = false,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// true: seleccionado = fondo salmón. false: seleccionado = borde salmón.
  final bool filledWhenSelected;

  @override
  Widget build(BuildContext context) {
    final filled = selected && filledWhenSelected;
    return Material(
      color: filled
          ? AppColors.salmon
          : (selected ? AppColors.line : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(subtitle == null ? 999 : 16),
        side: BorderSide(
          color: selected && !filledWhenSelected
              ? AppColors.salmon
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(subtitle == null ? 999 : 16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: subtitle == null ? 10 : 7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.body(
                  14,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: filled ? AppColors.bg : AppColors.text,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!, style: AppText.body(12, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cifra con etiqueta (para los bloques de estadísticas).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.text,
    this.valueSize = 20,
  });

  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Panel(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.muted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.display(valueSize, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

/// Barra de progreso redondeada y animada.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 12,
  });

  /// De 0 a 1.
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.bg,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón cuadrado con icono (volver, historial...).
class IconSquareButton extends StatelessWidget {
  const IconSquareButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: AppColors.text, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Aviso amarillo (desperdicio de comida, etc.).
class WarningBox extends StatelessWidget {
  const WarningBox(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Panel(
      color: AppColors.warningBg,
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppText.body(13, color: AppColors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila que se desliza en horizontal (categorías, rondas, personas...).
///
/// Respecto a un ListView horizontal normal, añade:
/// - que la rueda del ratón o el touchpad también la desplacen (por defecto
///   Flutter solo lo hace al arrastrar con el dedo);
/// - un degradado en los bordes que indica que hay más contenido;
/// - `ensureVisible` para centrar un elemento concreto (con su GlobalKey).
class HorizontalScroller extends StatefulWidget {
  const HorizontalScroller({
    super.key,
    required this.children,
    this.height = 44,
    this.spacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<Widget> children;
  final double height;
  final double spacing;
  final EdgeInsets padding;

  @override
  State<HorizontalScroller> createState() => _HorizontalScrollerState();
}

class _HorizontalScrollerState extends State<HorizontalScroller> {
  final ScrollController _controller = ScrollController();
  bool _fadeStart = false;
  bool _fadeEnd = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void didUpdateWidget(covariant HorizontalScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!mounted || !_controller.hasClients) return;
    final p = _controller.position;
    final start = p.pixels > 4;
    final end = p.pixels < p.maxScrollExtent - 4;
    if (start != _fadeStart || end != _fadeEnd) {
      setState(() {
        _fadeStart = start;
        _fadeEnd = end;
      });
    }
  }

  /// Rueda del ratón (arriba/abajo) → desplazamiento horizontal.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final delta = event.scrollDelta.dy != 0 ? event.scrollDelta.dy : event.scrollDelta.dx;
    final p = _controller.position;
    _controller.jumpTo((p.pixels + delta).clamp(0.0, p.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      if (i > 0) items.add(SizedBox(width: widget.spacing));
      items.add(widget.children[i]);
    }
    return SizedBox(
      height: widget.height,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            colors: [
              _fadeStart ? Colors.transparent : Colors.black,
              Colors.black,
              Colors.black,
              _fadeEnd ? Colors.transparent : Colors.black,
            ],
            stops: const [0, 0.08, 0.92, 1],
          ).createShader(rect),
          // ListView (no .builder): construye todos los elementos, así
          // ensureVisible funciona aunque estén fuera de la pantalla.
          child: ListView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: widget.padding,
            children: items,
          ),
        ),
      ),
    );
  }
}
