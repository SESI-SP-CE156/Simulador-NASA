import 'package:simulador_nasa/domain/models/habitat_result.dart';
import 'package:simulador_nasa/domain/models/resource_type.dart';

class SurvivalCalculatorService {
  static const int _habitantesFixos = 4;
  static const double limiteCargaKg = 99000.0;
  static const double limiteVolumeLitros = 1000000.0;

  static const double _taxaAgua = 3.8;
  static const double _taxaComida = 2850.0;
  static const double _taxaOxigenio = 630.0;

  // Cada Litro de Água pesa 1Kg
  static const double _pesoAguaKgPorLitro = 1.0;
  // Cada Litro de Oxigênio pesa 240g (0.24 Kg)
  static const double _pesoOxigenioKgPorLitro = 0.24;

  // Cada 350kcal pesa 100g (0.1 Kg)
  double _calcularPesoComidaKg(double kcal) {
    return (kcal / 350.0) * 0.1;
  }

  HabitatResult calcularSobrevivencia({
    required double aguaDisponivel,
    required double comidaDisponivel,
    required double oxigenioDisponivel,
    // Novos parâmetros dinâmicos para a variação física
    required double taxaVolumeComida,
    required double taxaAguaReidratacao,
  }) {
    final consumoDiarioComida = _taxaComida * _habitantesFixos;
    final consumoDiarioOxigenio = _taxaOxigenio * _habitantesFixos;

    final pesoComidaDiaria = _calcularPesoComidaKg(consumoDiarioComida);

    // Calcula a reidratação com base na taxa variável injetada (3 a 4 L/kg)
    final consumoAguaReidratacao = pesoComidaDiaria * taxaAguaReidratacao;
    final consumoDiarioAgua =
        (_taxaAgua * _habitantesFixos) + consumoAguaReidratacao;

    final duracaoAgua = aguaDisponivel > 0
        ? aguaDisponivel / consumoDiarioAgua
        : 0.0;
    final duracaoComida = comidaDisponivel > 0
        ? comidaDisponivel / consumoDiarioComida
        : 0.0;
    final duracaoOxigenio = oxigenioDisponivel > 0
        ? oxigenioDisponivel / consumoDiarioOxigenio
        : 0.0;

    double menorDuracao = duracaoAgua;
    ResourceType limitante = ResourceType.agua;

    if (duracaoComida < menorDuracao) {
      menorDuracao = duracaoComida;
      limitante = ResourceType.comida;
    }
    if (duracaoOxigenio < menorDuracao) {
      menorDuracao = duracaoOxigenio;
      limitante = ResourceType.oxigenio;
    }

    final pesoComidaTotal = _calcularPesoComidaKg(comidaDisponivel);
    final pesoAgua = aguaDisponivel * _pesoAguaKgPorLitro;
    final pesoOxigenio = oxigenioDisponivel * _pesoOxigenioKgPorLitro;
    final pesoTotal = pesoAgua + pesoOxigenio + pesoComidaTotal;

    // VOLUME
    // 1kg de comida ocupa de 3 a 5 litros (definido pela taxaVolumeComida)
    final volumeComidaTotal = pesoComidaTotal * taxaVolumeComida;
    // 1 litro de água ocupa exatamente 1L do volume
    final volumeAgua = aguaDisponivel;
    // Se 1L de oxigênio (input) pesa 240g, e cada 240g ocupam 1L de volume,
    // a proporção de volume do oxigênio é exatamente 1:1 em relação ao input.
    final volumeOxigenio = oxigenioDisponivel;

    final volumeTotal = volumeAgua + volumeOxigenio + volumeComidaTotal;

    return HabitatResult(
      consumoDiarioAgua: consumoDiarioAgua,
      consumoDiarioComida: consumoDiarioComida,
      consumoDiarioOxigenio: consumoDiarioOxigenio,
      duracaoAguaDias: duracaoAgua,
      duracaoComidaDias: duracaoComida,
      duracaoOxigenioDias: duracaoOxigenio,
      diasSobrevivencia: menorDuracao,
      recursoLimitante: limitante,
      pesoTotalKg: pesoTotal,
      pesoExcedido: pesoTotal > limiteCargaKg,
      volumeTotalLitros: volumeTotal,
      volumeExcedido: volumeTotal > limiteVolumeLitros,
      consumoAguaReidratacaoDiario: consumoAguaReidratacao,
    );
  }
}
