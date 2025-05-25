import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // لجلب userId
import 'main.dart'; // ✅ Assure-toi que DailyMenuPage est bien importée
import 'editprofile.dart'; // استيراد صفحة EditProfileScreen
import 'history.dart'; // استيراد صفحة HistoriquePage

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // جلب userId من Supabase
    final userId =
        Supabase.instance.client.auth.currentUser?.id ?? 'default_user_id';
    final userEmail =
        Supabase.instance.client.auth.currentUser?.email ?? 'user@example.com';

    return Scaffold(
      body: Stack(
        children: [
          // ✅ background image
          Positioned.fill(
            child: Image(
              image:
                  NetworkImage('https://i.ibb.co/Mk6w779z/1739918839709.jpg'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                    color: Colors.grey); // خلفية بديلة إذا فشل التحميل
              },
            ),
          ),

          // ✅ rose overlay
          Positioned.fill(
            child: Container(
              color: Colors.brown.withOpacity(0.3),
            ),
          ),

          // ✅ circular photo aligned to center left
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://i.ibb.co/Mk6w779z/1739918839709.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ✅ vertical buttons on the right (moved lower)
          Positioned(
            right: 40,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                MenuButton(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () {
                    // الانتقال إلى HistoriquePage مع تمرير userId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoriquePage(userId: userId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
                MenuButton(icon: Icons.restaurant_menu, label: 'Dishes'),
              ],
            ),
          ),

          // ✅ vertical buttons on the left
          Positioned(
            right: 200,
            top: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                MenuButton(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {
                    // الانتقال إلى EditProfileScreen مع تمرير البريد الإلكتروني
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileScreen(email: userEmail),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 270),
                MenuButton(
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  onTap: () {
                    // الانتقال إلى DailyMenuPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyMenuPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const MenuButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.brown[300],
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  color: Color(0x42000000),
                  blurRadius: 2,
                  offset: Offset(2, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
