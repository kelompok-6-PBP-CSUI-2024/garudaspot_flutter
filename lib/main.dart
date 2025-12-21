import 'package:flutter/material.dart';

import 'package:garudaspot_flutter/schedule/macth_list.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'auth/login.dart';
import 'auth/register.dart';
import 'news/newspage.dart';
import 'merch/merch_page.dart';
import 'Squad/player.dart';
import 'forum/forum_page.dart';
import 'tiket/pages/ticket_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'Garuda Spot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/news': (_) => const NewsPage(),
          '/merch': (_) => const MerchPage(),
          '/schedule': (_) => const MatchListPage(),
          '/Squad': (_) => const SquadPage(),
        },
        onGenerateRoute: (settings) {
          // Route: forum
          if (settings.name == '/forum') {
            final args = settings.arguments as Map<String, dynamic>?;

            final username = (args?['username'] ?? '') as String;
            final isAdmin = (args?['isAdmin'] ?? false) as bool;

            return MaterialPageRoute(
              builder: (_) => ForumPage(
                username: username,
                isAdmin: isAdmin,
              ),
            );
          }

          // Route: ticket
          if (settings.name == '/ticket') {
            final args = settings.arguments;
            bool isAdmin = false;
            bool isSuperuser = false;

            if (args is Map) {
              isAdmin = args['isAdmin'] == true;
              isSuperuser = args['isSuperuser'] == true;
            }

            return MaterialPageRoute(
              builder: (_) => TicketViewPage(
                isAdmin: isAdmin,
                isSuperuser: isSuperuser,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}
