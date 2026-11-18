import 'package:supabase/supabase.dart';

Future<Map<String, dynamic>> cadastrarVeiculo(
  SupabaseClient client,
  String marca,
  String modelo,
  int ano,
  double valor,
  int quilometragem,
) async {
  final response = await client
      .from('veiculos')
      .insert({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .select()
      .single();

  return response;
}

Future<List<Map<String, dynamic>>> listarVeiculos(
  SupabaseClient client,
) async {
  final response = await client
      .from('veiculos')
      .select()
      .order('id', ascending: true);

  return List<Map<String, dynamic>>.from(response);
}

Future<Map<String, dynamic>?> atualizarVeiculo(
  SupabaseClient client,
  int id,
  String marca,
  String modelo,
  int ano,
  double valor,
  int quilometragem,
) async {
  final response = await client
      .from('veiculos')
      .update({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .eq('id', id)
      .select();

  if (response.isEmpty) {
    return null;
  }

  return response.first;
}

Future<Map<String, dynamic>?> excluirVeiculo(
  SupabaseClient client,
  int id,
) async {
  final response = await client
      .from('veiculos')
      .delete()
      .eq('id', id)
      .select();

  if (response.isEmpty) {
    return null;
  }

  return response.first;
}
