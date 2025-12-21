import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'merch/merch_page.dart';
import 'news/newspage.dart';
import 'schedule/macth_list.dart';

class RightDrawer extends StatelessWidget {
  const RightDrawer({
    super.key,
    this.isAdmin = false,
    this.isSuperuser = false,
  });

  final bool isAdmin;
  final bool isSuperuser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black12),
            child: Text('Menu'),
          ),
          _drawerItem(Icons.article_outlined, 'News', context),
          _drawerItem(Icons.shopping_bag_outlined, 'Merch', context),
          _drawerItem(Icons.groups_outlined, 'Squad', context),
          _drawerItem(Icons.event_available_outlined, 'Schedule', context),
          _drawerItem(Icons.confirmation_num_outlined, 'Ticket', context),
          _drawerItem(Icons.forum_outlined, 'Forum', context),
          const Divider(),
          _drawerItem(Icons.logout, 'Logout', context, isLogout: true),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label, BuildContext context, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () async {
        Navigator.of(context).pop();
        if (label == 'News') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsPage(isAdmin: isAdmin, isSuperuser: isSuperuser),
            ),
          );
        } else if (label == 'Merch') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MerchPage(isAdmin: isAdmin, isSuperuser: isSuperuser),
            ),
          );
        } else if (label == 'Schedule') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchListPage(isAdmin: isAdmin, isSuperuser: isSuperuser),
            ),
          );
        } else if (isLogout) {
          final request = context.read<CookieRequest>();
          try {
            await request.logout(
              "https://hasanul-muttaqin-garudaspot.pbp.cs.ui.ac.id/accounts/logout-mobile/",
            );
          } catch (_) {}
          Navigator.pushReplacementNamed(context, '/news');
        } else if (label == 'Squad') {
          Navigator.pushNamed(context, '/Squad');
        } else if (label == 'Ticket') {
          Navigator.pushNamed(
            context,
            '/ticket',
            arguments: {
              'isAdmin': isAdmin,
              'isSuperuser': isSuperuser,
            },
          );
        }
        else if (label == 'Forum') {
          final request = context.read<CookieRequest>();
          if (!request.loggedIn) {
            Navigator.pushReplacementNamed(context, '/');
            return;
          }
          final username = request.jsonData['username'];
          Navigator.pushNamed(
            context,
            '/forum',
            arguments: {
              'username': username is String ? username : '',
              'isAdmin': isAdmin || isSuperuser,
            },
          );
        }
      },
    );
  }
}
