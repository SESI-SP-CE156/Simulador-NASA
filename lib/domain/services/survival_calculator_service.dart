// lib/domain/services/survival_calculator_service.dart
import 'package:simulador_nasa/domain/models/habitat_result.dart';
import 'package:simulador_nasa/domain/models/resource_type.dart';

class SurvivalCalculatorService {
  static const int _habitantesFixos = 4;
  static const double limiteCargaKg = 150000.0;
  static const double limiteVolumeLitros = 1000000.0;
  // Constantes para o cálculo de viagem (em dias)
  static const double tBase = 180.0; // 6 meses (tempo mínimo)
  static const double pPenalidade =
      40.0; // Dias extras se lançar com peso máximo (chegando a 270 dias / 9 meses)
  static const double _taxaAgua = 3.8;
  static const double _taxaComida = 2850.0;
  static const double _taxaOxigenio = 630.0;
  static const double _pesoAguaKgPorLitro = 1.0;
  static const double _pesoOxigenioKgPorLitro = 0.24;

  double _calcularPesoComidaKg(double kcal) {
    return (kcal / 350.0) * 0.1;
  }

  double calcularTempoViagemDias(double pesoAtual) {
    if (limiteCargaKg <= 0) return tBase;
    final proporcaoPeso = (pesoAtual / limiteCargaKg).clamp(0.0, 1.0);
    return tBase + (proporcaoPeso * pPenalidade);
  }

  HabitatResult calcularSobrevivencia({
    required double aguaDisponivel,
    required double comidaDisponivel,
    required double oxigenioDisponivel,
    required double taxaVolumeComida,
    required double taxaAguaReidratacao,
    double modProdAgua = 0,
    double modConsAgua = 0,
    double modProdComida = 0,
    double modProdOxigenio = 0,
    required double
    pesoTotalCargaModulos, // Novo parâmetro para o peso total dos módulos
  }) {
    final consumoDiarioComidaBase = _taxaComida * _habitantesFixos;
    final consumoDiarioOxigenioBase = _taxaOxigenio * _habitantesFixos;
    final pesoComidaDiaria = _calcularPesoComidaKg(consumoDiarioComidaBase);
    final consumoAguaReidratacao = pesoComidaDiaria * taxaAguaReidratacao;
    final consumoDiarioAguaBase =
        (_taxaAgua * _habitantesFixos) + consumoAguaReidratacao;

    // Cálculo do peso total do foguete (Sliders + Módulos) para a viagem
    final pesoEstoqueSliders =
        (aguaDisponivel * _pesoAguaKgPorLitro) +
        (oxigenioDisponivel * _pesoOxigenioKgPorLitro) +
        _calcularPesoComidaKg(comidaDisponivel);

    final pesoTotalFoguete = pesoEstoqueSliders + pesoTotalCargaModulos;

    // Calcula o tempo de viagem em dias baseado no peso atual
    final tempoViagemDias = calcularTempoViagemDias(pesoTotalFoguete);

    // Déficit considerando a produção dos módulos
    final deficitAgua = (consumoDiarioAguaBase + modConsAgua) - modProdAgua;
    final deficitComida = consumoDiarioComidaBase - modProdComida;
    final deficitOxigenio = consumoDiarioOxigenioBase - modProdOxigenio;

    // Duração bruta de cada recurso com base no estoque inicial
    final duracaoAgua = deficitAgua > 0
        ? (aguaDisponivel > 0 ? aguaDisponivel / deficitAgua : 0.0)
        : double.infinity;
    final duracaoComida = deficitComida > 0
        ? (comidaDisponivel > 0 ? comidaDisponivel / deficitComida : 0.0)
        : double.infinity;
    final duracaoOxigenio = deficitOxigenio > 0
        ? (oxigenioDisponivel > 0 ? oxigenioDisponivel / deficitOxigenio : 0.0)
        : double.infinity;

    // REGRA DE SOBREVIVÊNCIA AO TRÂNSITO:
    // Se o estoque inicial acaba ANTES de completar o tempo de viagem, a tripulação morre no trajeto (0 dias).
    final sobreviveuViagemAgua = duracaoAgua >= tempoViagemDias;
    final sobreviveuViagemComida = duracaoComida >= tempoViagemDias;
    final sobreviveuViagemOxigenio = duracaoOxigenio >= tempoViagemDias;

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

    // Se falhar em qualquer recurso durante a viagem, o tempo de sobrevivencia é limitado ao que possuía ou zerado se insuficiente
    bool falhaNaViagem =
        !sobreviveuViagemAgua ||
        !sobreviveuViagemComida ||
        !sobreviveuViagemOxigenio;

    if (falhaNaViagem) {
      // Encontra qual esgotou primeiro antes da viagem terminar
      if (!sobreviveuViagemAgua && duracaoAgua < tempoViagemDias) {
        menorDuracao = duracaoAgua;
        limitante = ResourceType.agua;
      }
      if (!sobreviveuViagemComida &&
          duracaoComida < tempoViagemDias &&
          duracaoComida < menorDuracao) {
        menorDuracao = duracaoComida;
        limitante = ResourceType.comida;
      }
      if (!sobreviveuViagemOxigenio &&
          duracaoOxigenio < tempoViagemDias &&
          duracaoOxigenio < menorDuracao) {
        menorDuracao = duracaoOxigenio;
        limitante = ResourceType.oxigenio;
      }
    } else if (menorDuracao == double.infinity) {
      limitante = ResourceType.nenhum;
    }

    return HabitatResult(
      consumoDiarioAgua: deficitAgua,
      consumoDiarioComida: deficitComida,
      consumoDiarioOxigenio: deficitOxigenio,
      duracaoAguaDias: duracaoAgua,
      duracaoComidaDias: duracaoComida,
      duracaoOxigenioDias: duracaoOxigenio,
      diasSobrevivencia: menorDuracao,
      recursoLimitante: limitante,
      pesoTotalKg: pesoEstoqueSliders,
      pesoExcedido: pesoTotalFoguete > limiteCargaKg,
      volumeTotalLitros:
          aguaDisponivel +
          oxigenioDisponivel +
          (_calcularPesoComidaKg(comidaDisponivel) * taxaVolumeComida),
      volumeExcedido:
          (aguaDisponivel +
              oxigenioDisponivel +
              (_calcularPesoComidaKg(comidaDisponivel) * taxaVolumeComida)) >
          limiteVolumeLitros,
      consumoAguaReidratacaoDiario: consumoAguaReidratacao,
    );
  }
}
