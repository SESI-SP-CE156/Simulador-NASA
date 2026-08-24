// lib/presentation/providers/cargo_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simulador_nasa/domain/models/cargo_item.dart';
import 'package:simulador_nasa/domain/services/survival_calculator_service.dart';
import 'package:simulador_nasa/presentation/providers/habitat_provider.dart';

part 'cargo_provider.g.dart';

typedef CargoInventory = Map<String, int>;

@riverpod
class CargoController extends _$CargoController {
  @override
  CargoInventory build() => {};

  void addItem(String id) {
    final current = state[id] ?? 0;
    state = {...state, id: current + 1};
  }

  void removeItem(String id) {
    final current = state[id] ?? 0;
    if (current > 0) {
      state = {...state, id: current - 1};
    }
  }
}

// Provider derivado para calcular os totais
@riverpod
Map<String, dynamic> cargoStats(CargoStatsRef ref) {
  final inventory = ref.watch(cargoControllerProvider);
  final habitat = ref.watch(habitatControllerProvider);

  double pEnergia = 0, cEnergia = 0;
  double pAgua = 0,
      cAgua = habitat.stepAgua; // Agora inclui os ~13L de reidratação!
  double pOxigenio = 0, cOxigenio = habitat.stepOxigenio;
  double pComida = 0, cComida = habitat.stepComida;
  double pGelo = 0, cGelo = 0; // NOVA VARIÁVEL
  int felicidade = 0;

  inventory.forEach((id, qtd) {
    final item = catalogoCarga.firstWhere((e) => e.id == id);
    pEnergia += item.prodEnergia * qtd;
    cEnergia += item.consEnergia * qtd;
    pAgua += item.prodAgua * qtd;
    cAgua += item.consAgua * qtd;
    pOxigenio += item.prodOxigenio * qtd;
    pComida += item.prodComida * qtd;

    // Calcula a extração e o refino
    pGelo += item.prodGelo * qtd;
    cGelo += item.consGelo * qtd;

    felicidade += item.ganhoFelicidade * qtd;
  });

  if (pAgua < cAgua || pOxigenio < cOxigenio || pComida < cComida) {
    felicidade -= 30;
  }

  // Penalidade se o filtro estiver operando sem gelo suficiente
  if (pGelo < cGelo) {
    felicidade -= 10;
  }

  return {
    'energia': {'prod': pEnergia, 'cons': cEnergia, 'unidade': 'kWh/dia'},
    'agua': {'prod': pAgua, 'cons': cAgua, 'unidade': 'L/dia'},
    'oxigenio': {'prod': pOxigenio, 'cons': cOxigenio, 'unidade': 'L/dia'},
    'comida': {'prod': pComida, 'cons': cComida, 'unidade': 'kcal/dia'},
    'gelo': {'prod': pGelo, 'cons': cGelo, 'unidade': 'L/dia'},
    'felicidade': (felicidade).clamp(0, 100),
  };
}

@riverpod
({double pesoTotal, double volumeTotal, bool pesoExcedido, bool volumeExcedido})
cargoCapacity(CargoCapacityRef ref) {
  final inventory = ref.watch(cargoControllerProvider);

  double peso = 0;
  double volume = 0;

  inventory.forEach((id, qtd) {
    final item = catalogoCarga.firstWhere((e) => e.id == id);
    peso += item.pesoKg * qtd;
    volume += item.volumeL * qtd;
  });

  return (
    pesoTotal: peso,
    volumeTotal: volume,
    pesoExcedido: peso > SurvivalCalculatorService.limiteCargaKg,
    volumeExcedido: volume > SurvivalCalculatorService.limiteVolumeLitros,
  );
}
