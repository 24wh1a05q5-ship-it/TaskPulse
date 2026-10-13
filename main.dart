import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskController(),
      child: const TaskPulseApp(),
    ),
  );
}

// TASK MODEL
class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime dueAt;
  final String reminder;
  final int duration;
  final List<String> tags;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueAt,
    required this.reminder,
    required this.duration,
    required this.tags,
    this.completed = false,
  });
}

// PROVIDER STATE MANAGEMENT
class TaskController extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  int get total => _tasks.length;
  int get completed => _tasks.where((t) => t.completed).length;
  int get pending => total - completed;
  double get progress => total == 0 ? 0 : completed / total;

  void addTask(Task task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.completed = !task.completed;
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

// APP THEME AND NAMED ROUTES
class TaskPulseApp extends StatelessWidget {
  const TaskPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F6FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F6FC),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/add': (_) => const AddTaskScreen(),
        '/tasks': (_) => const AllTasksScreen(),
        '/feed': (_) => const ApiFeedScreen(),
      },
    );
  }
}

// DASHBOARD
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskPulse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Community Feed',
            onPressed: () => Navigator.pushNamed(context, '/feed'),
            icon: const Icon(Icons.public),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: Consumer<TaskController>(
        builder: (context, controller, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6750A4),
                                Color(0xFF9580D8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'YOUR PRODUCTIVITY',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Small steps.\nBig achievements.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Plan your day, your way.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Icon(
                                  Icons.bolt,
                                  color: Colors.white70,
                                  size: 42,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Today's Overview",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (wide)
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  label: 'Total',
                                  value: controller.total,
                                  icon: Icons.checklist,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  label: 'Pending',
                                  value: controller.pending,
                                  icon: Icons.pending_actions,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  label: 'Completed',
                                  value: controller.completed,
                                  icon: Icons.task_alt,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      label: 'Total',
                                      value: controller.total,
                                      icon: Icons.checklist,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StatCard(
                                      label: 'Pending',
                                      value: controller.pending,
                                      icon: Icons.pending_actions,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              StatCard(
                                label: 'Completed',
                                value: controller.completed,
                                icon: Icons.task_alt,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: controller.progress,
                                ),
                                duration: const Duration(milliseconds: 700),
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(10),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(controller.progress * 100).round()}% completed',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Tasks',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/tasks'),
                              child: const Text('View all'),
                            ),
                          ],
                        ),
                        if (controller.tasks.isEmpty)
                          const EmptyState()
                        else
                          ...controller.tasks.take(4).map(
                                (task) => TaskCard(task: task),
                              ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// REUSABLE STATISTICS CARD
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// EMPTY STATE
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 55, color: Colors.deepPurple),
          SizedBox(height: 12),
          Text(
            'No tasks yet!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('Tap Add Task to get started.'),
        ],
      ),
    );
  }
}

// ENHANCED TASK CARD
class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color get priorityColor {
    switch (task.priority) {
      case 'Urgent':
        return Colors.red;
      case 'High':
        return Colors.deepOrange;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TaskController>();

    return AnimatedOpacity(
      opacity: task.completed ? 0.6 : 1,
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (_) => controller.toggleTask(task.id),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Text(
                  '${task.category} • ${task.priority}',
                ),
                trailing: IconButton(
                  tooltip: 'Delete task',
                  onPressed: () => controller.deleteTask(task.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ),
              if (task.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(task.description),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _infoChip(
                      Icons.flag,
                      task.priority,
                      priorityColor,
                    ),
                    _infoChip(
                      Icons.calendar_today,
                      '${task.dueAt.day}/${task.dueAt.month}/${task.dueAt.year}',
                      Colors.blue,
                    ),
                    _infoChip(
                      Icons.access_time,
                      '${task.dueAt.hour.toString().padLeft(2, '0')}:'
                      '${task.dueAt.minute.toString().padLeft(2, '0')}',
                      Colors.deepPurple,
                    ),
                    _infoChip(
                      Icons.timer_outlined,
                      '${task.duration} min',
                      Colors.teal,
                    ),
                    _infoChip(
                      Icons.notifications_outlined,
                      task.reminder,
                      Colors.indigo,
                    ),
                    ...task.tags.map(
                      (tag) => _infoChip(
                        Icons.tag,
                        tag,
                        Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Chip(
      avatar: Icon(icon, size: 15, color: color),
      label: Text(text, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

// ADD TASK FORM WITH EXTRA FEATURES
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  String _category = 'Study';
  String _priority = 'Medium';
  String _reminder = '10 minutes before';
  int _duration = 60;

  DateTime _dueAt = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _timeLabel(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt.isBefore(now) ? now : _dueAt,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && mounted) {
      setState(() {
        _dueAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueAt.hour,
          _dueAt.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
    );

    if (picked != null && mounted) {
      setState(() {
        _dueAt = DateTime(
          _dueAt.year,
          _dueAt.month,
          _dueAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    if (_dueAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a future due date and time.'),
        ),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
      dueAt: _dueAt,
      reminder: _reminder,
      duration: _duration,
      tags: tags,
    );

    context.read<TaskController>().addTask(task);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task created successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create a Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6750A4),
                              Color(0xFF9580D8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add_task,
                              color: Colors.white,
                              size: 42,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plan your next win!',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Organize your work in one place.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // TASK TITLE
                      TextFormField(
                        controller: _titleController,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: 'Task title *',
                          hintText: 'e.g. Practice DSA',
                          prefixIcon: Icon(Icons.edit_note),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          if (value.trim().length < 3) {
                            return 'Enter at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // DESCRIPTION
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Add details about this task...',
                          prefixIcon: Icon(Icons.notes),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CATEGORY
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          'Study',
                          'Personal',
                          'Project',
                          'Health',
                          'College',
                          'Placement',
                          'Other',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // PRIORITY
                      const Text(
                        'Priority level',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _priorityOption('Low', Colors.green),
                          _priorityOption('Medium', Colors.orange),
                          _priorityOption('High', Colors.deepOrange),
                          _priorityOption('Urgent', Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // DATE AND TIME
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.calendar_month,
                                color: Colors.deepPurple,
                              ),
                              title: const Text('Due date'),
                              subtitle: Text(_dateLabel(_dueAt)),
                              trailing: const Icon(Icons.edit_calendar),
                              onTap: _selectDate,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.access_time,
                                color: Colors.deepPurple,
                              ),
                              title: const Text('Due time'),
                              subtitle: Text(_timeLabel(_dueAt)),
                              trailing: const Icon(Icons.schedule),
                              onTap: _selectTime,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // REMINDER
                      DropdownButtonFormField<String>(
                        value: _reminder,
                        decoration: const InputDecoration(
                          labelText: 'Reminder preference',
                          prefixIcon: Icon(Icons.notifications_active),
                        ),
                        items: [
                          'No reminder',
                          'At due time',
                          '5 minutes before',
                          '10 minutes before',
                          '30 minutes before',
                          '1 hour before',
                          '1 day before',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminder = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // DURATION
                      const Text(
                        'Estimated duration',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [15, 30, 45, 60, 90, 120].map((minutes) {
                          return ChoiceChip(
                            avatar: const Icon(Icons.timer_outlined, size: 18),
                            label: Text(
                              minutes >= 60
                                  ? '${minutes ~/ 60}h'
                                      '${minutes % 60 == 0 ? '' : ' 30m'}'
                                  : '$minutes min',
                            ),
                            selected: _duration == minutes,
                            onSelected: (_) {
                              setState(() => _duration = minutes);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // CUSTOM TAGS
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Custom tags',
                          hintText: 'DSA, Placements, Important',
                          helperText: 'Separate multiple tags with commas.',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                        validator: (value) {
                          final tags =
                              (value ?? '').split(',').map((tag) => tag.trim());

                          if (tags.any((tag) => tag.length > 25)) {
                            return 'Each tag must be at most 25 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // SAVE
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _saveTask,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            'Create Task',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          '* Required field',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _priorityOption(String value, Color color) {
    return ChoiceChip(
      avatar: Icon(Icons.flag, color: color, size: 18),
      label: Text(value),
      selected: _priority == value,
      onSelected: (_) => setState(() => _priority = value),
      selectedColor: color.withValues(alpha: 0.15),
      side: BorderSide(
        color: _priority == value ? color : Colors.grey.shade300,
      ),
    );
  }
}

// ALL TASKS
class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: Consumer<TaskController>(
        builder: (context, controller, child) {
          if (controller.tasks.isEmpty) {
            return const EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(task: controller.tasks[index]);
            },
          );
        },
      ),
    );
  }
}

// REST API FEED
class ApiFeedScreen extends StatefulWidget {
  const ApiFeedScreen({super.key});

  @override
  State<ApiFeedScreen> createState() => _ApiFeedScreenState();
}

class _ApiFeedScreenState extends State<ApiFeedScreen> {
  late Future<List<dynamic>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = fetchPosts();
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(
      Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=15',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Unable to load posts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _posts = fetchPosts()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const Text('Unable to load posts.'),
                  TextButton(
                    onPressed: () => setState(() => _posts = fetchPosts()),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index] as Map<String, dynamic>;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text('${post['id']}'),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Community Post',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${post['title']}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${post['body']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
