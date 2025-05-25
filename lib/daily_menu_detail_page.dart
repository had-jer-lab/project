import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Page2.dart';

class DailyMenuDetailPage extends StatelessWidget {
  final String day;

  const DailyMenuDetailPage({Key? key, required this.day}) : super(key: key);

  Future<Map<int, String>> fetchMealsForDay(String mealType) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('calendar_details')
        .select('meal_index, meals(name)')
        .eq('day_of_week', day)
        .eq('meal_type', mealType);

    final Map<int, String> mealsMap = {
      1: 'Non sélectionné',
      2: 'Non sélectionné',
      3: 'Non sélectionné',
    };

    if (response is List) {
      for (final row in response) {
        final index = row['meal_index'];
        final name = row['meals']?['name'];
        if (index != null && name != null) {
          mealsMap[index] = name;
        }
      }
    }

    return mealsMap;
  }

  Widget buildMealSection(String title, String mealType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cursive',
              color: Color(0xFF5C4033),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<Map<int, String>>(
          future: fetchMealsForDay(mealType),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final meals = snapshot.data ??
                {
                  1: 'Non sélectionné',
                  2: 'Non sélectionné',
                  3: 'Non sélectionné',
                };

            return Column(
              children: [
                menuItem(Icons.restaurant_menu, meals[1]!),
                menuItem(Icons.fastfood, meals[2]!),
                menuItem(Icons.cake, meals[3]!),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget menuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 40, top: 18, bottom: 1),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 2),
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.add, size: 16, color: Color(0xFF3E2723)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.ibb.co/tMFFXm03/calender.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.only(
                left: 0.0, right: 40, top: 60.0, bottom: 8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  buildMealSection('$day déjeuner  ', 'Breakfast'),
                  buildMealSection('Dîner', 'Dinner'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFB68A59),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 26),
              onPressed: () {
                // Action pour l'icône "profile" (facultatif)
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu_book, color: Colors.white, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DailyMenuDetailPage(day: day)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page2()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.restaurant, color: Colors.white, size: 26),
              onPressed: () {
                // Action pour restaurant (facultatif)
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 26),
              onPressed: () {
                // Action pour settings (facultatif)
              },
            ),
          ],
        ),
      ),
    );
  }
}
