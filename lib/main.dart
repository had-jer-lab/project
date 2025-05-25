import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_helper.dart';
import 'Page1.dart'; // استيراد الصفحة الأولى بشكل صحيح

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseHelper.initialize(); // تهيئة Supabase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Menu App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Page1Screen(), // بدء التطبيق من Page1Screen
    );
  }
}
