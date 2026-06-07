import 'package:flutter/material.dart';

void main() {
  runApp(const FirearmsTrackerApp());
}

class Incident {
  final String id;
  final DateTime date;
  final String location;
  final int injuries;
  final int fatalities;
  final String description;

  Incident({
    required this.id,
    required this.date,
    required this.location,
    required this.injuries,
    required this.fatalities,
    required this.description,
  });
}

class FirearmsTrackerApp extends StatelessWidget {
  const FirearmsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firearms Injury Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Incident> _incidents = [
    Incident(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Downtown District',
      injuries: 2,
      fatalities: 0,
      description: 'Altercation near main street.',
    ),
    Incident(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 5)),
      location: 'Westside Park',
      injuries: 1,
      fatalities: 1,
      description: 'Accidental discharge incident.',
    ),
  ];

  void _addIncident(Incident incident) {
    setState(() {
      _incidents.insert(0, incident);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalInjuries = _incidents.fold(0, (sum, item) => sum + item.injuries);
    int totalFatalities = _incidents.fold(0, (sum, item) => sum + item.fatalities);

    final List<Widget> pages = [
      _DashboardView(totalIncidents: _incidents.length, totalInjuries: totalInjuries, totalFatalities: totalFatalities),
      _IncidentListView(incidents: _incidents),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firearms Injury Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(
        onPressed: () async {
          final newIncident = await Navigator.push<Incident>(
            context,
            MaterialPageRoute(builder: (context) => const AddIncidentScreen()),
          );
          if (newIncident != null) {
            _addIncident(newIncident);
          }
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Incidents',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final int totalIncidents;
  final int totalInjuries;
  final int totalFatalities;

  const _DashboardView({
    required this.totalIncidents,
    required this.totalInjuries,
    required this.totalFatalities,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _StatCard(title: 'Total Incidents', value: totalIncidents.toString(), icon: Icons.report, color: Colors.blue),
                _StatCard(title: 'Total Injuries', value: totalInjuries.toString(), icon: Icons.local_hospital, color: Colors.orange),
                _StatCard(title: 'Total Fatalities', value: totalFatalities.toString(), icon: Icons.warning, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _IncidentListView extends StatelessWidget {
  final List<Incident> incidents;

  const _IncidentListView({required this.incidents});

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return const Center(child: Text('No incidents recorded.'));
    }
    return ListView.builder(
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.report_problem, color: Colors.white),
            ),
            title: Text(incident.location),
            subtitle: Text('${incident.date.toLocal().toString().split(' ')[0]} - Injuries: ${incident.injuries}, Fatalities: ${incident.fatalities}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Incident at ${incident.location}'),
                  content: Text('Date: ${incident.date.toLocal().toString().split(' ')[0]}\nInjuries: ${incident.injuries}\nFatalities: ${incident.fatalities}\n\nDescription:\n${incident.description}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _location = '';
  int _injuries = 0;
  int _fatalities = 0;
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Injuries', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a number';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => _injuries = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Fatalities', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a number';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => _fatalities = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 4,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final newIncident = Incident(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: DateTime.now(),
                        location: _location,
                        injuries: _injuries,
                        fatalities: _fatalities,
                        description: _description,
                      );
                      Navigator.pop(context, newIncident);
                    }
                  },
                  child: const Text('Save Incident'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
