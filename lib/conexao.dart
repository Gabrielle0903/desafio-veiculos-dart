import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

SupabaseClient conectar() {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final url = env['SUPABASE_URL'];
  final key = env['SUPABASE_PUBLISHABLE_KEY'] ?? env['SUPABASE_ANON_KEY'];

  if (url == null || url.isEmpty || key == null || key.isEmpty) {
    throw Exception(
      'Variáveis SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY não configuradas no arquivo .env.',
    );
  }

  return SupabaseClient(url, key);
}
