import 'package:flutter/material.dart';

void main() => runApp(const AthleteTrackApp());

/* ---------------- APP ---------------- */
class AthleteTrackApp extends StatelessWidget {
  const AthleteTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AthleteTrack',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF60A5FA),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        brightness: Brightness.dark,
      ),
      home: const MainShell(),
    );
  }
}

/* ---------------- MODEL ---------------- */
enum Status { done, upcoming, missed }

class Routine {
  final String icon, name, details;
  final Status status;
  const Routine(this.icon, this.name, this.details, this.status);
}

const routines = <Routine>[
  Routine('🏃', 'Sprint Intervals', 'Mon · 4:00 PM · 45 min', Status.upcoming),
  Routine('🏋️', 'Strength Training', 'Sun · 7:00 AM · 60 min', Status.done),
  Routine('🧘', 'Recovery & Stretching', 'Sat · 6:00 PM · 30 min', Status.done),
  Routine('🏊', 'Endurance Swim', 'Fri · 5:30 PM · 40 min', Status.missed),
  Routine('🚴', 'Cycling Cardio', 'Wed · 6:00 AM · 50 min', Status.upcoming),
];

/* ---------------- MAIN SHELL (bottom nav) ---------------- */
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _unread = 3;

  static const _titles = ['🏅 AthleteTrack', '📋 Training Schedule', '🔔 Alerts', '👤 My Profile'];

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ));
  }

  void _select(int i) {
    setState(() {
      _index = i;
      if (i == 2) _unread = 0; // clear badge when alerts opened
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onSchedule: () => _select(1), onMessage: _snack),
      SchedulePage(onMessage: _snack),
      const NotificationsPage(),
      ProfilePage(onMessage: _snack),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Text('⚡', style: TextStyle(fontSize: 20)))],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        height: 68,
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          const NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Schedule'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _unread > 0,
              label: Text('$_unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

/* ---------------- HOME / LANDING PAGE ---------------- */
class HomePage extends StatelessWidget {
  final VoidCallback onSchedule;
  final void Function(String) onMessage;
  const HomePage({super.key, required this.onSchedule, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withOpacity(.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good day, Athlete 👋',
                  style: TextStyle(color: cs.onPrimary.withOpacity(.85))),
              const SizedBox(height: 4),
              Text('Next: Sprint Intervals\nToday · 4:00 PM',
                  style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: cs.primary,
                ),
                onPressed: () => onMessage('Session started ▶'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Session'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Stats
        const Row(
          children: [
            Expanded(child: StatCard(value: '5', label: 'Sessions / wk')),
            SizedBox(width: 10),
            Expanded(child: StatCard(value: '12', label: 'Day streak 🔥')),
            SizedBox(width: 10),
            Expanded(child: StatCard(value: '85%', label: 'Completion')),
          ],
        ),

        const SectionTitle('Weekly Progress'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('4 of 5 sessions done'),
                    Text('80%', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                ProgressBar(value: 0.8, color: Colors.green),
              ],
            ),
          ),
        ),

        const SectionTitle('Quick Actions'),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: onSchedule,
                icon: const Icon(Icons.list_alt),
                label: const Text('Schedule'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => onMessage('Log entry saved ✓'),
                icon: const Icon(Icons.edit_note),
                label: const Text('Log Workout'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/* ---------------- PROFILE PAGE ---------------- */
class ProfilePage extends StatelessWidget {
  final void Function(String) onMessage;
  const ProfilePage({super.key, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SizedBox(height: 10),
        Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: cs.primary,
            child: Text('JD',
                style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text('Juan Dela Cruz',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Center(
          child: Text('Track & Field · Sprinter',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                InfoRow('Age', '19'),
                Divider(height: 1),
                InfoRow('Height / Weight', '172 cm / 64 kg'),
                Divider(height: 1),
                InfoRow('Coach', 'Coach Reyes'),
                Divider(height: 1),
                InfoRow('Team', 'University Varsity'),
              ],
            ),
          ),
        ),
        const SectionTitle('Goals'),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('🎯 100m under 11s')),
            Chip(label: Text('💪 Build strength')),
            Chip(label: Text('😴 8h sleep')),
          ],
        ),
        const SectionTitle('Monitoring'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fitness readiness'),
                    Text('78%', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                ProgressBar(value: 0.78, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: () => onMessage('Edit profile opened'),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

/* ---------------- LIST / SCHEDULE PAGE ---------------- */
class SchedulePage extends StatefulWidget {
  final void Function(String) onMessage;
  const SchedulePage({super.key, required this.onMessage});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Status? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final items = routines.where((r) => _filter == null || r.status == _filter).toList();

    return Column(
      children: [
        // Filter tabs
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              _tab('All', null),
              _tab('Done', Status.done),
              _tab('Upcoming', Status.upcoming),
              _tab('Missed', Status.missed),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text('No routines here yet.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => RoutineTile(routine: items[i]),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => widget.onMessage('Add new routine'),
            icon: const Icon(Icons.add),
            label: const Text('Add Routine'),
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, Status? s) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == s,
          onSelected: (_) => setState(() => _filter = s),
        ),
      );
}

/* ---------------- NOTIFICATIONS PAGE ---------------- */
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [
        NoticeTile('⏰', 'Training in 30 min', 'Sprint Intervals · 4:00 PM'),
        NoticeTile('📈', 'Weekly report ready', 'You completed 80% of sessions'),
        NoticeTile('💬', 'Coach Reyes', 'Focus on starts tomorrow'),
      ],
    );
  }
}

/* ---------------- REUSABLE WIDGETS ---------------- */
class StatCard extends StatelessWidget {
  final String value, label;
  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const ProgressBar({super.key, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: value, minHeight: 10, color: color),
      );
}

class InfoRow extends StatelessWidget {
  final String label, value;
  const InfoRow(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

class RoutineTile extends StatelessWidget {
  final Routine routine;
  const RoutineTile({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, label) = switch (routine.status) {
      Status.done => (Colors.green.shade700, 'Done'),
      Status.upcoming => (Colors.amber.shade800, 'Upcoming'),
      Status.missed => (Colors.red.shade700, 'Missed'),
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(routine.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routine.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(routine.details, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeTile extends StatelessWidget {
  final String icon, title, subtitle;
  const NoticeTile(this.icon, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        minVerticalPadding: 12,
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}