import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/common_appbar.dart';
import '../widgets/common_bottom_nav.dart';

// 화면들 import
import '../screens/home_page.dart';
import '../screens/order_page.dart';
import '../screens/meal_match_setting.dart';

// 현재 위치를 하단탭 인덱스로 변환
int _indexFromLocation(String location) {
  if (location.startsWith('/order')) return 1;
  if (location.startsWith('/match')) return 2;
  return 0; // home
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/match', // 기존 첫 화면 유지
  routes: [
    // 공통 AppBar + BottomNav를 감싸는 Shell
    ShellRoute(
      builder: (context, state, child) {
        final loc = state.fullPath ?? state.uri.toString();
        final currentIndex = _indexFromLocation(loc);

        return Scaffold(
          appBar: buildCommonAppBar(userName: "홍길동"),
          body: child,
          bottomNavigationBar: CommonBottomNav(
            currentIndex: currentIndex,
            onTap: (i) {
              switch (i) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/order');
                  break;
                case 2:
                  context.go('/match');
                  break;
              }
            },
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/order',
          name: 'order',
          builder: (context, state) => const OrderPage(),
        ),
        GoRoute(
          path: '/match',
          name: 'match',
          builder: (context, state) => const MealMatchSettingScreen(),
        ),
      ],
    ),

    // 필요 시 탭 밖(풀스크린) 상세 페이지는 여기 추가
    // GoRoute(
    //   path: '/restaurant/:id',
    //   name: 'restaurantDetail',
    //   builder: (context, state) => RestaurantDetailScreen(
    //     id: state.pathParameters['id']!,
    //   ),
    // ),
  ],
);
