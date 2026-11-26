import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Health & Meal AI',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const SplashRouter(),
    );
  }
}

class UserStorage {
  static Future<String?> getActiveMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_mobile');
  }

  static Future<void> setActiveMobile(String? mobile) async {
    final prefs = await SharedPreferences.getInstance();
    if (mobile == null) {
      await prefs.remove('active_mobile');
    } else {
      await prefs.setString('active_mobile', mobile);
    }
  }

  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key') ?? '';
  }

  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key.trim());
  }

  static Future<Map<String, dynamic>?> loadUser(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_$mobile');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveUser(String mobile, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_$mobile', jsonEncode(data));
    await prefs.setString('active_mobile', mobile);
  }
}

class GeminiService {
  static Future<Map<String, dynamic>?> analyzeMeal({
    required String apiKey,
    required String foodText,
    File? imageFile,
    required double bmi,
    required String goal,
    required String diet,
  }) async {
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('https://googleapis.com');

    final parts = <Map<String, dynamic>>[];
    if (imageFile != null && await imageFile.exists()) {
      final bytes = await imageFile.readAsBytes();
      parts.add({
        'inlineData': {'mimeType': 'image/jpeg', 'data': base64Encode(bytes)}
      });
    }

    final prompt = 'Identify this food/meal accurately (if an image is provided, identify the exact food items on the plate; user note: "$foodText"). '
        'Estimate realistic nutrition for the visible portion. User BMI is ${bmi.toStringAsFixed(1)}, goal is "$goal", diet is "$diet". '
        'Respond ONLY with raw valid JSON (no markdown) using exact keys: '
        '{"name":"Dish Name & Portion","kcal":450,"protein":18,"fat":14,"carbs":60,"status":"GOOD / MODERATE / REDUCE PORTION","tip":"1 short personalized sentence based on BMI and goal"}';
    parts.add({'text': prompt});

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': parts}],
          'generationConfig': {'responseMimeType': 'application/json'}
        }),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        String text = decoded['candidates'][0]['content']['parts'][0]['text'];
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(text) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, String>?> generateDailyTip({
    required String apiKey,
    required double bmi,
    required String goal,
    required String diet,
    required double currW,
    required double targW,
    required int todayKcal,
    required int todayProtein,
  }) async {
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('https://googleapis.com');
    final prompt = 'You are an expert nutrition coach. Give 1 fresh, practical daily health/diet tip for a user with BMI ${bmi.toStringAsFixed(1)}, '
        'current weight $currW kg, target weight $targW kg, goal "$goal", diet "$diet", who has eaten $todayKcal kcal and ${todayProtein}g protein today. '
        'Random seed: ${DateTime.now().millisecondsSinceEpoch}. '
        'Respond ONLY with raw valid JSON: {"title":"Short Catchy Title with 1 Emoji","body":"2 short practical sentences."}';

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'responseMimeType': 'application/json'}
        }),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        String text = decoded['candidates'][0]['content']['parts'][0]['text'];
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final map = jsonDecode(text) as Map<String, dynamic>;
        return {'title': '${map['title']}', 'body': '${map['body']}'};
      }
    } catch (_) {}
    return null;
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});
  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final mobile = await UserStorage.getActiveMobile();
    if (!mounted) return;
    if (mobile != null) {
      final data = await UserStorage.loadUser(mobile);
      if (data != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(userData: data)));
        return;
      }
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LandingPage()));
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade800, Colors.teal.shade400], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.health_and_safety, size: 90, color: Colors.white),
          const SizedBox(height: 20),
          const Text('Smart Health & Meal AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Snap real meal photos for live Gemini Vision macro analysis, track daily nutrition, and get real AI health coaching.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white70)),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage())),
            icon: const Icon(Icons.arrow_forward), label: const Text('Login / Register with Mobile'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal.shade900, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
          ),
        ]),
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
  final _mobileCtrl = TextEditingController(), _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController(text: '165'), _weightCtrl = TextEditingController(text: '72');
  bool _isNewUser = false, _checkedMobile = false, _acceptedTerms = false;
  String? _errorMsg;

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _lookupMobile() async {
    final mobile = _mobileCtrl.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) { setState(() => _errorMsg = 'Enter a valid 10-digit Indian mobile number.'); return; }
    final existing = await UserStorage.loadUser(mobile);
    if (existing != null) {
      await UserStorage.setActiveMobile(mobile);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainScreen(userData: existing)), (_) => false);
    } else {
      setState(() { _checkedMobile = true; _isNewUser = true; _errorMsg = null; });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Health Disclaimer: Smart Health & Meal AI provides general BMI and AI nutrition estimates for educational purposes and is not medical advice.\n\n'
            '2. Saved Data: Your profile, weight logs, and daily calorie/protein/fat history are saved permanently on your phone under your mobile number.\n\n'
            '3. AI Vision Privacy: Meal photos are sent only to Google Gemini when you tap AI Check.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(onPressed: () { setState(() { _acceptedTerms = true; _errorMsg = null; }); Navigator.pop(ctx); }, child: const Text('I Accept')),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final mobile = _mobileCtrl.text.trim(), name = _nameCtrl.text.trim();
    final h = double.tryParse(_heightCtrl.text.trim()), w = double.tryParse(_weightCtrl.text.trim());
    if (name.isEmpty) { setState(() => _errorMsg = 'Please enter your full name.'); return; }
    if (h == null || h < 50 || h > 260 || w == null || w < 20 || w > 300) { setState(() => _errorMsg = 'Enter valid height (cm) and weight (kg).'); return; }
    if (!_acceptedTerms) { setState(() => _errorMsg = 'Please accept the Terms & Conditions.'); return; }

    final todayKey = _dateKey(DateTime.now());
    final newUserData = <String, dynamic>{
      'name': name, 'mobile': mobile, 'age': '28', 'heightCm': h, 'startW': w, 'currW': w,
      'targW': (w - 5).clamp(40.0, 200.0), 'goal': 'Weight Loss', 'diet': 'Balanced',
      'weightLogs': [{'dateKey': todayKey, 'w': w}], 'mealLogs': [],
    };
    await UserStorage.saveUser(mobile, newUserData);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainScreen(userData: newUserData)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isNewUser ? 'Complete Registration' : 'Mobile Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Icon(_isNewUser ? Icons.person_add_alt_1 : Icons.phone_android, size: 54, color: Colors.teal),
          const SizedBox(height: 10),
          Text(_isNewUser ? 'New Number — Create Your Profile' : 'Enter Mobile Number to Login or Register', textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _mobileCtrl, enabled: !_checkedMobile, keyboardType: TextInputType.phone, maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Mobile Number', prefixText: '+91 ', prefixIcon: const Icon(Icons.phone), border: const OutlineInputBorder(), counterText: '',
              suffixIcon: _checkedMobile ? IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() { _checkedMobile = false; _isNewUser = false; })) : null,
            ),
          ),
          if (!_checkedMobile) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _lookupMobile, icon: const Icon(Icons.login), label: const Text('Continue with Mobile Number'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14))),
          ],
          if (_isNewUser) ...[
            const SizedBox(height: 14),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: TextField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Checkbox(value: _acceptedTerms, activeColor: Colors.teal, onChanged: (v) => setState(() { _acceptedTerms = v ?? false; _errorMsg = null; })),
              Expanded(child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                const Text('I accept the '),
                GestureDetector(onTap: _showTermsDialog, child: const Text('Terms & Conditions', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
              ])),
            ]),
            const SizedBox(height: 14),
            ElevatedButton.icon(onPressed: _register, icon: const Icon(Icons.check_circle), label: const Text('Register & Open Home'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14))),
          ],
          if (_errorMsg != null) ...[
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade300)), child: Text(_errorMsg!, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w600))),
          ],
        ]),
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
  String _dateKey(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  Future<void> _persist() async => await UserStorage.saveUser(_data['mobile'], _data);
  Future<void> _logout() async {
    await UserStorage.setActiveMobile(null);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final weightLogs = List<Map<String, dynamic>>.from((_data['weightLogs'] as List).map((e) => Map<String, dynamic>.from(e)));
    final mealLogs = List<Map<String, dynamic>>.from((_data['mealLogs'] as List).map((e) => Map<String, dynamic>.from(e)));
    return Scaffold(
      body: _tab == 0
          ? HomeTab(
              userData: _data, weightLogs: weightLogs, mealLogs: mealLogs,
              onAddMeal: (meal) async { setState(() { mealLogs.add(meal); _data['mealLogs'] = mealLogs; }); await _persist(); },
              onLogW: (w) async {
                final todayKey = _dateKey(DateTime.now());
                setState(() {
                  _data['currW'] = w;
                  final idx = weightLogs.indexWhere((e) => e['dateKey'] == todayKey);
                  if (idx != -1) { weightLogs[idx]['w'] = w; } else { weightLogs.add({'dateKey': todayKey, 'w': w}); }
                  _data['weightLogs'] = weightLogs;
                });
                await _persist();
              },
              onEdit: () => setState(() => _tab = 1),
              onLogout: _logout,
            )
          : ProfileTab(userData: _data, onSave: (updated) async { setState(() { _data = updated; _tab = 0; }); await _persist(); }, onLogout: _logout),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab, onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home & Daily Log'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Personal Details'),
        ],
      ),
    );
  }
}
class HomeTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> weightLogs, mealLogs;
  final Future<void> Function(Map<String, dynamic>) onAddMeal;
  final Future<void> Function(double) onLogW;
  final VoidCallback onEdit, onLogout;
  const HomeTab({super.key, required this.userData, required this.weightLogs, required this.mealLogs, required this.onAddMeal, required this.onLogW, required this.onEdit, required this.onLogout});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _foodCtrl = TextEditingController(), _wCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late String _selectedDateKey = _dateKey(DateTime.now());
  File? _selectedImage;
  String? _identified, _status, _tip;
  int _estKcal = 0, _estProtein = 0, _estFat = 0, _estCarbs = 0;
  bool _analyzing = false, _loadingTip = false;
  String _apiKey = '';
  Map<String, String> _aiTip = {'title': 'Loading AI Health Tip... ✨', 'body': 'Add your free Gemini API Key in Personal Details for live AI photo recognition & daily tips.'};

  @override
  void initState() {
    super.initState();
    _initAi();
  }

  Future<void> _initAi() async {
    _apiKey = await UserStorage.getApiKey();
    await _refreshAiTip();
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _friendlyDate(String key) {
    final now = DateTime.now();
    if (key == _dateKey(now)) return 'Today';
    if (key == _dateKey(now.subtract(const Duration(days: 1)))) return 'Yesterday';
    if (key == _dateKey(now.subtract(const Duration(days: 2)))) return 'Day Before Yesterday';
    final parts = key.split('-');
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${int.parse(parts)} ${months[int.parse(parts) - 1]}';
  }

  double _calculateBmi() {
    final h = (widget.userData['heightCm'] as num).toDouble() / 100.0;
    final w = (widget.userData['currW'] as num).toDouble();
    return h <= 0 ? 0.0 : w / (h * h);
  }

  String _bmiCategory(double bmi) => bmi < 18.5 ? 'Underweight' : bmi < 25.0 ? 'Normal' : bmi < 30.0 ? 'Overweight' : 'Obese';

  Future<void> _refreshAiTip() async {
    setState(() => _loadingTip = true);
    _apiKey = await UserStorage.getApiKey();
    final bmi = _calculateBmi();
    final todayKey = _dateKey(DateTime.now());
    int todayKcal = 0, todayProtein = 0;
    for (final m in widget.mealLogs.where((m) => m['dateKey'] == todayKey)) {
      todayKcal += (m['kcal'] as num).toInt();
      todayProtein += (m['protein'] as num).toInt();
    }

    final liveTip = await GeminiService.generateDailyTip(
      apiKey: _apiKey, bmi: bmi, goal: widget.userData['goal'], diet: widget.userData['diet'],
      currW: (widget.userData['currW'] as num).toDouble(), targW: (widget.userData['targW'] as num).toDouble(),
      todayKcal: todayKcal, todayProtein: todayProtein,
    );

    if (!mounted) return;
    setState(() {
      _loadingTip = false;
      if (liveTip != null) {
        _aiTip = liveTip;
      } else if (_apiKey.isEmpty) {
        _aiTip = {
          'title': 'Connect Live Gemini AI 🔑',
          'body': 'Tap the Profile icon (top right) and paste your free Gemini API Key to enable real photo scanning & live AI coaching tips.'
        };
      } else {
        _aiTip = {
          'title': 'Balanced Plate Reminder 🥗',
          'body': 'Fill half your plate with fiber-rich vegetables, a quarter with ${widget.userData['diet']} protein, and stay hydrated.'
        };
      }
    });
  }

  Future<void> _pickImageSource() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.teal), title: const Text('Take Photo with Camera'),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
              if (picked != null) setState(() => _selectedImage = File(picked.path));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.teal), title: const Text('Choose Photo from Gallery'),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
              if (picked != null) setState(() => _selectedImage = File(picked.path));
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _analyze() async {
    final text = _foodCtrl.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    _apiKey = await UserStorage.getApiKey();

    if (_apiKey.isEmpty) {
      setState(() {
        _identified = text.isEmpty ? 'Photo Selected' : text;
        _estKcal = 0; _estProtein = 0; _estFat = 0; _estCarbs = 0;
        _status = 'GEMINI API KEY REQUIRED 🔑';
        _tip = 'Go to Personal Details (top right icon) and save your free Gemini API key from ://google.com to scan real food images.';
      });
      return;
    }

    setState(() { _analyzing = true; _status = null; });
    final bmi = _calculateBmi();
    final res = await GeminiService.analyzeMeal(
      apiKey: _apiKey, foodText: text, imageFile: _selectedImage,
      bmi: bmi, goal: widget.userData['goal'], diet: widget.userData['diet'],
    );

    if (!mounted) return;
    setState(() {
      _analyzing = false;
      if (res != null) {
        _identified = '${res['name'] ?? text}';
        _estKcal = (res['kcal'] as num?)?.toInt() ?? 350;
        _estProtein = (res['protein'] as num?)?.toInt() ?? 15;
        _estFat = (res['fat'] as num?)?.toInt() ?? 10;
        _estCarbs = (res['carbs'] as num?)?.toInt() ?? 45;
        _status = '${res['status'] ?? 'AI ANALYZED ✅'}';
        _tip = '${res['tip'] ?? ''}';
      } else {
        _identified = text.isEmpty ? 'Meal Photo' : text;
        _status = 'AI CONNECTION FAILED ⚠️';
        _tip = 'Check your internet connection or verify your Gemini API key in Personal Details.';
      }
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

    final dayMeals = widget.mealLogs.where((m) => m['dateKey'] == _selectedDateKey).toList();
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
          IconButton(icon: const Icon(Icons.person), tooltip: 'Profile & AI Key', onPressed: widget.onEdit),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: widget.onLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hi, ${widget.userData['name']}! 👋', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text('+91 ${widget.userData['mobile']} • ${widget.userData['goal']}', style: TextStyle(fontSize: 12, color: Colors.teal.shade800), overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                Chip(backgroundColor: Colors.teal.shade700, padding: const EdgeInsets.symmetric(horizontal: 4), label: Text('BMI ${bmi.toStringAsFixed(1)} (${_bmiCategory(bmi)})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('Daily Intake History (Calories, Protein & Fat)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: baseDates.map((dKey) {
                final selected = dKey == _selectedDateKey;
                return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(_friendlyDate(dKey)), selected: selected, selectedColor: Colors.teal, labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold), onSelected: (_) => setState(() => _selectedDateKey = dKey)));
              }).toList()),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigo.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_friendlyDate(_selectedDateKey)} Total Nutrition', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _macroTile('Calories', '$totalKcal kcal', Colors.deepOrange),
                  _macroTile('Protein', '${totalProtein}g', Colors.teal),
                  _macroTile('Fat', '${totalFat}g', Colors.amber.shade900),
                  _macroTile('Carbs', '${totalCarbs}g', Colors.blue.shade800),
                ]),
                if (dayMeals.isNotEmpty) ...[
                  const Divider(height: 18),
                  ...dayMeals.map((m) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• ${m['name']} — ${m['kcal']} kcal | P: ${m['protein']}g | F: ${m['fat']}g', style: const TextStyle(fontSize: 12)))),
                ] else
                  const Padding(padding: EdgeInsets.only(top: 8), child: Text('No meals logged for this date yet.', style: TextStyle(fontSize: 12, color: Colors.grey))),
              ]),
            ),
            const Divider(height: 28),
            const Text('Snap or Upload Meal for Gemini Vision AI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_selectedImage != null) ...[
              Stack(alignment: Alignment.topRight, children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, height: 170, width: double.infinity, fit: BoxFit.cover)),
                IconButton(icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)), onPressed: () => setState(() => _selectedImage = null)),
              ]),
              const SizedBox(height: 8),
            ],
            TextField(controller: _foodCtrl, decoration: const InputDecoration(labelText: 'Optional note (or just upload food photo)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _pickImageSource, icon: const Icon(Icons.camera_alt), label: const Text('Camera / Gallery'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(onPressed: _analyzing ? null : _analyze, icon: const Icon(Icons.auto_awesome), label: Text(_analyzing ? 'Scanning...' : 'AI Check'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white))),
            ]),
            if (_analyzing) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator()),
            if (_status != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.teal)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$_identified ($_estKcal kcal • P: ${_estProtein}g • F: ${_estFat}g • C: ${_estCarbs}g)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_status!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  Text(_tip!, style: const TextStyle(fontSize: 13)),
                  if (_estKcal > 0) ...[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await widget.onAddMeal({'dateKey': _selectedDateKey, 'name': _identified!, 'kcal': _estKcal, 'protein': _estProtein, 'fat': _estFat, 'carbs': _estCarbs});
                        setState(() { _status = null; _foodCtrl.clear(); _selectedImage = null; });
                        await _refreshAiTip();
                      },
                      icon: const Icon(Icons.add_task),
                      label: Text('Save Meal to ${_friendlyDate(_selectedDateKey)}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                    ),
                  ],
                ]),
              ),
            ],
            const Divider(height: 28),
            const Text('Daily Weight Monitor', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Start: $startW kg', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Current: $currW kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Target: $targW kg', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: _wCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Log today weight (kg)', isDense: true, border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () async { final v = double.tryParse(_wCtrl.text); if (v != null && v > 20 && v < 300) { await widget.onLogW(v); _wCtrl.clear(); } }, child: const Text('Log')),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: widget.weightLogs.map((e) => Chip(label: Text('${_friendlyDate(e['dateKey'])}: ${e['w']} kg'))).toList()),
              ]),
            ),
            const Divider(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Live Gemini AI Coach Tip ✨', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _loadingTip ? null : _refreshAiTip, icon: const Icon(Icons.refresh, size: 18), label: Text(_loadingTip ? 'Thinking...' : 'New AI Tip')),
            ]),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade50, Colors.cyan.shade50]), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade300)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.psychology, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_aiTip['title']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal.shade900))),
                ]),
                const SizedBox(height: 6),
                Text(_aiTip['body']!, style: const TextStyle(fontSize: 13, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _macroTile(String label, String val, Color col) {
    return Column(children: [
      Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: col)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ]);
  }
}

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Future<void> Function(Map<String, dynamic>) onSave;
  final VoidCallback onLogout;
  const ProfileTab({super.key, required this.userData, required this.onSave, required this.onLogout});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final _n = TextEditingController(text: widget.userData['name']),
      _a = TextEditingController(text: widget.userData['age']),
      _h = TextEditingController(text: '${widget.userData['heightCm']}'),
      _cw = TextEditingController(text: '${widget.userData['currW']}'),
      _tw = TextEditingController(text: '${widget.userData['targW']}'),
      _keyCtrl = TextEditingController();
  late String _g = widget.userData['goal'], _d = widget.userData['diet'];

  @override
  void initState() {
    super.initState();
    UserStorage.getApiKey().then((k) {
      if (mounted) setState(() => _keyCtrl.text = k);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = (double.tryParse(_h.text) ?? (widget.userData['heightCm'] as num).toDouble()) / 100.0;
    final w = double.tryParse(_cw.text) ?? (widget.userData['currW'] as num).toDouble();
    final bmi = h > 0 ? w / (h * h) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details & AI Key'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.teal.shade300)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Registered Mobile: +91 ${widget.userData['mobile']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('BMI: ${bmi.toStringAsFixed(1)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
              ]),
            ),
            TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key (from ://google.com)',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: _n, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _a, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _h, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _cw, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Current Weight (kg)', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _tw, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Weight (kg)', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _g, decoration: const InputDecoration(labelText: 'Health Goal', border: OutlineInputBorder()), items: ['Weight Loss', 'Muscle Gain', 'Maintain Weight'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _g = v ?? _g)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _d, decoration: const InputDecoration(labelText: 'Diet Preference', border: OutlineInputBorder()), items: ['Balanced', 'Vegetarian', 'High Protein', 'Keto'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _d = v ?? _d)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () async {
                await UserStorage.saveApiKey(_keyCtrl.text);
                final updated = Map<String, dynamic>.from(widget.userData);
                updated['name'] = _n.text.trim().isEmpty ? 'Friend' : _n.text.trim();
                updated['age'] = _a.text.trim();
                updated['heightCm'] = double.tryParse(_h.text) ?? widget.userData['heightCm'];
                updated['currW'] = double.tryParse(_cw.text) ?? widget.userData['currW'];
                updated['targW'] = double.tryParse(_tw.text) ?? widget.userData['targW'];
                updated['goal'] = _g;
                updated['diet'] = _d;
                await widget.onSave(updated);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save & Return to Home'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
