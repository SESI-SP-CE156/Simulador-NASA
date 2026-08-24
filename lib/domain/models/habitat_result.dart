import 'resource_type.dart';

class HabitatResult {
  final double consumoDiarioAgua;
  final double consumoDiarioComida;
  final double consumoDiarioOxigenio;
  final double duracaoAguaDias;
  final double duracaoComidaDias;
  final double duracaoOxigenioDias;
  final double diasSobrevivencia;
  final ResourceType recursoLimitante;

  final double pesoTotalKg;
  final bool pesoExcedido;

  final double volumeTotalLitros;
  final bool volumeExcedido;
  final double consumoAguaReidratacaoDiario;

  const HabitatResult({
    required this.consumoDiarioAgua,
    required this.consumoDiarioComida,
    required this.consumoDiarioOxigenio,
    required this.duracaoAguaDias,
    required this.duracaoComidaDias,
    required this.duracaoOxigenioDias,
    required this.diasSobrevivencia,
    required this.recursoLimitante,
    required this.pesoTotalKg,
    required this.pesoExcedido,
    required this.volumeTotalLitros,
    required this.volumeExcedido,
    required this.consumoAguaReidratacaoDiario,
  });

  factory HabitatResult.mock() => const HabitatResult(
    consumoDiarioAgua: 10,
    consumoDiarioComida: 10000,
    consumoDiarioOxigenio: 5000,
    duracaoAguaDias: 99,
    duracaoComidaDias: 99,
    duracaoOxigenioDias: 99,
    diasSobrevivencia: 99,
    recursoLimitante: ResourceType.nenhum,
    pesoTotalKg: 50000,
    pesoExcedido: false,
    volumeTotalLitros: 500000,
    volumeExcedido: false,
    consumoAguaReidratacaoDiario: 5,
  );
}
