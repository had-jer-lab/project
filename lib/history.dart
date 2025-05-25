import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Tracker',
      theme: ThemeData(primarySwatch: Colors.brown),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/historique': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return HistoriquePage(userId: args?['userId'] ?? 'default_user_id');
        },
        '/meals': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return MealsPage(userId: args?['userId'] ?? 'default_user_id');
        },
        '/add_note': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return AddNotePage(arguments: args);
        },
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  Future<void> _login() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('email', emailController.text)
          .eq('password', passwordController.text)
          .maybeSingle();

      if (response == null) {
        setState(() {
          errorMessage = "Invalid email or password.";
        });
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/historique',
          arguments: {'userId': response['id']},
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error logging in: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E8D9), // اللون المولي
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  final Function(String) onSortSelected;
  final String userId;

  SideMenu({required this.onSortSelected, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // خلفية الصورة الشفافة
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&auto=format&fit=crop&q=60'), // صورة عشوائية كمثال
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // شفافية 0.3
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // خلفية اللون الأبيض الخفيف
          Container(
            color: Color(0xFFF5F5F5).withOpacity(0.8), // أبيض شفاف قليلاً
          ),
          // المحتوى
          Container(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B6F47), // بني متوسط
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "HISTORIQUE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                CustomButton(
                  text: "Weeks Sorted by Ratings",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String tempSortBy = 'normal';
                        return AlertDialog(
                          backgroundColor: Color(0xFFF5F5F5), // أبيض تقريبًا
                          title: Text(
                            "Sort Weeks",
                            style: TextStyle(color: Colors.black),
                          ),
                          content: StatefulBuilder(
                            builder: (context, setState) {
                              return DropdownButton<String>(
                                value: tempSortBy,
                                items: [
                                  DropdownMenuItem(
                                      value: 'normal', child: Text('Normal')),
                                  DropdownMenuItem(
                                      value: 'top', child: Text('Top Rated')),
                                  DropdownMenuItem(
                                      value: 'low', child: Text('Low Rated')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    tempSortBy = value!;
                                  });
                                },
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                onSortSelected(tempSortBy);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text("Apply",
                                  style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel",
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 25),
                CustomButton(
                  text: "Dishes by Frequency",
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/meals',
                      arguments: {'userId': userId},
                    );
                  },
                ),
                SizedBox(height: 25),
                CustomButton(
                  text: "Add Note",
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add_note',
                      arguments: {'userId': userId},
                    );
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Color(0xFF8B6F47), // بني متوسط
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class HistoriquePage extends StatefulWidget {
  final String userId;

  HistoriquePage({required this.userId});

  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<Map<String, dynamic>> historique = [];
  String searchWeek = '';
  String sortBy = 'normal';

  @override
  void initState() {
    super.initState();
    fetchHistorique();
  }

  Future<void> fetchHistorique() async {
    try {
      var query = Supabase.instance.client
          .from('calendar')
          .select('id, start_date, end_date, notes')
          .eq('user_id', widget.userId);

      final response = await query.order('start_date', ascending: false);
      List<Map<String, dynamic>> tempHistorique =
          List<Map<String, dynamic>>.from(response);

      for (var item in tempHistorique) {
        final details = await fetchDetails(item['id']);
        double avgRating = details.isNotEmpty
            ? details.fold(0.0, (sum, d) => sum + d['avg_rating']) /
                details.length
            : 0.0;

        double highestMealRating = 0.0;
        Map<String, dynamic>? topMeal;

        for (var detail in details) {
          if (detail['avg_rating'] > highestMealRating) {
            highestMealRating = detail['avg_rating'];
            topMeal = detail;
          }
        }

        item['avg_rating'] = avgRating;
        item['top_meal'] = topMeal;
      }

      if (sortBy == 'top') {
        tempHistorique.sort(
            (a, b) => (b['avg_rating'] ?? 0).compareTo(a['avg_rating'] ?? 0));
      } else if (sortBy == 'low') {
        tempHistorique.sort(
            (a, b) => (a['avg_rating'] ?? 0).compareTo(b['avg_rating'] ?? 0));
      }

      setState(() {
        historique = tempHistorique;
      });
    } catch (e) {
      print('Error fetching historique: $e');
      setState(() {
        historique = [];
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetails(String calendarId) async {
    try {
      final detailsResponse = await Supabase.instance.client
          .from('calendar_details')
          .select('day_of_week, meal_type, meal_id, rating')
          .eq('calendar_id', calendarId)
          .order('day_of_week, meal_type');

      List<Map<String, dynamic>> details =
          List<Map<String, dynamic>>.from(detailsResponse);

      Map<String, Map<String, dynamic>> groupedDetails = {};

      for (var detail in details) {
        String key =
            '${detail['day_of_week']}_${detail['meal_type']}_${detail['meal_id']}';
        groupedDetails.putIfAbsent(
            key,
            () => {
                  'day_of_week': detail['day_of_week'],
                  'meal_type': detail['meal_type'],
                  'meal_id': detail['meal_id'],
                  'ratings': [],
                });
        groupedDetails[key]!['ratings'].add(detail['rating']);
      }

      List<Map<String, dynamic>> finalDetails =
          groupedDetails.values.map((item) {
        List ratings = item['ratings'];
        double avgRating = ratings.isNotEmpty
            ? ratings.fold(0.0, (sum, r) => sum + (r ?? 0)) / ratings.length
            : 0.0;
        return {
          'day_of_week': item['day_of_week'],
          'meal_type': item['meal_type'],
          'meal_id': item['meal_id'],
          'avg_rating': avgRating,
        };
      }).toList();

      for (var detail in finalDetails) {
        final mealResponse = await Supabase.instance.client
            .from('meals')
            .select('name')
            .eq('id', detail['meal_id'])
            .maybeSingle();
        detail['meal_name'] =
            mealResponse != null ? mealResponse['name'] : 'وجبة غير معروفة';
      }

      return finalDetails;
    } catch (e) {
      print('Error fetching details: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E8D9), // اللون المولي
      appBar: AppBar(
        backgroundColor: Color(0xFFD2B48C), // بني فاتح
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("Historique", style: TextStyle(color: Colors.black)),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: SideMenu(
        onSortSelected: (String sort) {
          setState(() {
            sortBy = sort;
            fetchHistorique();
          });
        },
        userId: widget.userId,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFE8D5C4), // بيج أغمق
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF8B6F47)), // بني متوسط
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter week date...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchWeek = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: historique.isEmpty
                  ? Center(child: Text('No calendars found'))
                  : ListView(
                      children: historique
                          .where((item) =>
                              searchWeek.isEmpty ||
                              item['start_date']
                                  .toString()
                                  .contains(searchWeek))
                          .map((item) => FutureBuilder(
                                future: fetchDetails(item['id']),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final details = snapshot.data!;
                                  return _buildWeekCard(item, details);
                                },
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCard(
      Map<String, dynamic> item, List<Map<String, dynamic>> details) {
    List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    double avgWeekRating = item['avg_rating'] ?? 0.0;
    final topMeal = item['top_meal'];

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Color(0xffecded1), // بيج أغمق
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week: ${item['start_date']} / ${item['end_date']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text('rating: ${avgWeekRating.toStringAsFixed(2)}'),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                return _buildDayCard(days[index], details);
              },
            ),
            SizedBox(height: 10),
            if (topMeal != null)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Color(0xffecd6bb), // بني فاتح
                      title: Text('the meal of the week is:'),
                      content: Text(topMeal['meal_name'] ?? ''),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xffe5ccac), // بني فاتح
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFF8B6F47)), // بني متوسط
                      SizedBox(width: 8),
                      Text(
                          'the meal of the week is: ${topMeal['meal_name'] ?? ''}'),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 10),
            Text(
              'notes: ${item['notes'] ?? 'لا توجد ملاحظات'}',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, List<Map<String, dynamic>> details) {
    List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

    return Container(
      decoration: BoxDecoration(
        color: Color(0xffe5ccac), // بني فاتح
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            for (var type in mealTypes)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$type:', style: TextStyle(color: Colors.black87)),
                  ...details
                      .where((d) =>
                          d['day_of_week'] == day && d['meal_type'] == type)
                      .map((meal) => Row(
                            children: [
                              Expanded(child: Text(meal['meal_name'])),
                              Text('${meal['avg_rating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.yellow[800])),
                              Icon(Icons.star,
                                  color: Colors.yellow[800], size: 16),
                            ],
                          ))
                      .toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class MealsPage extends StatefulWidget {
  final String userId;
  MealsPage({required this.userId});

  @override
  _MealsPageState createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage>
    with SingleTickerProviderStateMixin {
  late final SupabaseClient _client;
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _filteredMeals = [];
  String _searchQuery = '';
  bool _ascending = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Offset _fabPosition = Offset(20, 20);

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _loadMeals();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    try {
      final calendarResponse = await _client
          .from('calendar')
          .select('id')
          .eq('user_id', widget.userId)
          .single();

      if (calendarResponse == null) {
        setState(() {
          _meals = [];
          _filteredMeals = [];
        });
        return;
      }

      final calendarId = calendarResponse['id'];

      final response = await _client
          .from('calendar_details')
          .select('meal_id, meals(name, image)')
          .eq('calendar_id', calendarId);

      if (response == null || response.isEmpty) {
        setState(() {
          _meals = [];
          _filteredMeals = [];
        });
        return;
      }

      Map<String, Map<String, dynamic>> mealCountMap = {};
      for (var entry in response) {
        String mealId = entry['meal_id'];
        String mealName = entry['meals']['name'] ?? 'Repas Inconnu';
        String mealImage = entry['meals']['image'] ?? '';

        if (!mealCountMap.containsKey(mealId)) {
          mealCountMap[mealId] = {
            'meal_id': mealId,
            'name': mealName,
            'image': mealImage,
            'count': 1
          };
        } else {
          mealCountMap[mealId]!['count'] += 1;
        }
      }

      List<Map<String, dynamic>> sortedMeals = mealCountMap.values.toList()
        ..sort((a, b) => _ascending
            ? a['count'].compareTo(b['count'])
            : b['count'].compareTo(a['count']));

      setState(() {
        _meals = sortedMeals;
        _filteredMeals = sortedMeals;
      });
    } catch (e) {
      print('Erreur de chargement des repas: $e');
    }
  }

  void _filterMeals(String query) {
    setState(() {
      _searchQuery = query;
      _filteredMeals = _meals
          .where((meal) =>
              meal['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _ascending = !_ascending;
      _filteredMeals.sort((a, b) => _ascending
          ? a['count'].compareTo(b['count'])
          : b['count'].compareTo(a['count']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E8D9), // اللون المولي
      appBar: AppBar(
        backgroundColor: Color(0xFFD2B48C), // بني فاتح
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/historique',
                arguments: {'userId': widget.userId});
          },
        ),
        title: Text('Suivi des Repas', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8D5C4), // بيج أغمق
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A3728).withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _filterMeals,
                    decoration: InputDecoration(
                      labelText: 'Rechercher des repas',
                      labelStyle: TextStyle(color: Color(0xFF4A3728)),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF4A3728)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: TextStyle(color: Color(0xFF4A3728)),
                  ),
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _filteredMeals[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Color(0xFFE8D5C4), // بيج أغمق
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.network(
                                meal['image'] ??
                                    'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&auto=format&fit=crop&q=60',
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    'https://via.placeholder.com/200x150?text=Repas',
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    meal['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF4A3728),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Utilisation: ${meal['count']}',
                                    style: TextStyle(color: Color(0xFF4A3728)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: _fabPosition.dx,
            top: _fabPosition.dy,
            child: Draggable(
              feedback: Material(
                color: Colors.transparent,
                child: FloatingActionButton(
                  backgroundColor: Color(0xFF8B6F47), // بني متوسط
                  onPressed: () {},
                  child: Icon(Icons.sort, color: Colors.white),
                ),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _fabPosition = details.offset;
                });
              },
              child: FloatingActionButton(
                backgroundColor: Color(0xFF8B6F47), // بني متوسط
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      _fabPosition.dx,
                      _fabPosition.dy + 50,
                      0,
                      0,
                    ),
                    items: [
                      PopupMenuItem<String>(
                        value: "Moins utilisé",
                        child: Text("Moins utilisé"),
                      ),
                      PopupMenuItem<String>(
                        value: "Plus utilisé",
                        child: Text("Plus utilisé"),
                      ),
                    ],
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        _ascending = (value == "Moins utilisé");
                        _filteredMeals.sort((a, b) => _ascending
                            ? a['count'].compareTo(b['count'])
                            : b['count'].compareTo(a['count']));
                      });
                    }
                  });
                },
                child: Icon(Icons.sort, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddNotePage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  AddNotePage({this.arguments});

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.arguments?['userId'] ?? 'default_user_id';
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      print('Loading notes for user_id: $userId');
      final response = await Supabase.instance.client
          .from('notes')
          .select('id, note')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _notes = List<Map<String, dynamic>>.from(response);
      });
      print('Notes loaded: $_notes');
    } catch (e) {
      print('Error loading notes: $e');
      setState(() {
        _notes = [];
      });
    }
  }

  Future<void> _saveNote(String note) async {
    if (note.trim().isNotEmpty) {
      try {
        print('Saving note for user_id: $userId');
        await Supabase.instance.client.from('notes').insert({
          'user_id': userId,
          'note': note.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
        _noteController.clear();
        await _loadNotes();
        print('Note saved successfully');
      } catch (e) {
        print('Error saving note: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    }
  }

  void _confirmDeleteNote(String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(noteId);
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await Supabase.instance.client.from('notes').delete().eq('id', noteId);
      await _loadNotes();
    } catch (e) {
      print('Error deleting note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note')),
      );
    }
  }

  void _editNote(String noteId, String noteText) {
    _noteController.text = noteText;
    _deleteNote(noteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E8D9), // اللون المولي
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Text(
                      "Add a note",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Color(0xFFE8D5C4), // بيج أغمق
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            _notes[index]['note'],
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editNote(
                                    _notes[index]['id'], _notes[index]['note']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteNote(_notes[index]['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Add your note ...",
                      filled: true,
                      fillColor: Color(0xFFE8D5C4), // بيج أغمق
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _saveNote(_noteController.text),
                  child: Icon(Icons.add),
                  backgroundColor: Color(0xFF8B6F47), // بني متوسط
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
