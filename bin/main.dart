import 'dart:io';
import 'package:supabase/supabase.dart';
import '../lib/conexao.dart';
import '../lib/veiculos.dart';

String _formatarValor(dynamic valor) {
  final numero = (valor is num) ? valor.toDouble() : double.parse(valor.toString());
  return 'R\$ ${numero.toStringAsFixed(2)}';
}

String? _lerTextoObrigatorio(String prompt, String nomeCampo, int limite) {
  stdout.write(prompt);
  final entrada = stdin.readLineSync()?.trim() ?? '';

  if (entrada.isEmpty) {
    print('Entrada inválida: $nomeCampo não pode ficar vazio.');
    return null;
  }
  if (entrada.length > limite) {
    print('Entrada inválida: $nomeCampo deve ter no máximo $limite caracteres.');
    return null;
  }
  return entrada;
}

int? _lerAno(String prompt) {
  stdout.write(prompt);
  final entrada = stdin.readLineSync()?.trim() ?? '';
  final ano = int.tryParse(entrada);
  final anoMaximo = DateTime.now().year + 1;

  if (ano == null) {
    print('Entrada inválida: o ano deve ser um número inteiro.');
    return null;
  }
  if (ano < 1900 || ano > anoMaximo) {
    print('Entrada inválida: o ano deve estar entre 1900 e $anoMaximo.');
    return null;
  }
  return ano;
}

double? _lerValor(String prompt) {
  stdout.write(prompt);
  final entrada = stdin.readLineSync()?.trim() ?? '';

  if (entrada.isEmpty) {
    print('Entrada inválida: o valor não pode ficar vazio.');
    return null;
  }

  // Rejeita separador de milhar (ex: 65.000,00 ou 65,000.00 ou múltiplos pontos/vírgulas)
  final temPonto = entrada.contains('.');
  final temVirgula = entrada.contains(',');
  if ((temPonto && temVirgula) ||
      '.'.allMatches(entrada).length > 1 ||
      ','.allMatches(entrada).length > 1) {
    print('Entrada inválida: informe o valor sem separador de milhar, usando apenas ponto ou vírgula como separador decimal.');
    return null;
  }

  final normalizado = entrada.replaceAll(',', '.');
  final valor = double.tryParse(normalizado);

  if (valor == null || !valor.isFinite) {
    print('Entrada inválida: informe um valor numérico válido.');
    return null;
  }
  if (valor <= 0) {
    print('Entrada inválida: o valor deve ser maior que zero.');
    return null;
  }
  if (valor >= 10000000000000) {
    print('Entrada inválida: o valor deve ser menor que 10000000000000.');
    return null;
  }

  return valor;
}

int? _lerQuilometragem(String prompt) {
  stdout.write(prompt);
  final entrada = stdin.readLineSync()?.trim() ?? '';
  final km = int.tryParse(entrada);

  if (km == null) {
    print('Entrada inválida: a quilometragem deve ser um número inteiro.');
    return null;
  }
  if (km < 0) {
    print('Entrada inválida: a quilometragem não pode ser negativa.');
    return null;
  }
  return km;
}

int? _lerId(String prompt) {
  stdout.write(prompt);
  final entrada = stdin.readLineSync()?.trim() ?? '';
  final id = int.tryParse(entrada);

  if (id == null || id <= 0) {
    print('Entrada inválida: o ID deve ser um número inteiro positivo.');
    return null;
  }
  return id;
}

Future<void> main() async {
  SupabaseClient? client;

  try {
    client = conectar();
    var executando = true;

    while (executando) {
      print('\nCADASTRO DE VEÍCULOS');
      print('1- Cadastrar veículo');
      print('2- Listar veículos');
      print('3- Atualizar veículo');
      print('4- Excluir veículo');
      print('0 - Sair');
      stdout.write('O que deseja fazer? ');

      final opcao = stdin.readLineSync()?.trim() ?? '';

      switch (opcao) {
        case '1':
          final marca = _lerTextoObrigatorio('Marca: ', 'A marca', 50);
          if (marca == null) break;

          final modelo = _lerTextoObrigatorio('Modelo: ', 'O modelo', 100);
          if (modelo == null) break;

          final ano = _lerAno('Ano: ');
          if (ano == null) break;

          final valor = _lerValor('Valor: ');
          if (valor == null) break;

          final quilometragem = _lerQuilometragem('Quilometragem: ');
          if (quilometragem == null) break;

          try {
            final criado = await cadastrarVeiculo(
              client,
              marca,
              modelo,
              ano,
              valor,
              quilometragem,
            );
            print('Veículo cadastrado!');
            print(
              'ID: ${criado['id']} | ${criado['marca']} ${criado['modelo']} | '
              'Ano: ${criado['ano']} | Valor: ${_formatarValor(criado['valor'])} | '
              'Quilometragem: ${criado['quilometragem']} km',
            );
          } catch (e) {
            print('Erro ao cadastrar veículo: $e');
          }
          break;

        case '2':
          try {
            final veiculos = await listarVeiculos(client);
            if (veiculos.isEmpty) {
              print('Nenhum veículo cadastrado.');
            } else {
              for (final v in veiculos) {
                print(
                  'ID: ${v['id']} | Marca: ${v['marca']} | Modelo: ${v['modelo']} | '
                  'Ano: ${v['ano']} | Valor: ${_formatarValor(v['valor'])} | '
                  'Quilometragem: ${v['quilometragem']} km',
                );
              }
            }
          } catch (e) {
            print('Erro ao listar veículos: $e');
          }
          break;

        case '3':
          final id = _lerId('ID do veículo: ');
          if (id == null) break;

          final novaMarca = _lerTextoObrigatorio('Nova marca: ', 'A marca', 50);
          if (novaMarca == null) break;

          final novoModelo = _lerTextoObrigatorio('Novo modelo: ', 'O modelo', 100);
          if (novoModelo == null) break;

          final novoAno = _lerAno('Novo ano: ');
          if (novoAno == null) break;

          final novoValor = _lerValor('Novo valor: ');
          if (novoValor == null) break;

          final novaQuilometragem = _lerQuilometragem('Nova quilometragem: ');
          if (novaQuilometragem == null) break;

          try {
            final atualizado = await atualizarVeiculo(
              client,
              id,
              novaMarca,
              novoModelo,
              novoAno,
              novoValor,
              novaQuilometragem,
            );

            if (atualizado == null) {
              print('Nenhum veículo encontrado com o ID $id.');
            } else {
              print('Veículo atualizado!');
              print(
                'ID: ${atualizado['id']} | ${atualizado['marca']} ${atualizado['modelo']} | '
                'Ano: ${atualizado['ano']} | Valor: ${_formatarValor(atualizado['valor'])} | '
                'Quilometragem: ${atualizado['quilometragem']} km',
              );
            }
          } catch (e) {
            print('Erro ao atualizar veículo: $e');
          }
          break;

        case '4':
          final id = _lerId('ID do veículo: ');
          if (id == null) break;

          stdout.write('Confirma a exclusão? S/N: ');
          final confirmacao = stdin.readLineSync()?.trim() ?? '';

          if (confirmacao == 'N' || confirmacao == 'n') {
            print('Exclusão cancelada.');
            break;
          }

          if (confirmacao != 'S' && confirmacao != 's') {
            print('Resposta inválida. Exclusão cancelada.');
            break;
          }

          try {
            final excluido = await excluirVeiculo(client, id);
            if (excluido == null) {
              print('Nenhum veículo encontrado com o ID $id.');
            } else {
              print('Veículo excluído!');
              print(
                'ID: ${excluido['id']} | ${excluido['marca']} ${excluido['modelo']}',
              );
            }
          } catch (e) {
            print('Erro ao excluir veículo: $e');
          }
          break;

        case '0':
          print('Sistema encerrado.');
          executando = false;
          break;

        default:
          print('Opção inválida. Tente novamente.');
      }
    }
  } catch (e) {
    print('Falha na inicialização do sistema: $e');
  } finally {
    client?.dispose();
  }
}
