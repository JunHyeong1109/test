import 'package:flutter/material.dart';

class CommonBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CommonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CommonBottomNav> createState() => _CommonBottomNavState();
}

class _CommonBottomNavState extends State<CommonBottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      selectedItemColor: const Color(0xFFF29C50),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: '주문하기'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '혼밥매치'),
      ],
    );
  }
}
