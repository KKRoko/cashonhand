import 'package:flutter/material.dart';
import 'widgets/achievement_list_view.dart';

class AchievementsScreen extends StatelessWidget {  // Changed from ConsumerWidget
  static const routeName = '/achievements';

  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {  // Removed WidgetRef ref parameter
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Achievements'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Unlocked'),
              Tab(text: 'In Progress'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AchievementListView(filter: AchievementFilter.all),
            AchievementListView(filter: AchievementFilter.unlocked),
            AchievementListView(filter: AchievementFilter.inProgress),
          ],
        ),
      ),
    );
  }
}
