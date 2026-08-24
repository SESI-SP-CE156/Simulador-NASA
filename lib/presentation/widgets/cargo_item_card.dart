// lib/presentation/widgets/cargo_item_card.dart
import 'package:flutter/material.dart';
import 'package:simulador_nasa/domain/models/cargo_item.dart';

class CargoItemCard extends StatelessWidget {
  final CargoItem item;
  final int quantidade;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CargoItemCard({
    super.key,
    required this.item,
    required this.quantidade,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = quantidade > 0;

    return Card(
      elevation: isSelected ? 3 : 0,
      margin: EdgeInsets.zero, // A margem agora é controlada pelo GridView
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Empurra controles para baixo
          children: [
            // Seção Superior: Nome e Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? theme.colorScheme.primary : null,
                    fontSize: 15,
                  ),
                  maxLines:
                      2, // Garante que títulos grandes quebrem a linha sem quebrar o layout
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '⚖️ ${item.pesoKg.toStringAsFixed(0)} kg\n📦 ${item.volumeL.toStringAsFixed(0)} L',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height:
                        1.4, // Melhora o espaçamento entre as linhas do texto
                  ),
                ),
              ],
            ),

            // Seção Inferior: Controles de Quantidade
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Separa os botões igualmente
              children: [
                IconButton.filledTonal(
                  onPressed: quantidade > 0 ? onRemove : null,
                  icon: const Icon(Icons.remove, size: 20),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  quantidade.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filled(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 20),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
