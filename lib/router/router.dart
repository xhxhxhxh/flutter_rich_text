import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home/home.dart';

class CustomPage {
  final String path;
  final Widget Function() page;

  CustomPage({required this.path, required this.page}) ;
}

var routes = <CustomPage>[
  CustomPage(path: '/', page: () => const Home())
];

List<RouteBase> generateRoutes(List<CustomPage> routes) {
  return routes.map((route) => GoRoute(
    path: route.path,
    builder: (BuildContext context, GoRouterState state) {
        return route.page();
      },
  )).toList();
}


final GoRouter router = GoRouter(
  routes: generateRoutes(routes)
);

