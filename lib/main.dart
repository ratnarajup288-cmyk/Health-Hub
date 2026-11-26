import 'package:flutter/material.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Health & Meal AI',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const LandingPage(),
    );
  }
}

// Persistent Mobile-Keyed Session Store (DartPad & Mobile Compatible)
class UserDatabase {
  static final Map<String, Map<String, dynamic>> _accounts = {};

  static Map<String, dynamic>? loadUser(String mobile) {
    if (!_accounts.containsKey(mobile)) return null;
    return Map<String, dynamic>.from(_accounts[mobile]!);
  }

  static void saveUser(String mobile, Map<String, dynamic> data) {
    _accounts[mobile] = Map<String, dynamic>.from(data);
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.teal.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 90, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Smart Health & Meal AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Track daily Calories, Protein & Fat, monitor BMI, and save your progress with your mobile number.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Login / Register with Mobile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade900,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _mobileCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController(text: '165');
  final _weightCtrl = TextEditingController(text: '72');
  bool _isNewUser = false;
  bool _checkedMobile = false;
  bool _acceptedTerms = false;
  String? _errorMsg;

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _lookupMobile() {
    final mobile = _mobileCtrl.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      setState(
        () => _errorMsg = 'Enter a valid 10-digit Indian mobile number.',
      );
      return;
    }
    final existing = UserDatabase.loadUser(mobile);
    if (existing != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(userData: existing)),
        (_) => false,
      );
    } else {
      setState(() {
        _checkedMobile = true;
        _isNewUser = true;
        _errorMsg = null;
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Health Disclaimer: Smart Health & Meal AI provides general BMI and macro estimates for educational purposes and is not medical advice.\n\n'
            '2. Saved Data: Your profile, weight logs, and daily calorie/protein/fat history are saved under your mobile number.\n\n'
            '3. User Responsibility: Consult a healthcare professional before making major dietary changes.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _acceptedTerms = true;
                _errorMsg = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('I Accept'),
          ),
        ],
      ),
    );
  }

  void _register() {
    final mobile = _mobileCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());

    if (name.isEmpty) {
      setState(() => _errorMsg = 'Please enter your full name.');
      return;
    }
    if (h == null || h < 50 || h > 260 || w == null || w < 20 || w > 300) {
      setState(() => _errorMsg = 'Enter valid height (cm) and weight (kg).');
      return;
    }
    if (!_acceptedTerms) {
      setState(() => _errorMsg = 'Please accept the Terms & Conditions.');
      return;
    }

    final now = DateTime.now();
    final yesterday = _dateKey(now.subtract(const Duration(days: 1)));
    final dayBefore = _dateKey(now.subtract(const Duration(days: 2)));

    final newUserData = <String, dynamic>{
      'name': name,
      'mobile': mobile,
      'age': '28',
      'heightCm': h,
      'startW': w,
      'currW': w,
      'targW': (w - 5).clamp(40.0, 200.0),
      'goal': 'Weight Loss',
      'diet': 'Balanced',
      'weightLogs': [
        {'dateKey': dayBefore, 'w': w + 0.6},
        {'dateKey': yesterday, 'w': w + 0.3},
        {'dateKey': _dateKey(now), 'w': w},
      ],
      'mealLogs': [
        {
          'dateKey': dayBefore,
          'name': '3 Idlis & Sambar + Dal Roti',
          'kcal': 1480,
          'protein': 52,
          'fat': 38,
          'carbs': 210,
        },
        {
          'dateKey': yesterday,
          'name': 'Oats Bowl + 2 Rotis, Paneer & Salad',
          'kcal': 1390,
          'protein': 64,
          'fat': 41,
          'carbs': 175,
        },
      ],
    };

    UserDatabase.saveUser(mobile, newUserData);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(userData: newUserData)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewUser ? 'Complete Registration' : 'Mobile Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              _isNewUser ? Icons.person_add_alt_1 : Icons.phone_android,
              size: 54,
              color: Colors.teal,
            ),
            const SizedBox(height: 10),
            Text(
              _isNewUser
                  ? 'New Number Detected — Create Profile'
                  : 'Enter Mobile Number to Continue',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mobileCtrl,
              enabled: !_checkedMobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: _checkedMobile
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => setState(() {
                          _checkedMobile = false;
                          _isNewUser = false;
                        }),
                      )
                    : null,
              ),
            ),
            if (!_checkedMobile) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _lookupMobile,
                icon: const Icon(Icons.login),
                label: const Text('Continue with Mobile Number'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            if (_isNewUser) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    activeColor: Colors.teal,
                    onChanged: (v) => setState(() {
                      _acceptedTerms = v ?? false;
                      _errorMsg = null;
                    }),
                  ),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('I accept the '),
                        GestureDetector(
                          onTap: _showTermsDialog,
                          child: const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _register,
                icon: const Icon(Icons.check_circle),
                label: const Text('Register & Open Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  _errorMsg!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MainScreen({super.key, required this.userData});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;
  late Map<String, dynamic> _data = Map<String, dynamic>.from(widget.userData);

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _persist() {
    UserDatabase.saveUser(_data['mobile'], _data);
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightLogs = List<Map<String, dynamic>>.from(
      (_data['weightLogs'] as List).map((e) => Map<String, dynamic>.from(e)),
    );
    final mealLogs = List<Map<String, dynamic>>.from(
      (_data['mealLogs'] as List).map((e) => Map<String, dynamic>.from(e)),
    );

    return Scaffold(
      body: _tab == 0
          ? HomeTab(
              userData: _data,
              weightLogs: weightLogs,
              mealLogs: mealLogs,
              onAddMeal: (meal) {
                setState(() {
                  mealLogs.add(meal);
                  _data['mealLogs'] = mealLogs;
                });
                _persist();
              },
              onLogW: (w) {
                final todayKey = _dateKey(DateTime.now());
                setState(() {
                  _data['currW'] = w;
                  final idx = weightLogs.indexWhere(
                    (e) => e['dateKey'] == todayKey,
                  );
                  if (idx != -1) {
                    weightLogs[idx]['w'] = w;
                  } else {
                    weightLogs.add({'dateKey': todayKey, 'w': w});
                  }
                  _data['weightLogs'] = weightLogs;
                });
                _persist();
              },
              onEdit: () => setState(() => _tab = 1),
              onLogout: _logout,
            )
          : ProfileTab(
              userData: _data,
              onSave: (updated) {
                setState(() {
                  _data = updated;
                  _tab = 0;
                });
                _persist();
              },
              onLogout: _logout,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home & Daily Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Personal Details',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> weightLogs, mealLogs;
  final void Function(Map<String, dynamic>) onAddMeal;
  final void Function(double) onLogW;
  final VoidCallback onEdit, onLogout;
  const HomeTab({
    super.key,
    required this.userData,
    required this.weightLogs,
    required this.mealLogs,
    required this.onAddMeal,
    required this.onLogW,
    required this.onEdit,
    required this.onLogout,
  });
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _foodCtrl = TextEditingController(), _wCtrl = TextEditingController();
  late String _selectedDateKey = _dateKey(DateTime.now());
  String? _photo, _identified, _status, _tip;
  int _estKcal = 0, _estProtein = 0, _estFat = 0, _estCarbs = 0;

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _friendlyDate(String key) {
    final now = DateTime.now();
    if (key == _dateKey(now)) return 'Today';
    if (key == _dateKey(now.subtract(const Duration(days: 1))))
      return 'Yesterday';
    if (key == _dateKey(now.subtract(const Duration(days: 2))))
      return 'Day Before Yesterday';
    final parts = key.split('-');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${int.parse(parts[2])} ${months[int.parse(parts[1]) - 1]}';
  }

  double _calculateBmi() {
    final h = (widget.userData['heightCm'] as num).toDouble() / 100.0;
    final w = (widget.userData['currW'] as num).toDouble();
    return h <= 0 ? 0.0 : w / (h * h);
  }

  String _bmiCategory(double bmi) => bmi < 18.5
      ? 'Underweight'
      : bmi < 25.0
      ? 'Normal'
      : bmi < 30.0
      ? 'Overweight'
      : 'Obese';

  Map<String, int> _estimateMacros(String food) {
    final low = food.toLowerCase();
    if (low.contains('biryani') || low.contains('fried'))
      return {'kcal': 650, 'protein': 24, 'fat': 26, 'carbs': 78};
    if (low.contains('idli'))
      return {'kcal': 240, 'protein': 8, 'fat': 3, 'carbs': 46};
    if (low.contains('paneer') || low.contains('chicken'))
      return {'kcal': 520, 'protein': 34, 'fat': 20, 'carbs': 48};
    if (low.contains('roti') || low.contains('dal'))
      return {'kcal': 420, 'protein': 16, 'fat': 10, 'carbs': 64};
    if (low.contains('salad') || low.contains('fruit') || low.contains('oats'))
      return {'kcal': 210, 'protein': 7, 'fat': 4, 'carbs': 36};
    return {'kcal': 380, 'protein': 14, 'fat': 12, 'carbs': 52};
  }

  void _pickPhoto() {
    final samples = [
      'Biryani / Fried Rice (~650 kcal)',
      '3 Idlis & Sambar (~240 kcal)',
      '2 Rotis, Dal, Sabzi & Salad (~420 kcal)',
      'Paneer / Chicken Bowl & Rice (~520 kcal)',
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select Food Photo (AI Macro Scan)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...samples.map(
            (s) => ListTile(
              leading: const Icon(Icons.image, color: Colors.teal),
              title: Text(s),
              onTap: () {
                setState(() {
                  _photo = s;
                  _foodCtrl.text = s;
                });
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _analyze() {
    final f = _foodCtrl.text.trim();
    if (f.isEmpty) return;
    final macros = _estimateMacros(f);
    final bmi = _calculateBmi();
    final currW = (widget.userData['currW'] as num).toDouble();
    final targW = (widget.userData['targW'] as num).toDouble();
    final goal = widget.userData['goal'] as String;

    String st = 'BALANCED INTAKE ✅';
    String tp = 'Fits your BMI (${bmi.toStringAsFixed(1)}) and $goal target.';
    if ((bmi >= 25.0 || goal == 'Weight Loss' || currW > targW) &&
        macros['kcal']! > 550) {
      st = 'HIGH CALORIE / FAT — REDUCE PORTION 🔻';
      tp =
          'At BMI ${bmi.toStringAsFixed(1)}, keep meals under 500 kcal. Reduce rice/oil by 30% & add salad.';
    } else if (macros['protein']! < 12) {
      st = 'LOW PROTEIN — ADD PROTEIN BOOST ⚖️';
      tp =
          'Only ${macros['protein']}g protein. Pair with curd, sprouts, paneer, dal, or egg whites.';
    }

    setState(() {
      _identified = f;
      _estKcal = macros['kcal']!;
      _estProtein = macros['protein']!;
      _estFat = macros['fat']!;
      _estCarbs = macros['carbs']!;
      _status = st;
      _tip = tp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBmi();
    final currW = (widget.userData['currW'] as num).toDouble();
    final targW = (widget.userData['targW'] as num).toDouble();
    final startW = (widget.userData['startW'] as num).toDouble();

    final now = DateTime.now();
    final baseDates = [
      _dateKey(now.subtract(const Duration(days: 2))),
      _dateKey(now.subtract(const Duration(days: 1))),
      _dateKey(now),
    ];
    for (final m in widget.mealLogs) {
      if (!baseDates.contains(m['dateKey'])) baseDates.insert(0, m['dateKey']);
    }

    final dayMeals = widget.mealLogs
        .where((m) => m['dateKey'] == _selectedDateKey)
        .toList();
    int totalKcal = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;
    for (final m in dayMeals) {
      totalKcal += (m['kcal'] as num).toInt();
      totalProtein += (m['protein'] as num).toInt();
      totalFat += (m['fat'] as num).toInt();
      totalCarbs += (m['carbs'] as num).toInt();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Meal AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: widget.onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${widget.userData['name']}! 👋',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '+91 ${widget.userData['mobile']} • ${widget.userData['goal']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    backgroundColor: Colors.teal.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    label: Text(
                      'BMI ${bmi.toStringAsFixed(1)} (${_bmiCategory(bmi)})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Daily Intake History (Calories, Protein & Fat)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: baseDates.map((dKey) {
                  final selected = dKey == _selectedDateKey;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_friendlyDate(dKey)),
                      selected: selected,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedDateKey = dKey),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_friendlyDate(_selectedDateKey)} Total Nutrition',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroTile(
                        'Calories',
                        '$totalKcal kcal',
                        Colors.deepOrange,
                      ),
                      _macroTile('Protein', '${totalProtein}g', Colors.teal),
                      _macroTile('Fat', '${totalFat}g', Colors.amber.shade900),
                      _macroTile(
                        'Carbs',
                        '${totalCarbs}g',
                        Colors.blue.shade800,
                      ),
                    ],
                  ),
                  if (dayMeals.isNotEmpty) ...[
                    const Divider(height: 18),
                    ...dayMeals.map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${m['name']} — ${m['kcal']} kcal | P: ${m['protein']}g | F: ${m['fat']}g',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'No meals logged for this date yet.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 28),
            const Text(
              'Check & Log Meal',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _foodCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter meal (e.g., 2 Rotis, Dal, Biryani)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _photo ?? 'Sample Photo',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_status != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_identified ($_estKcal kcal • P: ${_estProtein}g • F: ${_estFat}g • C: ${_estCarbs}g)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _status!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    Text(_tip!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onAddMeal({
                          'dateKey': _selectedDateKey,
                          'name': _identified!,
                          'kcal': _estKcal,
                          'protein': _estProtein,
                          'fat': _estFat,
                          'carbs': _estCarbs,
                        });
                        setState(() {
                          _status = null;
                          _foodCtrl.clear();
                          _photo = null;
                        });
                      },
                      icon: const Icon(Icons.add_task),
                      label: Text(
                        'Save Meal to ${_friendlyDate(_selectedDateKey)}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 28),
            const Text(
              'Daily Weight Monitor',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start: $startW kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Current: $currW kg',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Target: $targW kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _wCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Log today weight (kg)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final v = double.tryParse(_wCtrl.text);
                          if (v != null && v > 20 && v < 300) {
                            widget.onLogW(v);
                            _wCtrl.clear();
                          }
                        },
                        child: const Text('Log'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.weightLogs
                        .map(
                          (e) => Chip(
                            label: Text(
                              '${_friendlyDate(e['dateKey'])}: ${e['w']} kg',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroTile(String label, String val, Color col) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: col,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final void Function(Map<String, dynamic>) onSave;
  final VoidCallback onLogout;
  const ProfileTab({
    super.key,
    required this.userData,
    required this.onSave,
    required this.onLogout,
  });
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final _n = TextEditingController(text: widget.userData['name']),
      _a = TextEditingController(text: widget.userData['age']),
      _h = TextEditingController(text: '${widget.userData['heightCm']}'),
      _cw = TextEditingController(text: '${widget.userData['currW']}'),
      _tw = TextEditingController(text: '${widget.userData['targW']}');
  late String _g = widget.userData['goal'], _d = widget.userData['diet'];

  @override
  Widget build(BuildContext context) {
    final h =
        (double.tryParse(_h.text) ??
            (widget.userData['heightCm'] as num).toDouble()) /
        100.0;
    final w =
        double.tryParse(_cw.text) ??
        (widget.userData['currW'] as num).toDouble();
    final bmi = h > 0 ? w / (h * h) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registered Mobile: +91 ${widget.userData['mobile']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'BMI: ${bmi.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _n,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _a,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _h,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cw,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Current Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _tw,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _g,
              decoration: const InputDecoration(
                labelText: 'Health Goal',
                border: OutlineInputBorder(),
              ),
              items: [
                'Weight Loss',
                'Muscle Gain',
                'Maintain Weight',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _g = v ?? _g),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _d,
              decoration: const InputDecoration(
                labelText: 'Diet Preference',
                border: OutlineInputBorder(),
              ),
              items: [
                'Balanced',
                'Vegetarian',
                'High Protein',
                'Keto',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _d = v ?? _d),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                final updated = Map<String, dynamic>.from(widget.userData);
                updated['name'] = _n.text.trim().isEmpty
                    ? 'Friend'
                    : _n.text.trim();
                updated['age'] = _a.text.trim();
                updated['heightCm'] =
                    double.tryParse(_h.text) ?? widget.userData['heightCm'];
                updated['currW'] =
                    double.tryParse(_cw.text) ?? widget.userData['currW'];
                updated['targW'] =
                    double.tryParse(_tw.text) ?? widget.userData['targW'];
                updated['goal'] = _g;
                updated['diet'] = _d;
                widget.onSave(updated);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save & Return to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
