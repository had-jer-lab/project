import 'package:flutter/material.dart';
import 'login.dart'; // ✅ importer page 2

class Page1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background
          Positioned.fill(
            child: Image.network(
              'https://i.postimg.cc/kM6XSrbJ/Brown-and-Yellow-Modern-Food-Poster-1.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // صور الأطباق الثلاثة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleImage('https://i.ibb.co/0pKfY6JD/brgger.png', 105),
                  SizedBox(width: 0),
                  CircleImage('https://i.ibb.co/zWjxz0sQ/l2.png', 150),
                  SizedBox(width: 0),
                  CircleImage('https://i.ibb.co/zW4KpXSR/cap-cake.png', 105),
                  SizedBox(width: 0),
                ],
              ),
              SizedBox(height: 90),
              Text(
                '',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              Text(
                'BEST MENU OF THE WEEK',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff5d4037),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.brown[900]!),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text(
                  'START',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'www.dailymenu.com',
                      style: TextStyle(color: Colors.brown[700]),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      '+123-456-7890',
                      style: TextStyle(color: Colors.brown[700]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class CircleImage extends StatefulWidget {
  final String imageUrl;
  final double size;

  CircleImage(this.imageUrl, this.size);

  @override
  _CircleImageState createState() => _CircleImageState();
}

class _CircleImageState extends State<CircleImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            margin: EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown[600]!, width: 4),
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
