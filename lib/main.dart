import 'package:flutter/material.dart';
import 'router/app_router.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '혼밥매칭',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF29C50), // 오렌지 메인 컬러
      ),
      routerConfig: appRouter, // ✅ 라우터 적용
    );
  }
}
