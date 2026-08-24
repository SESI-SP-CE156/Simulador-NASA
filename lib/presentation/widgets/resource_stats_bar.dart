import 'package:flutter/material.dart';

class ResourceStatBar extends StatelessWidget {
  final String label;
  final double producao;
  final double consumo;
  final String unidade;
  final IconData icone;

  const ResourceStatBar({
    super.key,
    required this.label,
    required this.producao,
    required this.consumo,
    required this.unidade,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deficit = consumo > producao;
    final proporcao = consumo > 0 ? (producao / consumo).clamp(0.0, 1.0) : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icone,
                size: 18,
                color: deficit
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Saldo: ${(producao - consumo).toStringAsFixed(1)} $unidade',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: deficit ? theme.colorScheme.error : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: proporcao,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: deficit ? theme.colorScheme.error : Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prod: +${producao.toStringAsFixed(1)}',
                style: theme.textTheme.labelSmall,
              ),
              Text(
                'Cons: -${consumo.toStringAsFixed(1)}',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
