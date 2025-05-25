import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'daily_menu_detail_page.dart';
import 'home.dart';

class DailyMenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Menu',
      debugShowCheckedModeBanner: false,
      home: DailyMenuPage(),
    );
  }
}

class DailyMenuPage extends StatefulWidget {
  @override
  _DailyMenuPageState createState() => _DailyMenuPageState();
}

class _DailyMenuPageState extends State<DailyMenuPage> {
  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  Future<Map<String, List<String>>> fetchWeeklyMeals() async {
    final supabase = Supabase.instance.client;
    final Map<String, List<String>> weeklyMeals = {};
    for (String day in days) {
      final response = await supabase
          .from('calendar_details')
          .select('meal_id, meals(name)')
          .eq('day_of_week', day);

      if (response is List) {
        final meals = response
            .map((e) => e['meals']?['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        weeklyMeals[day] = meals;
      } else {
        weeklyMeals[day] = ['Erreur'];
      }
    }
    return weeklyMeals;
  }

  void showNoteDialog(BuildContext context) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une note'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(hintText: "Écris ta note ici..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = noteController.text.trim();
              final userId = Supabase.instance.client.auth.currentUser?.id;

              if (userId == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Utilisateur non connecté."),
                  backgroundColor: Colors.red,
                ));
                return;
              }

              if (content.isNotEmpty) {
                try {
                  await Supabase.instance.client.from('notes1').insert({
                    'day_of_week': DateTime.now().weekday.toString(),
                    'content': content,
                    'user_id': userId,
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Note enregistrée !'),
                    backgroundColor: Colors.green,
                  ));
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final weeklyMeals = await fetchWeeklyMeals();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: weeklyMeals.entries
              .map((entry) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(entry.key,
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      ...entry.value.map((meal) => pw.Text('• $meal')),
                      pw.SizedBox(height: 10)
                    ],
                  ))
              .toList(),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void generateRandomWeeklyMenu(BuildContext context) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.from('meals').select('id');
      if (response == null || response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Aucun plat trouvé dans la base de données.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final allMeals = List<Map<String, dynamic>>.from(response);
      final random = List<Map<String, dynamic>>.from(allMeals)..shuffle();

      for (String day in days) {
        await supabase.from('calendar_details').delete().eq('day_of_week', day);
        final selectedMeals = random.take(3).toList();
        for (var meal in selectedMeals) {
          await supabase.from('calendar_details').insert({
            'day_of_week': day,
            'meal_id': meal['id'],
          });
        }
        random.shuffle();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Menu généré avec succès pour toute la semaine!'),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DailyMenuPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7EFE9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://i.ibb.co/9HXXLPbR/1739221666248.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white),
                  Text('',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pacifico',
                          color: Colors.white)),
                  Icon(Icons.restaurant_menu, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('Menu',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Freehand',
                  color: Color(0xFF9E8367),
                )),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    ...days.map((day) => DayBox(day)).toList(),
                    GestureDetector(
                      onTap: () => showNoteDialog(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE8D6C3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes',
                                style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold)),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(FontAwesomeIcons.plusCircle,
                                  size: 16, color: Color(0xFF5C4033)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomButton(
                    icon: FontAwesomeIcons.shuffle,
                    label: 'aléatoire',
                    onPressed: () => generateRandomWeeklyMenu(context),
                  ),
                  BottomButton(
                    icon: FontAwesomeIcons.image,
                    label: 'png',
                    onPressed: () {},
                  ),
                  BottomButton(
                    icon: FontAwesomeIcons.filePdf,
                    label: 'pdf',
                    onPressed: () => generatePdf(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 59, // Hauteur personnalisée ici
            color: const Color(
                0xFFB68A59), // Obligatoire si tu ne veux pas perdre la couleur
            child: BottomNavigationBar(
              backgroundColor: Colors
                  .transparent, // Pour ne pas écraser le color du Container
              selectedItemColor: Colors.white,
              unselectedItemColor: Color(0xb3ffffff),
              type: BottomNavigationBarType.fixed,
              elevation: 0, // Supprime l'ombre si besoin
              onTap: (index) {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Page2()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DayBox extends StatelessWidget {
  final String day;
  const DayBox(this.day);

  Future<List<String>> fetchMeals() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('calendar_details')
        .select('meal_id, meals(name)')
        .eq('day_of_week', day);

    final meals =
        (response as List).map((e) => e['meals']['name'] as String).toList();
    return meals;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DailyMenuDetailPage(day: day)),
        );
      },
      child: FutureBuilder<List<String>>(
        future: fetchMeals(),
        builder: (context, snapshot) {
          return Container(
            decoration: BoxDecoration(
              color: Color(0xFFE8D6C3),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day,
                    style: TextStyle(
                        color: Colors.brown, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Text('Erreur...', style: TextStyle(color: Colors.red))
                else if (snapshot.data!.isEmpty)
                  Text("Aucune repas", style: TextStyle(color: Colors.grey))
                else
                  ...snapshot.data!.map((name) =>
                      Text('• $name', style: TextStyle(color: Colors.black))),
                Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(FontAwesomeIcons.plusCircle,
                      size: 16, color: Color(0xFFA1887F)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  BottomButton(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: FaIcon(icon, color: Color(0xFF5D4037)),
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF5D4037))),
      ],
    );
  }
}
