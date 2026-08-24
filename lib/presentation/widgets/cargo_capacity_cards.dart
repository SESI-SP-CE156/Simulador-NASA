import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simulador_nasa/domain/services/survival_calculator_service.dart';
import 'package:simulador_nasa/presentation/providers/cargo_provider.dart';
import 'package:sizer/sizer.dart';

class CargoCapacityCards extends ConsumerWidget {
  const CargoCapacityCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta em tempo real o peso e volume calculados
    final capacidade = ref.watch(cargoCapacityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Análise de Lançamento',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        _buildMetric(
          context: context,
          titulo: 'Carga Útil do Foguete (Peso)',
          atual: capacidade.pesoTotal,
          limite: SurvivalCalculatorService.limiteCargaKg,
          excedeu: capacidade.pesoExcedido,
          unidade: 'kg',
        ),
        SizedBox(height: 1.h),
        _buildMetric(
          context: context,
          titulo: 'Área do Foguete (Volume)',
          atual: capacidade.volumeTotal,
          limite: SurvivalCalculatorService.limiteVolumeLitros,
          excedeu: capacidade.volumeExcedido,
          unidade: 'L',
        ),
      ],
    );
  }

  // O seu método original intacto
  Widget _buildMetric({
    required BuildContext context,
    required String titulo,
    required double atual,
    required double limite,
    required bool excedeu,
    required String unidade,
  }) {
    final theme = Theme.of(context);
    final percentual = (atual / limite).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      color: excedeu
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: excedeu ? theme.colorScheme.error : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: excedeu ? theme.colorScheme.onErrorContainer : null,
                  ),
                ),
                if (excedeu)
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            LinearProgressIndicator(
              value: percentual,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: excedeu
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 1.h),
            Text(
              '${atual.toStringAsFixed(1)} $unidade / ${limite.toStringAsFixed(0)} $unidade',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: excedeu ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
