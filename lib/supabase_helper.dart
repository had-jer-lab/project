import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static const String supabaseUrl =
      'https://romncegfvzrwoxxnbtzr.supabase.co'; // استبدلي هذا بالرابط الخاص بك
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvbW5jZWdmdnpyd294eG5idHpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEzNTA2ODMsImV4cCI6MjA1NjkyNjY4M30.diZlvSctla-3lRkQJFtGjl4TsOUpT6D_A3EBlcrm3UM'; // استبدلي هذا بمفتاح Anon Key الخاص بك

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
