import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simulador_nasa/domain/models/cargo_item.dart';
import 'package:simulador_nasa/presentation/providers/cargo_provider.dart';

import '../../domain/models/habitat_result.dart';
import '../../domain/services/survival_calculator_service.dart';

part 'habitat_provider.g.dart';

class HabitatInputState {
  final double agua;
  final double comida;
  final double oxigenio;

  final double maxAgua;
  final double maxComida;
  final double maxOxigenio;

  final double taxaVolumeComida;
  final double taxaAguaReidratacao;

  final double stepAgua;
  final double stepComida;
  final double stepOxigenio;
  final int diasIdeais;

  const HabitatInputState({
    this.agua = 0.0,
    this.comida = 0.0,
    this.oxigenio = 0.0,
    this.maxAgua = 1.0,
    this.maxComida = 1.0,
    this.maxOxigenio = 1.0,
    this.taxaVolumeComida = 4.0,
    this.taxaAguaReidratacao = 3.5,
    this.stepAgua = 1.0,
    this.stepComida = 11400.0,
    this.stepOxigenio = 2520.0,
    this.diasIdeais = 1,
  });

  HabitatInputState copyWith({
    double? agua,
    double? comida,
    double? oxigenio,
    double? maxAgua,
    double? maxComida,
    double? maxOxigenio,
    double? taxaVolumeComida,
    double? taxaAguaReidratacao,
    double? stepAgua,
    double? stepComida,
    double? stepOxigenio,
    int? diasIdeais,
  }) {
    return HabitatInputState(
      agua: agua ?? this.agua,
      comida: comida ?? this.comida,
      oxigenio: oxigenio ?? this.oxigenio,
      maxAgua: maxAgua ?? this.maxAgua,
      maxComida: maxComida ?? this.maxComida,
      maxOxigenio: maxOxigenio ?? this.maxOxigenio,
      taxaVolumeComida: taxaVolumeComida ?? this.taxaVolumeComida,
      taxaAguaReidratacao: taxaAguaReidratacao ?? this.taxaAguaReidratacao,
      stepAgua: stepAgua ?? this.stepAgua,
      stepComida: stepComida ?? this.stepComida,
      stepOxigenio: stepOxigenio ?? this.stepOxigenio,
      diasIdeais: diasIdeais ?? this.diasIdeais,
    );
  }

  bool get isEmpty => agua == 0 && comida == 0 && oxigenio == 0;
}

@riverpod
class HabitatController extends _$HabitatController {
  @override
  HabitatInputState build() {
    final random = Random();

    // 1. Gera as taxas físicas aleatórias
    final taxaVolume = random.nextDouble() * 2.0 + 3.0; // 3 a 5 L/kg
    final taxaReidratacao = random.nextDouble() * 1.0 + 3.0; // 3 a 4 L/kg

    // 2. Calcula o consumo exato de 1 dia para a tripulação (Os Steps)
    const stepComida = 11400.0;
    const stepOxigenio = 2520.0;

    final pesoComidaPorDia = (stepComida / 350.0) * 0.1;
    final stepAgua = 15.2 + (pesoComidaPorDia * taxaReidratacao);

    // 3. Descobre o Gargalo Máximo (Ponto de Equilíbrio Ideal)
    final pesoTotalDiario = 604.8 + pesoComidaPorDia + stepAgua;
    final diasIdeais =
        (SurvivalCalculatorService.limiteCargaKg / pesoTotalDiario).floor();

    // 4. Define limites máximos independentes para cada recurso
    // Multiplicadores aleatórios entre 1.2x e 10x garantem proporções visuais desalinhadas.
    final multAgua = random.nextDouble() * 1.8 + 1.6;
    final multComida = random.nextDouble() * 1.4 + 1.0;
    final multOxigenio = random.nextDouble() * 1.6 + 1.4;

    // Converte os multiplicadores em quantidade máxima de "dias" (para manter o múltiplo do step perfeito)
    final diasMaxAgua = (diasIdeais * multAgua).ceil();
    final diasMaxComida = (diasIdeais * multComida).ceil();
    final diasMaxOxigenio = (diasIdeais * multOxigenio).ceil();

    return HabitatInputState(
      maxAgua: diasMaxAgua * stepAgua,
      maxComida: diasMaxComida * stepComida,
      maxOxigenio: diasMaxOxigenio * stepOxigenio,
      taxaVolumeComida: taxaVolume,
      taxaAguaReidratacao: taxaReidratacao,
      stepAgua: stepAgua,
      stepComida: stepComida,
      stepOxigenio: stepOxigenio,
      diasIdeais: diasIdeais,
    );
  }

  void updateAgua(double value) =>
      state = state.copyWith(agua: value < 0 ? 0 : value);
  void updateComida(double value) =>
      state = state.copyWith(comida: value < 0 ? 0 : value);
  void updateOxigenio(double value) =>
      state = state.copyWith(oxigenio: value < 0 ? 0 : value);
}

@riverpod
HabitatResult habitatResult(HabitatResultRef ref) {
  final inputs = ref.watch(habitatControllerProvider);
  final inventory = ref.watch(cargoControllerProvider);
  final cargoCapacity = ref.watch(
    cargoCapacityProvider,
  ); // Pega o peso dos módulos

  double modProdAgua = 0, modConsAgua = 0;
  double modProdComida = 0;
  double modProdOxigenio = 0;

  inventory.forEach((id, qtd) {
    final item = catalogoCarga.firstWhere((e) => e.id == id);
    modProdAgua += item.prodAgua * qtd;
    modConsAgua += item.consAgua * qtd;
    modProdComida += item.prodComida * qtd;
    modProdOxigenio += item.prodOxigenio * qtd;
  });

  final service = SurvivalCalculatorService();

  return service.calcularSobrevivencia(
    aguaDisponivel: inputs.agua,
    comidaDisponivel: inputs.comida,
    oxigenioDisponivel: inputs.oxigenio,
    taxaVolumeComida: inputs.taxaVolumeComida,
    taxaAguaReidratacao: inputs.taxaAguaReidratacao,
    modProdAgua: modProdAgua,
    modConsAgua: modConsAgua,
    modProdComida: modProdComida,
    modProdOxigenio: modProdOxigenio,
    pesoTotalCargaModulos: cargoCapacity.pesoTotal, // Injeta o peso aqui
  );
}
