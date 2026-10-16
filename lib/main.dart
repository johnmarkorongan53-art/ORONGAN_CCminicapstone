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
  final int id;
  final String icon, name, schedule;
  final int durationMinutes;
  final Status status;
  const Routine({
    required this.id,
    required this.icon,
    required this.name,
    required this.schedule,
    required this.durationMinutes,
    required this.status,
  });

  String get details => '$schedule · $durationMinutes min';
}

const initialRoutines = <Routine>[
  Routine(
    id: 1,
    icon: '🏃',
    name: 'Sprint Intervals',
    schedule: 'Mon · 4:00 PM',
    durationMinutes: 45,
    status: Status.upcoming,
  ),
  Routine(
    id: 2,
    icon: '🏋️',
    name: 'Strength Training',
    schedule: 'Sun · 7:00 AM',
    durationMinutes: 60,
    status: Status.done,
  ),
  Routine(
    id: 3,
    icon: '🧘',
    name: 'Recovery & Stretching',
    schedule: 'Sat · 6:00 PM',
    durationMinutes: 30,
    status: Status.done,
  ),
  Routine(
    id: 4,
    icon: '🏊',
    name: 'Endurance Swim',
    schedule: 'Fri · 5:30 PM',
    durationMinutes: 40,
    status: Status.missed,
  ),
  Routine(
    id: 5,
    icon: '🚴',
    name: 'Cycling Cardio',
    schedule: 'Wed · 6:00 AM',
    durationMinutes: 50,
    status: Status.upcoming,
  ),
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
  int _nextRoutineId = 6;
  List<Routine> _routines = initialRoutines;
  String _athleteName = 'Juan Dela Cruz';
  String _sport = 'Track & Field · Sprinter';

  static const _titles = [
    '🏅 AthleteTrack',
    '📋 Training Schedule',
    '🔔 Alerts',
    '👤 My Profile',
  ];

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  void _select(int i) {
    setState(() {
      _index = i;
      if (i == 2) _unread = 0; // clear badge when alerts opened
    });
  }

  Future<void> _showRoutineEditor({
    Routine? routine,
    Status initialStatus = Status.upcoming,
  }) async {
    final result = await showDialog<Routine>(
      context: context,
      builder: (_) => RoutineEditorDialog(
        routine: routine,
        initialStatus: initialStatus,
        nextId: () => _nextRoutineId++,
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      final index = _routines.indexWhere((item) => item.id == result.id);
      if (index == -1) {
        _routines = [result, ..._routines];
      } else {
        _routines = [
          for (final item in _routines)
            if (item.id == result.id) result else item,
        ];
      }
    });
    _snack(
      routine == null
          ? '${result.name} added successfully'
          : '${result.name} updated successfully',
    );
  }

  Future<void> _deleteRoutine(Routine routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text('“${routine.name}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _routines = _routines.where((item) => item.id != routine.id).toList();
    });
    _snack('Routine deleted');
  }

  Future<void> _showProfileEditor() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) =>
          ProfileEditorDialog(athleteName: _athleteName, sport: _sport),
    );
    if (result == null || !mounted) return;
    setState(() {
      _athleteName = result.$1;
      _sport = result.$2;
    });
    _snack('Profile updated');
  }

  Future<void> _showNotice(String title, String subtitle) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        routines: _routines,
        onSchedule: () => _select(1),
        onLogWorkout: () => _showRoutineEditor(initialStatus: Status.done),
        onMessage: _snack,
      ),
      SchedulePage(
        routines: _routines,
        onAdd: () => _showRoutineEditor(),
        onEdit: (routine) => _showRoutineEditor(routine: routine),
        onDelete: _deleteRoutine,
      ),
      NotificationsPage(onOpenNotice: _showNotice),
      ProfilePage(
        athleteName: _athleteName,
        sport: _sport,
        onEdit: _showProfileEditor,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text('⚡', style: TextStyle(fontSize: 20)),
          ),
        ],
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
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Schedule',
          ),
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
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

String _statusLabel(Status status) => switch (status) {
  Status.done => 'Done',
  Status.upcoming => 'Upcoming',
  Status.missed => 'Missed',
};

class RoutineEditorDialog extends StatefulWidget {
  final Routine? routine;
  final Status initialStatus;
  final int Function() nextId;

  const RoutineEditorDialog({
    super.key,
    required this.routine,
    required this.initialStatus,
    required this.nextId,
  });

  @override
  State<RoutineEditorDialog> createState() => _RoutineEditorDialogState();
}

class _RoutineEditorDialogState extends State<RoutineEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _scheduleController;
  late final TextEditingController _durationController;
  final _formKey = GlobalKey<FormState>();
  late Status _selectedStatus;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _nameController = TextEditingController(text: routine?.name ?? '');
    _scheduleController = TextEditingController(text: routine?.schedule ?? '');
    _durationController = TextEditingController(
      text: routine?.durationMinutes.toString() ?? '',
    );
    _selectedStatus = routine?.status ?? widget.initialStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scheduleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routine = widget.routine;
    return AlertDialog(
      title: Text(routine == null ? 'Add Routine' : 'Edit Routine'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Routine name',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a routine name'
                    : null,
              ),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule (for example, Mon · 4:00 PM)',
                  prefixIcon: Icon(Icons.schedule),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a schedule'
                    : null,
              ),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (value) {
                  final minutes = int.tryParse(value ?? '');
                  return minutes == null || minutes <= 0
                      ? 'Enter a duration greater than 0'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Status>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: Status.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
                onChanged: (status) {
                  if (status != null) {
                    setState(() => _selectedStatus = status);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              Routine(
                id: routine?.id ?? widget.nextId(),
                icon: routine?.icon ?? '🏃',
                name: _nameController.text.trim(),
                schedule: _scheduleController.text.trim(),
                durationMinutes: int.parse(_durationController.text.trim()),
                status: _selectedStatus,
              ),
            );
          },
          child: Text(routine == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

class ProfileEditorDialog extends StatefulWidget {
  final String athleteName;
  final String sport;

  const ProfileEditorDialog({
    super.key,
    required this.athleteName,
    required this.sport,
  });

  @override
  State<ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<ProfileEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _sportController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.athleteName);
    _sportController = TextEditingController(text: widget.sport);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit Profile'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your name'
                : null,
          ),
          TextFormField(
            controller: _sportController,
            decoration: const InputDecoration(labelText: 'Sport / role'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your sport or role'
                : null,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(context, (
            _nameController.text.trim(),
            _sportController.text.trim(),
          ));
        },
        child: const Text('Save'),
      ),
    ],
  );
}

/* ---------------- HOME / LANDING PAGE ---------------- */
class HomePage extends StatelessWidget {
  final List<Routine> routines;
  final VoidCallback onSchedule;
  final VoidCallback onLogWorkout;
  final void Function(String) onMessage;
  const HomePage({
    super.key,
    required this.routines,
    required this.onSchedule,
    required this.onLogWorkout,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final completed = routines
        .where((routine) => routine.status == Status.done)
        .length;
    final completion = routines.isEmpty
        ? 0
        : (completed / routines.length * 100).round();
    final upcoming = routines.where(
      (routine) => routine.status == Status.upcoming,
    );
    final nextRoutine = upcoming.isEmpty ? null : upcoming.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withValues(alpha: .75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day, Athlete 👋',
                style: TextStyle(color: cs.onPrimary.withValues(alpha: .85)),
              ),
              const SizedBox(height: 4),
              Text(
                nextRoutine == null
                    ? 'No upcoming routines'
                    : 'Next: ${nextRoutine.name}\n${nextRoutine.schedule}',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${routines.length}',
                label: 'Sessions / wk',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(value: '12', label: 'Day streak 🔥'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(value: '$completion%', label: 'Completion'),
            ),
          ],
        ),

        const SectionTitle('Weekly Progress'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$completed of ${routines.length} sessions done'),
                    Text(
                      '$completion%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ProgressBar(value: completion / 100, color: Colors.green),
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
                onPressed: onLogWorkout,
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
  final String athleteName;
  final String sport;
  final VoidCallback onEdit;
  const ProfilePage({
    super.key,
    required this.athleteName,
    required this.sport,
    required this.onEdit,
  });

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
            child: Text(
              _initials(athleteName),
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            athleteName,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(sport, style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

/* ---------------- LIST / SCHEDULE PAGE ---------------- */
class SchedulePage extends StatefulWidget {
  final List<Routine> routines;
  final VoidCallback onAdd;
  final ValueChanged<Routine> onEdit;
  final ValueChanged<Routine> onDelete;
  const SchedulePage({
    super.key,
    required this.routines,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Status? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final items = widget.routines
        .where((r) => _filter == null || r.status == _filter)
        .toList();

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
                  child: Text(
                    'No routines here yet.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => RoutineTile(
                    routine: items[i],
                    onEdit: () => widget.onEdit(items[i]),
                    onDelete: () => widget.onDelete(items[i]),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: widget.onAdd,
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
  final void Function(String title, String subtitle) onOpenNotice;
  const NotificationsPage({super.key, required this.onOpenNotice});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        NoticeTile(
          '⏰',
          'Training in 30 min',
          'Sprint Intervals · 4:00 PM',
          onTap: () =>
              onOpenNotice('Training in 30 min', 'Sprint Intervals · 4:00 PM'),
        ),
        NoticeTile(
          '📈',
          'Weekly report ready',
          'You completed 80% of sessions',
          onTap: () => onOpenNotice(
            'Weekly report ready',
            'You completed 80% of sessions',
          ),
        ),
        NoticeTile(
          '💬',
          'Coach Reyes',
          'Focus on starts tomorrow',
          onTap: () => onOpenNotice('Coach Reyes', 'Focus on starts tomorrow'),
        ),
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
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
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
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class RoutineTile extends StatelessWidget {
  final Routine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const RoutineTile({
    super.key,
    required this.routine,
    required this.onEdit,
    required this.onDelete,
  });

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
                  Text(
                    routine.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    routine.details,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Routine actions',
              onSelected: (action) {
                if (action == 'edit') onEdit();
                if (action == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeTile extends StatelessWidget {
  final String icon, title, subtitle;
  final VoidCallback onTap;
  const NoticeTile(
    this.icon,
    this.title,
    this.subtitle, {
    super.key,
    required this.onTap,
  });

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
        onTap: onTap,
      ),
    );
  }
}
