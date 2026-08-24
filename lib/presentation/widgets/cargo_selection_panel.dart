// lib/presentation/widgets/cargo_selection_panel.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simulador_nasa/domain/models/cargo_item.dart';
import 'package:simulador_nasa/presentation/providers/cargo_provider.dart';
import 'package:sizer/sizer.dart';

import 'cargo_item_card.dart';

class CargoSelectionPanel extends ConsumerWidget {
  const CargoSelectionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final inventario = ref.watch(cargoControllerProvider);
    final controller = ref.read(cargoControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Módulos & Equipamentos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),

        // LayoutBuilder permite verificar a largura disponível em tempo real
        LayoutBuilder(
          builder: (context, constraints) {
            // Define a quantidade de colunas (3 ou 4) com base no tamanho da tela
            int crossAxisCount = 1;
            if (constraints.maxWidth >= 1100) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth >= 800) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth >= 500) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 3.w, // Espaçamento horizontal
                mainAxisSpacing: 2.h, // Espaçamento vertical
                mainAxisExtent: 170, // Altura fixa do retângulo
              ),
              itemCount: catalogoCarga.length,
              itemBuilder: (context, index) {
                final item = catalogoCarga[index];
                final quantidade = inventario[item.id] ?? 0;

                return CargoItemCard(
                  item: item,
                  quantidade: quantidade,
                  onAdd: () => controller.addItem(item.id),
                  onRemove: () => controller.removeItem(item.id),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
