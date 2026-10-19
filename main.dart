import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const CyberTaskApp());
}

class CyberTaskApp extends StatelessWidget {
  const CyberTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow Cyber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007F), // Neon Pink
          secondary: Color(0xFF00F0FF), // Neon Cyan
          surface: Color(0xFF1F1B24),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELO DE DADOS
// -----------------------------------------------------------------------------
class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime date;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
  });
}

// -----------------------------------------------------------------------------
// TELA 1: CADASTRO / LOGIN
// -----------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF007F).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFFFF007F), width: 2),
                ),
                child: const Icon(Icons.bolt, size: 60, color: Color(0xFFFF007F)),
              ),
              const SizedBox(height: 16),
              Text(
                isLogin ? 'Bem-Vindo de Volta!' : 'Criar Nova Conta',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('Gerenciador de Tarefas Cyberpunk', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00F0FF)),
                  filled: true,
                  fillColor: const Color(0xFF1F1B24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00F0FF)),
                  filled: true,
                  fillColor: const Color(0xFF1F1B24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF007F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(
                    isLogin ? 'ENTRAR' : 'CADASTRAR',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Faça Login',
                  style: const TextStyle(color: Color(0xFF00F0FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TELA PRINCIPAL DE NAVEGAÇÃO E GERENCIAMENTO DE ESTADO
// -----------------------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Lista global de tarefas na memória
  final List<Task> _allTasks = [
    Task(id: '1', title: 'Estudar Flutter e Dart', isCompleted: false, date: DateTime.now()),
    Task(id: '2', title: 'Fazer exercícios físicos', isCompleted: true, date: DateTime.now()),
    Task(id: '3', title: 'Comprar suprimentos', isCompleted: false, date: DateTime.now()),
  ];

  // Regra de Ordenação Requerida: Pendentes primeiro (A-Z), depois Concluídas (A-Z)
  List<Task> _getTasksForSelectedDay() {
    final dayTasks = _allTasks.where((t) => isSameDay(t.date, _selectedDay)).toList();

    dayTasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return a.isCompleted ? 1 : -1;
    });

    return dayTasks;
  }

  void _addTask(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _allTasks.add(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        date: _selectedDay,
      ));
    });
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final task = _allTasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _removeTask(String id) {
    setState(() {
      _allTasks.removeWhere((t) => t.id == id);
    });
  }

  void _showAddTaskDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1B24),
        title: const Text('Nova Tarefa', style: TextStyle(color: Color(0xFF00F0FF))),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Digite a descrição da tarefa...',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF007F)),
            onPressed: () {
              _addTask(textController.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      // Tela de Calendário
      CalendarTab(
        selectedDay: _selectedDay,
        focusedDay: _focusedDay,
        onDaySelected: (sDay, fDay) {
          setState(() {
            _selectedDay = sDay;
            _focusedDay = fDay;
            _currentIndex = 1; // Navega para a lista de tarefas após selecionar o dia
          });
        },
      ),
      // Tela de Lista de Tarefas
      TaskListTab(
        selectedDay: _selectedDay,
        tasks: _getTasksForSelectedDay(),
        onToggle: _toggleTaskStatus,
        onDelete: _removeTask,
        onAddTaskPressed: _showAddTaskDialog,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Cyber', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F1B24),
        elevation: 0,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1F1B24),
        selectedItemColor: const Color(0xFFFF007F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendário'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Tarefas'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TELA 2: CALENDÁRIO
// -----------------------------------------------------------------------------
class CalendarTab extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarTab({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: const Color(0xFF1F1B24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: onDaySelected,
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Color(0xFFFF007F), shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Color(0xFF00F0FF), shape: BoxShape.circle),
                defaultTextStyle: TextStyle(color: Colors.white),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F0FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.touch_app, color: Colors.black),
            label: const Text(
              'Selecione um dia para ver as tarefas',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TELA 3: LISTA DE TAREFAS
// -----------------------------------------------------------------------------
class TaskListTab extends StatelessWidget {
  final DateTime selectedDay;
  final List<Task> tasks;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final VoidCallback onAddTaskPressed;

  const TaskListTab({
    super.key,
    required this.selectedDay,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.onAddTaskPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = "${selectedDay.day.toString().padLeft(2, '0')}/${selectedDay.month.toString().padLeft(2, '0')}/${selectedDay.year}";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarefas do dia: $dateStr',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00F0FF)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('Nenhuma tarefa cadastrada para este dia.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, index) {
                      final task = tasks[index];
                      return Card(
                        color: const Color(0xFF1F1B24),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            activeColor: const Color(0xFFFF007F),
                            onChanged: (_) => onToggle(task.id),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? Colors.grey : Colors.white,
                              fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => onDelete(task.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF007F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAddTaskPressed,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('ADICIONAR TAREFA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
