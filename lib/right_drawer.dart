import 'package:flutter/material.dart';

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
      onTap: () {
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
          Navigator.pushReplacementNamed(context, '/');
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
      },
    );
  }
}
