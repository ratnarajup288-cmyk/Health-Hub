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
              'Upload meals for BMI-based AI intake guidance and monitor daily weight to achieve your target.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistrationPage()),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade900,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
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

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _heightCtrl = TextEditingController(text: '165');
  final _weightCtrl = TextEditingController(text: '72');
  bool _acceptedTerms = false;
  String? _errorMsg;

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Health Disclaimer: Smart Health & Meal AI provides general BMI and dietary portion guidance for educational purposes only and is not a substitute for professional medical advice.\n\n'
            '2. Privacy & Data: Your mobile number, height, weight, and meal logs are stored locally during your session to personalize your BMI recommendations.\n\n'
            '3. User Responsibility: Please consult a qualified doctor or nutritionist before making major dietary changes.',
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

  void _submit() {
    final name = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());

    if (name.isEmpty) {
      setState(() => _errorMsg = 'Please enter your full name.');
      return;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      setState(
        () => _errorMsg = 'Please enter a valid 10-digit mobile number.',
      );
      return;
    }
    if (h == null || h < 50 || h > 260 || w == null || w < 20 || w > 300) {
      setState(
        () => _errorMsg = 'Please enter valid height (cm) and weight (kg).',
      );
      return;
    }
    if (!_acceptedTerms) {
      setState(
        () => _errorMsg = 'Please accept the Terms & Conditions to continue.',
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(
          initialName: name,
          initialMobile: mobile,
          initialHeight: h,
          initialWeight: w,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_alt_1, size: 54, color: Colors.teal),
            const SizedBox(height: 8),
            const Text(
              'Register to Start Your BMI Journey',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
                counterText: '',
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
            const SizedBox(height: 14),
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
                      const Text('I agree to the '),
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
            if (_errorMsg != null) ...[
              const SizedBox(height: 8),
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle),
              label: const Text('Accept & Continue to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String initialName, initialMobile;
  final double initialHeight, initialWeight;
  const MainScreen({
    super.key,
    this.initialName = 'Ratna',
    this.initialMobile = '9876543210',
    this.initialHeight = 165.0,
    this.initialWeight = 72.0,
  });
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;
  late String _name = widget.initialName,
      _mobile = widget.initialMobile,
      _age = '28',
      _goal = 'Weight Loss',
      _diet = 'Balanced';
  late double _heightCm = widget.initialHeight,
      _startW = widget.initialWeight,
      _currW = widget.initialWeight,
      _targW = 65.0;

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]}';
  }

  late final List<Map<String, dynamic>> _logs = [
    {
      'date': _formatDate(DateTime.now().subtract(const Duration(days: 1))),
      'w': _currW + 0.5,
    },
    {'date': _formatDate(DateTime.now()), 'w': _currW},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tab == 0
          ? HomeTab(
              name: _name,
              heightCm: _heightCm,
              startW: _startW,
              currW: _currW,
              targW: _targW,
              goal: _goal,
              diet: _diet,
              logs: _logs,
              onLogW: (w) => setState(() {
                final todayStr = _formatDate(DateTime.now());
                _currW = w;
                final idx = _logs.indexWhere((e) => e['date'] == todayStr);
                if (idx != -1) {
                  _logs[idx]['w'] = w;
                } else {
                  _logs.add({'date': todayStr, 'w': w});
                }
              }),
              onEdit: () => setState(() => _tab = 1),
            )
          : ProfileTab(
              name: _name,
              mobile: _mobile,
              age: _age,
              heightCm: _heightCm,
              currW: _currW,
              targW: _targW,
              goal: _goal,
              diet: _diet,
              onSave: (n, m, a, h, cw, tw, g, d) => setState(() {
                _name = n.isEmpty ? 'Friend' : n;
                _mobile = m;
                _age = a;
                _heightCm = h;
                _startW = cw;
                _currW = cw;
                _targW = tw;
                _goal = g;
                _diet = d;
                _tab = 0;
              }),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
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
  final String name, goal, diet;
  final double heightCm, startW, currW, targW;
  final List<Map<String, dynamic>> logs;
  final Function(double) onLogW;
  final VoidCallback onEdit;
  const HomeTab({
    super.key,
    required this.name,
    required this.heightCm,
    required this.startW,
    required this.currW,
    required this.targW,
    required this.goal,
    required this.diet,
    required this.logs,
    required this.onLogW,
    required this.onEdit,
  });
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _foodCtrl = TextEditingController(), _wCtrl = TextEditingController();
  String? _photo, _identified, _status, _tip;

  double _calculateBmi() {
    final hMeters = widget.heightCm / 100.0;
    return hMeters <= 0 ? 0.0 : widget.currW / (hMeters * hMeters);
  }

  String _bmiCategory(double bmi) => bmi < 18.5
      ? 'Underweight'
      : bmi < 25.0
      ? 'Normal Weight'
      : bmi < 30.0
      ? 'Overweight'
      : 'Obese';
  Color _bmiColor(double bmi) => bmi < 18.5
      ? Colors.blue.shade700
      : bmi < 25.0
      ? Colors.green.shade700
      : bmi < 30.0
      ? Colors.orange.shade800
      : Colors.red.shade700;

  String _idealWeightRange() {
    final hMeters = widget.heightCm / 100.0;
    return '${(18.5 * hMeters * hMeters).toStringAsFixed(1)} – ${(24.9 * hMeters * hMeters).toStringAsFixed(1)} kg';
  }

  void _pickPhoto() {
    final samples = [
      'Biryani / Fried Rice (~650 kcal)',
      '3 Idlis & Sambar (~240 kcal)',
      '2 Rotis, Dal, Sabzi & Salad (~420 kcal)',
      'Paneer / Chicken Bowl & Brown Rice (~520 kcal)',
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select Food Photo (AI Test)',
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
    final bmi = _calculateBmi(),
        bmiCat = _bmiCategory(bmi),
        diff = widget.currW - widget.targW,
        low = f.toLowerCase();
    final heavy =
        low.contains('biryani') ||
        low.contains('fried') ||
        low.contains('burger') ||
        low.contains('pizza') ||
        low.contains('sweet');
    final light =
        low.contains('idli') ||
        low.contains('salad') ||
        low.contains('fruit') ||
        low.contains('oats');

    String
    st = 'MAINTAIN PORTION ✅',
    tp =
        'BMI ${bmi.toStringAsFixed(1)} ($bmiCat). Fits your ${widget.diet} plan and ${widget.targW} kg target.';
    if (bmi >= 25.0 || widget.goal == 'Weight Loss' || diff > 0.5) {
      if (heavy) {
        st = 'DECREASE INTAKE 🔻';
        tp =
            'BMI is ${bmi.toStringAsFixed(1)} ($bmiCat) and you are ${diff.abs().toStringAsFixed(1)} kg from ${widget.targW} kg. Cut portion by 30% & add salad.';
      } else if (light) {
        st = 'GOOD / ADD LEAN PROTEIN ✅';
        tp =
            'Great low-calorie choice for BMI ${bmi.toStringAsFixed(1)} ($bmiCat). Safe to pair with curd, sprouts, egg whites, or dal.';
      } else {
        st = 'DECREASE CARBS SLIGHTLY ⚖️';
        tp =
            'At BMI ${bmi.toStringAsFixed(1)} ($bmiCat), reduce rice/roti by 1 portion and keep protein steady (${widget.diet}).';
      }
    } else if (bmi < 18.5 || widget.goal == 'Muscle Gain' || diff < -0.5) {
      st = 'INCREASE INTAKE 🔺';
      tp =
          'BMI is ${bmi.toStringAsFixed(1)} ($bmiCat). Increase healthy carbs & protein by 20% (${widget.diet}) to reach ${widget.targW} kg.';
    }
    setState(() {
      _identified = f;
      _status = st;
      _tip = tp;
    });
  }

  double _calculateProgress() {
    final totalDiff = (widget.startW - widget.targW).abs();
    if (totalDiff < 0.1) return 1.0;
    final achieved = (widget.startW - widget.currW).abs();
    if (widget.startW > widget.targW && widget.currW > widget.startW)
      return 0.0;
    if (widget.startW < widget.targW && widget.currW < widget.startW)
      return 0.0;
    return (achieved / totalDiff).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final rem = widget.currW - widget.targW,
        progress = _calculateProgress(),
        percent = (progress * 100).toStringAsFixed(0);
    final bmi = _calculateBmi(),
        bmiCat = _bmiCategory(bmi),
        bmiCol = _bmiColor(bmi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Meal AI'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: widget.onEdit),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Welcome, ${widget.name}! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: bmiCol.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: bmiCol),
                        ),
                        child: Text(
                          'BMI ${bmi.toStringAsFixed(1)} • $bmiCat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: bmiCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Height: ${widget.heightCm.toStringAsFixed(0)} cm • Healthy Range: ${_idealWeightRange()}',
                    style: TextStyle(fontSize: 13, color: Colors.teal.shade900),
                  ),
                  Text(
                    'Goal: ${widget.goal} (${widget.diet}) • Target: ${widget.targW} kg',
                    style: TextStyle(fontSize: 13, color: Colors.teal.shade800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Food Going to Eat',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _foodCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter meal or upload photo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_photo ?? 'Upload Food Image'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _analyze,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI Identify & Check BMI Intake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _status!.contains('DECREASE')
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Identified: $_identified',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _status!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_tip!),
                  ],
                ),
              ),
            ],
            const Divider(height: 28),
            const Text(
              'Daily Weight & Target Monitor',
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
                        'Start: ${widget.startW} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Current: ${widget.currW} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Target: ${widget.targW} kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.teal.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.teal.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rem.abs() <= 0.2
                            ? '🎉 Target Achieved!'
                            : rem > 0
                            ? '📉 ${rem.toStringAsFixed(1)} kg to lose'
                            : '📈 ${rem.abs().toStringAsFixed(1)} kg to gain',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$percent% Done',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
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
                    children: widget.logs
                        .map(
                          (e) =>
                              Chip(label: Text('${e['date']}: ${e['w']} kg')),
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
}

class ProfileTab extends StatefulWidget {
  final String name, mobile, age, goal, diet;
  final double heightCm, currW, targW;
  final Function(String, String, String, double, double, double, String, String)
  onSave;
  const ProfileTab({
    super.key,
    required this.name,
    required this.mobile,
    required this.age,
    required this.heightCm,
    required this.currW,
    required this.targW,
    required this.goal,
    required this.diet,
    required this.onSave,
  });
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final _n = TextEditingController(text: widget.name),
      _m = TextEditingController(text: widget.mobile),
      _a = TextEditingController(text: widget.age),
      _h = TextEditingController(text: '${widget.heightCm}'),
      _cw = TextEditingController(text: '${widget.currW}'),
      _tw = TextEditingController(text: '${widget.targW}');
  late String _g = widget.goal, _d = widget.diet;

  double _previewBmi() {
    final h = (double.tryParse(_h.text) ?? widget.heightCm) / 100.0;
    final w = double.tryParse(_cw.text) ?? widget.currW;
    return h <= 0 ? 0.0 : w / (h * h);
  }

  @override
  Widget build(BuildContext context) {
    final liveBmi = _previewBmi();
    final liveCat = liveBmi < 18.5
        ? 'Underweight'
        : liveBmi < 25.0
        ? 'Normal Weight'
        : liveBmi < 30.0
        ? 'Overweight'
        : 'Obese';

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Details')),
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
                  const Text(
                    'Calculated BMI:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${liveBmi.toStringAsFixed(1)} ($liveCat)',
                    style: TextStyle(
                      fontSize: 16,
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
            TextField(
              controller: _m,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
                counterText: '',
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
                final hVal = double.tryParse(_h.text);
                final cwVal = double.tryParse(_cw.text);
                final twVal = double.tryParse(_tw.text);
                widget.onSave(
                  _n.text.trim(),
                  _m.text.trim(),
                  _a.text.trim(),
                  (hVal != null && hVal > 50 && hVal < 260)
                      ? hVal
                      : widget.heightCm,
                  (cwVal != null && cwVal > 20 && cwVal < 300)
                      ? cwVal
                      : widget.currW,
                  (twVal != null && twVal > 20 && twVal < 300)
                      ? twVal
                      : widget.targW,
                  _g,
                  _d,
                );
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
