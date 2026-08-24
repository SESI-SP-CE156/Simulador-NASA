class CargoItem {
  final String id;
  final String nome;
  final double pesoKg;
  final double volumeL;
  final double prodEnergia, consEnergia;
  final double prodAgua, consAgua;
  final double prodOxigenio;
  final double prodComida;
  final double prodGelo, consGelo;
  final int ganhoFelicidade;

  const CargoItem({
    required this.id,
    required this.nome,
    required this.pesoKg,
    required this.volumeL,
    this.prodEnergia = 0,
    this.consEnergia = 0,
    this.prodAgua = 0,
    this.consAgua = 0,
    this.prodOxigenio = 0,
    this.prodComida = 0,
    this.prodGelo = 0,
    this.consGelo = 0,
    this.ganhoFelicidade = 0,
  });
}

// Catálogo fixo de itens disponíveis
const List<CargoItem> catalogoCarga = [
  CargoItem(
    id: 'painel_solar',
    nome: 'Painel Solar',
    pesoKg: 150,
    volumeL: 300,
    prodEnergia: 50,
  ),
  CargoItem(
    id: 'extrator_gelo',
    nome: 'Extrator de Gelo',
    pesoKg: 600,
    volumeL: 1200,
    consEnergia: 10,
    prodGelo: 30,
  ),
  CargoItem(
    id: 'filtro_agua',
    nome: 'Filtro de Água',
    pesoKg: 200,
    volumeL: 400,
    consEnergia: 5,
    consGelo: 30,
    prodAgua: 25,
  ),
  CargoItem(
    id: 'conv_eletro',
    nome: 'Conversor Eletrolítico',
    pesoKg: 350,
    volumeL: 700,
    consEnergia: 15,
    consAgua: 5,
    prodOxigenio: 3000,
  ),
  CargoItem(
    id: 'estufa',
    nome: 'Estufa',
    pesoKg: 1200,
    volumeL: 4500,
    consEnergia: 12,
    consAgua: 8,
    prodComida: 5700,
    ganhoFelicidade: 10,
  ),
  CargoItem(
    id: 'mod_sobrevivencia',
    nome: 'Módulo de Sobrevivência',
    pesoKg: 4500,
    volumeL: 22000,
    consEnergia: 20,
    ganhoFelicidade: 40,
  ),
  CargoItem(
    id: 'hover_leve',
    nome: 'Hover de Reconhecimento',
    pesoKg: 350,
    volumeL: 1500,
    consEnergia: 20,
    ganhoFelicidade: 15,
  ),
  CargoItem(
    id: 'rover_pesado',
    nome: 'Rover de Carga',
    pesoKg: 1200,
    volumeL: 4000,
    consEnergia: 10,
  ),
];
