// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/models/habitat_result.dart';
import '../../domain/models/resource_type.dart';
import '../../domain/services/survival_calculator_service.dart';
import '../providers/cargo_provider.dart';
import '../providers/habitat_provider.dart';
import '../widgets/cargo_selection_panel.dart';
import '../widgets/resource_stats_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(habitatControllerProvider.notifier);
    final inputs = ref.watch(habitatControllerProvider);
    final resultado = ref.watch(habitatResultProvider);
    final isEmpty = inputs.isEmpty;

    // 1. Calcula o peso e volume combinados (Recursos dos Sliders + Carga dos Módulos)
    final cargo = ref.watch(cargoCapacityProvider);
    final pesoTotalCombinado = resultado.pesoTotalKg + cargo.pesoTotal;
    final volumeTotalCombinado =
        resultado.volumeTotalLitros + cargo.volumeTotal;

    final isPesoExcedido =
        pesoTotalCombinado > SurvivalCalculatorService.limiteCargaKg;
    final isVolumeExcedido =
        volumeTotalCombinado > SurvivalCalculatorService.limiteVolumeLitros;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador Espacial (4 Tripulantes)'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Recursos Disponíveis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            _buildSliderField(
              context: context,
              label: 'Água (Litros)',
              icon: Icons.water_drop,
              value: inputs.agua,
              max: inputs.maxAgua,
              step: inputs.stepAgua,
              onChanged: controller.updateAgua,
            ),
            SizedBox(height: 1.5.h),
            _buildSliderField(
              context: context,
              label: 'Comida (kcal)',
              icon: Icons.restaurant,
              value: inputs.comida,
              max: inputs.maxComida,
              step: inputs.stepComida,
              onChanged: controller.updateComida,
            ),
            SizedBox(height: 1.5.h),
            _buildSliderField(
              context: context,
              label: 'Oxigênio (Litros)',
              icon: Icons.air,
              value: inputs.oxigenio,
              max: inputs.maxOxigenio,
              step: inputs.stepOxigenio,
              onChanged: controller.updateOxigenio,
            ),
            SizedBox(height: 4.h),

            // 2. Painel de Módulos & Equipamentos (Posicionado antes da análise de lançamento)
            const CargoSelectionPanel(),

            SizedBox(height: 4.h),

            Text(
              'Análise de Lançamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),

            Skeletonizer(
              enabled: isEmpty,
              child: Column(
                children: [
                  // 3. Marcadores originais reutilizados e alimentados com os dados combinados
                  _CapacityCards(
                    pesoAtual: isEmpty ? 50000 : pesoTotalCombinado,
                    pesoExcedido: isEmpty ? false : isPesoExcedido,
                    volumeAtual: isEmpty ? 500000 : volumeTotalCombinado,
                    volumeExcedido: isEmpty ? false : isVolumeExcedido,
                  ),
                  SizedBox(height: 2.h),
                  _ResultCard(
                    resultado: isEmpty ? HabitatResult.mock() : resultado,
                    diasIdeais: inputs.diasIdeais,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required double value,
    required double max,
    required double step,
    required void Function(double) onChanged,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value.toInt().toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: max,
            divisions: (max > 0 && step > 0) ? (max / step).round() : 1,
            activeColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _CapacityCards extends StatelessWidget {
  final double pesoAtual;
  final bool pesoExcedido;
  final double volumeAtual;
  final bool volumeExcedido;

  const _CapacityCards({
    required this.pesoAtual,
    required this.pesoExcedido,
    required this.volumeAtual,
    required this.volumeExcedido,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMetric(
          context: context,
          titulo: 'Carga Útil do Foguete (Peso)',
          atual: pesoAtual,
          limite: SurvivalCalculatorService.limiteCargaKg,
          excedeu: pesoExcedido,
          unidade: 'kg',
        ),
        SizedBox(height: 1.h),
        _buildMetric(
          context: context,
          titulo: 'Área do Foguete (Volume)',
          atual: volumeAtual,
          limite: SurvivalCalculatorService.limiteVolumeLitros,
          excedeu: volumeExcedido,
          unidade: 'L',
        ),
      ],
    );
  }

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

class _ResultCard extends ConsumerWidget {
  final HabitatResult resultado;
  final int diasIdeais;

  const _ResultCard({required this.resultado, required this.diasIdeais});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final inputs = ref.read(habitatControllerProvider);
    final stats = ref.watch(cargoStatsProvider);
    final cargo = ref.watch(cargoCapacityProvider);

    final pesoTotalCombinado = resultado.pesoTotalKg + cargo.pesoTotal;
    final volumeTotalCombinado =
        resultado.volumeTotalLitros + cargo.volumeTotal;
    final possuiRestricao =
        pesoTotalCombinado > SurvivalCalculatorService.limiteCargaKg ||
        volumeTotalCombinado > SurvivalCalculatorService.limiteVolumeLitros;

    final isAutossustentavel = resultado.diasSobrevivencia == double.infinity;
    final diasAtuais = isAutossustentavel
        ? -1
        : resultado.diasSobrevivencia.floor();
    final isBalancoPerfeito =
        (diasAtuais == diasIdeais) && !possuiRestricao && !inputs.isEmpty;

    final service = SurvivalCalculatorService();
    final tempoViagemDias = service.calcularTempoViagemDias(pesoTotalCombinado);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isBalancoPerfeito
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      size: 20,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 2.w),
                    Text('Viagem até Marte', style: theme.textTheme.titleSmall),
                  ],
                ),
                Text(
                  '~${tempoViagemDias.toStringAsFixed(0)} dias (${(tempoViagemDias / 30).toStringAsFixed(1)} meses)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tempo Máximo Estimado',
                  style: theme.textTheme.titleMedium,
                ),
                if (isBalancoPerfeito)
                  Text(
                    'BALANÇO PERFEITO',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            Text(
              isAutossustentavel
                  ? 'Autossustentável (∞)'
                  : '${resultado.diasSobrevivencia.toStringAsFixed(1)} dias',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: isAutossustentavel ? 24 : null,
                color: isBalancoPerfeito
                    ? Colors.green
                    : (possuiRestricao
                          ? theme.colorScheme.outline
                          : (isAutossustentavel
                                ? Colors.blue
                                : theme.colorScheme.primary)),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),

            _buildResourceStat(
              context: context,
              nome: 'Água',
              duracao: resultado.duracaoAguaDias,
              consumoDiario: resultado.consumoDiarioAgua,
              isLimitante: resultado.recursoLimitante == ResourceType.agua,
              infoExtra:
                  '+${resultado.consumoAguaReidratacaoDiario.toStringAsFixed(1)}L reidratação/dia',
            ),
            _buildResourceStat(
              context: context,
              nome: 'Comida',
              duracao: resultado.duracaoComidaDias,
              consumoDiario: resultado.consumoDiarioComida,
              isLimitante: resultado.recursoLimitante == ResourceType.comida,
            ),
            _buildResourceStat(
              context: context,
              nome: 'Oxigênio',
              duracao: resultado.duracaoOxigenioDias,
              consumoDiario: resultado.consumoDiarioOxigenio,
              isLimitante: resultado.recursoLimitante == ResourceType.oxigenio,
            ),

            const Divider(height: 20),

            ResourceStatBar(
              label: 'Gelo Bruto (Mineração)',
              icone: Icons.ac_unit, // Ícone temático
              producao: stats['gelo']['prod'],
              consumo: stats['gelo']['cons'],
              unidade: stats['gelo']['unidade'],
            ),
            ResourceStatBar(
              label: 'Oxigênio (Módulos)',
              icone: Icons.air,
              producao: stats['oxigenio']['prod'],
              consumo: stats['oxigenio']['cons'],
              unidade: stats['oxigenio']['unidade'],
            ),
            ResourceStatBar(
              label: 'Água (Módulos)',
              icone: Icons.water_drop,
              producao: stats['agua']['prod'],
              consumo: stats['agua']['cons'],
              unidade: stats['agua']['unidade'],
            ),
            ResourceStatBar(
              label: 'Energia (Módulos)',
              icone: Icons.bolt,
              producao: stats['energia']['prod'],
              consumo: stats['energia']['cons'],
              unidade: stats['energia']['unidade'],
            ),
            ResourceStatBar(
              label: 'Comida (Módulos)',
              icone: Icons.restaurant,
              producao: stats['comida']['prod'],
              consumo: stats['comida']['cons'],
              unidade: stats['comida']['unidade'],
            ),

            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Felicidade Geral', style: theme.textTheme.titleSmall),
                Text(
                  '${stats['felicidade']}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            LinearProgressIndicator(
              value: (stats['felicidade'] as num) / 100.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceStat({
    required BuildContext context,
    required String nome,
    required double duracao,
    required double consumoDiario,
    required bool isLimitante,
    String? infoExtra,
  }) {
    final theme = Theme.of(context);
    final isSurplus = consumoDiario <= 0;
    final valConsumo = consumoDiario.abs();

    // Altera a apresentação baseado em superávit ou déficit
    final textoConsumo = isSurplus
        ? '+${valConsumo.toStringAsFixed(1)}/dia (Superávit)'
        : '-${valConsumo.toStringAsFixed(1)}/dia';
    final textoDuracao = duracao == double.infinity
        ? '∞ dias'
        : '${duracao.toStringAsFixed(1)} dias';

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isLimitante
            ? theme.colorScheme.errorContainer
            : (isSurplus
                  ? Colors.green.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(8),
        border: isLimitante
            ? Border.all(color: theme.colorScheme.error, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLimitante
                      ? theme.colorScheme.onErrorContainer
                      : null,
                ),
              ),
              Text(
                textoConsumo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSurplus ? Colors.green : null,
                  fontWeight: isSurplus ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (infoExtra != null)
                Text(
                  infoExtra,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                textoDuracao,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLimitante)
                Text(
                  'RECURSO CRÍTICO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
