import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexoVaultApp());
}

class NexoVaultApp extends StatelessWidget {
  const NexoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexoVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF151B2F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const BootstrapScreen(),
    );
  }
}

class SecureStore {
  static const _storage = FlutterSecureStorage();
  static const masterHashKey = 'master_hash';
  static const masterSaltKey = 'master_salt';
  static const vaultKey = 'vault_items';

  static Future<bool> isConfigured() async =>
      (await _storage.read(key: masterHashKey)) != null;

  static Future<void> createMasterPassword(String password) async {
    final salt = _randomString(32);
    final hash = _deriveHash(password, salt);
    await _storage.write(key: masterSaltKey, value: salt);
    await _storage.write(key: masterHashKey, value: hash);
  }

  static Future<bool> verifyMasterPassword(String password) async {
    final salt = await _storage.read(key: masterSaltKey);
    final expected = await _storage.read(key: masterHashKey);
    if (salt == null || expected == null) return false;
    return _constantTimeEquals(_deriveHash(password, salt), expected);
  }

  static String _deriveHash(String password, String salt) {
    var bytes = utf8.encode('$salt:$password');
    for (var i = 0; i < 120000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64UrlEncode(bytes);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static String _randomString(int length) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static Future<List<VaultItem>> readItems() async {
    final raw = await _storage.read(key: vaultKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => VaultItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> writeItems(List<VaultItem> items) async {
    await _storage.write(
      key: vaultKey,
      value: jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}

class VaultItem {
  VaultItem({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
  });

  final String id;
  final String title;
  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'username': username,
        'password': password,
      };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
        id: json['id'] as String,
        title: json['title'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
      );
}

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool? configured;

  @override
  void initState() {
    super.initState();
    SecureStore.isConfigured().then((value) {
      if (mounted) setState(() => configured = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (configured == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return configured! ? const LoginScreen() : const SetupScreen();
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool hidden = true;
  String? error;

  Future<void> createVault() async {
    final value = password.text;
    if (value.length < 10) {
      setState(() => error = 'Usa al menos 10 caracteres.');
      return;
    }
    if (value != confirm.text) {
      setState(() => error = 'Las contraseñas no coinciden.');
      return;
    }
    await SecureStore.createMasterPassword(value);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VaultHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.shield_moon_rounded, size: 88),
              const SizedBox(height: 20),
              const Text('Crea tu bóveda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Tu contraseña maestra protege el acceso local a NexoVault.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: password,
                obscureText: hidden,
                decoration: InputDecoration(
                  labelText: 'Contraseña maestra',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(hidden ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: confirm,
                obscureText: hidden,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: createVault,
                icon: const Icon(Icons.lock),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text('Crear mi bóveda'),
                ),
              ),
              const Spacer(),
              const Text(
                'NexoVault no puede recuperar una contraseña maestra olvidada.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final password = TextEditingController();
  final auth = LocalAuthentication();
  String? error;

  Future<void> unlock() async {
    final ok = await SecureStore.verifyMasterPassword(password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VaultHomeScreen()),
      );
    } else {
      setState(() => error = 'Contraseña maestra incorrecta.');
    }
  }

  Future<void> unlockBiometric() async {
    try {
      final supported = await auth.isDeviceSupported();
      if (!supported) {
        setState(() => error = 'El dispositivo no admite autenticación local.');
        return;
      }
      final ok = await auth.authenticate(
        localizedReason: 'Desbloquea tu bóveda NexoVault',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (ok && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VaultHomeScreen()),
        );
      }
    } catch (_) {
      setState(() => error = 'No fue posible usar la biometría.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_rounded, size: 86),
              const SizedBox(height: 20),
              const Text('NexoVault',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              TextField(
                controller: password,
                obscureText: true,
                onSubmitted: (_) => unlock(),
                decoration: const InputDecoration(labelText: 'Contraseña maestra'),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 18),
              FilledButton(onPressed: unlock, child: const Text('Desbloquear')),
              TextButton.icon(
                onPressed: unlockBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Usar biometría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  List<VaultItem> items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await SecureStore.readItems();
    if (mounted) setState(() => items = data);
  }

  Future<void> addItem() async {
    final item = await Navigator.push<VaultItem>(
      context,
      MaterialPageRoute(builder: (_) => const AddCredentialScreen()),
    );
    if (item == null) return;
    items = [...items, item];
    await SecureStore.writeItems(items);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi bóveda'),
        actions: [
          IconButton(
            tooltip: 'Bloquear',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addItem,
        icon: const Icon(Icons.add),
        label: const Text('Credencial'),
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.key_off_outlined, size: 64, color: Colors.white38),
                  SizedBox(height: 14),
                  Text('Tu bóveda está vacía'),
                  Text('Agrega tu primera credencial.',
                      style: TextStyle(color: Colors.white60)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.key)),
                    title: Text(item.title),
                    subtitle: Text(item.username),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}

class AddCredentialScreen extends StatefulWidget {
  const AddCredentialScreen({super.key});

  @override
  State<AddCredentialScreen> createState() => _AddCredentialScreenState();
}

class _AddCredentialScreenState extends State<AddCredentialScreen> {
  final title = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  String generatePassword() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#\$%&*_-+';
    final random = Random.secure();
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void save() {
    if (title.text.trim().isEmpty || password.text.isEmpty) return;
    Navigator.pop(
      context,
      VaultItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.text.trim(),
        username: username.text.trim(),
        password: password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva credencial')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Servicio')),
          const SizedBox(height: 14),
          TextField(controller: username, decoration: const InputDecoration(labelText: 'Usuario o correo')),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                tooltip: 'Generar contraseña',
                onPressed: () => setState(() => password.text = generatePassword()),
                icon: const Icon(Icons.auto_awesome),
              ),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('Guardar')),
        ],
      ),
    );
  }
}
