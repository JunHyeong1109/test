import 'package:flutter/material.dart';

AppBar buildCommonAppBar({String userName = "홍길동"}) {
  return AppBar(
    leading: Image.asset('assets/logo.png', scale: 2.0),
    backgroundColor: const Color(0xFFFCAA5E),
    title: Row(
      children: [
        const Text('밥플', style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(userName, style: const TextStyle(fontSize: 14)),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          // TODO: 설정 페이지 연결 시 context.go('/settings') 등으로 교체
          debugPrint('Settings button pressed!');
        },
      ),
    ],
  );
}
